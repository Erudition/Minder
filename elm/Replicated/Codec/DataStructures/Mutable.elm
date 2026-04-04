module Replicated.Codec.DataStructures.Mutable exposing (repDb, repDict, repList, repStore, seedlessPair)

{-| Codecs for reptype data structures, that support Changes (hence referred to as "mutable"). This is the special sauce!
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
import Replicated.Codec.Base as Base exposing (Codec(..))
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder as BytesEncoder exposing (BytesEncoder)
import Replicated.Codec.DataStructures.Immutable.SyncUnsafe exposing (..)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Initializer as Initializer exposing (Initializer)
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Json.Encoder exposing (JsonEncoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (Inputs, NodeDecoder)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder(..))
import Replicated.Collection as Collection exposing (Collection)
import Replicated.Node.AncestorDb as AncestorDb exposing (AncestorDb)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.Payload as Payload
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))


{-| A replicated list
-}
repList : Codec memberSeed o memberType -> WrappedCodec (RepList memberType)
repList memberCodec =
    let
        normalJsonDecoder =
            JD.fail "no replist"

        jsonEncoder : RepList memberType -> JE.Value
        jsonEncoder input =
            JE.list (Base.getJsonEncoder memberCodec) (RepList.listValues input)

        bytesEncoder : RepList memberType -> BE.Encoder
        bytesEncoder input =
            listEncodeHelper (Base.getBytesEncoder memberCodec) (RepList.listValues input)

        memberChanger : { node : Node, modeMaybe : Maybe NodeEncoder.ChangesToGenerate, parent : Change.Parent } -> Location -> memberType -> Maybe OpID -> Change.ObjectChange
        memberChanger { node, modeMaybe, parent } memberIndex newMemberValue newRefMaybe =
            let
                memberNodeEncoded : Change.ComplexPayload
                memberNodeEncoded =
                    Base.getNodeEncoder memberCodec
                        { mode = Maybe.withDefault NodeEncoder.defaultMode modeMaybe
                        , node = node
                        , thingToEncode = NodeEncoder.EncodeThis newMemberValue
                        , parent = parent
                        , position = memberIndex
                        }
                        |> .complex
            in
            case newRefMaybe of
                Just givenRef ->
                    Change.NewPayloadWithRef { payload = memberNodeEncoded, ref = givenRef }

                Nothing ->
                    Change.NewPayload memberNodeEncoded

        memberRonDecoder : { node : Node, parent : Parent, cutoff : Maybe Moment } -> JE.Value -> Maybe memberType
        memberRonDecoder { node, parent, cutoff } encodedMember =
            case JD.decodeValue (Base.getNodeDecoder memberCodec { node = node, parent = parent, position = Location.newSingle "repListContainer", cutoff = cutoff, oldMaybe = Nothing, changedObjectIDs = [] }).decoder encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        repListRonDecoder : NodeDecoder (RepList memberType)
        repListRonDecoder { node, parent, cutoff, position, oldMaybe, changedObjectIDs } =
            let
                repListBuilder foundObjectIDs =
                    let
                        collection =
                            Node.initializeCollection { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, parent = parent, reducer = RepList.reducerID, position = position }

                        repListPointer =
                            Collection.getPointer collection

                        repListAsParent =
                            Change.becomeInstantParent repListPointer

                        finalMemberChanger =
                            memberChanger { node = node, modeMaybe = Nothing, parent = repListAsParent }

                        finalPayloadToMember =
                            memberRonDecoder { node = node, parent = repListAsParent, cutoff = cutoff }
                    in
                    Ok <| RepList.buildFromReplicaDb collection finalPayloadToMember finalMemberChanger nonChanger oldMaybe
            in
            { decoder = RonPayloadDecoderLegacy (NodeDecoder.reuseOldIfUnchanged oldMaybe RepList.getPointer changedObjectIDs (JD.map repListBuilder NodeDecoder.concurrentObjectIDsDecoder))
            , ancestors = AncestorDb.empty
            }

        repListRonEncoder : NodeEncoder (RepList memberType) NodeEncoder.SoloObject
        repListRonEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                NodeEncoder.EncodeThis givenRepList ->
                    let
                        externalChanges =
                            RepList.getInit givenRepList
                    in
                    NodeEncoder.soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepList.getPointer givenRepList
                            , objectChanges = []
                            , externalUpdates = externalChanges
                            }

                _ ->
                    let
                        repListPointer =
                            Change.newPointer { parent = parent, position = position, reducerID = RepList.reducerID }
                    in
                    NodeEncoder.justInit repListPointer

        initializer : Initializer (Changer (RepList memberType)) (RepList memberType)
        initializer { parent, position, seed } =
            let
                collection =
                    Node.initializeCollection { node = Node.testNode, cutoff = Nothing, foundIDs = [], position = position, reducer = RepList.reducerID, parent = parent }

                repListAsParent =
                    Change.becomeInstantParent (Collection.getPointer collection)

                finalMemberChanger =
                    memberChanger { node = Node.testNode, modeMaybe = Nothing, parent = repListAsParent }

                finalPayloadToMember =
                    memberRonDecoder { node = Node.testNode, parent = repListAsParent, cutoff = Nothing }

                repListBuilder =
                    RepList.buildFromReplicaDb collection finalPayloadToMember finalMemberChanger seed Nothing
            in
            repListBuilder
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder =
            BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = normalJsonDecoder
        , nodeEncoder = repListRonEncoder
        , nodeDecoder = repListRonDecoder
        , nodePlaceholder = initializer
        }


