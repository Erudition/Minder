module Replicated.Codec.RegisterField.Encoder exposing (Inputs, Output, RegisterFieldEncoder, SmartJsonFieldEncoder, newRegisterFieldEncoderEntry)

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
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (WrappedJsonDecoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (NodeDecoder, NodeDecoderInputs)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
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


type alias RegisterFieldEncoder full =
    Inputs full -> Output


type alias SmartJsonFieldEncoder full =
    ( String, full -> JE.Value )


{-| Inputs to a node Field encoder.

No "position" because it's already in the parent, and field index can be determined by record counter
No "parent", just pointer, because the parent is constructed in the individual field encoder.

-}
type alias Inputs field =
    { node : Node
    , mode : NodeEncoder.ChangesToGenerate
    , history : FieldHistoryDict
    , regPointer : Pointer
    , existingValMaybe : Maybe field
    }


{-| Whether we will be encoding this field, or skipping it. specific to registers. Used to do this for all encoder output, but it made everything harder.
-}
type Output
    = EncodeThisField Change.ObjectChange
    | SkipThisField


{-| Adds an item to the list of replica encoders, for encoding a single Register field into an Op, if applicable. This field may contain further nested fields which also are encoded.
-}
newRegisterFieldEncoderEntry : Int -> FieldIdentifier -> FieldFallback parentSeed fieldSeed fieldType -> Codec fieldSeed o fieldType -> (RegisterFieldEncoder.Inputs fieldType -> RegisterFieldEncoder.Output)
newRegisterFieldEncoderEntry index ( fieldSlot, fieldName ) fieldFallback fieldCodec { mode, node, regPointer, history, existingValMaybe } =
    let
        regAsParent =
            Change.becomeDelayedParent regPointer (updateRegisterPostChildInit regPointer ( fieldSlot, fieldName ))

        runFieldNodeEncoder valueToEncode =
            getNodeEncoder fieldCodec
                { mode = mode
                , node = node
                , thingToEncode = valueToEncode
                , parent = regAsParent
                , position = Location.new (fieldLocationLabel fieldName fieldSlot) index
                }

        getPayloadIfSet =
            getFieldLatestOnly history ( fieldSlot, fieldName )

        fieldDecodedMaybe payload =
            -- even though we're in an encoder, we must run the decoder to get the value out of the register's memory. This is borrowed from registerReadOnlyFieldDecoder
            let
                run =
                    JD.decodeValue
                        (getNodeDecoder fieldCodec
                            { node = node
                            , position = Location.new (fieldLocationLabel fieldName fieldSlot) index
                            , parent = regAsParent
                            , cutoff = Nothing
                            }
                        )
                        (Op.payloadToJsonValue payload)
            in
            case run of
                Ok (Ok fieldValue) ->
                    Just fieldValue

                problem ->
                    Log.crashInDev ("fieldDecodedMaybe: Failed to decode from register memory, got " ++ Log.dump problem) Nothing

        explicitDefaultIfNeeded val =
            if mode.setDefaultsExplicitly then
                -- we were asked to encode all defaults
                EncodeThisField <| Change.NewPayload <| encodedDefaultAsPayload val

            else
                case encodeDefaultVal val of
                    (Nonempty (Change.QuoteNestedObject { skippable }) []) as encodedVal ->
                        -- payload must be a single nested object with no other atoms
                        if skippable then
                            -- field encoder said we can skip this one
                            -- EncodeThisField <|
                            --     Change.NewPayload <|
                            --         wrappedOutput val
                            SkipThisField

                        else
                            EncodeThisField <|
                                Change.NewPayload <|
                                    encodedDefaultAsPayload val

                    _ ->
                        if isExistingSameAsDefault then
                            -- it's equivalent to default
                            SkipThisField

                        else
                            -- Nested objects are never equal to default, respect their necessity
                            EncodeThisField <| Change.NewPayload <| encodedDefaultAsPayload val

        isExistingSameAsDefault =
            case ( fieldDefaultMaybe fieldFallback, Maybe.andThen fieldDecodedMaybe getPayloadIfSet ) of
                ( Just fieldDefault, Just existingValue ) ->
                    -- is the calculated default the same as the existing/placeholder value?
                    fieldDefault == existingValue

                ( Just _, Nothing ) ->
                    -- no existing val in memory, so equal to default unless it's seeded
                    True

                ( Nothing, Nothing ) ->
                    case fieldFallback of
                        PlaceholderDefault _ ->
                            -- we can figure out how to init this
                            True

                        _ ->
                            -- guess it must require a seed
                            False

                _ ->
                    -- if there's no default, and not placeholder, it can't be equal. (seeded)
                    False

        encodeDefaultVal : fieldType -> Change.ComplexPayload
        encodeDefaultVal defaultVal =
            -- EncodeThis because this only gets used on default value
            (runFieldNodeEncoder (EncodeThis defaultVal)).complex

        encodedDefaultAsPayload : fieldType -> Change.ComplexPayload
        encodedDefaultAsPayload val =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (encodeDefaultVal val)
    in
    case Maybe.Extra.or existingValMaybe (fieldDefaultMaybe fieldFallback) of
        Just valToEncode ->
            -- Okay we have a default to fall back to
            -- has the value been set?
            case getPayloadIfSet of
                Nothing ->
                    -- never been set before, encode default if requested by mode, or just skip
                    explicitDefaultIfNeeded valToEncode

                Just foundPreviousValue ->
                    -- it's been set before. even if set to default (e.g. Nothing) we will honor this
                    -- EncodeThisField <| Change.NewPayload <| encodeVal foundPreviousValue
                    Debug.todo "what to do here?"

        Nothing ->
            -- we have no default to fall back to, this is for SEEDED nested objects only
            case getPayloadIfSet of
                Nothing ->
                    -- no default, no seed, no pre-existing object.. can't encode defaults even if we wanted to. Should only occur with seeded naked records
                    SkipThisField

                Just latestPayload ->
                    -- it was set before, can we decode it?
                    case fieldDecodedMaybe latestPayload of
                        Nothing ->
                            -- -- give up! spit back out what we already had in the register.
                            -- EncodeThisField <| Change.NewPayload <| Nonempty.map Change.FromPrimitiveAtom latestPayload
                            Log.logSeparate "WARNING newRegisterFieldEncoderEntry: failed to decode latest payload from reg, can't encode it." latestPayload SkipThisField

                        Just fieldValue ->
                            -- object acquired! make sure we don't miss the opportunity to pass objectID info to naked subcodecs
                            case extractQuotedObjects (Nonempty.toList latestPayload) of
                                [] ->
                                    -- -- give up! spit back out what we already had in the register.
                                    -- EncodeThisField <| Change.NewPayload <| Nonempty.map Change.FromPrimitiveAtom latestPayload
                                    Log.logSeparate "WARNING newRegisterFieldEncoderEntry: failed to extract ObjectIDs from latest payload from reg, can't encode it." latestPayload SkipThisField

                                firstFoundObjectID :: moreFoundObjectIDs ->
                                    let
                                        runNestedEncoder =
                                            EncodeObjectOrThis (Nonempty firstFoundObjectID moreFoundObjectIDs) fieldValue
                                                |> runFieldNodeEncoder
                                    in
                                    -- encode not only this field (set to this object), but also grab any encoder output from that object
                                    EncodeThisField <| Change.NewPayload runNestedEncoder.complex



-- HELPERS


{-| For getting the list of pointers out of the stored ops - perhaps even a bunch of ops, whose atoms can be concatenated (to merge all concurrent inits)
-}
extractQuotedObjects : List Op.OpPayloadAtom -> List ObjectID
extractQuotedObjects atomList =
    let
        keepUUIDs atom =
            case atom of
                Op.IDPointerAtom opID ->
                    Just opID

                _ ->
                    Nothing
    in
    List.filterMap keepUUIDs atomList


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> Change.ComplexPayload -> Change.ComplexPayload
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    Nonempty.append
        (Nonempty (Change.FromPrimitiveAtom (Change.IntegerAtom fieldSlot)) [ Change.FromPrimitiveAtom (Change.NakedStringAtom fieldName) ])
        fieldPayload


{-| Register field fetch - will combine nested objectIDs if found
-}
getFieldLatestOnly : FieldHistoryDict -> FieldIdentifier -> Maybe FieldPayload
getFieldLatestOnly fields ( fieldSlot, name ) =
    case Dict.get fieldSlot fields of
        Nothing ->
            Nothing

        Just ((Nonempty ( firstOpID, Nonempty (Op.IDPointerAtom objectID) anyMoreAtoms ) anyMoreOps) as history) ->
            -- nested object will be in this specific form, an objectID as its first (usually only) atom
            -- can't just detect objectIDs present because it could be a custom type wrapping one
            -- stick together all objectIDs found ever
            Just <| Nonempty.concatMap Tuple.second history

        Just historyNonempty ->
            -- first one didn't begin with an ObjectID atom, go back to normal
            Just <| Tuple.second (Nonempty.head historyNonempty)


getFieldHistory : FieldHistoryDict -> FieldIdentifier -> List ( OpID, FieldPayload )
getFieldHistory fields ( desiredFieldSlot, name ) =
    Dict.get desiredFieldSlot fields
        |> Maybe.map Nonempty.toList
        |> Maybe.withDefault []


getFieldHistoryValues : FieldHistoryDict -> FieldIdentifier -> List FieldPayload
getFieldHistoryValues fields givenField =
    List.map Tuple.second (getFieldHistory fields givenField)
