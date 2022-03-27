module ReplicaTests exposing (suite)

import Dict
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GraphicSVG exposing (GraphicSVG)
import List.Extra
import Log
import Main exposing (Screen(..))
import Maybe.Extra
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register exposing (RW)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.ReplicaCodec as RC exposing (Codec, decodeFromNode)
import SmartTime.Moment as Moment
import Test exposing (..)


suite : Test
suite =
    describe "RON Encode-Decode"
        [ repListEncodeThenDecode
        , repListInsertAndRemove
        , readOnlyObjectEncodeThenDecode
        , writableObjectEncodeThenDecode
        , writableObjectModify
        , nestedStressTestIntegrityCheck
        ]


nodeFromCodec : Codec e profile -> Node
nodeFromCodec profileCodec =
    let
        logOps ops =
            List.map (\op -> Op.toString op ++ "\n") ops
                |> String.concat
    in
    Node.startNewNode Nothing (RC.encodeDefaults profileCodec)


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


type alias ReadOnlyObject =
    { name : ExampleSubObjectLegalName
    , address : String
    , number : Int
    , living : Bool
    }


readOnlyObjectCodec : Codec e ReadOnlyObject
readOnlyObjectCodec =
    RC.record ReadOnlyObject
        |> RC.fieldN ( 1, "legal_name" ) .name exampleSubObjectCodec
        |> RC.fieldR ( 2, "address" ) .address RC.string "default address"
        |> RC.fieldR ( 3, "number" ) .number RC.int 0
        |> RC.fieldR ( 4, "living" ) .living RC.bool True
        |> RC.finishRecord


correctDefaultReadOnlyObject : ReadOnlyObject
correctDefaultReadOnlyObject =
    { name = correctDefaultName
    , address = "default address"
    , number = 0
    , living = True
    }


type alias ExampleSubObjectLegalName =
    { first : String
    , last : String
    }


exampleSubObjectCodec : Codec e ExampleSubObjectLegalName
exampleSubObjectCodec =
    RC.record ExampleSubObjectLegalName
        |> RC.fieldR ( 1, "first" ) .first RC.string "firstname"
        |> RC.fieldR ( 2, "last" ) .last RC.string "default surname"
        |> RC.finishRecord


correctDefaultName : ExampleSubObjectLegalName
correctDefaultName =
    ExampleSubObjectLegalName "firstname" "default surname"


fakeNode1 : Node
fakeNode1 =
    nodeFromCodec readOnlyObjectCodec


readOnlyObjectEncodeThenDecode =
    test "Encoding a read-only object to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                processOutput =
                    RC.decodeFromNode readOnlyObjectCodec fakeNode1
            in
            processOutput
                |> Expect.equal (Ok correctDefaultReadOnlyObject)



-- WRITABLES


