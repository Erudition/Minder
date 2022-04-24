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
        [ modifiedNestedStressTestIntegrityCheck

        -- , repListEncodeThenDecode
        -- , repListInsertAndRemove
        -- , readOnlyObjectEncodeThenDecode
        -- , writableObjectEncodeThenDecode
        -- , nodeModifications
        -- , nestedStressTestIntegrityCheck
        -- , modifiedNestedStressTestIntegrityCheck
        ]


nodeFromCodec : Codec e profile -> { startNode : Node, result : Result (RC.Error e) profile, outputMaybe : Maybe profile }
nodeFromCodec profileCodec =
    let
        logOps ops =
            List.map (\op -> Op.toString op ++ "\n") ops
                |> String.concat

        startedNode =
            Node.startNewNode Nothing (RC.encodeDefaults profileCodec)

        tryDecoding =
            RC.decodeFromNode profileCodec startedNode
    in
    { startNode = startedNode, result = tryDecoding, outputMaybe = Result.toMaybe tryDecoding }


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
        |> RC.fieldR ( 3, "number" ) .number RC.int 1
        |> RC.fieldR ( 4, "living" ) .living RC.bool True
        |> RC.finishRecord


correctDefaultReadOnlyObject : ReadOnlyObject
correctDefaultReadOnlyObject =
    { name = correctDefaultName
    , address = "default address"
    , number = 1
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


readOnlyObjectEncodeThenDecode =
    test "Encoding a read-only object to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                { result } =
                    nodeFromCodec readOnlyObjectCodec
            in
            result
                |> Expect.equal (Ok correctDefaultReadOnlyObject)



-- WRITABLES


type alias WritableObject =
    { name : RW ExampleSubObjectLegalName
    , address : RW String
    , number : RW Int
    , minor : RW Bool
    }


writableObjectCodec : Codec e WritableObject
writableObjectCodec =
    RC.record WritableObject
        |> RC.fieldRW ( 1, "name" ) .name exampleSubObjectCodec { first = "default first", last = "default last" }
        |> RC.fieldRW ( 2, "address" ) .address RC.string "default address 2"
        |> RC.fieldRW ( 3, "number" ) .number RC.int 42
        |> RC.fieldRW ( 4, "minor" ) .minor RC.bool False
        |> RC.finishRecord


writableObjectEncodeThenDecode =
    test "Encoding a writable object to Changes, applying to a node, then decoding it from the node." <|
        \_ ->
            Expect.all
                [ expectOkAndEqualWhenMapped (\obj -> obj.address.get) "default address 2"
                , expectOkAndEqualWhenMapped (\obj -> obj.number.get) 42

                -- , expectOkAndEqualWhenMapped (\obj -> obj.name.get) { first = "default first", last = "default last" }
                -- disabled because forced default op generation is overruled by codec defaults
                ]
                (nodeFromCodec writableObjectCodec).result



-- NOW MODIFY IT


changeList =
    -- designed to allow changes in place
    [ ( \obj -> obj.minor.set True, expectOkAndEqualWhenMapped (\obj -> obj.minor.get) True )
    , ( \obj -> obj.number.set 7, expectOkAndEqualWhenMapped (\obj -> obj.number.get) 7 )
    , ( \obj -> obj.address.set "CaNdYlAnE", expectOkAndEqualWhenMapped (\obj -> obj.address.get) "CaNdYlAnE" )
    ]


nodeModifications =
    let
        { startNode, outputMaybe } =
            nodeFromCodec writableObjectCodec

        beforeNode =
            startNode

        afterNode =
            case outputMaybe of
                Just exampleObjectFound ->
                    let
                        makeChanges =
                            List.map (\( changer, _ ) -> changer exampleObjectFound) changeList

                        { updatedNode, ops } =
                            Node.apply Nothing beforeNode (Node.saveChanges "making some changes to the writable object" makeChanges)

                        logOps =
                            List.map (\op -> Op.toString op ++ "\n") ops
                                |> String.concat
                    in
                    Log.logMessage ("\n Adding ops to afterNode: \n" ++ logOps) updatedNode

                Nothing ->
                    Debug.todo "should always be found"

        generatedRootObjectID =
            "3+here"

        changedObjectDecoded =
            RC.decodeFromNode writableObjectCodec afterNode
    in
    describe "Modifying a simple node with a writable root object."
        [ describe "Checking the node has changed in correct places"
            [ test "the node should the same number of objects in it." <|
                \_ ->
                    Expect.equal (Dict.size beforeNode.objects) (Dict.size afterNode.objects)
            , test "the demo node should have one profile" <|
                \_ ->
                    Expect.equal (List.length afterNode.profiles) 1
            , test "the root object should have n more events, with n being the number of new changes to the root object" <|
                \_ -> Expect.equal (Dict.size (getObjectEventList generatedRootObjectID beforeNode) + List.length changeList) (Dict.size (getObjectEventList generatedRootObjectID afterNode))
            ]
        , test "Testing the final decoded object for the new changes" <|
            \_ ->
                Expect.all
                    (List.map Tuple.second changeList)
                    changedObjectDecoded
        ]



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
        { startNode, result } =
            nodeFromCodec simpleListCodec

        addChanges repList =
            RepList.append repList simpleList
    in
    case result of
        Ok repList ->
            let
                applied =
                    Node.apply Nothing startNode (Node.saveChanges "adding replist changes" [ addChanges repList ])

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
                    Node.apply Nothing fakeNodeWithSimpleList (Node.saveChanges "making some changes to the replist" changes)

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


getObjectEventList generatedRootObjectID node =
    case Dict.get generatedRootObjectID node.objects of
        Just foundObject ->
            foundObject.events

        Nothing ->
            Debug.todo ("There was no " ++ generatedRootObjectID ++ " in the objects database, all I found was these " ++ String.fromInt (Dict.size node.objects) ++ ": \n" ++ String.join "\n" (Dict.keys node.objects) ++ ".")



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


nestedStressTestIntegrityCheck =
    test "checking the nested mess has everything we put in it" <|
        \_ ->
            Expect.all
                [ expectOkAndEqualWhenMapped .recordDepth "first layer"
                , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records.recordDepth) "second layer"
                , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records.recordOf2Records.recordDepth) "third layer"
                , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records.recordOf2Records.recordWithRecord.number.get) 42
                ]
                (nodeFromCodec nestedStressTestCodec).result



