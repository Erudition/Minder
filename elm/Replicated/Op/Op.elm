module Replicated.Op exposing (Op, Payload, ReducerID, create, opCodec)

import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Op.OpID as OpID exposing (OpID)
import Replicated.Serialize as RS exposing (Codec)
import Set exposing (Set)
import SmartTime.Moment as Moment


type Op
    = Op
        { reducerID : ReducerID
        , objectID : OpID
        , operationID : OpID
        , referenceID : OpID
        , payload : Payload
        }


opCodec : Codec e Op
opCodec =
    RS.record Op
        |> RS.field .reducerID RS.string
        |> RS.field .objectID RS.string
        |> RS.field .operationID RS.string
        |> RS.field .referenceID RS.string
        |> RS.field .payload RS.string
        |> RS.finishRecord


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


create : ReducerID -> OpID.ObjectID -> OpID -> OpID -> String -> Op
create reducer object opID reference payload =
    Op
        { reducerID = reducer
        , objectID = object
        , operationID = opID
        , referenceID = reference
        , payload = payload
        }