type alias WritableObject =
    { name : RW ExampleSubObjectLegalName
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
    obj.name.get == { first = "default first", last = "default last" } && obj.address.get == "default address" && obj.number.get == 0


exampleObjectReDecoded : Node -> Result (RC.Error String) WritableObject
exampleObjectReDecoded node =
    RC.decodeFromNode writableObjectCodec fakeNode1


writableObjectEncodeThenDecode =
    test "Encoding a writable object to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                processOutput =
                    RC.decodeFromNode writableObjectCodec fakeNode1
            in
            Expect.true "Expected the writable object to have default fields" <|
                Result.withDefault False
                    (Result.map correctDefaultWritableObject processOutput)



-- NOW MODIFY IT


fakeNodeWithModifications =
    let
        exampleObjectMaybe =
            Result.toMaybe (exampleObjectReDecoded fakeNode1)
    in
    case exampleObjectMaybe of
        Just exampleObjectFound ->
            let
                changeList =
                    [ exampleObjectFound.address.set "candylane"
                    , exampleObjectFound.number.set 7
                    ]

                { updatedNode, ops } =
                    Node.apply Nothing fakeNode1 changeList

                logOps =
                    List.map (\op -> Op.toString op ++ "\n") ops
                        |> String.concat
            in
            updatedNode

        Nothing ->
            Debug.todo "should always be found"


correctModifiedObject : WritableObject -> Bool
correctModifiedObject obj =
    obj.name.get == { first = "default first", last = "default last" } && obj.address.get == "candylane" && obj.number.get == 7


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



--- REPSETS


simpleList : List String
simpleList =
    [ "0-Alpha", "1-Beta", "2-Charley", "3-Delta", "4-Gamma" ]


simpleListCodec : Codec e (RepList String)
simpleListCodec =
    RC.repList RC.string


fakeNodeWithSimpleList : Node
fakeNodeWithSimpleList =
    let
        startNode =
            nodeFromCodec simpleListCodec

        startRepList =
            RC.decodeFromNode simpleListCodec startNode

        addChanges repList =
            RepList.append repList simpleList
    in
    case startRepList of
        Ok repList ->
            let
                applied =
                    Node.apply Nothing startNode [ addChanges repList ]

                logOps =
                    List.map (\op -> Op.toString op ++ "\n") applied.ops
                        |> String.concat
            in
            applied.updatedNode

        Err _ ->
            Debug.todo "no start repList"


repListEncodeThenDecode =
    test "Encoding a list to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                generatedRepList =
                    RC.decodeFromNode simpleListCodec fakeNodeWithSimpleList
            in
            Result.map RepList.list generatedRepList |> Expect.equal (Ok simpleList)


fakeNodeWithModifiedList : Node
fakeNodeWithModifiedList =
    case RC.decodeFromNode simpleListCodec fakeNodeWithSimpleList of
        Ok repList ->
            let
                membersWithIDs =
                    Dict.toList (RepList.dict repList)

                secondMemberHandle =
                    List.Extra.getAt 1 membersWithIDs
                        |> Maybe.map Tuple.first

                firstMemberHandle =
                    List.head membersWithIDs
                        |> Maybe.map Tuple.first

                addItemInPosition3 handle =
                    RepList.insertAfter repList handle "Inserted after 1"

                removeItemPosition0 handle =
                    RepList.remove repList handle

                changes =
                    List.filterMap identity
                        [ Maybe.map addItemInPosition3 secondMemberHandle
                        , Maybe.map removeItemPosition0 firstMemberHandle
                        ]

                applied =
                    Node.apply Nothing fakeNodeWithSimpleList changes

                logOps =
                    List.map (\op -> Op.toString op ++ "\n") applied.ops
                        |> String.concat
            in
            applied.updatedNode

        Err _ ->
            Debug.todo "no start repList"


modifiedList : List String
modifiedList =
    [ "1-Beta", "Inserted after 1", "2-Charley", "3-Delta", "4-Gamma" ]


repListInsertAndRemove =
    test "taking the node's list, adding an item after the second one, then removing the first item." <|
        \_ ->
            let
                generatedRepList =
                    RC.decodeFromNode simpleListCodec fakeNodeWithModifiedList

                list =
                    Result.map RepList.list generatedRepList
            in
            list |> Expect.equal (Ok modifiedList)



-- HELPERS


expectOkAndEqualWhenMapped mapper expectedValue testedResultValue =
    case testedResultValue of
        Ok foundValue ->
            Expect.equal expectedValue (mapper foundValue)

        Err error ->
            Expect.fail (Log.logSeparate "failure" error "did not decode")



-- NESTED MESS


type alias NestedStressTest =
    { recordDepth : String
    , recordOf3Records : RecordOf3Records
    , listOfNestedRecords : RepList WritableObject
    }


nestedStressTestCodec : Codec e NestedStressTest
nestedStressTestCodec =
    RC.record NestedStressTest
        |> RC.fieldR ( 1, "recordDepth" ) .recordDepth RC.string "first layer"
        |> RC.fieldN ( 2, "recordOf3Records" ) .recordOf3Records recordOf3RecordsCodec
        |> RC.fieldN ( 3, "listOfNestedRecords" ) .listOfNestedRecords (RC.repList writableObjectCodec)
        |> RC.finishRecord


type alias RecordOf3Records =
    { recordDepth : String
    , recordOf2Records : RecordOf2Records
    }


recordOf3RecordsCodec : Codec e RecordOf3Records
recordOf3RecordsCodec =
    RC.record RecordOf3Records
        |> RC.fieldR ( 1, "recordDepth" ) .recordDepth RC.string "second layer"
        |> RC.fieldN ( 2, "recordOf2Records" ) .recordOf2Records recordOf2RecordsCodec
        |> RC.finishRecord


type alias RecordOf2Records =
    { recordDepth : String
    , recordWithRecord : WritableObject
    }


recordOf2RecordsCodec : Codec e RecordOf2Records
recordOf2RecordsCodec =
    RC.record RecordOf2Records
        |> RC.fieldR ( 1, "recordDepth" ) .recordDepth RC.string "third layer"
        |> RC.fieldN ( 2, "recordWithRecord" ) .recordWithRecord writableObjectCodec
        |> RC.finishRecord



-- NOW TEST IT


nestedStressTestReDecoded : Result (RC.Error String) NestedStressTest
nestedStressTestReDecoded =
    RC.decodeFromNode nestedStressTestCodec (nodeFromCodec nestedStressTestCodec)


nestedStressTestIntegrityCheck =
    test "checking the nested mess has everything we put in it" <|
        \_ ->
            Expect.all
                [ expectOkAndEqualWhenMapped .recordDepth "first layer"
                , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records.recordDepth) "second layer"
                , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records.recordOf2Records.recordDepth) "third layer"
                ]
                nestedStressTestReDecoded
