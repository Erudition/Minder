module Replicated.Codec.Register exposing (coreR, coreRW, field, fieldList, fieldRW, fieldRec, fieldReg, fieldStore, finishRecord, finishRegister, finishSeededRecord, finishSeededRegister, maybeR, record, seededR, seededRW)

{-| Module for building a Register codec.
-}

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Console
import Css exposing (None)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (input, th)
import ID exposing (ID)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Change as Change exposing (Change, ChangeSet(..), Changer, ComplexAtom(..), Context, ObjectChange, Parent(..), Pointer(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Codec.Base as Base
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.DataStructures.Immutable.SyncSafe
import Replicated.Codec.DataStructures.Immutable.SyncUnsafe
import Replicated.Codec.DataStructures.Mutable
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (NodeDecoder, NodeDecoderInputs)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
import Replicated.Codec.Primitives as Primitives
import Replicated.Codec.RegisterField.Decoder as RegisterFieldDecoder exposing (RegisterFieldDecoder)
import Replicated.Codec.RegisterField.Encoder as RegisterFieldEncoder exposing (RegisterFieldEncoder)
import Replicated.Codec.RegisterField.Shared exposing (..)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))


{-| A partially built Codec for a smart record.
-}
type PartialRegister s full remaining
    = PartialRegister
        { bytesEncoder : full -> List BE.Encoder
        , bytesDecoder : BytesDecoder remaining
        , jsonEncoders : List (SmartJsonFieldEncoder full)
        , jsonArrayDecoder : JsonDecoder remaining
        , fieldIndex : Int
        , nodeEncoders : List (RegisterFieldEncoder full)
        , nodeDecoder : RegisterFieldDecoder remaining
        , nodeInitializer : RegisterFieldInitializer s remaining
        }


record : remaining -> PartialRegister i full remaining
record remainingConstructor =
    PartialRegister
        { bytesEncoder = \_ -> []
        , bytesDecoder = BD.succeed (Ok remainingConstructor)
        , jsonEncoders = []
        , jsonArrayDecoder = JD.succeed (Ok remainingConstructor)
        , fieldIndex = 0
        , nodeEncoders = []
        , nodeDecoder = \_ -> ( Just remainingConstructor, [] )
        , nodeInitializer = \_ _ -> remainingConstructor
        }


{-| Read a record field.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Your code will not be able to make changes to this field, only read the value set by other sources. Consider "writable" if you want a read+write field. You will need to prefix your field's type with `RW`.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
field : FieldIdentifier -> (full -> fieldType) -> Codec fieldType o fieldType -> fieldType -> PartialRegister i full (fieldType -> remaining) -> PartialRegister i full remaining
field ( fieldSlot, fieldName ) fieldGetter fieldCodec fieldDefault soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (HardcodedDefault fieldDefault) soFar


fieldReg : FieldIdentifier -> (full -> fieldType) -> WrappedOrSkelCodec s fieldType -> PartialRegister i full (fieldType -> remaining) -> PartialRegister i full remaining
fieldReg ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (PlaceholderDefault nonChanger) soFar


fieldRec : FieldIdentifier -> (full -> fieldType) -> SkelCodec fieldType -> PartialRegister i full (fieldType -> remaining) -> PartialRegister i full remaining
fieldRec ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec (PlaceholderDefault nonChanger) soFar


maybeR : FieldIdentifier -> (full -> Maybe justFieldType) -> Codec o fieldSeed justFieldType -> PartialRegister i full (Maybe justFieldType -> remaining) -> PartialRegister i full remaining
maybeR fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (maybe fieldCodec) (HardcodedDefault Nothing) recordBuilt



-- might need to split these into specialfields module to avoid dependency cycles


fieldList : FieldIdentifier -> (full -> RepList memberType) -> Codec o memberSeed memberType -> PartialRegister i full (RepList memberType -> remaining) -> PartialRegister i full remaining
fieldList fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repList fieldCodec) (PlaceholderDefault nonChanger) recordBuilt


fieldDict : FieldIdentifier -> (full -> RepDict keyType valueType) -> ( PrimitiveCodec keyType, Codec valInit o valueType ) -> PartialRegister i full (RepDict keyType valueType -> remaining) -> PartialRegister i full remaining
fieldDict fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    readableHelper fieldID fieldGetter (repDict keyCodec valueCodec) (PlaceholderDefault nonChanger) recordBuilt


fieldStore : FieldIdentifier -> (full -> RepStore keyType valueType) -> ( PrimitiveCodec keyType, Codec (any -> List Change) o valueType ) -> PartialRegister i full (RepStore keyType valueType -> remaining) -> PartialRegister i full remaining
fieldStore fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    readableHelper fieldID fieldGetter (repStore keyCodec valueCodec) (PlaceholderDefault nonChanger) recordBuilt


