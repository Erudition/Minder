module Porting exposing (EncodeField, Updateable(..), applyChanges, arrayAsTuple2, customDecoder, decodeBoolAsInt, decodeCustom, decodeCustomFlat, decodeInterval, encodeBoolAsInt, encodeInterval, homogeneousTuple2AsArray, ifPresent, normal, omitNothings, omittable, subtype, subtype2, toClassic, updateable)

import Json.Decode as ClassicDecode
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Decode.Extra as ClassicDecode2
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


{-| Opposite of arrayAsTuple2.
Only works on tuple2s where the types are the same.
-}
homogeneousTuple2AsArray : (sameType -> Encode.Value) -> ( sameType, sameType ) -> Encode.Value
homogeneousTuple2AsArray encoder ( a, b ) =
    Encode.list encoder [ a, b ]


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



-- broken! check wants succeed decoders only


decodeCustom : List ( String, Decoder a ) -> Decoder a
decodeCustom tagsWithDecoders =
    let
        tryValues ( tag, decoder ) =
            check string tag decoder
    in
    oneOf (List.map tryValues tagsWithDecoders)



-- Decode.check should be used here


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


{-| The thing you normally pass a list of to `Encode.object`.
-}
type alias EncodeField =
    ( String, Encode.Value )


{-| A cool new API for JSON object encoding. If a value to be encoded is Nothing, now you can skip encoding it in the first place!
If not, encode the bare value (no `Just` wrapper).

Prefix your list of fields to encode with this function. Then, prefix normal fields in the list with `normal` and omittable fields with `omittable`. For omittable items, tweak your tuple as described in `omittable`, and you're done!

-}
omitNothings : List (Maybe EncodeField) -> List EncodeField
omitNothings =
    List.filterMap identity


{-| For optional field encoding. Pass in the usual String (field name ) & Encoder tuple, _except_ put a comma between the encoder function and the value to encode, making the whole thing a 3-tuple. That's it!

    So,
    `("widget", encodeWidget record.widget)`
    becomes:
    `("widget", encodeWidget, record.widget)`

    ..where record.widget is some `Maybe Widget` value, for example, and `encodeWidget` encodes `Widget` values (which are *not* wrapped in `Maybe`).

-}
omittable : ( String, a -> Encode.Value, Maybe a ) -> Maybe EncodeField
omittable ( name, encoder, fieldToCheck ) =
    Maybe.map (\field -> ( name, encoder field )) fieldToCheck


{-| Stick this in front of normal field encoder tuples, when they're in an `omitNothings` list with some `omittable` encoder tuples.

    Alias for `Just`.

    So,
    `("widget", encodeWidget record.widget)`
    becomes:
    `normal ("widget", encodeWidget record.widget)`
    ...for example.

-}
normal : EncodeField -> Maybe EncodeField
normal =
    Just


{-| Use this function in Decoder Pipelines, in place of functions like Pipeline.optional or Pipeline.required, to decode object fields that are not wrapped in `Maybe` into Elm values that are.

    This is used for fields that may not be present (in which case the decode result is `Nothing`), such as those generated by the Encoder functions `omitNothings` and friends. This allows you to encode/decode "Nothing" as the absence of a field in JSON, rather than a field set to "null".

-}
ifPresent : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
ifPresent fieldName decoder =
    Pipeline.optional fieldName (Decode.map Just decoder) Nothing


type alias BoolAsInt =
    Int


decodeBoolAsInt : Decoder Bool
decodeBoolAsInt =
    oneOf
        [ check int 1 <| succeed True
        , check int 0 <| succeed False
        ]


encodeBoolAsInt : Bool -> Encode.Value
encodeBoolAsInt bool =
    case bool of
        True ->
            Encode.int 1

        False ->
            Encode.int 0


{-| Allows for Updateable fields during decoding, such as for incremental syncs or storing only deltas.
-}
type Updateable a
    = NoChange
    | ChangedTo a


{-| Pipeline: Same as `optional` but works on Updateable fields - wraps matches in `ChangedTo`, otherwise returns `NoChange`.
-}
updateable : String -> Decoder a -> Decoder (Updateable a -> b) -> Decoder b
updateable key valDecoder decoder =
    let
        wrappedValDecoder =
            Decode.map ChangedTo valDecoder
    in
    decoder |> optional key wrappedValDecoder NoChange


applyChanges : a -> Updateable a -> a
applyChanges original change =
    case change of
        NoChange ->
            original

        ChangedTo new ->
            new


toClassic : Decoder a -> ClassicDecode.Decoder a
toClassic decoder =
    let
        runRealDecoder value =
            decodeValue decoder value

        asResult value =
            strict (runRealDecoder value)

        convertToNormalResult fancyResult =
            Result.mapError errorsToString fancyResult

        final value =
            convertToNormalResult (asResult value)
    in
    ClassicDecode.value |> ClassicDecode.andThen (ClassicDecode2.fromResult << final)
