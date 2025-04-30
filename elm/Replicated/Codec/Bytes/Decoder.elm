module Replicated.Codec.Bytes.Decoder exposing (BytesDecoder, map)

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


map : (a -> b) -> BytesDecoder a -> BytesDecoder b
map fromAtoB (BytesDecoder bdA) =
    let
        fromResultData value =
            case value of
                Ok ok ->
                    fromAtoB ok |> Ok

                Err err ->
                    Err err
    in
    BytesDecoder (Bytes.Decode.map fromResultData bdA)