fieldDb : FieldIdentifier -> (full -> RepDb memberType) -> Codec memberSeed SoloObject memberType -> PartialRegister i full (RepDb memberType -> remaining) -> PartialRegister i full remaining
fieldDb fieldID fieldGetter fieldCodec recordBuilt =
    readableHelper fieldID fieldGetter (repDb fieldCodec) (PlaceholderDefault nonChanger) recordBuilt


fieldRWM : FieldIdentifier -> (full -> RWMaybe fieldType) -> Codec fieldSeed o fieldType -> PartialRegister i full (RWMaybe fieldType -> remaining) -> PartialRegister i full remaining
fieldRWM fieldIdentifier fieldGetter fieldCodec soFar =
    writableHelper fieldIdentifier fieldGetter (maybe fieldCodec) (HardcodedDefault Nothing) False soFar


fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldType o fieldType -> fieldType -> PartialRegister i full (RW fieldType -> remaining) -> PartialRegister i full remaining
fieldRW fieldIdentifier fieldGetter fieldCodec fieldDefault soFar =
    writableHelper fieldIdentifier fieldGetter fieldCodec (HardcodedDefault fieldDefault) False soFar


coreR : FieldIdentifier -> (full -> fieldType) -> Codec fieldSeed o fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (fieldType -> remaining) -> PartialRegister parentSeed full remaining
coreR fieldID fieldGetter fieldCodec seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) recordBuilt


coreRW : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldSeed o fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (RW fieldType -> remaining) -> PartialRegister parentSeed full remaining
coreRW fieldID fieldGetter fieldCodec seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (InitWithParentSeed seeder) False recordBuilt


seededR : FieldIdentifier -> (full -> fieldType) -> Codec fieldSeed o fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (fieldType -> remaining) -> PartialRegister parentSeed full remaining
seededR fieldID fieldGetter fieldCodec default seeder recordBuilt =
    readableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) recordBuilt


seededRW : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldSeed o fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (RW fieldType -> remaining) -> PartialRegister parentSeed full remaining
seededRW fieldID fieldGetter fieldCodec default seeder recordBuilt =
    writableHelper fieldID fieldGetter fieldCodec (DefaultAndInitWithParentSeed default seeder) False recordBuilt



-- FINISHERS


finishRecord : PartialRegister () full full -> SkelCodec full
finishRecord ((PartialRegister allFieldsCodec) as partial) =
    let
        encodeAsJsonObject nakedRecord =
            let
                fullRecord =
                    nakedRecord

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder full
        nodeDecoder { node, parent, position, cutoff } =
            let
                nakedRegisterDecoder : List ObjectID -> JD.Decoder (Result RepDecodeError full)
                nakedRegisterDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        regPointer =
                            Object.getPointer object

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecodingMaybe =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = cutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.log ("regToRecordByDecoding returned errors! " ++ Log.dump errors ++ " while decoding record at " ++ Location.toString position) recovered

                        regToRecordByInit =
                            allFieldsCodec.nodeInitializer

                        finalRecord =
                            case regToRecordByDecodingMaybe of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    Log.crashInDev "nakedRegisterDecoder decoded nothing!" <|
                                        regToRecordByInit () regPointer
                    in
                    JD.succeed <| Ok <| finalRecord
            in
            JD.andThen nakedRegisterDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full SoloObject
        nodeEncoder inputs =
            recordNodeEncoder partial inputs

        emptyRegister : Initializer Skel full
        emptyRegister { parent, position } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }
            in
            allFieldsCodec.nodeInitializer () (Object.getPointer object)

        bytesDecoder : BD.Decoder (Result RepDecodeError full)
        bytesDecoder =
            allFieldsCodec.bytesDecoder

        jsonDecoder : JD.Decoder (Result RepDecodeError full)
        jsonDecoder =
            allFieldsCodec.jsonArrayDecoder
    in
    Codec
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }


