module ReplicaTests exposing (suite)

import Console
import Dict
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GraphicSVG exposing (GraphicSVG)
import List.Extra
import Log
import Main exposing (Screen(..))
import Maybe.Extra
import Replicated.Change as Change exposing (Context, Creator)
import Replicated.Codec as Codec exposing (Codec, SymCodec, decodeFromNode)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register exposing (RW)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Moment as Moment
import Test exposing (..)


suite : Test
suite =
    describe "RON Encode-Decode"
        [ readOnlyObjectEncodeThenDecode
        , writableObjectEncodeThenDecode
        , repListEncodeThenDecode
        , repListInsertAndRemove
        , nodeModifications
        , nestedStressTestIntegrityCheck
        , modifiedNestedStressTestIntegrityCheck
        ]


nodeFromCodec : Codec e () profile -> { startNode : Node, result : Result (Codec.Error e) profile, outputMaybe : Maybe profile, startFrame : List Op.ClosedChunk }
nodeFromCodec profileCodec =
    let
        logOps chunks =
            Op.closedChunksToFrameText chunks

        { newNode, startFrame } =
            Node.startNewNode Nothing [ Codec.encodeDefaults Node.testNode profileCodec ]

        tryDecoding =
            Codec.decodeFromNode profileCodec newNode
    in
    { startNode = newNode, result = tryDecoding, outputMaybe = Result.toMaybe tryDecoding, startFrame = startFrame }


type alias ReadOnlyObject =
    { name : ExampleSubObjectLegalName
    , address : String
    , number : Int
    , living : Bool
    , heightMaybe : Maybe Int
    }


readOnlyObjectCodec : Codec e () ReadOnlyObject
readOnlyObjectCodec =
    Codec.record ReadOnlyObject
        |> Codec.fieldReg ( 1, "legal_name" ) .name exampleSubObjectCodec
        |> Codec.field ( 2, "address" ) .address Codec.string "default address"
        |> Codec.field ( 3, "number" ) .number Codec.int 1
        |> Codec.field ( 4, "living" ) .living Codec.bool True
        |> Codec.field ( 5, "heightMaybe" ) .heightMaybe (Codec.maybe Codec.int) (Just 5)
        |> Codec.finishRecord


correctDefaultReadOnlyObject : ReadOnlyObject
correctDefaultReadOnlyObject =
    { name = correctDefaultName
    , address = "default address"
    , number = 1
    , living = True
    , heightMaybe = Just 5
    }


type FormalTitle
    = Mr
    | Mrs
    | Ms


titleCodec =
    Codec.quickEnum Mr [ Mrs, Ms ]


type alias ExampleSubObjectLegalName =
    { first : String
    , last : String
    , title : FormalTitle
    }


exampleSubObjectCodec : Codec e () ExampleSubObjectLegalName
exampleSubObjectCodec =
    Codec.record ExampleSubObjectLegalName
        |> Codec.field ( 1, "first" ) .first Codec.string "firstname"
        |> Codec.field ( 2, "last" ) .last Codec.string "default surname"
        |> Codec.field ( 3, "title" ) .title titleCodec Mrs
        |> Codec.finishRecord


correctDefaultName : ExampleSubObjectLegalName
correctDefaultName =
    ExampleSubObjectLegalName "firstname" "default surname" Mrs


readOnlyObjectEncodeThenDecode =
    test "Encoding a read-only object to Ron, applying to a node, then decoding it from Ron." <|
        \_ ->
            let
                { result } =
                    nodeFromCodec readOnlyObjectCodec
            in
            result
                |> Expect.equal (Ok correctDefaultReadOnlyObject)


type KidsStatus
    = NoKids
    | BiologicalKids (RepList ExampleSubObjectLegalName)
    | FosterKids (RepList ExampleSubObjectLegalName)
    | SomeOfBoth (RepList ExampleSubObjectLegalName) (RepList ExampleSubObjectLegalName)


