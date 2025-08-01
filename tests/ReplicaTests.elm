module ReplicaTests exposing (suite)

import Console
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GraphicSVG exposing (GraphicSVG)
import List.Extra
import Log
import Maybe.Extra
import Replicated.Change as Change exposing (Change, Creator, Parent)
import Replicated.Codec as Codec exposing (Codec, PrimitiveCodec, SkelCodec, WrappedCodec, WrappedOrSkelCodec, decodeFromNodeAgain)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Op.ID as OpID
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Reducer.Register as Reg exposing (RW, Reg)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Moment as Moment
import Test exposing (..)


suite : Test
suite =
    describe "RON Encode-Decode"
        [ testDelayedCreation
        , testSpawning
        , readOnlyObjectEncodeThenDecode
        , writableObjectEncodeThenDecode
        , repListEncodeThenDecode
        , repListInsertAndRemove
        , nodeModifications
        , nestedStressTestIntegrityCheck
        , modifiedNestedStressTestIntegrityCheck
        ]


nodeFromCodecWithoutDefaults : WrappedOrSkelCodec e s profile -> { startNode : Node, result : Result (Codec.Error e) profile, outputMaybe : Maybe profile, startFrame : List Op.ClosedChunk }
nodeFromCodecWithoutDefaults profileCodec =
    let
        logOps chunks =
            Op.closedChunksToFrameText chunks

        { newNode, startFrame } =
            Node.startNewNode Nothing []

        tryDecoding =
            Codec.decodeFromNodeAgain profileCodec newNode

        logStart =
            Log.proseToString
                [ [ "ReplicaTests.nodeFromCodec:" ]
                , [ "Output Frame:" ]
                , [ Op.closedChunksToFrameText startFrame ]
                ]
    in
    { startNode = { newNode | identity = NodeID.bumpSessionID newNode.identity }, result = tryDecoding, outputMaybe = Result.toMaybe tryDecoding, startFrame = startFrame }


nodeFromCodecWithDefaults : WrappedOrSkelCodec e s profile -> { startNode : Node, result : Result (Codec.Error e) profile, outputMaybe : Maybe profile, startFrame : List Op.ClosedChunk }
nodeFromCodecWithDefaults profileCodec =
    let
        logOps chunks =
            Op.closedChunksToFrameText chunks

        { newNode, startFrame } =
            Node.startNewNode Nothing [ Change.WithFrameIndex (\_ -> addEncodedDefaults) ]

        addEncodedDefaults =
            Codec.encodeDefaults Node.testNode profileCodec

        tryDecoding =
            Codec.decodeFromNodeAgain profileCodec newNode

        logStart =
            Log.proseToString
                [ [ "ReplicaTests.nodeFromCodec:" ]
                , [ "Output Frame:" ]
                , [ Op.closedChunksToFrameText startFrame ]
                ]
    in
    { startNode = { newNode | identity = NodeID.bumpSessionID newNode.identity }, result = tryDecoding, outputMaybe = Result.toMaybe tryDecoding, startFrame = startFrame }


type alias ReadOnlyObject =
    { name : ExampleSubObjectLegalName
    , address : String
    , number : Int
    , living : Bool
    , heightMaybe : Maybe Int
    }


readOnlyObjectCodec : SkelCodec e ReadOnlyObject
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


exampleSubObjectCodec : SkelCodec e ExampleSubObjectLegalName
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
                    nodeFromCodecWithDefaults readOnlyObjectCodec
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
    { address : RW String
    , number : RW Int
    , minor : RW Bool
    , kids : RW KidsStatus
    , name : ExampleSubObjectLegalName
    }


writableObjectCodec : WrappedCodec e (Reg WritableObject)
writableObjectCodec =
    Codec.record WritableObject
        |> Codec.fieldRW ( 2, "address" ) .address Codec.string "default address 2"
        |> Codec.fieldRW ( 3, "number" ) .number Codec.int 42
        |> Codec.fieldRW ( 4, "minor" ) .minor Codec.bool False
        |> Codec.fieldRW ( 5, "kids" ) .kids kidsStatusCodec NoKids
        |> Codec.fieldReg ( 1, "name" ) .name exampleSubObjectCodec
        -- was ^ an example of using fieldRW instead of fieldReg, providing an explicit default
        |> Codec.finishRegister