finishSeededRecord : PartialRegister s full full -> Codec s SoloObject full
finishSeededRecord ((PartialRegister allFieldsCodec) as partial) =
    let
        encodeAsJsonObject nakedRecord =
            let
                fullRecord =
                    nakedRecord

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder full
        nodeDecoder { node, parent, position, cutoff } =
            let
                nakedRegisterDecoder : List ObjectID -> JD.Decoder (Result RepDecodeError full)
                nakedRegisterDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        regPointer =
                            Object.getPointer object

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = givenCutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        wrongCutoffRegToRecordByDecoding =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = Nothing, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        regToRecord regCanBeBuilt givenCutoff =
                            case regToRecordByDecoding givenCutoff of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    -- if it was decodable when built, but not with the given cutoff, ignore the cutoff. Should not matter, as we will provide defaults no matter what cutoff is given.
                                    regCanBeBuilt
                    in
                    case wrongCutoffRegToRecordByDecoding of
                        Just regCanBeBuilt ->
                            JD.succeed <| Ok <| regToRecord regCanBeBuilt Nothing

                        Nothing ->
                            JD.succeed <| Err <| WrongCutoff cutoff regPointer
            in
            JD.andThen nakedRegisterDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder full SoloObject
        nodeEncoder inputs =
            recordNodeEncoder partial inputs

        emptyRegister : Initializer s full
        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }
            in
            allFieldsCodec.nodeInitializer seed (Object.getPointer object)

        bytesDecoder : BD.Decoder (Result RepDecodeError full)
        bytesDecoder =
            allFieldsCodec.bytesDecoder

        jsonDecoder : JD.Decoder (Result RepDecodeError full)
        jsonDecoder =
            allFieldsCodec.jsonArrayDecoder
    in
    Codec
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }


finishRegister : PartialRegister () full full -> WrappedCodec (Reg full)
finishRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject (Register regDetails) =
            let
                fullRecord =
                    regDetails.latest

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder (Reg full)
        nodeDecoder { node, parent, position, cutoff } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result RepDecodeError (Reg full))
                registerDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        history =
                            buildRegisterFieldDictionary object

                        regPointer =
                            Object.getPointer object

                        regToRecordByDecoding givenCutoff =
                            case
                                allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = givenCutoff, history = history }
                            of
                                ( success, [] ) ->
                                    success

                                ( recovered, errors ) ->
                                    Log.crashInDev ("regToRecordByDecoding returned errors!" ++ Log.dump errors) recovered

                        regToRecordByInit =
                            allFieldsCodec.nodeInitializer

                        regToRecord givenCutoff =
                            case regToRecordByDecoding givenCutoff of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    regToRecordByInit () regPointer
                    in
                    JD.succeed <| Ok <| Register { pointer = regPointer, included = Object.All, latest = regToRecord Nothing, older = Just >> regToRecord, history = history, init = nonChanger }
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Reg full) SoloObject
        nodeEncoder inputs =
            registerNodeEncoder partialRegister inputs

        emptyRegister : Initializer (Changer (Reg full)) (Reg full)
        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                history =
                    buildRegisterFieldDictionary object

                regToRecord =
                    allFieldsCodec.nodeInitializer () (Object.getPointer object)
            in
            Register { pointer = Object.getPointer object, included = Object.All, latest = regToRecord, older = \_ -> regToRecord, history = history, init = seed }

        tempEmpty =
            emptyRegister { parent = Change.genesisParent "flatTodo", seed = nonChanger, position = Location.none }

        bytesDecoder : BD.Decoder (Result RepDecodeError (Reg full))
        bytesDecoder =
            -- TODO use allFieldsCodec.bytesDecoder
            BD.succeed <| Ok <| tempEmpty

        jsonDecoder : JD.Decoder (Result RepDecodeError (Reg full))
        jsonDecoder =
            -- TODO use allFieldsCodec.jsonArrayDecoder
            JD.succeed <| Ok <| tempEmpty
    in
    Codec
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = \(Register regDetails) -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) regDetails.latest
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }


