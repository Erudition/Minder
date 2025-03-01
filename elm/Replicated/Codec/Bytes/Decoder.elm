module Replicated.Codec.Bytes.Decoder exposing (BytesDecoder)

{-| Wrapper for whatever Bytes decoding library is currently chosen.
-}

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Decode
import Replicated.Codec.Error as Error exposing (RepDecodeError)


endian : Bytes.Endianness
endian =
    Bytes.BE


type BytesDecoder a
    = BytesDecoder (Bytes.Decode.Decoder (Result RepDecodeError a))