writableObjectEncodeThenDecode : Test
writableObjectEncodeThenDecode =
    test "Encoding a writable object to Changes, applying to a node, then decoding it from the node." <|
        \_ ->
            Expect.all
                [ expectOkAndEqualWhenMapped (\obj -> obj.address.get) "default address 2"
                , expectOkAndEqualWhenMapped (\obj -> obj.number.get) 42

                -- , expectOkAndEqualWhenMapped (\obj -> obj.name.get) { first = "default first", last = "default last" }
                -- disabled because forced default op generation is overruled by codec defaults
                ]
                (Result.map Reg.latest (nodeFromCodecWithDefaults writableObjectCodec).result)



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
            nodeFromCodecWithDefaults writableObjectCodec

        beforeNode =
            startNode

        afterNode =
            case Result.map Reg.latest result of
                Ok exampleObjectFound ->
                    let
                        makeChanges =
                            List.map (\( changer, _ ) -> changer exampleObjectFound) changeList

                        { updatedNode, outputFrame } =
                            Node.applyChanges Nothing beforeNode (Change.saveUserChanges "making some changes to the writable object" makeChanges)

                        logOps =
                            Log.logMessageOnly (Console.green <| Op.closedChunksToFrameText outputFrame) ()
                    in
                    updatedNode

                Err problem ->
                    Debug.todo ("did not decode the test object from node successfully. ran into codec error. " ++ Debug.toString problem)

        generatedRootObjectID =
            afterNode.root
                |> Maybe.withDefault (OpID.fromStringForced "5+here")

        changedObjectDecoded =
            Codec.decodeFromNodeAgain writableObjectCodec afterNode
    in
    describe "Modifying a simple node with a writable root object."
        [ describe "Checking the node has changed in correct places"
            [ test "the node should have the same number of objects in it." <|
                \_ ->
                    Node.objectCount afterNode |> Expect.equal (Node.objectCount beforeNode)
            , test "the demo node should have a root" <|
                \_ ->
                    Expect.notEqual afterNode.root Nothing
            , test ("the root object should have " ++ String.fromInt (List.length changeList) ++ " more events, one for each new change. Expected <-> Actual") <|
                \_ -> (List.length (getObjectEventList generatedRootObjectID beforeNode) + List.length changeList) |> Expect.equal (List.length (getObjectEventList generatedRootObjectID afterNode))
            ]
        , test "Testing the final decoded object for the new changes" <|
            \_ ->
                Expect.all
                    (List.map Tuple.second changeList)
                    (Result.map Reg.latest changedObjectDecoded)
        ]



--- REPSETS


simpleList : List String
simpleList =
    [ "0-Alpha", "1-Beta", "2-Charley", "3-Delta", "4-Gamma" ]


simpleListCodec : WrappedCodec e (RepList String)
simpleListCodec =
    Codec.repList Codec.string


fakeNodeWithSimpleList : Node
fakeNodeWithSimpleList =
    let
        { startNode, result } =
            nodeFromCodecWithDefaults simpleListCodec

        addChanges repList =
            RepList.append RepList.Last simpleList repList
    in
    case result of
        Ok repList ->
            let
                applied =
                    Node.applyChanges Nothing startNode (Change.saveUserChanges "adding replist changes" [ addChanges repList ])

                logOps =
                    Op.closedChunksToFrameText applied.outputFrame
            in
            applied.updatedNode

        Err _ ->
            Debug.todo "no start repList"


repListEncodeThenDecode : Test
repListEncodeThenDecode =
    test "repListEncodeThenDecode : Encoding a list to Changes, applying to a node, then decoding it from the node." <|
        \_ ->
            let
                generatedRepList =
                    Codec.decodeFromNodeAgain simpleListCodec fakeNodeWithSimpleList
            in
            Result.map RepList.listValues generatedRepList |> Expect.equal (Ok simpleList)