repDb : Codec s NodeEncoder.SoloObject memberType -> WrappedCodec (RepDb memberType)
repDb memberCodec =
    let
        memberChanger : { node : Node, modeMaybe : Maybe NodeEncoder.ChangesToGenerate, asParent : Parent } -> memberType -> Change.ObjectChange
        memberChanger { node, modeMaybe, asParent } newValue =
            Base.getNodeEncoder memberCodec
                { mode = Maybe.withDefault NodeEncoder.defaultMode modeMaybe
                , node = node
                , thingToEncode = NodeEncoder.EncodeThis newValue
                , parent = asParent
                , position = Location.newSingle "repDbContainer"
                }
                |> .complex
                |> Change.NewPayload

        memberRonDecoder : { node : Node, asParent : Parent, cutoff : Maybe Moment } -> Collection.Event Payload.Payload -> Maybe memberType
        memberRonDecoder { node, asParent, cutoff } event =
            let
                encodedMember =
                    Collection.eventPayloadAsJson event
            in
            case JD.decodeValue (Base.getNodeDecoder memberCodec { node = node, parent = asParent, position = Location.newSingle "repDbMember", cutoff = cutoff, oldMaybe = Nothing, changedObjectIDs = [] }).decoder encodedMember of
                Ok (Ok member) ->
                    Just member

                _ ->
                    Nothing

        childInstaller myPointer childPendingID =
            Change.delayedChangeObject myPointer
                (Change.NewPayload <| Nonempty.singleton (Change.PendingObjectReferenceAtom childPendingID))

        repDbNodeDecoder : NodeDecoder (RepDb memberType)
        repDbNodeDecoder { node, parent, position, cutoff } =
            let
                repDbBuilder foundObjectIDs =
                    let
                        collection =
                            Node.initializeCollection { node = node, cutoff = Nothing, foundIDs = foundObjectIDs, parent = parent, reducer = RepDb.reducerID, position = position }

                        repDbPointer =
                            Collection.getPointer collection

                        repDbAsParent =
                            Change.becomeDelayedParent repDbPointer (childInstaller repDbPointer)
                    in
                    Ok <| RepDb.buildFromReplicaDb collection (memberRonDecoder { node = node, asParent = repDbAsParent, cutoff = cutoff }) (memberChanger { node = node, modeMaybe = Nothing, asParent = repDbAsParent }) nonChanger
            in
            { decoder = RonPayloadDecoderLegacy (JD.map repDbBuilder NodeDecoder.concurrentObjectIDsDecoder)
            , ancestors = AncestorDb.empty
            }

        repDbNodeEncoder : NodeEncoder (RepDb memberType) NodeEncoder.SoloObject
        repDbNodeEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                NodeEncoder.EncodeThis givenRepDb ->
                    let
                        externalChanges =
                            RepDb.getInit givenRepDb
                    in
                    NodeEncoder.soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepDb.getPointer givenRepDb
                            , objectChanges = []
                            , externalUpdates = externalChanges
                            }

                _ ->
                    NodeEncoder.justInit (Change.newPointer { parent = parent, position = position, reducerID = RepDb.reducerID })

        initializer : Initializer (Changer (RepDb memberType)) (RepDb memberType)
        initializer { parent, position, seed } =
            let
                collection =
                    Node.initializeCollection { node = Node.testNode, cutoff = Nothing, foundIDs = [], position = position, reducer = RepDb.reducerID, parent = parent }

                repDbPointer =
                    Collection.getPointer collection

                repDbAsParent =
                    Change.becomeDelayedParent repDbPointer (childInstaller repDbPointer)

                finalMemberChanger =
                    memberChanger { node = Node.testNode, modeMaybe = Nothing, asParent = repDbAsParent }

                finalPayloadToMember =
                    memberRonDecoder { node = Node.testNode, asParent = repDbAsParent, cutoff = Nothing }
            in
            RepDb.buildFromReplicaDb collection finalPayloadToMember finalMemberChanger seed
    in
    Codec
        { bytesEncoder = \input -> listEncode (Base.getBytesEncoder memberCodec) (RepDb.listValues input)
        , bytesDecoder = BD.fail
        , jsonEncoder = \input -> JE.list (Base.getJsonEncoder memberCodec) (RepDb.listValues input)
        , jsonDecoder = JD.fail "no repdb"
        , nodeEncoder = repDbNodeEncoder
        , nodeDecoder = repDbNodeDecoder
        , nodePlaceholder = initializer
        }


