module Replicated.Value exposing (..)

import Bytes exposing (Bytes)
import Json.Encode
import Replicated.Serialize as RS exposing (Codec)


{-| A raw value that's been encoded somehow.
-}
type Value
    = JsonValue Json.Encode.Value
    | ByteValue Bytes


decode codec value =
    case value of
        JsonValue json ->
            RS.decodeFromJson codec json

        ByteValue bytes ->
            RS.decodeFromBytes codec bytes
