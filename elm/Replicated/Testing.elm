module Replicated.Testing exposing (..)

import Replicated.Node as Node exposing (Node)
import Replicated.ReplicaCodec as RC exposing (Codec, decodeFromNode)


testNode : Node
testNode =
    Debug.log "here's my node" Node.fakeNode



-- MESSING AROUND with new replica stuff


type alias ExampleObject =
    { name : String
    , address : String
    , number : Int
    }


exampleObjectCodec : Codec e ExampleObject
exampleObjectCodec =
    RC.record ExampleObject
        |> RC.fieldR ( 1, "name" ) .name RC.string "nameless"
        |> RC.fieldR ( 2, "address" ) .address RC.string "nowhere"
        |> RC.fieldR ( 3, "number" ) .number RC.int 0
        |> RC.finishRecord


exampleObject : Node -> Maybe ExampleObject
exampleObject node =
    Result.toMaybe <| decodeFromNode exampleObjectCodec node