repDict : PrimitiveCodec k -> Codec vi o v -> WrappedCodec (RepDict k v)
repDict keyCodec valueCodec =
    let
        -- We use the json-encoded form as the dict key, since it's always comparable!
        keyToString key =
            JE.encode 0 (Base.getJsonEncoder keyCodec key)

        flatDictListCodec =
            list (pair keyCodec valueCodec)

        jsonEncoder : RepDict k v -> JE.Value
        jsonEncoder input =
            Base.getJsonEncoder flatDictListCodec (RepDict.list input)

        bytesEncoder : RepDict k v -> BE.Encoder
        bytesEncoder input =
            Base.getBytesEncoder flatDictListCodec (RepDict.list input)

        entryRonEncoder : Node -> Maybe NodeEncoder.ChangesToGenerate -> Pointer -> Location -> RepDict.RepDictEntry k v -> Change.ComplexPayload
        entryRonEncoder node encodeModeMaybe parent entryPosition newEntry =
            let
                keyEncoder givenKey =
                    Base.getNodeEncoder keyCodec
                        { mode = Maybe.withDefault NodeEncoder.defaultMode encodeModeMaybe
                        , node = node
                        , thingToEncode = NodeEncoder.EncodeThis givenKey
                        , parent = Change.becomeInstantParent parent
                        , position = Location.nestSingle entryPosition ("repDictKey(" ++ keyToString givenKey ++ ")")
                        }

                valueEncoder givenValue =
                    Base.getNodeEncoder valueCodec
                        { mode = Maybe.withDefault NodeEncoder.defaultMode encodeModeMaybe
                        , node = node
                        , thingToEncode = NodeEncoder.EncodeThis givenValue
                        , parent = Change.becomeInstantParent parent
                        , position = Location.nestSingle entryPosition "repDictVal"
                        }
            in
            case newEntry of
                RepDict.Cleared key ->
                    (keyEncoder key).complex

                RepDict.Present key value ->
                    Nonempty.append (keyEncoder key).complex (valueEncoder value).complex

        entryChanger node encodeModeMaybe parent entryPosition newEntry =
            Change.NewPayload (entryRonEncoder node encodeModeMaybe parent entryPosition newEntry)

        entryRonDecoder : Node -> Pointer -> Maybe Moment -> Payload.Payload -> Maybe (RepDictEntry k v)
        entryRonDecoder node parent cutoff atoms =
            let
                encodedEntry =
                    Payload.toJsonValue (Nonempty.fromList atoms |> Maybe.withDefault (Nonempty (Atom.IntegerAtom 0) []))

                decodeKey encodedKey =
                    JD.decodeValue (Base.getNodeDecoder keyCodec { node = node, position = Location.newSingle "repDictKey", parent = Change.becomeInstantParent parent, cutoff = cutoff, oldMaybe = Nothing, changedObjectIDs = [] }).decoder encodedKey

                decodeValue key encodedValue =
                    JD.decodeValue (Base.getNodeDecoder valueCodec { node = node, position = Location.newSingle (keyToString key), parent = Change.becomeInstantParent parent, cutoff = cutoff, oldMaybe = Nothing, changedObjectIDs = [] }).decoder encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            case decodeValue key valueEncoded of
                                Ok (Ok value) ->
                                    Just (Present key value)

                                _ ->
                                    Log.crashInDev ("entryRonDecoder : found key " ++ keyToString key ++ " and decoded it, but not able to decode the value") Nothing

                        _ ->
                            Log.crashInDev "entryRonDecoder : found key and value but not able to decode them?" Nothing

                Ok [ keyEncoded ] ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            Just (Cleared key)

                        _ ->
                            Log.crashInDev "entryRonDecoder : found just key alone but not able to decode it" Nothing

                other ->
                    Log.crashInDev "entryRonDecoder : the dict entry wasn't in the expected shape" Nothing

        repDictNodeDecoder : NodeDecoder (RepDict k v)
        repDictNodeDecoder ({ node, parent, position, cutoff } as details) =
            let
                object foundObjectIDs =
                    Node.initializeCollection { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, parent = parent, reducer = RepDict.reducerID, position = position }

                repDictBuilder foundObjects =
                    let
                        repDictObject =
                            object foundObjects

                        repDictPointer =
                            Collection.getPointer repDictObject
                    in
                    Ok <| RepDict.buildFromReplicaDb keyToString (entryRonDecoder node repDictPointer cutoff) (entryChanger node Nothing repDictPointer) nonChanger (Collection.Saved repDictObject)
            in
            { decoder = RonPayloadDecoderLegacy (JD.map repDictBuilder NodeDecoder.concurrentObjectIDsDecoder)
            , ancestors = AncestorDb.empty
            }

        repDictRonEncoder : NodeEncoder (RepDict k v) NodeEncoder.SoloObject
        repDictRonEncoder ({ node, thingToEncode, mode, parent, position } as details) =
            case thingToEncode of
                NodeEncoder.EncodeThis givenRepDict ->
                    let
                        externalChanges =
                            RepDict.getInit givenRepDict
                    in
                    NodeEncoder.soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepDict.getPointer givenRepDict
                            , objectChanges = []
                            , externalUpdates = externalChanges
                            }

                _ ->
                    NodeEncoder.justInit (Change.newPointer { parent = parent, position = position, reducerID = RepDict.reducerID })

        initializer : Initializer (Changer (RepDict k v)) (RepDict k v)
        initializer { parent, position, seed } =
            let
                collection =
                    Node.initializeCollection { node = Node.testNode, cutoff = Nothing, foundIDs = [], parent = parent, reducer = RepDict.reducerID, position = position }

                repDictPointer =
                    Collection.getPointer collection
            in
            RepDict.buildFromReplicaDb keyToString (entryRonDecoder Node.testNode repDictPointer Nothing) (entryChanger Node.testNode Nothing repDictPointer) seed collection
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder = BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = JD.fail "no repdict"
        , nodeEncoder = repDictRonEncoder
        , nodeDecoder = repDictRonDecoder
        , nodePlaceholder = initializer
        }