kidsStatusCodec =
    Codec.customType
        (\noKidsEncoder bioKidsEncoder fosterKidsEncoder someEncoder value ->
            case value of
                NoKids ->
                    noKidsEncoder

                BiologicalKids kidsList ->
                    bioKidsEncoder kidsList

                FosterKids kidsList ->
                    fosterKidsEncoder kidsList

                SomeOfBoth bio foster ->
                    someEncoder bio foster
        )
        |> Codec.variant0 ( 0, "nokids" ) NoKids
        |> Codec.variant1 ( 1, "biokids" ) BiologicalKids (Codec.repList exampleSubObjectCodec)
        |> Codec.variant1 ( 2, "fosterkids" ) FosterKids (Codec.repList exampleSubObjectCodec)
        |> Codec.variant2 ( 3, "bothkindsofkids" ) SomeOfBoth (Codec.repList exampleSubObjectCodec) (Codec.repList exampleSubObjectCodec)
        |> Codec.finishCustomType



-- WRITABLES


type alias WritableObject =
    { name : RW ExampleSubObjectLegalName
    , address : RW String
    , number : RW Int
    , minor : RW Bool
    , kids : RW KidsStatus
    }


writableObjectCodec : Codec e () WritableObject
writableObjectCodec =
    Codec.record WritableObject
        |> Codec.fieldRW ( 1, "name" ) .name exampleSubObjectCodec { first = "default first", last = "default last", title = Ms }
        -- ^ an example of using fieldRW instead of fieldReg, providing an explicit default
        |> Codec.fieldRW ( 2, "address" ) .address Codec.string "default address 2"
        |> Codec.fieldRW ( 3, "number" ) .number Codec.int 42
        |> Codec.fieldRW ( 4, "minor" ) .minor Codec.bool False
        |> Codec.fieldRW ( 5, "kids" ) .kids kidsStatusCodec NoKids
        |> Codec.finishRecord


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
    [ ( \obj -> obj.number.set 7, expectOkAndEqualWhenMapped (\obj -> obj.number.get) 7 )
    , ( \obj -> obj.address.set "CaNdYlAnE", expectOkAndEqualWhenMapped (\obj -> obj.address.get) "CaNdYlAnE" )
    , ( \obj -> obj.minor.set True, expectOkAndEqualWhenMapped (\obj -> obj.minor.get) True )
    ]