-- NOW MODIFY THE STRESSTEST


nodeWithModifiedNestedStressTest : Node
nodeWithModifiedNestedStressTest =
    let
        { startNode, result } =
            nodeFromCodec nestedStressTestCodec
    in
    case result of
        Ok nestedStressTest ->
            let
                repList =
                    nestedStressTest.listOfNestedRecords

                addItems =
                    RepList.addNewWithChanges repList
                        [ \obj -> obj.address.set "bologna street"
                        , \obj -> obj.number.set 999
                        ]

                changes =
                    [ addItems
                    ]

                applied =
                    Node.apply Nothing startNode (Node.saveChanges "modifying the nested stress test" changes)

                logOps =
                    List.map (\op -> Op.toString op ++ "\n") applied.ops
                        |> String.concat
            in
            applied.updatedNode

        Err _ ->
            Debug.todo "no start dummy object"


modifiedNestedStressTestIntegrityCheck =
    let
        { startNode, result } =
            nodeFromCodec nestedStressTestCodec

        generatedRootObjectID =
            "0+here"

        generatedRepListObjectID =
            "102+here"

        eventListSize givenID givenNode =
            Dict.size (getObjectEventList givenID givenNode)

        decodedNST =
            RC.decodeFromNode nestedStressTestCodec nodeWithModifiedNestedStressTest
    in
    describe "checking the modified NST node and objects"
        [ describe "Checking the node has changed in correct places"
            [ test "the node should have 2 more initialized objects in it." <|
                \_ ->
                    Expect.equal (Dict.size nodeWithModifiedNestedStressTest.objects) 3
            , test "the demo node should have one profile" <|
                \_ ->
                    Expect.equal (List.length nodeWithModifiedNestedStressTest.profiles) 1
            , test "the replist object should have n more events, with n being the number of new changes to the replist object" <|
                \_ -> Expect.equal 2 (eventListSize generatedRepListObjectID nodeWithModifiedNestedStressTest)
            , test "the repList has been initialized and its ID is not a placeholder" <|
                \_ -> expectOkAndEqualWhenMapped (\o -> Op.isPlaceholder (RepList.getID o.listOfNestedRecords)) False decodedNST
            ]
        , test "checking the decoded nested mess has the changes" <|
            \_ ->
                Expect.all
                    [ expectOkAndEqualWhenMapped (\o -> List.map (.address >> .get) <| RepList.list (Debug.log "\n\nfinal post-modified replist" o.listOfNestedRecords)) [ "bologna street" ]
                    ]
                    decodedNST
        ]
