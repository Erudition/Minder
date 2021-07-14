module Replicated.Op exposing (..)

import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Identifier as Identifier exposing (..)
import Replicated.Op.OpID exposing (OpID)
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


createOp : String -> String -> String -> Op
createOp objectID opID payload =
    { reducerID = "lww"
    , objectID = objectID
    , operationID = opID
    , referenceID = opID
    , payload = payload
    }
