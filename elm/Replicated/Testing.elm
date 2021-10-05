module Replicated.Testing exposing (..)

import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.LWWObject exposing (RW)
import Replicated.ReplicaCodec as RC exposing (Codec, decodeFromNode)
import SmartTime.Moment as Moment


testNode : Node
testNode =
    Node.fakeNode



-- MESSING AROUND with new replica stuff


type alias ExampleObject =
    { name : RW ExampleSubObjectName
    , address : RW String
    , number : RW Int
    }


exampleObjectCodec : Codec e ExampleObject
exampleObjectCodec =
    RC.record ExampleObject
        |> RC.fieldRW ( 1, "name" ) .name exampleSubObjectCodec { first = "default first", last = "default last" }
        |> RC.fieldRW ( 2, "address" ) .address RC.string "default address"
        |> RC.fieldRW ( 3, "number" ) .number RC.int 0
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


fakeNodeWithExampleObject : Node
fakeNodeWithExampleObject =
    let
        ( exampleObjectAsOpList, rootIDMaybe ) =
            RC.encodeToRonWithRootID testNode OpID.testCounter exampleObjectCodec

        apply op node =
            { node | db = Node.applyOpToDb node.db (Debug.log (Op.toString op) op) }

        filledNode =
            List.foldl apply Node.fakeNode exampleObjectAsOpList
    in
    { filledNode | root = rootIDMaybe }


fakeNodeWithModifications =
    let
        exampleObjectMaybe =
            Result.toMaybe (exampleObjectReDecoded fakeNodeWithExampleObject)
    in
    case exampleObjectMaybe of
        Just exampleObjectFound ->
            let
                preOpList =
                    [ exampleObjectFound.address.set "1234 candy lane" ]

                ( outputOps, updatedNode ) =
                    Node.applyLocalChanges (Moment.fromSmartInt 1000000) fakeNodeWithExampleObject preOpList
            in
            updatedNode

        Nothing ->
            fakeNodeWithExampleObject


exampleObjectReDecoded : Node -> Result (RC.Error String) ExampleObject
exampleObjectReDecoded node =
    RC.decodeFromNode exampleObjectCodec node
