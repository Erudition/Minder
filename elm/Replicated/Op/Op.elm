module Replicated.Op.Op exposing (Op, Payload, ReducerID, create, id, object, opCodec, payload, reducer, reference)

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