fakeNodeWithModifiedList : Node
fakeNodeWithModifiedList =
    case Codec.decodeFromNodeAgain simpleListCodec fakeNodeWithSimpleList of
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
                    Node.applyChanges Nothing fakeNodeWithSimpleList (Change.saveUserChanges "making some changes to the replist" changes)

                logOps =
                    Op.closedChunksToFrameText applied.outputFrame
            in
            applied.updatedNode

        Err _ ->
            Debug.todo "no start repList"


modifiedList : List String
modifiedList =
    [ "1-Beta", "Inserted after 1", "2-Charley", "3-Delta", "4-Gamma" ]


repListInsertAndRemove : Test
repListInsertAndRemove =
    test "repListInsertAndRemove: taking the node's list, adding an item after the second one, then removing the first item." <|
        \_ ->
            let
                generatedRepList =
                    Codec.decodeFromNodeAgain simpleListCodec fakeNodeWithModifiedList

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
            Expect.fail (Log.logSeparate "failure" error "expectOkAndEqualWhenMapped: did not decode")


getObjectEventList objectID node =
    List.filter (\o -> Op.objectID o == objectID) (AnyDict.values node.ops)



-- NESTED MESS


type alias NestedStressTest =
    { recordDepth : String
    , recordOf3Records : Reg RecordOf3Records
    , listOfNestedRecords : RepList (Reg WritableObject)
    , lastField : RW String
    }


nestedStressTestCodec : WrappedCodec e (Reg NestedStressTest)
nestedStressTestCodec =
    Codec.record NestedStressTest
        |> Codec.field ( 1, "recordDepth" ) .recordDepth Codec.string "first layer"
        |> Codec.fieldReg ( 2, "recordOf3Records" ) .recordOf3Records recordOf3RecordsCodec
        |> Codec.fieldList ( 3, "listOfNestedRecords" ) .listOfNestedRecords writableObjectCodec
        |> Codec.fieldRW ( 4, "lastField" ) .lastField Codec.string "NST ending"
        |> Codec.finishRegister


type alias RecordOf3Records =
    { recordDepth : String
    , recordOf2Records : Reg RecordOf2Records
    }


recordOf3RecordsCodec : WrappedCodec e (Reg RecordOf3Records)
recordOf3RecordsCodec =
    Codec.record RecordOf3Records
        |> Codec.field ( 1, "recordDepth" ) .recordDepth Codec.string "second layer"
        |> Codec.fieldReg ( 2, "recordOf2Records" ) .recordOf2Records recordOf2RecordsCodec
        |> Codec.finishRegister


type alias RecordOf2Records =
    { recordDepth : String
    , recordWithRecord : Reg WritableObject
    }


recordOf2RecordsCodec : WrappedCodec e (Reg RecordOf2Records)
recordOf2RecordsCodec =
    Codec.record RecordOf2Records
        |> Codec.field ( 1, "recordDepth" ) .recordDepth Codec.string "third layer"
        |> Codec.fieldReg ( 2, "recordWithRecord" ) .recordWithRecord writableObjectCodec
        |> Codec.finishRegister



-- NOW TEST IT


nestedStressTestIntegrityCheck =
    let
        expectations : List (Result (Codec.Error e) NestedStressTest -> Expectation)
        expectations =
            [ expectOkAndEqualWhenMapped .recordDepth "first layer"
            , expectOkAndEqualWhenMapped (\r -> (Reg.latest r.recordOf3Records).recordDepth) "second layer"
            , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records |> Reg.latest |> .recordOf2Records |> Reg.latest |> .recordDepth) "third layer"
            , expectOkAndEqualWhenMapped (\r -> r.recordOf3Records |> Reg.latest |> .recordOf2Records |> Reg.latest |> .recordWithRecord |> Reg.latest |> .number |> .get) 42
            ]
    in
    test "checking the nested mess has everything we put in it" <|
        \_ ->
            Expect.all
                expectations
                (Result.map Reg.latest (nodeFromCodecWithDefaults nestedStressTestCodec).result)



