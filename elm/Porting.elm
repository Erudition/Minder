module Porting exposing (arrayAsTuple2, customDecoder, decodeCustom, decodeCustomFlat, decodeInterval, encodeInterval, subtype, subtype2)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import Time.Extra exposing (Interval(..))



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


decodeCustomFlat : List ( String, a ) -> Decoder a
decodeCustomFlat tags =
    let
        justTag =
            Tuple.mapSecond Decode.succeed
    in
    decodeCustom (List.map justTag tags)



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


encodeInterval : Time.Extra.Interval -> Value
encodeInterval v =
    case v of
        Year ->
            Encode.string "Year"

        Quarter ->
            Encode.string "Quarter"

        Month ->
            Encode.string "Month"

        Week ->
            Encode.string "Week"

        Monday ->
            Encode.string "Monday"

        Tuesday ->
            Encode.string "Tuesday"

        Wednesday ->
            Encode.string "Wednesday"

        Thursday ->
            Encode.string "Thursday"

        Friday ->
            Encode.string "Friday"

        Saturday ->
            Encode.string "Saturday"

        Sunday ->
            Encode.string "Sunday"

        Day ->
            Encode.string "Day"

        Hour ->
            Encode.string "Hour"

        Minute ->
            Encode.string "Minute"

        Second ->
            Encode.string "Second"

        Millisecond ->
            Encode.string "Millisecond"


decodeInterval : Decoder Time.Extra.Interval
decodeInterval =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "Year" ->
                        Decode.succeed Year

                    "Quarter" ->
                        Decode.succeed Quarter

                    "Month" ->
                        Decode.succeed Month

                    "Week" ->
                        Decode.succeed Week

                    "Monday" ->
                        Decode.succeed Monday

                    "Tuesday" ->
                        Decode.succeed Tuesday

                    "Wednesday" ->
                        Decode.succeed Wednesday

                    "Thursday" ->
                        Decode.succeed Thursday

                    "Friday" ->
                        Decode.succeed Friday

                    "Saturday" ->
                        Decode.succeed Saturday

                    "Sunday" ->
                        Decode.succeed Sunday

                    "Day" ->
                        Decode.succeed Day

                    "Hour" ->
                        Decode.succeed Hour

                    "Minute" ->
                        Decode.succeed Minute

                    "Second" ->
                        Decode.succeed Second

                    "Millisecond" ->
                        Decode.succeed Millisecond

                    _ ->
                        Decode.fail "Invalid Interval"
            )
