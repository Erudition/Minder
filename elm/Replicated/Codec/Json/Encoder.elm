module Replicated.Codec.Json.Encoder exposing (JsonEncoder)

{-| Wrapper for whatever Json encoding library is currently chosen.
-}

import Array exposing (Array)
import Css exposing (None)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (input, th)
import ID exposing (ID)
import Json.Decode
import Json.Encode
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))


type alias JsonEncoder a =
    a -> Json.Encode.Value