-- NOW MODIFY THE STRESSTEST


nodeWithModifiedNestedStressTest : { original : Node, serialized : Node, warnings : List Node.OpImportWarning }
nodeWithModifiedNestedStressTest =
    let
        { startNode, result, startFrame } =
            nodeFromCodecWithDefaults nestedStressTestCodec
    in
    case Result.map Reg.latest result of
        Ok nestedStressTest ->
            let
                repListOfWritables =
                    nestedStressTest.listOfNestedRecords

                deepestRecordAddress =
                    nestedStressTest.recordOf3Records |> Reg.latest |> .recordOf2Records |> Reg.latest |> .recordWithRecord |> Reg.latest |> .address

                blankWritable =
                    Codec.new writableObjectCodec

                changes =
                    [ deepestRecordAddress.set "Updated address"
                    , RepList.insertNew RepList.Last [ blankWritable ] repListOfWritables
                    , RepList.insertNew RepList.Last [ newWritable ] repListOfWritables
                    ]

                newWritable : Change.Creator (Reg WritableObject)
                newWritable c =
                    let
                        woChanges : Change.Changer (Reg WritableObject)
                        woChanges wrappedObj =
                            let
                                obj =
                                    Reg.latest wrappedObj
                            in
                            [ obj.address.set "1 bologna street"
                            , obj.address.set "2 bologna street"
                            , obj.address.set "3 bologna street" -- to make sure later-specified changes take precedence, though users should never need to do this in the same frame
                            , obj.number.set 999
                            , obj.minor.set False
                            , obj.kids.set (newKidsList c)
                            , nestedStressTest.lastField.set "externally updating nst within newWritable"
                            ]
                    in
                    Codec.newWithChanges writableObjectCodec c woChanges

                newKidsList p =
                    SomeOfBoth (Codec.newUnique 1 (Codec.repList exampleSubObjectCodec) p) (Codec.newUnique 2 (Codec.repList exampleSubObjectCodec) p)

                applied =
                    Node.applyChanges Nothing startNode (Change.saveUserChanges "modifying the nested stress test" changes)

                ronData =
                    Op.closedChunksToFrameText startFrame ++ Console.bold (Op.closedChunksToFrameText applied.outputFrame)

                concatOldAndNewFrame =
                    Op.closedChunksToFrameText startFrame ++ Op.closedChunksToFrameText applied.outputFrame

                reInitialized =
                    Node.initFromSaved { sameSession = True, storedNodeID = NodeID.toString applied.updatedNode.identity } (Log.logMessageOnly (Console.green <| "RON DATA: \n" ++ ronData) concatOldAndNewFrame)

                reInitializedNodeAndSuch =
                    case reInitialized of
                        Ok nodeAndSuch ->
                            nodeAndSuch

                        Err err ->
                            Debug.todo ("failed to init becuase " ++ Debug.toString err)

                -- (Op.toFrame applied.ops)
                logOps =
                    Op.closedChunksToFrameText applied.outputFrame
            in
            { original = applied.updatedNode, serialized = reInitializedNodeAndSuch.node, warnings = reInitializedNodeAndSuch.warnings }

        Err problem ->
            Debug.todo ("no start dummy object, failed because: " ++ Debug.toString problem)


