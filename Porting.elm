module Porting exposing (arrayAsTuple2, customDecoder, decodeTU, subValue, valueC)

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra as Decode2 exposing (..)
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


decodeTU : String -> List (Decoder a) -> Decoder a
decodeTU unionName vcList =
    let
        fallthrough string =
            Result.Err ("Not valid pattern for decoder to " ++ unionName ++ ". Pattern: " ++ toString string)

        listPlusFallThrough =
            vcList ++ [ Decode.string |> andThen (fromResult << fallthrough) ]
    in
    oneOf listPlusFallThrough



-- encodeTU : List (Decoder a) -> Encode.Value
-- encodeTU  =
--     Encode.object []


valueC : String -> Decoder b -> Decoder b
valueC name decoder =
    when (field "tag" Decode.string) ((==) name) decoder


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
