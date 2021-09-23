module Replicated.Op.Op exposing (Op, Payload, ReducerID, create, id, object, opCodec, payload, reducer, reference, toString)

import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Op.OpID as OpID exposing (OpID)
import Replicated.Serialize as RS exposing (Codec)
import Result.Extra
import Set exposing (Set)
import SmartTime.Moment as Moment


type Op
    = Op OpRecord


type alias OpRecord =
    { reducerID : ReducerID
    , objectID : OpID
    , operationID : OpID
    , referenceID : Maybe OpID
    , payload : Payload
    }


opCodec : Codec (RS.Error e) Op
opCodec =
    let
        opRecordCodec =
            RS.record OpRecord
                |> RS.field .reducerID RS.string
                |> RS.field .objectID OpID.codec
                |> RS.field .operationID OpID.codec
                |> RS.field .referenceID (RS.maybe OpID.codec)
                |> RS.field .payload RS.string
                |> RS.finishRecord
    in
    RS.map Op (\(Op opRecord) -> opRecord) opRecordCodec


type alias EventStampString =
    String


type alias Payload =
    String


type alias ReducerID =
    String


type OpPattern
    = NormalOp
    | DeletionOp
    | UnDeletionOp
    | CreationOp
    | Acknowledgement
    | Annotation


{-| A bunch of Ops that are all about the same object - consisting of, at a minimum, the object's creation Op.
-}
type alias Group =
    Nonempty Op



--{-| Groups Ops together by target object.
--For monolithic OpLogs; not needed for pre-separated logs.
---}
--groupByObject : OpLog -> List Group
--groupByObject opLog =
--    let
--        sameObject : Op -> SpecObject
--        sameObject op =
--            op.specifier.object
--
--        toNonempty ( head, tail ) =
--            Nonempty head tail
--    in
--    List.map toNonempty (List.Extra.gatherEqualsBy sameObject opLog)


type alias Frame =
    Nonempty Op


create : ReducerID -> OpID.ObjectID -> OpID -> Maybe OpID -> String -> Op
create givenReducer givenObject opID givenReferenceMaybe givenPayload =
    Op
        { reducerID = givenReducer
        , objectID = givenObject
        , operationID = opID
        , referenceID = givenReferenceMaybe
        , payload = givenPayload
        }


reference (Op op) =
    op.referenceID


reducer (Op op) =
    op.reducerID


payload (Op op) =
    op.payload


id (Op op) =
    op.operationID


object (Op op) =
    op.objectID


toString : Op -> String
toString (Op op) =
    let
        opID =
            "@" ++ OpID.toString op.operationID

        ref =
            ":" ++ OpID.toString (Maybe.withDefault op.objectID op.referenceID)
    in
    opID ++ " " ++ ref ++ " " ++ op.payload