testRon =
    -- example straight outta RON docs
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
            nodeFromCodecWithDefaults nestedStressTestCodec

        eventListSize givenID givenNode =
            List.length (getObjectEventList givenID givenNode)

        subject =
            nodeWithModifiedNestedStressTest.original

        objectCount =
            AnyDict.values subject.ops

        decodedNSTReg =
            Codec.decodeFromNodeAgain nestedStressTestCodec subject

        decodedNST =
            decodedNSTReg
                |> Result.map Reg.latest

        generatedRepListObjectID : OpID.ObjectID
        generatedRepListObjectID =
            Result.map (\root -> Change.getPointerObjectID (RepList.getPointer root.listOfNestedRecords)) decodedNST
                |> Result.map (Maybe.withDefault (OpID.fromStringForced "was not initialized"))
                |> Result.withDefault (OpID.fromStringForced "decode NST fail")

        opsToFlush =
            (nodeFromCodecWithDefaults nestedStressTestCodec).startFrame
    in
    describe "checking the modified NST node and objects"
        [ test "the NST Register has been initialized and its ID is not a placeholder" <|
            \_ ->
                expectOkAndEqualWhenMapped (\o -> Change.isPlaceholder (Reg.getPointer o)) False decodedNSTReg
        , test "Checking there are no serialization warnings in the test node" <|
            \_ ->
                nodeWithModifiedNestedStressTest.warnings |> Expect.equal []
        , test "Checking there are no serialization warnings in the test RON string" <|
            \_ ->
                (Node.updateWithRon { node = startNode, warnings = [], newObjects = [] } testRon).warnings |> Expect.equal []
        , test "Expecting the (1) original Ops to encode and decode into (2) the same node" <|
            \_ ->
                nodeWithModifiedNestedStressTest.original |> Expect.equal nodeWithModifiedNestedStressTest.serialized
        , describe "Checking the node has changed in correct places"
            [ test "the node should have more initialized objects in it." <|
                \_ ->
                    Node.objectCount subject |> Expect.equal 10
            , test "the replist object should have n more events, with n being the number of new changes to the replist object" <|
                \_ -> eventListSize generatedRepListObjectID subject |> Expect.equal 3
            , test "the repList has been initialized and its ID is not a placeholder" <|
                \_ -> expectOkAndEqualWhenMapped (\o -> Change.isPlaceholder (RepList.getPointer o.listOfNestedRecords)) False decodedNST
            ]
        , test "checking the decoded nested mess has the changes from round 2" <|
            \_ ->
                Expect.all
                    [ expectOkAndEqualWhenMapped (\o -> List.map (Reg.latest >> .address >> .get) <| RepList.listValues o.listOfNestedRecords) [ "default address 2", "3 bologna street" ] -- default object is first
                    ]
                    decodedNST
        , test "the new Custom Type repLists have been initialized" <|
            \_ ->
                expectOkAndEqualWhenMapped
                    (\o ->
                        RepList.last o.listOfNestedRecords
                            |> Result.fromMaybe ".listOfNestedRecords was empty"
                            |> Result.map (.value >> Reg.latest >> .kids >> .get)
                            |> Result.andThen
                                (\kidsValue ->
                                    case kidsValue of
                                        SomeOfBoth repList1 repList2 ->
                                            Ok (RepList.list repList2)

                                        other ->
                                            Err ("not set to SomeOfBoth! found: " ++ Debug.toString other)
                                )
                    )
                    (Ok [])
                    decodedNST
        , test "the external init changes were made" <|
            \_ ->
                expectOkAndEqualWhenMapped
                    (\o -> o.lastField.get)
                    "externally updating nst within newWritable"
                    decodedNST
        ]



-- DELAYED CHANGES --------------------------------------------------


type alias DelayTestReplica =
    { propA : RW String
    , nestedDelayedRecord : NestedDelayed
    , nestedDelayedRegister : Reg NestedDelayed
    }


delayTestReplicaCodec : WrappedCodec e (Reg DelayTestReplica)
delayTestReplicaCodec =
    Codec.record DelayTestReplica
        |> Codec.fieldRW ( 1, "propA" ) .propA Codec.string "Prop A not set."
        |> Codec.fieldRec ( 2, "nestedDelayedRecord" ) .nestedDelayedRecord nestedDelayedCodec
        |> Codec.fieldReg ( 3, "nestedDelayedRegister" ) .nestedDelayedRegister nestedDelayedRegCodec
        |> Codec.finishRegister


type alias NestedDelayed =
    { propB : RW String
    , nestedList : RepList String
    }


nestedDelayedCodec : SkelCodec e NestedDelayed
nestedDelayedCodec =
    Codec.record NestedDelayed
        |> Codec.fieldRW ( 1, "propB" ) .propB Codec.string "Prop B not set."
        |> Codec.fieldList ( 2, "nestedList" ) .nestedList Codec.string
        |> Codec.finishRecord


