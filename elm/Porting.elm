module Porting exposing (arrayAsTuple2, customDecoder, decodeCustom, subtype)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode



-- import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)
-- import Json.Encode as Encode exposing (..)
-- import Json.Encode.Extra as Encode2 exposing (..)


arrayAsTuple2 : Decoder a -> Decoder b -> Decoder ( a, b )
arrayAsTuple2 a b =
    index 0 a
        |> andThen
            (\aVal ->
                index 1 b
                    |> andThen (\bVal -> Decode.succeed ( aVal, bVal ))
            )


customDecoder : Decoder b -> (b -> Result String a) -> Decoder a
customDecoder primitiveDecoder customDecoderFunction =
    Decode.andThen
        (\a ->
            case customDecoderFunction a of
                Ok b ->
                    Decode.succeed b

                Err err ->
                    Decode.fail err
        )
        primitiveDecoder


decodeCustom : List ( String, Decoder a ) -> Decoder a
decodeCustom tagsWithDecoders =
    let
        tryValues ( tag, decoder ) =
            check string tag decoder
    in
    oneOf (List.map tryValues tagsWithDecoders)



-- encodeTU : List (Decoder a) -> Encode.Value
-- encodeTU  =
--     Encode.object []
-- valueC : String -> Decoder b -> Decoder b
-- valueC name decoder =
--     when (field "tag" Decode.string) ((==) name) decoder


subtype : (subtype -> unionType) -> String -> Decoder subtype -> Decoder unionType
subtype tagger fieldName subTypeDecoder =
    Decode.map tagger (field fieldName subTypeDecoder)


subtype2 : (subtype1 -> subtype2 -> unionType) -> String -> Decoder subtype1 -> String -> Decoder subtype2 -> Decoder unionType
subtype2 tagger fieldName1 subType1Decoder fieldName2 subType2Decoder =
    Decode.map2 tagger
        (field fieldName1 subType1Decoder)
        (field fieldName2 subType2Decoder)



-- type TaggedUnionValue tagType a b c
--     = NoParams String tagType
--     | OneParam String tagType String Decoder
--     | TwoParam String (b -> c -> tagType) String (Decoder b) String (Decoder c)
