module Replicated.Codec.RonPayloadDecoder exposing (..)

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Console
import Css exposing (None)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (b, input, th)
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
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
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


type RonPayloadDecoder a
    = RonPayloadDecoderLegacy (JD.Decoder (Result RepDecodeError a))
    | RonPayloadDecoderNew (Op.Op.Payload -> Result RepDecodeError a)



-- fromJsonDecoder : JD.Decoder a -> RonPayloadDecoder a
-- fromJsonDecoder jsonDecoder =
--     RonPayloadDecoderLegacy jsonDecoder


map : (a -> b) -> RonPayloadDecoder a -> RonPayloadDecoder b
map fromAtoB decoderA =
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err
    in
    case decoderA of
        RonPayloadDecoderLegacy jsonDecoder ->
            RonPayloadDecoderLegacy (JD.map fromResultData jsonDecoder)

        RonPayloadDecoderNew payloadDecoderA ->
            RonPayloadDecoderNew (\opPayloadAtomsB -> Result.map fromAtoB (payloadDecoderA opPayloadAtomsB))


mapTry : (a -> Result Error.CustomError b) -> RonPayloadDecoder a -> RonPayloadDecoder b
mapTry fromAtoBResult decoderA =
    let
        fromResultData : Result RepDecodeError a -> Result RepDecodeError b
        fromResultData value =
            case value of
                Ok ok ->
                    case fromAtoBResult ok of
                        Ok out ->
                            Ok out

                        Err customErr ->
                            Err (Error.Custom customErr)

                Err err ->
                    Err err
    in
    case decoderA of
        RonPayloadDecoderLegacy jsonDecoder ->
            RonPayloadDecoderLegacy (JD.map fromResultData jsonDecoder)

        RonPayloadDecoderNew payloadDecoderA ->
            RonPayloadDecoderNew (\opPayloadAtomsB -> fromResultData (payloadDecoderA opPayloadAtomsB))


lazy : (() -> RonPayloadDecoder a) -> RonPayloadDecoder a
lazy thunkToDecoder =
    case thunkToDecoder () of
        RonPayloadDecoderLegacy jsonDecoder ->
            RonPayloadDecoderLegacy (JD.succeed () |> JD.andThen (\() -> jsonDecoder))

        RonPayloadDecoderNew payloadDecoder ->
            -- TODO this is probably not lazy
            RonPayloadDecoderNew payloadDecoder
