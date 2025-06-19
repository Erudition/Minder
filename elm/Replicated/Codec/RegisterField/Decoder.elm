module Replicated.Codec.RegisterField.Decoder exposing (RegisterFieldDecoder)

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
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (Inputs, NodeDecoder)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
import Replicated.Codec.RegisterField.Shared exposing (..)
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.ObjectGroup as Object exposing (ObjectGroup)
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


type alias RegisterFieldDecoder remaining =
    RegisterFieldDecoderInputs -> ( Maybe remaining, List RepDecodeError )


type alias RegisterFieldDecoderInputs =
    { node : Node
    , regPointer : Pointer
    , history : FieldHistoryDict
    , cutoff : Maybe Moment
    }


{-| RON what to do when decoding a (potentially nested!) object field.
-}
registerReadOnlyFieldDecoder : Int -> ( FieldSlot, FieldName ) -> Fallback parentSeed fieldSeed fieldType -> Codec fieldSeed o fieldType -> RegisterFieldDecoderInputs -> ( Maybe fieldType, List RepDecodeError )
registerReadOnlyFieldDecoder index (( fieldSlot, fieldName ) as fieldIdentifier) fallback fieldCodec inputs =
    let
        regAsParent =
            Change.becomeDelayedParent inputs.regPointer (updateRegisterPostChildInit inputs.regPointer fieldIdentifier)

        position =
            Location.new (fieldLocationLabel fieldName fieldSlot) index

        runFieldDecoder thingToDecode =
            JD.decodeValue
                (getNodeDecoder fieldCodec
                    { node = inputs.node, position = position, parent = regAsParent, cutoff = inputs.cutoff }
                )
                thingToDecode

        generatedDefaultMaybe =
            case fallback of
                PlaceholderDefault fieldSeed ->
                    Just <| getInitializer fieldCodec { parent = regAsParent, seed = fieldSeed, position = position }

                _ ->
                    Nothing

        default =
            Maybe.Extra.or (fieldDefaultMaybe fallback) generatedDefaultMaybe
    in
    case getFieldLatestOnly inputs.history fieldIdentifier of
        Nothing ->
            -- field was never set - fall back to default
            case default of
                Just _ ->
                    ( default, [] )

                Nothing ->
                    Log.crashInDev ("registerReadOnlyFieldDecoder: Failed to decode a field (" ++ fieldName ++ ") that should always decode (required missing, or nested should return defaults), there's no default to fall back to")
                        ( default, [ MissingRequiredField fieldSlot fieldName ] )

        Just foundField ->
            -- field was set before
            case runFieldDecoder (Payload.toJsonValue foundField) of
                Ok (Ok goodValue) ->
                    ( Just goodValue, [] )

                Ok (Err problem) ->
                    ( default, [ problem ] )

                Err jsonDecodeError ->
                    ( default, [ FailedToDecodeRegField fieldSlot fieldName (Payload.toJsonValue foundField |> JE.encode 0) jsonDecodeError ] )


registerWritableFieldDecoder : Int -> ( FieldSlot, FieldName ) -> Fallback parentSeed fieldSeed fieldType -> Bool -> Codec fieldSeed o fieldType -> RegisterFieldDecoderInputs -> ( Maybe (RW fieldType), List RepDecodeError )
registerWritableFieldDecoder index (( fieldSlot, fieldName ) as fieldIdentifier) fallback isDelayable fieldCodec inputs =
    let
        regAsParent =
            if isDelayable then
                Change.becomeDelayedParent inputs.regPointer (updateRegisterPostChildInit inputs.regPointer ( fieldSlot, fieldName ))

            else
                Change.becomeInstantParent inputs.regPointer

        fieldEncoder newValue =
            getNodeEncoder fieldCodec
                { node = inputs.node
                , mode = defaultEncodeMode
                , thingToEncode = EncodeThis newValue
                , parent = regAsParent
                , position = Location.new (fieldLocationLabel fieldName fieldSlot) index
                }

        wrapRW : Change.Pointer -> fieldType -> RW fieldType
        wrapRW targetObject head =
            buildRW targetObject fieldIdentifier fieldEncoder head
    in
    case registerReadOnlyFieldDecoder index fieldIdentifier fallback fieldCodec inputs of
        ( Just thingToWrap, errorsSoFar ) ->
            ( Just (wrapRW inputs.regPointer thingToWrap), errorsSoFar )

        ( previousShowstopper, errorsSoFar ) ->
            ( Nothing, errorsSoFar )



-- HELPERS


extractFieldEventFromObjectPayload : Object.EventPayload -> Result String ( FieldIdentifier, FieldPayload )
extractFieldEventFromObjectPayload payload =
    case payload of
        (Op.IntegerAtom fieldSlot) :: (Op.NakedStringAtom fieldName) :: rest ->
            case rest of
                [] ->
                    Err <| "Register: Missing payload for field " ++ fieldName

                head :: tail ->
                    Ok ( ( fieldSlot, fieldName ), Nonempty head tail )

        badList ->
            Err ("Register: Failed to extract field slot, field name, event payload from the given op payload because the value list is supposed to have 3+ elements and I found " ++ String.fromInt (List.length badList))
