module ReplicaTests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GraphicSVG exposing (GraphicSVG)
import List.Extra
import Main exposing (Screen(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register exposing (RW)
import Replicated.ReplicaCodec as RC exposing (Codec, decodeFromNode)
import SmartTime.Moment as Moment
import Test exposing (..)


suite : Test
suite =
    describe "RON Encode-Decode"
        [ temp
        , readOnlyObjectEncodeThenDecode
        , writableObjectEncodeThenDecode
        , writableObjectModify
        ]


temp =
    test "Empty placeholder test" <|
        \_ ->
            Expect.equal 1 1


fakeOps : List Op
fakeOps =
    let
        ops =
            """
            @1200+0.0.0.0 :lww,
            @1244+0.0.0.0 :1200+0.0.0.0 [1,[[1,first],firstname]]
            """
    in
    Maybe.withDefault [] <| Result.toMaybe <| Op.fromFrame ops


fakeNode =
    List.foldl Node.updateNodeWithSingleOp Node.blankNode fakeOps


type alias ReadOnlyObject =
    { name : ExampleSubObjectName
    , address : String
    , number : Int
    }


readOnlyObjectCodec : Codec e ReadOnlyObject
readOnlyObjectCodec =
    RC.record ReadOnlyObject
        |> RC.fieldR ( 1, "name" ) .name exampleSubObjectCodec { first = "default first", last = "default last" }
        |> RC.fieldR ( 2, "address" ) .address RC.string "default address"
        |> RC.fieldR ( 3, "number" ) .number RC.int 0
        |> RC.finishRecord


correctDefaultReadOnlyObject : ReadOnlyObject
correctDefaultReadOnlyObject =
    ReadOnlyObject correctDefaultName "default address" 0


type alias ExampleSubObjectName =
    { first : String
    , last : String
    }


exampleSubObjectCodec : Codec e ExampleSubObjectName
exampleSubObjectCodec =
    RC.record ExampleSubObjectName
        |> RC.fieldR ( 1, "first" ) .first RC.string "firstname"
        |> RC.fieldR ( 2, "last" ) .last RC.string "specific-codec default surname"
        |> RC.finishRecord


correctDefaultName : ExampleSubObjectName
correctDefaultName =
    ExampleSubObjectName "firstname" "specific-codec default surname"


fakeNodeWithExampleObject : Node
fakeNodeWithExampleObject =
    let
        ( exampleObjectAsOpList, rootIDMaybe ) =
            RC.encodeToRonWithRootID fakeNode OpID.testCounter readOnlyObjectCodec

        apply op node =
            { node | db = Node.applyOpToDb node.db op }

        filledNode =
            List.foldl apply fakeNode exampleObjectAsOpList
    in
    { filledNode | root = rootIDMaybe }


readOnlyObjectEncodeThenDecode =
    test "Encoding an object to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                processOutput =
                    RC.decodeFromNode readOnlyObjectCodec fakeNodeWithExampleObject
            in
            processOutput
                |> Expect.equal (Ok correctDefaultReadOnlyObject)



-- WRITABLES


type alias WritableObject =
    { name : RW ExampleSubObjectName
    , address : RW String
    , number : RW Int
    }


writableObjectCodec : Codec e WritableObject
writableObjectCodec =
    RC.record WritableObject
        |> RC.fieldRW ( 1, "name" ) .name exampleSubObjectCodec { first = "default first", last = "default last" }
        |> RC.fieldRW ( 2, "address" ) .address RC.string "default address"
        |> RC.fieldRW ( 3, "number" ) .number RC.int 0
        |> RC.finishRecord


correctDefaultWritableObject : WritableObject -> Bool
correctDefaultWritableObject obj =
    obj.name.get == correctDefaultName && obj.address.get == "default address" && obj.number.get == 0


fakeNodeWithModifications =
    let
        exampleObjectMaybe =
            Result.toMaybe (exampleObjectReDecoded fakeNodeWithExampleObject)
    in
    case exampleObjectMaybe of
        Just exampleObjectFound ->
            let
                preOpList =
                    [ exampleObjectFound.address.set "candylane" ]

                ( outputOps, updatedNode ) =
                    Node.applyLocalChanges (Moment.fromSmartInt 1000) fakeNodeWithExampleObject preOpList
            in
            updatedNode

        Nothing ->
            fakeNodeWithExampleObject


correctModifiedObject : WritableObject -> Bool
correctModifiedObject obj =
    obj.name.get == correctDefaultName && obj.address.get == "candylane" && obj.number.get == 0


exampleObjectReDecoded : Node -> Result (RC.Error String) WritableObject
exampleObjectReDecoded node =
    RC.decodeFromNode writableObjectCodec fakeNodeWithExampleObject


writableObjectEncodeThenDecode =
    test "Encoding a writable object to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                processOutput =
                    RC.decodeFromNode writableObjectCodec fakeNodeWithExampleObject
            in
            Expect.true "Expected the writable object to have default fields" <|
                Result.withDefault False
                    (Result.map correctDefaultWritableObject processOutput)


writableObjectModify =
    test "Encoding a writable object to Ron, applying to a node, writing new values to some fields, then decoding it from Ron." <|
        \_ ->
            let
                processOutput =
                    RC.decodeFromNode writableObjectCodec fakeNodeWithModifications
            in
            Expect.true "Expected the writable object to have modified fields" <|
                Result.withDefault False
                    (Result.map correctModifiedObject processOutput)
