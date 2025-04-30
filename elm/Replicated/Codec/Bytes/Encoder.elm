module Replicated.Codec.Bytes.Encoder exposing (BytesEncoder, map)

{-| Wrapper for whatever Bytes encoding library is currently chosen.
-}

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Encode


endian : Bytes.Endianness
endian =
    Bytes.BE


type alias BytesEncoder thing =
    thing -> Bytes.Encode.Encoder


map : (b -> a) -> BytesEncoder a -> BytesEncoder b
map fromBtoA encoderA =
    \v -> encoderA (fromBtoA v)
