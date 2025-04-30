module Replicated.Codec.Json.Decoder exposing (JsonDecoder, map, prepRonAtomForLegacyDecoder)

{-| Wrapper for whatever Json decoding library is currently chosen.
-}

import Array exposing (Array)
import Css exposing (None)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (b, input, th)
import ID exposing (ID)
import Json.Decode
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))



-- TODO investigate using more featureful json decoder libraries:
-- - [] https://package.elm-lang.org/packages/MackeyRMS/json-decode-attempt/latest/
--   - Decode with warnings instead of errors
-- TODO investigate supporting evolutions of json (e.g. with comments) by falling back to more lenient parsing when built-in decoder fails


type alias JsonDecoder a =
    Json.Decode.Decoder (Result RepDecodeError a)


prepRonAtomForLegacyDecoder : String -> String
prepRonAtomForLegacyDecoder inputString =
    case String.startsWith ">" inputString of
        True ->
            "\"" ++ String.dropLeft 1 (String.dropRight 1 inputString) ++ "\""

        False ->
            inputString


map : (a -> b) -> JsonDecoder a -> JsonDecoder b
map fromAtoB jdA =
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err
    in
    Json.Decode.map fromResultData jdA
