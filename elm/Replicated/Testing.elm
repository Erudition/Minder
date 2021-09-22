module Replicated.Testing exposing (..)

import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID
import Replicated.ReplicaCodec as RC exposing (Codec, decodeFromNode)


testNode : Node
testNode =
    Node.fakeNode



-- MESSING AROUND with new replica stuff


type alias ExampleObject =
    { name : ExampleSubObjectName
    , address : String
    , number : Int
    }


exampleObjectCodec : Codec e ExampleObject
exampleObjectCodec =
    RC.record ExampleObject
        |> RC.fieldR ( 1, "name" ) .name exampleSubObjectCodec { first = "default first", last = "default last" }
        |> RC.fieldR ( 2, "address" ) .address RC.string "nowhere"
        |> RC.fieldR ( 3, "number" ) .number RC.int 0
        |> RC.finishRecord


type alias ExampleSubObjectName =
    { first : String
    , last : String
    }


exampleSubObjectCodec : Codec e ExampleSubObjectName
exampleSubObjectCodec =
    RC.record ExampleSubObjectName
        |> RC.fieldR ( 1, "first" ) .first RC.string "firstname"
        |> RC.fieldR ( 2, "last" ) .last RC.string "surname"
        |> RC.finishRecord


exampleObject : Maybe ExampleObject
exampleObject =
    Result.toMaybe <| decodeFromNode exampleObjectCodec testNode


exampleObjectAsOpList : List Op
exampleObjectAsOpList =
    RC.encodeToRon testNode OpID.testCounter exampleObjectCodec


fakeNodeWithExampleObject : Node
fakeNodeWithExampleObject =
    let
        apply op node =
            { node | db = Node.applyOpToDb node.db (Debug.log (Op.toString op) op) }
    in
    List.foldl apply Node.fakeNode exampleObjectAsOpList
