module Replicated.Codec.Bytes.Decoder exposing (BytesDecoder, lazy, map, mapTry)

{-| Wrapper for whatever Bytes decoding library is currently chosen.

TODO: Switch to <https://package.elm-lang.org/packages/zwilias/elm-bytes-parser/latest/Bytes-Parser>

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


mapTry : (a -> Result Error.CustomError b) -> BytesDecoder a -> BytesDecoder b
mapTry fromAtoBResult (BytesDecoder bdA) =
    let
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
    BytesDecoder (Bytes.Decode.map fromResultData bdA)


lazy : BytesDecoder a -> BytesDecoder a
lazy (BytesDecoder dec) =
    Bytes.Decode.succeed ()
        |> Bytes.Decode.andThen (\() -> dec)
        |> BytesDecoder