nestedDelayedRegCodec : WrappedCodec e (Reg NestedDelayed)
nestedDelayedRegCodec =
    Codec.record NestedDelayed
        |> Codec.fieldRW ( 1, "propB" ) .propB Codec.string "Prop B not set."
        |> Codec.fieldList ( 2, "nestedList" ) .nestedList Codec.string
        |> Codec.finishRegister


testDelayedCreation =
    let
        { startNode, result } =
            nodeFromCodecWithoutDefaults delayTestReplicaCodec

        afterChange givenChanges =
            case Result.map Reg.latest result of
                Ok delayTestReplica ->
                    let
                        -- outChunks =
                        --     Debug.log "changes to delay test" <| all.outputFrame
                        all =
                            Node.applyChanges Nothing startNode (Change.saveUserChanges "making some changes to the delay test object" (givenChanges delayTestReplica))
                    in
                    all

                Err problem ->
                    Debug.todo ("did not decode the test object from node successfully. ran into codec error. " ++ Debug.toString problem)

        expectAfterDecodingFrom node fromRoot expected =
            Codec.decodeFromNodeAgain delayTestReplicaCodec tryAddingToNestedList.updatedNode |> expectOkAndEqualWhenMapped (\root -> fromRoot (Reg.latest root)) expected

        tryChangingPropA =
            afterChange (\obj -> [ obj.propA.set "Nondefault" ])

        tryChangingPropB1 =
            afterChange (\obj -> [ obj.nestedDelayedRecord.propB.set "Nondefault" ])

        tryChangingPropB2 =
            afterChange (\obj -> [ (Reg.latest obj.nestedDelayedRegister).propB.set "Nondefault" ])

        tryAddingToNestedList =
            afterChange (\obj -> [ RepList.insert RepList.Last "List Item Added" obj.nestedDelayedRecord.nestedList ])
    in
    describe "Testing delayed changes."
        [ describe "Modify PropA, which should initialize the root object."
            [ test "the before node should start with 0 objects" <|
                \_ ->
                    Node.objectCount startNode |> Expect.equal 0
            , test "the change should have created one object." <|
                \_ ->
                    List.length tryChangingPropA.created |> Expect.equal 1
            , test "the after node should have one object, the delayed root." <|
                \_ ->
                    Node.objectCount tryChangingPropA.updatedNode |> Expect.equal 1
            , test "the after node should have a root" <|
                \_ ->
                    tryChangingPropA.updatedNode.root |> Expect.notEqual Nothing
            ]
        , describe "Modify PropB, which should initialize the root object."
            [ test "the change should have created two objects." <|
                \_ ->
                    List.length tryChangingPropB1.created |> Expect.equal 2
            , test "the after node should have two objects" <|
                \_ ->
                    Node.objectCount tryChangingPropB1.updatedNode |> Expect.equal 2
            , test "the after node should have a root" <|
                \_ ->
                    tryChangingPropB1.updatedNode.root |> Expect.notEqual Nothing
            ]
        , describe "Modify PropB in reg, which should initialize the root object."
            [ test "the change should have created two objects." <|
                \_ ->
                    List.length tryChangingPropB2.created |> Expect.equal 2
            , test "the after node should have two objects" <|
                \_ ->
                    Node.objectCount tryChangingPropB2.updatedNode |> Expect.equal 2
            , test "the after node should have a root" <|
                \_ ->
                    tryChangingPropB2.updatedNode.root |> Expect.notEqual Nothing
            ]
        , describe "Add an Item to a nested replist, which should initialize the containing objects."
            [ test "the change should have created three objects." <|
                \_ ->
                    List.length tryAddingToNestedList.created |> Expect.equal 3
            , test "the after node should have three objects" <|
                \_ ->
                    Node.objectCount tryAddingToNestedList.updatedNode |> Expect.equal 3
            , test "the after node should have a root" <|
                \_ ->
                    tryAddingToNestedList.updatedNode.root |> Expect.notEqual Nothing
            , test "the item should have been added to the replist" <|
                \_ ->
                    expectAfterDecodingFrom tryAddingToNestedList.updatedNode
                        (\root -> RepList.listValues root.nestedDelayedRecord.nestedList)
                        [ "List Item Added" ]
            ]
        ]