nodeModifications =
    let
        { startNode, outputMaybe, result } =
            nodeFromCodec writableObjectCodec

        beforeNode =
            startNode

        afterNode =
            case result of
                Ok exampleObjectFound ->
                    let
                        makeChanges =
                            List.map (\( changer, _ ) -> changer exampleObjectFound) changeList

                        { updatedNode, outputFrame } =
                            Node.apply Nothing beforeNode (Change.saveChanges "making some changes to the writable object" makeChanges)

                        logOps =
                            Log.logMessageOnly (Console.green <| Op.closedChunksToFrameText outputFrame) ()
                    in
                    updatedNode

                Err problem ->
                    Debug.todo ("did not decode the test object from node successfully. ran into codec error. " ++ Debug.toString problem)

        generatedRootObjectID =
            "5+here"

        changedObjectDecoded =
            Codec.decodeFromNode writableObjectCodec afterNode
    in
    describe "Modifying a simple node with a writable root object."
        [ describe "Checking the node has changed in correct places"
            [ test "the node should the same number of objects in it." <|
                \_ ->
                    Expect.equal (Dict.size beforeNode.objects) (Dict.size afterNode.objects)
            , test "the demo node should have a root" <|
                \_ ->
                    Expect.notEqual afterNode.root Nothing
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


simpleListCodec : Codec e () (RepList String)
simpleListCodec =
    Codec.repList Codec.string


fakeNodeWithSimpleList : Node
fakeNodeWithSimpleList =
    let
        { startNode, result } =
            nodeFromCodec simpleListCodec

        addChanges repList =
            RepList.append RepList.Last simpleList repList
    in
    case result of
        Ok repList ->
            let
                applied =
                    Node.apply Nothing startNode (Change.saveChanges "adding replist changes" [ addChanges repList ])

                logOps =
                    Op.closedChunksToFrameText applied.outputFrame
            in
            applied.updatedNode

        Err _ ->
            Debug.todo "no start repList"


repListEncodeThenDecode =
    test "Encoding a list to Changes, applying to a node, then decoding it from the node." <|
        \_ ->
            let
                generatedRepList =
                    Codec.decodeFromNode simpleListCodec fakeNodeWithSimpleList
            in
            Result.map RepList.listValues generatedRepList |> Expect.equal (Ok simpleList)


fakeNodeWithModifiedList : Node
fakeNodeWithModifiedList =
    case Codec.decodeFromNode simpleListCodec fakeNodeWithSimpleList of
        Ok repList ->
            let
                listItems =
                    RepList.list repList

                secondMemberHandle =
                    List.Extra.getAt 1 listItems
                        |> Maybe.map .handle

                firstMemberHandle =
                    List.head listItems
                        |> Maybe.map .handle

                addItemInPosition3 handle =
                    RepList.insert (RepList.After handle) "Inserted after 1" repList

                removeItemPosition0 handle =
                    RepList.remove handle repList

                changes =
                    List.filterMap identity
                        [ Maybe.map addItemInPosition3 secondMemberHandle
                        , Maybe.map removeItemPosition0 firstMemberHandle
                        ]

                applied =
                    Node.apply Nothing fakeNodeWithSimpleList (Change.saveChanges "making some changes to the replist" changes)

                logOps =
                    Op.closedChunksToFrameText applied.outputFrame
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
                    Codec.decodeFromNode simpleListCodec fakeNodeWithModifiedList

                list =
                    Result.map RepList.listValues generatedRepList
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


nestedStressTestCodec : Codec e () NestedStressTest
nestedStressTestCodec =
    Codec.record NestedStressTest
        |> Codec.field ( 1, "recordDepth" ) .recordDepth Codec.string "first layer"
        |> Codec.fieldReg ( 2, "recordOf3Records" ) .recordOf3Records recordOf3RecordsCodec
        |> Codec.fieldList ( 3, "listOfNestedRecords" ) .listOfNestedRecords writableObjectCodec
        |> Codec.finishRecord


type alias RecordOf3Records =
    { recordDepth : String
    , recordOf2Records : RecordOf2Records
    }


recordOf3RecordsCodec : Codec e () RecordOf3Records
recordOf3RecordsCodec =
    Codec.record RecordOf3Records
        |> Codec.field ( 1, "recordDepth" ) .recordDepth Codec.string "second layer"
        |> Codec.fieldReg ( 2, "recordOf2Records" ) .recordOf2Records recordOf2RecordsCodec
        |> Codec.finishRecord


type alias RecordOf2Records =
    { recordDepth : String
    , recordWithRecord : WritableObject
    }


recordOf2RecordsCodec : Codec e () RecordOf2Records
recordOf2RecordsCodec =
    Codec.record RecordOf2Records
        |> Codec.field ( 1, "recordDepth" ) .recordDepth Codec.string "third layer"
        |> Codec.fieldReg ( 2, "recordWithRecord" ) .recordWithRecord writableObjectCodec
        |> Codec.finishRecord



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


nodeWithModifiedNestedStressTest : { original : Node, serialized : Node, warnings : List Node.OpImportWarning }
nodeWithModifiedNestedStressTest =
    let
        { startNode, result, startFrame } =
            nodeFromCodec nestedStressTestCodec
    in
    case result of
        Ok nestedStressTest ->
            let
                repListOfWritables =
                    nestedStressTest.listOfNestedRecords

                changes =
                    [ RepList.insertNew RepList.Last (Codec.init writableObjectCodec) repListOfWritables
                    , RepList.insertNew RepList.Last newWritable repListOfWritables
                    ]

                newWritable : Change.Creator WritableObject
                newWritable c =
                    let
                        woChanges : Change.Changer WritableObject
                        woChanges obj =
                            [ obj.address.set "1 bologna street"
                            , obj.address.set "2 bologna street"
                            , obj.address.set "3 bologna street" -- to make sure later-specified changes take precedence, though users should never need to do this in the same frame
                            , obj.number.set 999
                            , obj.minor.set False
                            , obj.kids.set (newKidsList c)
                            ]
                    in
                    Codec.initAndChange writableObjectCodec c woChanges

                newKidsList c =
                    SomeOfBoth (Codec.init (Codec.repList exampleSubObjectCodec) c) (Codec.init (Codec.repList exampleSubObjectCodec) c)

                applied =
                    Node.apply Nothing startNode (Change.saveChanges "modifying the nested stress test" changes)

                ronData =
                    Op.closedChunksToFrameText startFrame ++ Op.closedChunksToFrameText applied.outputFrame

                reInitialized =
                    Node.initFromSaved { sameSession = True, storedNodeID = NodeID.toString applied.updatedNode.identity } (Op.closedChunksToFrameText (Debug.log ("RON DATA: " ++ ronData) <| startFrame ++ applied.outputFrame))

                reInitializedNodeAndSuch =
                    case reInitialized of
                        Ok nodeAndSuch ->
                            nodeAndSuch

                        Err err ->
                            Debug.todo "failed to init"

                -- (Op.toFrame applied.ops)
                logOps =
                    Op.closedChunksToFrameText applied.outputFrame
            in
            { original = applied.updatedNode, serialized = reInitializedNodeAndSuch.node, warnings = reInitializedNodeAndSuch.warnings }

        Err _ ->
            Debug.todo "no start dummy object"


testRon =
    """@42+there :lww,
    @43+there :42+there 3 'hello' 46 asf DHid 'sfd',
      3 'hello' 46 asf DHid 'sfd'  ;

      *lww #45+there @45+there :lww,
      'hello';
      .

    @789+biQFvtGV :lww,
       'id'        '20MF000CUS',
       'type'      'laptop',
       'cpu'       'i7-8850H',
       'display'   '15.6” UHD IPS multi-touch, 400nits',
       'RAM'       '16 GB DDR4 2666MHz',
       'storage'   '512 GB SSD, PCIe-NVME M.2',
       'graphics'  'NVIDIA GeForce GTX 1050Ti 4GB',
    @1024+biQFvtGV
       'wlan'      'Intel 9560 802.11AC vPro',
       'camera'    'IR & 720p HD Camera with microphone';
    .
      """


modifiedNestedStressTestIntegrityCheck =
    let
        { startNode, result } =
            nodeFromCodec nestedStressTestCodec

        generatedRootObjectID =
            "0+here"

        generatedRepListObjectID =
            "13+here"

        eventListSize givenID givenNode =
            Dict.size (getObjectEventList givenID givenNode)

        subject =
            nodeWithModifiedNestedStressTest.original

        decodedNST =
            Codec.decodeFromNode nestedStressTestCodec subject

        opsToFlush =
            (nodeFromCodec nestedStressTestCodec).startFrame
    in
    describe "checking the modified NST node and objects"
        [ test "Checking there are no serialization warnings in the test node" <|
            \_ ->
                nodeWithModifiedNestedStressTest.warnings |> Expect.equal []
        , test "Checking there are no serialization warnings in the test RON string" <|
            \_ ->
                (Node.updateWithRon { node = startNode, warnings = [] } testRon).warnings |> Expect.equal []
        , test "Expecting the (1) original Ops to encode and decode into (2) the same node" <|
            \_ ->
                nodeWithModifiedNestedStressTest.original |> Expect.equal nodeWithModifiedNestedStressTest.serialized
        , describe "Checking the node has changed in correct places"
            [ test "the node should have more initialized objects in it." <|
                \_ ->
                    Expect.equal (Dict.size subject.objects) 6
            , test "the replist object should have n more events, with n being the number of new changes to the replist object" <|
                \_ -> Expect.equal 2 (eventListSize generatedRepListObjectID subject)
            , test "the repList has been initialized and its ID is not a placeholder" <|
                \_ -> expectOkAndEqualWhenMapped (\o -> Change.isPlaceholder (RepList.getPointer o.listOfNestedRecords)) False decodedNST
            ]
        , test "checking the decoded nested mess has the changes" <|
            \_ ->
                Expect.all
                    [ expectOkAndEqualWhenMapped (\o -> List.map (.address >> .get) <| RepList.list o.listOfNestedRecords) [ "default address 2", "3 bologna street" ] -- default object is first
                    ]
                    decodedNST
        , test "the new Custom Type repLists have been initialized" <|
            \_ ->
                expectOkAndEqualWhenMapped
                    (\o ->
                        RepList.last o.listOfNestedRecords
                            |> Maybe.map (.value >> .kids >> .get)
                            |> Maybe.map
                                (\kidsValue ->
                                    case kidsValue of
                                        SomeOfBoth repList1 repList2 ->
                                            Ok (RepList.list repList2)

                                        other ->
                                            Err ("not set to SomeOfBoth! found: " ++ Debug.toString other)
                                )
                    )
                    (Just (Ok []))
                    decodedNST
        ]