finishSeededRegister : PartialRegister s full full -> WrappedSeededCodec s (Reg full)
finishSeededRegister ((PartialRegister allFieldsCodec) as partialRegister) =
    let
        encodeAsJsonObject (Register regDetails) =
            let
                fullRecord =
                    regDetails.latest

                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]

        nodeDecoder : NodeDecoder (Reg full)
        nodeDecoder { node, parent, position, cutoff } =
            let
                registerDecoder : List ObjectID -> JD.Decoder (Result RepDecodeError (Reg full))
                registerDecoder objectIDs =
                    let
                        object =
                            Node.getObject { node = node, cutoff = cutoff, foundIDs = objectIDs, parent = parent, reducer = registerReducerID, position = position }

                        regPointer =
                            Object.getPointer object

                        history =
                            buildRegisterFieldDictionary object

                        regToRecordByDecoding givenCutoff =
                            allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = givenCutoff, history = history }
                                -- TODO currently ignoring errors
                                |> Tuple.first

                        wrongCutoffRegToRecordByDecoding =
                            allFieldsCodec.nodeDecoder { node = node, regPointer = regPointer, cutoff = Nothing, history = history }
                                -- TODO currently ignoring errors
                                |> Tuple.first

                        regToRecord regCanBeBuilt givenCutoff =
                            case regToRecordByDecoding givenCutoff of
                                Just recordDecoded ->
                                    recordDecoded

                                Nothing ->
                                    -- if it was decodable when built, but not with the given cutoff, ignore the cutoff. Should not matter, as we will provide defaults no matter what cutoff is given.
                                    regCanBeBuilt
                    in
                    case wrongCutoffRegToRecordByDecoding of
                        Just regCanBeBuilt ->
                            JD.succeed <| Ok <| Register { pointer = regPointer, included = Object.All, latest = regToRecord regCanBeBuilt Nothing, older = Just >> regToRecord regCanBeBuilt, history = history, init = nonChanger }

                        Nothing ->
                            JD.succeed <| Err <| WrongCutoff cutoff regPointer
            in
            JD.andThen registerDecoder concurrentObjectIDsDecoder

        nodeEncoder : NodeEncoder (Reg full) SoloObject
        nodeEncoder inputs =
            registerNodeEncoder partialRegister inputs

        emptyRegister { parent, position, seed } =
            let
                object =
                    Node.getObject { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = registerReducerID, position = position }

                regPointer =
                    Object.getPointer object

                history =
                    buildRegisterFieldDictionary object

                regToRecord =
                    allFieldsCodec.nodeInitializer (Tuple.first seed) regPointer
            in
            Register
                { pointer = regPointer
                , included = Object.All
                , latest = regToRecord
                , older = \_ -> regToRecord
                , history = history
                , init = Tuple.second seed
                }

        bytesDecoder : BD.Decoder (Result RepDecodeError (Reg full))
        bytesDecoder =
            -- TODO use allFieldsCodec.bytesDecoder
            BD.fail

        jsonDecoder : JD.Decoder (Result RepDecodeError (Reg full))
        jsonDecoder =
            -- TODO use allFieldsCodec.jsonArrayDecoder
            JD.fail "Need to add decoder to reptype"
    in
    Codec
        { nodeEncoder = nodeEncoder
        , nodeDecoder = nodeDecoder
        , bytesEncoder = \(Register regDetails) -> (allFieldsCodec.bytesEncoder >> List.reverse >> BE.sequence) regDetails.latest
        , bytesDecoder = bytesDecoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = jsonDecoder
        , nodePlaceholder = emptyRegister
        }



-- ENCODING


{-| Encodes an register as a list of Changes (which generate Ops):
-- The Op encoding the register comes last in the list, as the preceding Ops create registers that it depends on.
For each field:
-- if it's a normal value (no nodeEncoder) just encode it, return a Change
-- if it's a nested register that does not yet exist in the tree, assign a placeholder ID for it, then proceed with the following.
-- if it's a nested register that does exist, run its registerNodeEncoder and put its requisite ops above us.

Also returns the ObjectID so that parent registers can refer to it.

Why not create missing Objects in the encoder? Because if it already exists, we'd need to pass the existing ObjectID in anyway. Might as well pass in a guaranteed-existing Register (pre-created if needed)

JK: Updated thinking is this doesn't work anyway - a custom type could contain a register, that doesn't get initialized until set to a different variant. (e.g. `No | Yes a`.) So we have to be ready for on-demand initialization anyway.

-}
registerNodeEncoder : PartialRegister i full full -> NodeEncoderInputs (Reg full) -> EncoderOutput SoloObject
registerNodeEncoder (PartialRegister allFieldsCodec) { node, thingToEncode, mode, parent, position } =
    let
        fallbackObject foundIDs =
            Node.getObject { node = node, cutoff = Nothing, foundIDs = foundIDs, parent = parent, reducer = registerReducerID, position = position }

        ( regMaybe, recordMaybe ) =
            case thingToEncode of
                EncodeThis reg ->
                    ( Just reg, Just <| Reg.latest reg )

                EncodeObjectOrThis objectIDs reg ->
                    ( Just reg, Just <| Reg.latest reg )

        ( registerPointer, history, initChanges ) =
            case regMaybe of
                Just ((Register regDetails) as reg) ->
                    ( regDetails.pointer, regDetails.history, regDetails.init reg )

                Nothing ->
                    ( Object.getPointer (fallbackObject []), Dict.empty, [] )

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : (RegisterFieldEncoder.Inputs full -> RegisterFieldEncoder.Output) -> Maybe Change.ObjectChange
                runSubEncoder subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , history = history
                        , mode = mode
                        , regPointer = registerPointer
                        , existingValMaybe = recordMaybe
                        }
                        |> asObjectChanges

                asObjectChanges : RegisterFieldEncoder.Output -> Maybe Change.ObjectChange
                asObjectChanges subEncoderOutput =
                    case subEncoderOutput of
                        EncodeThisField objChange ->
                            Just objChange

                        SkipThisField ->
                            Nothing
            in
            allFieldsCodec.nodeEncoders
                |> List.map runSubEncoder
                |> List.filterMap identity
                -- TODO so we set them in slot-increasing order.
                |> List.reverse

        -- { earlier, mine, later } =
        --     -- TODO optimizes op order, but should be unnecessary.
        --     -- mine currently broken as it leaves a pending ref
        --     Change.extractOwnSubChanges registerPointer initChanges
        allObjectChanges =
            subChanges

        -- outputWithoutEarlyChanges =
        --     Change.changeObjectWithExternal
        --         { target = registerPointer
        --         , objectChanges = allObjectChanges
        --         , externalUpdates = later
        --         }
        -- outputWithEarlyChanges =
        --     { outputWithoutEarlyChanges | changeSet = Change.mergeChanges outputWithoutEarlyChanges.changeSet (Log.logMessageOnly (Change.changeSetDebug 0 earlier) earlier) }
    in
    soloOut <|
        Change.changeObjectWithExternal
            { target = registerPointer
            , objectChanges = allObjectChanges
            , externalUpdates = Change.collapseChangesToChangeSet "registerInit" initChanges
            }