-- CODEC.NEW SPAWN TESTS ----------------------------------------------------------------


type alias SpawnTestReplica =
    { maybeRepList : RW (Maybe (RepList (Reg WritableObject)))
    , maybeSeeded : RW (Maybe SeededRec)
    }


spawnTestReplicaCodec : WrappedCodec e (Reg SpawnTestReplica)
spawnTestReplicaCodec =
    Codec.record SpawnTestReplica
        |> Codec.fieldRWM ( 1, "maybeRepList" ) .maybeRepList (Codec.repList writableObjectCodec)
        |> Codec.fieldRWM ( 2, "maybeSeeded" ) .maybeSeeded seededRecCodec
        |> Codec.finishRegister


type alias SeededRec =
    { propA : String
    }


seededRecCodec : Codec e String Codec.SoloObject SeededRec
seededRecCodec =
    Codec.record SeededRec
        |> Codec.coreR ( 1, "propA" ) .propA Codec.string (\parentSeed -> parentSeed)
        |> Codec.finishSeededRecord


testSpawning =
    let
        { startNode, result } =
            nodeFromCodecWithoutDefaults spawnTestReplicaCodec

        afterChange : (Reg SpawnTestReplica -> List Change) -> { outputFrame : List Op.ClosedChunk, updatedNode : Node, created : List OpID.ObjectID }
        afterChange givenChanges =
            case result of
                Ok spawnTestReplica ->
                    let
                        -- outChunks =
                        --     Debug.log "changes to delay test" <| all.outputFrame
                        all =
                            Node.applyChanges Nothing startNode (Change.saveUserChanges "making some changes to the spawn test object" (givenChanges spawnTestReplica))
                    in
                    all

                Err problem ->
                    Debug.todo ("did not decode the test object from node successfully. ran into codec error. " ++ Debug.toString problem)

        expectAfterDecodingFrom node fromRoot expected =
            Codec.decodeFromNodeAgain spawnTestReplicaCodec tryAddingItemToRepList.updatedNode |> expectOkAndEqualWhenMapped (\root -> fromRoot (Reg.latest root)) expected

        tryAddingItemToRepList : { outputFrame : List Op.ClosedChunk, updatedNode : Node, created : List OpID.ObjectID }
        tryAddingItemToRepList =
            let
                newRepList context =
                    Codec.newWithChanges (Codec.repList writableObjectCodec) context addNewItemToRepList

                addNewItemToRepList repList =
                    [ RepList.insertNew RepList.Last [ newItem ] repList ]

                newItem context =
                    Codec.newWithChanges writableObjectCodec context newItemChanger

                newItemChanger writableObjectReg =
                    [ (Reg.latest writableObjectReg).address.set "Spawned Item Address" ]

                setMaybeRepList : Reg SpawnTestReplica -> List Change
                setMaybeRepList obj =
                    [ (Reg.latest obj).maybeRepList.set (Just (newRepList (Reg.getContext obj))) ]
            in
            afterChange setMaybeRepList
    in
    describe "Testing spawn functions."
        [ describe "Initialize the Maybe-wrapped RepList, adding an item with sub changes."
            [ test "the before node should start with 0 objects" <|
                \_ ->
                    Node.objectCount startNode |> Expect.equal 0
            , test "the after node should have three objects" <|
                \_ ->
                    Node.objectCount tryAddingItemToRepList.updatedNode |> Expect.equal 3
            , test "the item should have been added to the replist" <|
                \_ ->
                    expectAfterDecodingFrom tryAddingItemToRepList.updatedNode
                        (\root -> Maybe.map RepList.length root.maybeRepList.get)
                        (Just 1)
            ]
        ]