repStore : PrimitiveCodec k -> Codec (any -> List Change) o v -> WrappedCodec (RepStore k v)
repStore keyCodec valueCodec =
    let
        keyToString : k -> String
        keyToString key =
            -- TODO parse same on decode
            String.join "_" <| Nonempty.toList <| Nonempty.map Change.primitiveAtomToString (Base.getPrimitiveNodeEncoder keyCodec key).primitive

        flatDictListCodec =
            list (pair keyCodec valueCodec)

        jsonEncoder : RepStore k v -> JE.Value
        jsonEncoder input =
            Base.getJsonEncoder flatDictListCodec (RepStore.listModified input)

        bytesEncoder : RepStore k v -> BE.Encoder
        bytesEncoder input =
            Base.getBytesEncoder flatDictListCodec (RepStore.listModified input)

        entryNodeEncodeWrapper : Node -> Maybe NodeEncoder.ChangesToGenerate -> Parent -> Location -> k -> Change.PendingID -> Change.ComplexPayload
        entryNodeEncodeWrapper node encodeModeMaybe parent entryPosition keyToSet childPendingID =
            let
                keyEncoder givenKey =
                    Base.getNodeEncoder keyCodec
                        { mode = Maybe.withDefault NodeEncoder.defaultMode encodeModeMaybe
                        , node = node
                        , thingToEncode = NodeEncoder.EncodeThis givenKey
                        , parent = parent
                        , position = Location.nestSingle entryPosition (keyToString keyToSet)
                        }
            in
            Nonempty.append (keyEncoder keyToSet).complex (Nonempty.singleton (Change.PendingObjectReferenceAtom childPendingID))

        entryNodeDecoder : Node -> Parent -> Maybe Moment -> JE.Value -> Maybe (RepStore.RepStoreEntry k v)
        entryNodeDecoder node parent cutoff encodedEntry =
            let
                decodeKey encodedKey =
                    JD.decodeValue (Base.getNodeDecoder keyCodec { node = node, position = Location.newSingle "key", parent = parent, cutoff = cutoff, oldMaybe = Nothing, changedObjectIDs = [] }).decoder encodedKey

                decodeValue key encodedValue =
                    JD.decodeValue
                        (Base.getNodeDecoder valueCodec
                            { node = node
                            , position = Location.newSingle (keyToString key)
                            , parent = parent -- no need to wrap child changes as decoding entries means they already exist
                            , cutoff = cutoff
                            , oldMaybe = Nothing
                            , changedObjectIDs = []
                            }
                        ).decoder
                        encodedValue
            in
            case JD.decodeValue (JD.list JD.value) encodedEntry of
                Ok (keyEncoded :: [ valueEncoded ]) ->
                    case decodeKey keyEncoded of
                        Ok (Ok key) ->
                            case decodeValue key valueEncoded of
                                Ok (Ok value) ->
                                    Just (RepStore.RepStoreEntry key value)

                                _ ->
                                    Log.crashInDev ("storeEntryNodeDecoder : found key " ++ keyToString key ++ " and value but not able to decode the value") Nothing

                        _ ->
                            Log.crashInDev "storeEntryNodeDecoder : found key and value but not able to decode them?" Nothing

                _ ->
                    Log.crashInDev "storeEntryNodeDecoder : the store entry wasn't in the expected shape" Nothing

        repStoreNodeDecoder : NodeDecoder (RepStore k v)
        repStoreNodeDecoder details =
            { decoder = RonPayloadDecoderLegacy (JD.map (repStoreBuilder details nonChanger >> Ok) NodeDecoder.concurrentObjectIDsDecoder)
            , ancestors = AncestorDb.empty
            }

        repStoreBuilder { node, parent, position, cutoff } changer foundObjects =
            let
                object foundObjectIDs =
                    Node.initializeCollection { node = node, cutoff = cutoff, foundIDs = foundObjectIDs, parent = parent, reducer = RepStore.reducerID, position = position }

                repStoreObject =
                    object foundObjects

                repStorePointer =
                    Collection.getPointer repStoreObject

                repStoreAsParent =
                    Change.becomeInstantParent repStorePointer

                allEntries =
                    List.filterMap (\event -> entryNodeDecoder node repStoreAsParent Nothing (Collection.eventPayloadAsJson event)) (AnyDict.values (Collection.getEvents repStoreObject))

                entriesDict : AnyDict String k (List v)
                entriesDict =
                    let
                        addEntryToDict : RepStore.RepStoreEntry k v -> AnyDict String k (List v) -> AnyDict String k (List v)
                        addEntryToDict (RepStore.RepStoreEntry k v) dictSoFar =
                            AnyDict.update k (updateEntry v) dictSoFar
                    in
                    List.foldl addEntryToDict (AnyDict.empty keyToString) allEntries

                updateEntry newVal oldValMaybe =
                    case oldValMaybe of
                        Nothing ->
                            Just [ newVal ]

                        Just [] ->
                            Just [ newVal ]

                        Just prevEntries ->
                            Just (newVal :: prevEntries)

                fetcher : k -> v
                fetcher key =
                    AnyDict.get key entriesDict
                        |> Maybe.andThen List.head
                        |> Maybe.withDefault (createObjectAt key)

                createObjectAt key =
                    -- TODO FrameIndex needed?
                    Base.new valueCodec (Change.Context (Location.newSingle "repStoreNew") (Change.becomeDelayedParent repStorePointer (wrapNewPendingChild key)))

                wrapNewPendingChild key pendingChild =
                    Change.delayedChangeObject repStorePointer
                        (Change.NewPayload (entryNodeEncodeWrapper node Nothing repStoreAsParent (Location.newSingle "repStoreVal") key pendingChild))
            in
            RepStore.buildFromReplicaDb { object = Collection.Saved repStoreObject, fetcher = fetcher, start = changer }

        repStoreNodeEncoder : NodeEncoder (RepStore k v) NodeEncoder.SoloObject
        repStoreNodeEncoder { thingToEncode, parent, position } =
            case thingToEncode of
                NodeEncoder.EncodeThis givenRepStore ->
                    NodeEncoder.soloOut <|
                        Change.changeObjectWithExternal
                            { target = RepStore.getPointer givenRepStore
                            , objectChanges = []
                            , externalUpdates = RepStore.getInit givenRepStore
                            }

                _ ->
                    NodeEncoder.justInit (Change.newPointer { parent = parent, position = position, reducerID = RepStore.reducerID })

        initializer : Initializer (Changer (RepStore k v)) (RepStore k v)
        initializer { parent, position, seed } =
            repStoreBuilder { node = Node.testNode, parent = parent, position = position, cutoff = Nothing } seed []
    in
    Codec
        { bytesEncoder = bytesEncoder
        , bytesDecoder = BD.fail
        , jsonEncoder = jsonEncoder
        , jsonDecoder = JD.fail "no repstore"
        , nodeEncoder = repStoreNodeEncoder
        , nodeDecoder = repStoreNodeDecoder
        , nodePlaceholder = initializer
        }


seedlessPair : WrappedOrSkelCodec s1 a -> WrappedOrSkelCodec s2 b -> SkelCodec ( a, b )
seedlessPair codecFirst codecSecond =
    record Tuple.pair
        |> fieldReg ( 1, "first" ) Tuple.first codecFirst
        |> fieldReg ( 2, "second" ) Tuple.second codecSecond
        |> finishRecord