{-| Encodes a naked record
-}
recordNodeEncoder : PartialRegister i full full -> NodeEncoderInputs full -> EncoderOutput SoloObject
recordNodeEncoder (PartialRegister allFieldsCodec) { node, thingToEncode, mode, parent, position } =
    let
        fallbackObject foundIDs =
            Node.getObject { node = node, cutoff = Nothing, foundIDs = foundIDs, parent = parent, reducer = registerReducerID, position = position }

        ( recordMaybe, object ) =
            case thingToEncode of
                EncodeThis nakedRecord ->
                    ( Just nakedRecord, fallbackObject [] )

                EncodeObjectOrThis objectIDs nakedRecord ->
                    ( Just nakedRecord, fallbackObject (Nonempty.toList objectIDs) )

        registerPointer =
            Object.getPointer object

        subChanges : List Change.ObjectChange
        subChanges =
            let
                runSubEncoder : (RegisterFieldEncoder.Inputs full -> RegisterFieldEncoder.Output) -> Maybe Change.ObjectChange
                runSubEncoder subEncoderFunction =
                    subEncoderFunction
                        { node = node
                        , history = buildRegisterFieldDictionary object
                        , mode = mode
                        , regPointer = registerPointer
                        , existingValMaybe = recordMaybe
                        }
                        |> asObjectChanges

                asObjectChanges : RegisterFieldEncoder.Output -> Maybe Change.ObjectChange
                asObjectChanges subEncoderOutput =
                    case subEncoderOutput of
                        EncodeThisField objChange ->
                            Just objChange

                        SkipThisField ->
                            Nothing
            in
            allFieldsCodec.nodeEncoders
                |> List.map runSubEncoder
                |> List.filterMap identity
                |> List.reverse

        -- TODO so we set them in slot-increasing order.
    in
    soloOut
        (Change.changeObject
            { target = registerPointer
            , objectChanges = subChanges
            }
        )



-- HELPERS


