module Replicated.Codec.Bytes.Encoder exposing (BytesEncoder, endian, map, replaceBase64Chars)

{-| Wrapper for whatever Bytes encoding library is currently chosen.
-}

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Encode
import Regex exposing (Regex)


endian : Bytes.Endianness
endian =
    Bytes.BE


type alias BytesEncoder thing =
    thing -> Bytes.Encode.Encoder


map : (b -> a) -> BytesEncoder a -> BytesEncoder b
map fromBtoA encoderA =
    \v -> encoderA (fromBtoA v)


replaceBase64Chars : Bytes.Bytes -> String
replaceBase64Chars =
    let
        replaceChar rematch =
            case rematch.match of
                "+" ->
                    "-"

                "/" ->
                    "_"

                _ ->
                    ""
    in
    Base64.fromBytes >> Maybe.withDefault "" >> Regex.replace replaceForUrl replaceChar


replaceForUrl : Regex
replaceForUrl =
    Regex.fromString "[\\+/=]" |> Maybe.withDefault Regex.never
