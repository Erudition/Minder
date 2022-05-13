module Replicated.Op.Op exposing (Op, OpPattern(..), OpPayloadAtoms, ReducerID, Reference(..), closedOpToString, create, fromFrame, fromLog, fromString, id, initObject, object, pattern, payload, reducer, reference, toFrame)

{-| Just Ops - already-happened events and such. Ignore Frames for now, they are "write batches" so once they're written they will slef-concatenate in the list of Ops.
-}

import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID)
import Replicated.Serialize as RS exposing (Codec)
import Result.Extra
import Set exposing (Set)
import SmartTime.Moment as Moment


type Op
    = Op ClosedOp


type alias ClosedOp =
    { reducerID : ReducerID
    , objectID : ObjectID
    , operationID : OpID
    , reference : Reference
    , payload : OpPayloadAtoms
    }



-- OPEN Ops


{-| RON: "Open notation is just a shorted version of closed one. Reducer id and object id are omitted in this case, as those could be deduced from full DB and reference id."

The ChainSpanOpenOp is part of a Chain Span, from which it infers its OpID (spans have incremental OpIDs).

-}
type alias OpenOpInSpan =
    { payload : OpPayloadAtoms
    }


{-| Span (Chain Span)
RON: "a chain where each op’s id is exactly an increment of the previous id (1gABC+origin, 1gABC00001+origin, 1gABC00002+origin...)."

We just use single-op spans in the case of non-incremental ops.

-}
type ChainSpan
    = ChainSpan { firstID : OpID, ops : List OpenOpInSpan }


{-| RON: "Chain: a fragment of a yarn where each next op references the previous one."
Where "yarn" means a list of Ops from the same origin.
-}
type Chain
    = Chain { firstRef : Reference, spans : List ChainSpan }


type Reference
    = OpReference OpID
    | ReducerReference ReducerID


referenceToString : Reference -> String
referenceToString givenRef =
    case givenRef of
        OpReference opID ->
            OpID.toString opID

        ReducerReference reducerID ->
            reducerID


opIDFromReference : Reference -> Maybe OpID
opIDFromReference givenRef =
    case givenRef of
        OpReference opID ->
            Just opID

        _ ->
            Nothing


type alias OpPayloadAtoms =
    List JE.Value


type alias ReducerID =
    String


type OpPattern
    = NormalOp
    | DeletionOp
    | UnDeletionOp
    | CreationOp
    | Acknowledgement
    | Annotation


pattern : Op -> OpPattern
pattern (Op opRecord) =
    case ( OpID.isReversion opRecord.operationID, Maybe.map OpID.isReversion (opIDFromReference opRecord.reference) ) of
        ( False, Just False ) ->
            -- "+", "+"
            NormalOp

        ( True, Just False ) ->
            -- "-", "+"
            DeletionOp

        ( True, Just True ) ->
            -- "-", "-"
            UnDeletionOp

        ( False, Nothing ) ->
            -- "+", "$"
            CreationOp

        ( False, Just True ) ->
            -- "+", "-"
            Acknowledgement

        _ ->
            -- "$", "+" or "$", "-"
            Annotation


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


create : ReducerID -> OpID.ObjectID -> OpID -> Reference -> OpPayloadAtoms -> Op
create givenReducer givenObject opID givenReference givenPayload =
    Op
        { reducerID = givenReducer
        , objectID = givenObject
        , operationID = opID
        , reference = givenReference
        , payload = givenPayload
        }


initObject : ReducerID -> OpID -> Op
initObject givenReducer opID =
    Op
        { reducerID = givenReducer
        , objectID = opID
        , operationID = opID
        , reference = ReducerReference givenReducer
        , payload = []
        }


reference (Op op) =
    op.reference


reducer (Op op) =
    op.reducerID


payload (Op op) =
    op.payload


id (Op op) =
    op.operationID


object (Op op) =
    op.objectID


closedOpToString : Op -> String
closedOpToString (Op op) =
    let
        opID =
            "@" ++ OpID.toString op.operationID

        ref =
            ":" ++ referenceToString op.reference

        encodePayloadAtom atom =
            JE.encode 0 atom
    in
    opID ++ " " ++ ref ++ " " ++ String.join " " (List.map encodePayloadAtom op.payload)


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
            let
                atomAsJEValue atomString =
                    JD.decodeString JD.value atomString
                        |> Result.toMaybe
            in
            List.filterMap atomAsJEValue otherAtoms

        reducerMaybe =
            case ( referenceAtom, previousOpMaybe ) of
                -- TODO check an actual list of known reducers
                ( Just ":lww", _ ) ->
                    Just "lww"

                ( _, Just previousOp ) ->
                    Just (reducer previousOp)

                ( _, Nothing ) ->
                    -- TODO Check the database. for now assume lww
                    Just "lww"

        resultWithReducer givenReducer =
            case ( opIDMaybe, otherAtoms, referenceMaybe ) of
                ( Just opID, [], _ ) ->
                    -- no payload - must be a creation op
                    Ok (create givenReducer opID opID (ReducerReference givenReducer) [])

                ( Just opID, _, Just ref ) ->
                    -- there's a payload - reference is required
                    case Maybe.map object previousOpMaybe of
                        Just objectLastTime ->
                            Ok (create givenReducer objectLastTime opID (OpReference ref) remainderPayload)

                        Nothing ->
                            -- TODO locate object via tree somehow
                            Err <| "Couldn't determine the object this op applies to: " ++ inputString

                ( Just _, _, Nothing ) ->
                    Err <| "This op has a nonempty payload (not a creation op) but I couldn't find the required *reference* atom (:) and got no prior op in the chain to deduce it from: " ++ inputString

                ( Nothing, _, _ ) ->
                    Err <| "Couldn't find Op's ID (@) and got no prior op to deduce it from: " ++ inputString
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
            String.split ",\n" span

        addToOpList : List String -> Result String (List Op) -> Result String (List Op)
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
                    addToOpList remainingUnparsedOps (Result.map List.singleton (fromString nextUnparsedOp Nothing))

                ( [ unparsedOp ], Ok [ parsedOp ] ) ->
                    -- one down, one to go
                    Result.map (\new -> new :: [ parsedOp ]) (fromString unparsedOp (Just parsedOp))

                ( nextUnparsedOp :: remainingUnparsedOps, Ok ((lastParsedOp :: _) as parsedOps) ) ->
                    -- multiple done, multiple remain
                    -- parsedOps is reversed, it's more efficient to grab a list head than the last item
                    addToOpList remainingUnparsedOps <| Result.map (\new -> new :: parsedOps) (fromString nextUnparsedOp (Just lastParsedOp))

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
            String.split " ;" frame
    in
    Result.map List.concat <| Result.Extra.combineMap fromChunk chunks


{-| A log can have multiple frames
-}
fromLog : String -> Result String (List Op)
fromLog log =
    let
        frames =
            String.split " ." log
    in
    Result.map List.concat <| Result.Extra.combineMap fromChunk frames


toFrame : List Op -> String
toFrame opList =
    List.map closedOpToString opList
        |> String.join ""
        |> (++) " ."