{-| Not exposed - for all `readable` functions
-}
readableHelper : FieldIdentifier -> (full -> fieldType) -> Codec fieldSeed o fieldType -> FieldFallback parentSeed fieldSeed fieldType -> PartialRegister parentSeed full (fieldType -> remaining) -> PartialRegister parentSeed full remaining
readableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback (PartialRegister recordCodecSoFar) =
    let
        newFieldIndex =
            recordCodecSoFar.fieldIndex + 1

        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            fieldName ++ String.fromInt fieldSlot

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldCodec <| fieldGetter existingRecord) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders

        nodeDecoder : RegisterFieldDecoder remaining
        nodeDecoder inputs =
            let
                ( thisFieldValueMaybe, thisFieldErrors ) =
                    registerReadOnlyFieldDecoder newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputs

                ( remainingRecordConstructorMaybe, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs

                updatedConstructorMaybe =
                    case ( thisFieldValueMaybe, remainingRecordConstructorMaybe ) of
                        ( Just thisFieldValue, Just remainingRecordConstructor ) ->
                            Just <| remainingRecordConstructor thisFieldValue

                        ( Nothing, _ ) ->
                            Log.crashInDev ("Codec.readableHelper.nodeDecoder: '" ++ fieldName ++ "' field decoded to nothing.. error was " ++ (String.join " ... and also ..." <| List.map Error.toString thisFieldErrors) ++ " for the object at " ++ Debug.toString inputs.regPointer) Nothing

                        ( _, Nothing ) ->
                            Log.crashInDev ("Codec.readableHelper.nodeDecoder: " ++ fieldName ++ " field was missing prior constructor, error was " ++ Debug.toString thisFieldErrors) Nothing
            in
            ( updatedConstructorMaybe, soFarErrors ++ thisFieldErrors )

        nodeInitializer : RegisterFieldInitializer parentSeed remaining
        nodeInitializer parentSeed regPointer =
            let
                applyToRemaining =
                    recordCodecSoFar.nodeInitializer parentSeed regPointer

                fieldInit : fieldSeed -> fieldType
                fieldInit fieldSeed =
                    getInitializer fieldCodec
                        { parent = Change.becomeDelayedParent regPointer (updateRegisterPostChildInit regPointer ( fieldSlot, fieldName ))
                        , position = Location.new (fieldLocationLabel fieldName fieldSlot) newFieldIndex
                        , seed = fieldSeed
                        }

                fieldValue : fieldType
                fieldValue =
                    case fallback of
                        HardcodedDefault fieldType ->
                            fieldType

                        PlaceholderDefault fieldSeed ->
                            fieldInit fieldSeed

                        InitWithParentSeed parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                        DefaultFromParentSeed parentSeedToFieldDefault ->
                            parentSeedToFieldDefault parentSeed

                        DefaultAndInitWithParentSeed default parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)
            in
            applyToRemaining fieldValue

        nodeEncoderEntry inputs =
            let
                inputsWithSpecificFieldValue : RegisterFieldEncoder.Inputs fieldType
                inputsWithSpecificFieldValue =
                    { node = inputs.node
                    , history = inputs.history
                    , mode = inputs.mode
                    , regPointer = inputs.regPointer
                    , existingValMaybe = Maybe.map fieldGetter inputs.existingValMaybe
                    }
            in
            newRegisterFieldEncoderEntry newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputsWithSpecificFieldValue
    in
    PartialRegister
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder =
            BD.map2
                combineIfBothSucceed
                recordCodecSoFar.bytesDecoder
                (getBytesDecoder fieldCodec)
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            JD.map2
                combineIfBothSucceed
                -- the previous decoder layers, functions stacked on top of each other
                recordCodecSoFar.jsonArrayDecoder
                -- and now we're wrapping it in yet another layer, this field's decoder
                (JD.index recordCodecSoFar.fieldIndex (getJsonDecoder fieldCodec))
        , fieldIndex = newFieldIndex
        , nodeEncoders = nodeEncoderEntry :: recordCodecSoFar.nodeEncoders
        , nodeDecoder = nodeDecoder
        , nodeInitializer = nodeInitializer
        }