fromString : String -> Maybe Op -> Result String Op
fromString inputString previousOpMaybe =
    let
        atoms =
            String.words inputString

        opIDatom =
            List.head (List.filter (String.startsWith "@") atoms)

        extractOpID atom =
            OpID.fromString (String.dropLeft 1 atom)

        opIDMaybe =
            Maybe.withDefault (Maybe.map (id >> OpID.nextOpInChain) previousOpMaybe) (Maybe.map extractOpID opIDatom)

        referenceAtom =
            List.head (List.filter (String.startsWith ":") atoms)

        referenceMaybe =
            -- if reference is missing, it is assumed to be the previous Op's ID
            Maybe.withDefault (Maybe.map id previousOpMaybe) (Maybe.map extractOpID referenceAtom)

        otherAtoms =
            List.Extra.filterNot (\atom -> String.startsWith ":" atom || String.startsWith "@" atom) atoms

        remainderPayload =
            String.concat otherAtoms

        reducerMaybe =
            case ( referenceAtom, previousOpMaybe ) of
                -- TODO check an actual list of known reducers
                ( ":lww", _ ) ->
                    Just "lww"

                ( _, Just previousOp ) ->
                    Just (reducer previousOp)

                ( _, Nothing ) ->
                    Nothing

        resultWithReducer givenReducer =
            case ( opIDMaybe, otherAtoms, referenceMaybe ) of
                ( Just opID, [], _ ) ->
                    -- no payload - must be a creation op
                    Ok (create givenReducer opID opID Nothing "")

                ( Just opID, _, Just ref ) ->
                    -- there's a payload - reference is required
                    case Maybe.map object previousOpMaybe of
                        Just objectLastTime ->
                            Ok (create givenReducer objectLastTime opID (Just ref) remainderPayload)

                        Nothing ->
                            -- TODO locate object via tree somehow
                            Err <| "Couldn't determine the object this op applies to: " ++ inputString

                ( Just _, _, Nothing ) ->
                    Err <| "This op has a nonempty payload (not a creation op) but I couldn't find the required *reference* atom (:) and got no prior op in the chain to deduce it from: " ++ inputString

                ( Nothing, _, _ ) ->
                    Err "Couldn't find Op's ID (@) and got no prior op to deduce it from."
    in
    case reducerMaybe of
        Just foundReducer ->
            resultWithReducer foundReducer

        Nothing ->
            Err <| "No reducer found for op: " ++ inputString


{-| A span is [or is part of] a chain (sequential refs) with sequential IDs as well.

Here we pass in the previously parsed Op (when available) to parsing of the next op, so we may derive its ID implicitly

-}
fromSpan : String -> Result String (List Op)
fromSpan span =
    let
        spanOpStrings =
            String.split "," span

        addToOpList unparsedOpList parsedOpListResult =
            -- Definitely a more efficient FP way to do this
            case ( unparsedOpList, parsedOpListResult ) of
                ( _, Err err ) ->
                    -- we crashed somewhere.
                    Err err

                ( [], _ ) ->
                    -- nothing to parse.
                    Ok []

                ( [ unparsedOp ], Ok [] ) ->
                    -- not started yet, one item to parse
                    Result.map List.singleton (fromString unparsedOp Nothing)

                ( nextUnparsedOp :: remainingUnparsedOps, Ok [] ) ->
                    -- not started yet, multiple items to parse
                    Result.map (addToOpList remainingUnparsedOps) (fromString nextUnparsedOp Nothing)

                ( [ unparsedOp ], Ok [ parsedOp ] ) ->
                    -- one down, one to go
                    Result.map (\new -> new :: [ parsedOp ]) (fromString unparsedOp (Just parsedOp))

                ( nextUnparsedOp :: _, Ok ((lastParsedOp :: _) as parsedOps) ) ->
                    -- multiple done, multiple remain
                    -- parsedOps is reversed, it's more efficient to grab a list head than the last item
                    Result.map (\new -> new :: parsedOps) (fromString nextUnparsedOp (Just lastParsedOp))

        finalList =
            -- recursively move from one list to the other
            -- second list is backwards for performance (ostensibly)
            addToOpList spanOpStrings (Ok [])
    in
    -- TODO does having it reversed defeat the point of building it backwards?
    Result.map List.reverse finalList


{-| TODO determine when a chain is not a single span
-}
fromChain : String -> Result String (List Op)
fromChain chain =
    fromSpan chain


{-| TODO determine when a chunk is not a single chain
-}
fromChunk : String -> Result String (List Op)
fromChunk chunk =
    fromChain chunk


{-| A frame can have multiple chunks
-}
fromFrame : String -> Result String (List Op)
fromFrame frame =
    let
        chunks =
            String.split ";" frame
    in
    Result.map List.concat <| Result.Extra.combineMap fromChunk chunks


{-| A log can have multiple frames
-}
fromLog : String -> Result String (List Op)
fromLog log =
    let
        frames =
            String.split "." log
    in
    Result.map List.concat <| Result.Extra.combineMap fromChunk frames
