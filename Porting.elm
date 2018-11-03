module Porting exposing (arrayAsTuple2, customDecoder, decodeTU, subValue)

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


decodeTU : List ( String, Decoder a ) -> Decoder a
decodeTU tagsWithDecoders =
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
--     check (field "tag" Decode.string) ((==) name) decoder


subValue : (subtype -> unionType) -> String -> Decoder subtype -> Decoder unionType
subValue tagger fieldName subTypeDecoder =
    Decode.map tagger (field fieldName subTypeDecoder)



-- type TaggedUnionValue tagType a b c
--     = NoParams String tagType
--     | OneParam String tagType String Decoder
--     | TwoParam String (b -> c -> tagType) String (Decoder b) String (Decoder c)
--
--
-- type ExampleAction
--     = SaySomething String
--     | CountUpTo Int
--     | GoPlaceTime String String
--     | Eat_for_daysGains_Lbs String Int Float
--     | GoAway