{-| Not exposed - for all `writable` functions
-}
writableHelper : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldSeed o fieldType -> FieldFallback parentSeed fieldSeed fieldType -> Bool -> PartialRegister parentSeed full (RW fieldType -> remaining) -> PartialRegister parentSeed full remaining
writableHelper ( fieldSlot, fieldName ) fieldGetter fieldCodec fallback isDelayable (PartialRegister recordCodecSoFar) =
    let
        newFieldIndex =
            recordCodecSoFar.fieldIndex + 1

        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            fieldName ++ String.fromInt fieldSlot

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (getBytesEncoder fieldCodec <| .get (fieldGetter existingRecord)) :: recordCodecSoFar.bytesEncoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, getJsonEncoder fieldCodec << (.get << fieldGetter) ) :: recordCodecSoFar.jsonEncoders

        asParent regPointer =
            -- make instant? this is for using .set on RWs, which should never need to init their parents.
            -- there may be a wrapper between the object and the parent (such as Just) which would be missing from the delayed init change anyway, causing errors.
            if isDelayable then
                Change.becomeDelayedParent regPointer (updateRegisterPostChildInit regPointer ( fieldSlot, fieldName ))

            else
                Change.becomeInstantParent regPointer

        nodeDecoder : RegisterFieldDecoder remaining
        nodeDecoder inputs =
            let
                ( thisFieldValueMaybe, thisFieldErrors ) =
                    registerWritableFieldDecoder newFieldIndex ( fieldSlot, fieldName ) fallback isDelayable fieldCodec inputs

                ( remainingRecordConstructorMaybe, soFarErrors ) =
                    recordCodecSoFar.nodeDecoder inputs

                updatedConstructorMaybe =
                    case ( thisFieldValueMaybe, remainingRecordConstructorMaybe ) of
                        ( Just thisFieldValue, Just remainingRecordConstructor ) ->
                            Just <| remainingRecordConstructor thisFieldValue

                        ( Nothing, _ ) ->
                            Log.crashInDev ("Codec.writableHelper.nodeDecoder: '" ++ fieldName ++ "' field decoded to nothing.. error was " ++ Debug.toString thisFieldErrors ++ " for the object at " ++ Debug.toString inputs.regPointer ++ " with history " ++ Debug.toString (Dict.get fieldSlot inputs.history)) Nothing

                        ( _, Nothing ) ->
                            Log.crashInDev ("Codec.writableHelper.nodeDecoder:" ++ fieldName ++ " field was missing prior constructor..") Nothing
            in
            ( updatedConstructorMaybe, soFarErrors ++ thisFieldErrors )

        nodeInitializer : RegisterFieldInitializer parentSeed remaining
        nodeInitializer parentSeed regPointer =
            let
                applyToRemaining =
                    recordCodecSoFar.nodeInitializer parentSeed regPointer

                fieldInit : fieldSeed -> fieldType
                fieldInit seed =
                    getInitializer fieldCodec
                        { parent = asParent regPointer
                        , position = Location.new (fieldLocationLabel fieldName fieldSlot) newFieldIndex
                        , seed = seed
                        }

                fieldValue : fieldType
                fieldValue =
                    case fallback of
                        HardcodedDefault fieldType ->
                            fieldType

                        PlaceholderDefault fieldSeed ->
                            fieldInit fieldSeed

                        InitWithParentSeed parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                        DefaultFromParentSeed parentSeedToFieldDefault ->
                            parentSeedToFieldDefault parentSeed

                        DefaultAndInitWithParentSeed default parentSeedToFieldSeed ->
                            fieldInit (parentSeedToFieldSeed parentSeed)

                wrapRW : fieldType -> RW fieldType
                wrapRW head =
                    buildRW regPointer ( fieldSlot, fieldName ) fieldEncoder head

                fieldEncoder newValue =
                    getNodeEncoder fieldCodec
                        { node = Node.testNode
                        , mode = defaultEncodeMode
                        , thingToEncode = EncodeThis newValue
                        , parent = asParent regPointer
                        , position = Location.new (fieldLocationLabel fieldName fieldSlot) newFieldIndex
                        }
            in
            applyToRemaining (wrapRW fieldValue)

        nodeEncoderEntry inputs =
            let
                inputsWithSpecificFieldValue : RegisterFieldEncoder.Inputs fieldType
                inputsWithSpecificFieldValue =
                    { node = inputs.node
                    , history = inputs.history
                    , mode = inputs.mode
                    , regPointer = inputs.regPointer
                    , existingValMaybe = Maybe.map (fieldGetter >> .get) inputs.existingValMaybe
                    }
            in
            newRegisterFieldEncoderEntry newFieldIndex ( fieldSlot, fieldName ) fallback fieldCodec inputsWithSpecificFieldValue
    in
    PartialRegister
        { bytesEncoder = addToPartialBytesEncoderList
        , bytesDecoder = BD.fail
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder = JD.fail "Can't use RW wrapper with JSON decoding"
        , fieldIndex = newFieldIndex
        , nodeEncoders = nodeEncoderEntry :: recordCodecSoFar.nodeEncoders
        , nodeDecoder = nodeDecoder
        , nodeInitializer = nodeInitializer
        }


fieldDefaultMaybe : FieldFallback parentSeed fieldSeed fieldType -> Maybe fieldType
fieldDefaultMaybe fallback =
    case fallback of
        HardcodedDefault default ->
            Just default

        DefaultAndInitWithParentSeed default _ ->
            -- TODO used anywhere?
            Just default

        InitWithParentSeed _ ->
            Nothing

        PlaceholderDefault seed ->
            Nothing

        DefaultFromParentSeed _ ->
            Nothing


fieldLocationLabel : String -> Int -> String
fieldLocationLabel fieldName fieldSlot =
    "." ++ fieldName ++ String.fromInt fieldSlot


{-| Helper for mapping over 2 decoders, since they contain Results. If one fails, the combined decoder fails.
-}
combineIfBothSucceed : Result RepDecodeError (fieldType -> remaining) -> Result RepDecodeError fieldType -> Result RepDecodeError remaining
combineIfBothSucceed decoderA decoderB =
    case ( decoderA, decoderB ) of
        ( Ok aDecodedValue, Ok bDecodedValue ) ->
            -- a is being applied to b
            Ok (aDecodedValue bDecodedValue)

        ( Err a_error, _ ) ->
            Err a_error

        ( _, Err b_error ) ->
            Err b_error


