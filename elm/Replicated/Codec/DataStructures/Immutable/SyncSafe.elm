module Replicated.Codec.DataStructures.Immutable.SyncSafe exposing (maybe, pair, result, triple)

{-| "Immutable" Data Structures are the primitive/built-in collection types that don't support changes.
This module contains codecs for the "sync safe" data structures, meaning there's no mutable alternative, and a Change that replaces the data entirely will generally align with user expectations when changes are merged.
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
import Replicated.Codec.Base as Base exposing (Codec(..), SelfSeededCodec)
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder as BytesEncoder exposing (BytesEncoder)
import Replicated.Codec.CustomType as CustomType exposing (customType)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Initializer as Initializer exposing (Initializer)
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Json.Encoder exposing (JsonEncoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (Inputs, NodeDecoder)
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


maybe : Codec s o a -> SelfSeededCodec {} (Maybe a)
maybe justCodec =
    customType
        (\nothingEncoder justEncoder value ->
            case value of
                Nothing ->
                    nothingEncoder

                Just value_ ->
                    justEncoder value_
        )
        |> variant0 ( 0, "Nothing" ) Nothing
        |> variant1 ( 1, "Just" ) Just justCodec
        |> finishCustomType


pair : Codec ia oa a -> Codec ib ob b -> NullCodec ( a, b )
pair codecFirst codecSecond =
    -- Used to be:
    -- fragileRecord Tuple.pair
    --     |> fixedField Tuple.first codecFirst
    --     |> fixedField Tuple.second codecSecond
    --     |> finishFragileRecord
    customType
        (\pairEncoder ( a, b ) ->
            pairEncoder a b
        )
        |> variant2 ( 2, "Pair" ) Tuple.pair codecFirst codecSecond
        |> finishCustomType


triple : Codec ia oa a -> Codec ib ob b -> Codec ic oc c -> SelfSeededCodec {} ( a, b, c )
triple codecFirst codecSecond codecThird =
    -- fragileRecord (\a b c -> ( a, b, c ))
    --     |> fixedField (\( a, _, _ ) -> a) codecFirst
    --     |> fixedField (\( _, b, _ ) -> b) codecSecond
    --     |> fixedField (\( _, _, c ) -> c) codecThird
    --     |> finishFragileRecord
    customType
        (\tripleEncoder ( a, b, c ) ->
            tripleEncoder a b c
        )
        |> variant3 ( 3, "Triple" ) (\a b c -> ( a, b, c )) codecFirst codecSecond codecThird
        |> finishCustomType


result : Codec sa oa error -> Codec sb ob value -> SelfSeededCodec {} (Result error value)
result errorCodec valueCodec =
    customType
        (\errEncoder okEncoder value ->
            case value of
                Err err ->
                    errEncoder err

                Ok ok ->
                    okEncoder ok
        )
        |> variant1 ( 0, "Err" ) Err errorCodec
        |> variant1 ( 1, "Ok" ) Ok valueCodec
        |> finishCustomType
