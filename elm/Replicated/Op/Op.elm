module Replicated.Op.Op exposing (Op, Payload, ReducerID, create, id, object, opCodec, payload, reducer, reference, toString)

import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Op.OpID as OpID exposing (OpID)
import Replicated.Serialize as RS exposing (Codec)
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
    in
    case ( opIDMaybe, otherAtoms, referenceMaybe ) of
        ( Just opID, [], _ ) ->
            -- no payload - must be a creation op
            Ok (create givenReducer opID opID Nothing "")

        ( Just opID, _, Just ref ) ->
            -- there's a payload - reference is required
            Ok (create givenReducer givenObject opID (Just ref) remainderPayload)

        ( Just _, _, Nothing ) ->
            Err <| "This op has a nonempty payload (not a creation op) but I couldn't find the required *reference* atom (:) and got no prior op in the chain to deduce it from: " ++ inputString

        ( Nothing, _, _ ) ->
            Err "Couldn't find Op's ID (@) and got no prior op to deduce it from."
