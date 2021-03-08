module Replicated.Value exposing (..)

import Json.Encode
import Serialize as S exposing (Codec)


{-| A raw value that's been encoded somehow.
-}
type Value
    = JsonValue Json.Encode.Value


decode codec value =
    case value of
        JsonValue json ->
            S.decodeFromJson codec json