{-| Same as JD.map2, but with RegisterFieldDecoderInputs argument built in
-}
mapRegisterNodeDecoder :
    (a -> b -> value)
    -> (RegisterFieldDecoderInputs -> JD.Decoder a)
    -> (RegisterFieldDecoderInputs -> JD.Decoder b)
    -> RegisterFieldDecoderInputs
    -> JD.Decoder value
mapRegisterNodeDecoder twoArgFunction nestableDecoderA nestableDecoderB inputs =
    let
        -- typevars a and b contain the Result blob
        decoderA : JD.Decoder a
        decoderA =
            nestableDecoderA inputs

        decoderB : JD.Decoder b
        decoderB =
            nestableDecoderB inputs
    in
    JD.map2 twoArgFunction decoderA decoderB


{-| Internal helper to wrap child changes in parent changes when the parent is still a placeholder.
-}
updateRegisterPostChildInit : Pointer -> FieldIdentifier -> Change.PendingID -> Change.DelayedChange
updateRegisterPostChildInit parentPointer fieldIdentifier pendingChildToWrap =
    Change.delayedChangeObject parentPointer
        (Change.NewPayload (encodeFieldPayloadAsObjectPayload fieldIdentifier (Nonempty.singleton <| PendingObjectReferenceAtom pendingChildToWrap)))


buildRegisterFieldDictionary : Object -> FieldHistoryDict
buildRegisterFieldDictionary object =
    let
        addFieldEntry : OpID -> Object.Event -> Dict FieldSlot FieldHistoryBackwards -> Dict FieldSlot FieldHistoryBackwards
        addFieldEntry eventID event buildingDict =
            case extractFieldEventFromObjectPayload (Object.eventPayload event) of
                Ok ( ( fieldSlot, fieldName ), fieldPayload ) ->
                    let
                        logMsg =
                            "Adding to " ++ Console.underline fieldName ++ " field history"
                    in
                    Dict.update fieldSlot (addUpdate ( eventID, fieldPayload )) buildingDict

                Err problem ->
                    Log.logSeparate ("WARNING addFieldEntry on op " ++ OpID.toString eventID ++ ": " ++ problem) (Object.eventPayload event) buildingDict

        addUpdate : ( OpID, FieldPayload ) -> Maybe FieldHistoryBackwards -> Maybe FieldHistoryBackwards
        addUpdate newUpdate existingUpdatesMaybe =
            Just
                (Nonempty newUpdate
                    (Maybe.withDefault []
                        (Maybe.map Nonempty.toList existingUpdatesMaybe)
                    )
                )
    in
    -- object.events is a dict, so always ID order, so always oldest to newest.
    -- we want newest to oldest list, but folding reverses the list, so stick with foldL
    -- (warn: foldL/foldR applies the arguments in opposite order to the folding function)
    AnyDict.foldl addFieldEntry Dict.empty (Object.getEvents object)


buildRW : Change.Pointer -> FieldIdentifier -> (fieldVal -> EncoderOutput o) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName )
                (nestedRonEncoder newValue).complex

        setter setValue =
            Change.changeObject
                { target = targetObject
                , objectChanges = [ Change.NewPayload (nestedChange setValue) ]
                }
                |> .changeSet
    in
    { get = latestValue
    , set = \setValue -> Change.WithFrameIndex (\_ -> setter setValue)
    }


buildRWH : Change.Pointer -> FieldIdentifier -> (fieldVal -> EncoderOutput o) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName )
                (nestedRonEncoder newValue).complex

        setter setValue =
            Change.changeObject
                { target = targetObject
                , objectChanges = [ Change.NewPayload (nestedChange setValue) ]
                }
                |> .changeSet
    in
    { get = latestValue
    , set = \setValue -> Change.WithFrameIndex (\_ -> setter setValue)
    , history = rest
    }


interceptPlaceholderLocation : Pointer -> Pointer -> Pointer
interceptPlaceholderLocation givenObjectPointer freshPointerFromEncoder =
    case ( givenObjectPointer, freshPointerFromEncoder ) of
        ( Change.PlaceholderPointer oldPendingID _, Change.PlaceholderPointer freshPendingID _ ) ->
            if oldPendingID == freshPendingID then
                -- no difference, leave it alone
                givenObjectPointer

            else
                Debug.log ("old pointer was " ++ Change.pendingIDToString oldPendingID ++ " and new pointer is " ++ Change.pendingIDToString freshPendingID) freshPointerFromEncoder

        ( _, _ ) ->
            -- existing objects don't need to be intercepted,
            -- and the fresh pointer given should always be a placeholder
            givenObjectPointer
