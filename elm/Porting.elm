module Porting exposing (BoolFromInt, EncodeField, Updateable(..), applyChanges, arrayAsTuple2, customDecoder, decodeBoolFromInt, decodeCustom, decodeCustomFlat, decodeDuration, decodeFuzzyMoment, decodeIntDict, decodeInterval, decodeMoment, decodeTuple2, decodeTuple3, decodeUnixTimestamp, encodeBoolToInt, encodeDuration, encodeFuzzyMoment, encodeIntDict, encodeInterval, encodeMoment, encodeObjectWithoutNothings, encodeTuple2, encodeTuple3, encodeUnixTimestamp, homogeneousTuple2AsArray, mapUpdateable, normal, omittable, omittableBool, omittableList, omittableNum, optionalIgnored, subtype, subtype2, toClassic, toClassicLoose, triple, updateable, withPresence, withPresenceList)

import IntDict exposing (IntDict)
import Json.Decode as ClassicDecode
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Decode.Extra as ClassicDecode2
import Json.Encode as Encode
import Maybe.Extra as Maybe
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment exposing (FuzzyMoment)
import SmartTime.Moment as Moment exposing (Moment)
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
encodeObjectWithoutNothings : List (Maybe EncodeField) -> Encode.Value
encodeObjectWithoutNothings =
    Encode.object << List.filterMap identity


{-| For optional field encoding. Pass in the usual String (field name ) & Encoder tuple, _except_ put a comma between the encoder function and the value to encode, making the whole thing a 3-tuple. That's it!

    So,
    `("widget", encodeWidget record.widget)`
    becomes:
    `omittable ("widget", encodeWidget, record.widget)`

    ..where record.widget is some `Maybe Widget` value, for example, and `encodeWidget` encodes `Widget` values (which are *not* wrapped in `Maybe`).

-}
omittable : ( String, a -> Encode.Value, Maybe a ) -> Maybe EncodeField
omittable ( name, encoder, fieldToCheck ) =
    Maybe.map (\field -> ( name, encoder field )) fieldToCheck


{-| For optional field encoding, when the field is a list. Wrapping an list in `Maybe` to make it "optional" is redundant when you can use an empty list instead of Nothing. If your list is empty, the field will be omitted from the encoded object!

Note: We already add an `Encode.list` for you, so leave that part out if you're going to use `omittableList` rather than `omittable`.

-}
omittableList : ( String, a -> Encode.Value, List a ) -> Maybe EncodeField
omittableList ( name, encoder, fieldToCheck ) =
    let
        listToCheck =
            Maybe.filter (not << List.isEmpty) (Just fieldToCheck)
    in
    Maybe.map (\field -> ( name, Encode.list encoder field )) listToCheck


{-| Encode a Bool only if it is true.
-}
omittableBool : ( String, Bool -> Encode.Value, Bool ) -> Maybe EncodeField
omittableBool ( name, encoder, fieldToCheck ) =
    if fieldToCheck then
        Just ( name, encoder fieldToCheck )

    else
        Nothing


{-| Encode an Int only if it is not zero.
-}
omittableNum : ( String, number -> Encode.Value, number ) -> Maybe EncodeField
omittableNum ( name, encoder, fieldToCheck ) =
    if fieldToCheck /= 0 then
        Just ( name, encoder fieldToCheck )

    else
        Nothing


{-| Stick this in front of normal field encoder tuples, when they're in an `encodeObjectWithoutNothings` list with some `omittable` encoder tuples.

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

    This is used for fields that may not be present (in which case the decode result is `Nothing`), such as those generated by the Encoder functions `encodeObjectWithoutNothings` and friends. This allows you to encode/decode "Nothing" as the absence of a field in JSON, rather than a field set to "null".

-}
withPresence : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
withPresence fieldName decoder =
    Pipeline.optional fieldName (Decode.map Just decoder) Nothing


{-| Use this function in Decoder Pipelines, in place of functions like Pipeline.optional or Pipeline.required, to decode object fields that are Lists (arrays). A nonempty list will be decoded as usual, and a missing field will be decoded as an empty list.

    See also "omittableList", which compliments this function.

-}
withPresenceList : String -> Decoder a -> Decoder (List a -> b) -> Decoder b
withPresenceList fieldName decoder =
    Pipeline.optional fieldName (Decode.list decoder) []


type alias BoolFromInt =
    Bool


decodeBoolFromInt : Decoder BoolFromInt
decodeBoolFromInt =
    oneOf
        [ check int 1 <| succeed True
        , check int 0 <| succeed False
        ]


encodeBoolToInt : BoolFromInt -> Encode.Value
encodeBoolToInt bool =
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


mapUpdateable : (a -> b) -> Updateable a -> Updateable b
mapUpdateable func up =
    case up of
        NoChange ->
            NoChange

        ChangedTo a ->
            ChangedTo (func a)


optionalIgnored : String -> Decoder a -> Decoder a
optionalIgnored field pipeline =
    Decode.oneOf
        [ Decode.field field Decode.value
        , Decode.succeed Encode.null
        ]
        |> Decode.andThen (\_ -> pipeline)



-- toClassic TODO: Switch to using Pipeline.resolve, ya dummy


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


toClassicLoose : Decoder a -> ClassicDecode.Decoder a
toClassicLoose decoder =
    let
        runRealDecoder value =
            decodeValue decoder value

        asResult value =
            case runRealDecoder value of
                BadJson ->
                    Err "Bad JSON"

                Errors errors ->
                    Err <| errorsToString errors

                WithWarnings _ result ->
                    Ok result

                Success result ->
                    Ok result

        final value =
            asResult value
    in
    ClassicDecode.value |> ClassicDecode.andThen (ClassicDecode2.fromResult << final)


encodeTuple2 : (a -> Encode.Value) -> (b -> Encode.Value) -> ( a, b ) -> Encode.Value
encodeTuple2 firstEncoder secondEncoder ( first, second ) =
    Encode.list identity [ firstEncoder first, secondEncoder second ]


decodeTuple2 : Decoder a -> Decoder b -> Decoder ( a, b )
decodeTuple2 decoderA decoderB =
    Decode.map2 Tuple.pair
        (Decode.index 0 decoderA)
        (Decode.index 1 decoderB)


encodeTuple3 : (a -> Encode.Value) -> (b -> Encode.Value) -> (c -> Encode.Value) -> ( a, b, c ) -> Encode.Value
encodeTuple3 firstEncoder secondEncoder thirdEncoder ( first, second, third ) =
    Encode.list identity [ firstEncoder first, secondEncoder second, thirdEncoder third ]


decodeTuple3 : Decoder a -> Decoder b -> Decoder c -> Decoder ( a, b, c )
decodeTuple3 decoderA decoderB decoderC =
    Decode.map3 triple
        (Decode.index 0 decoderA)
        (Decode.index 1 decoderB)
        (Decode.index 2 decoderC)


triple : a -> b -> c -> ( a, b, c )
triple a b c =
    ( a, b, c )


encodeIntDict : (valuetype -> Encode.Value) -> IntDict valuetype -> Encode.Value
encodeIntDict valueEncoder dict =
    Encode.list (encodeTuple2 Encode.int valueEncoder) (IntDict.toList dict)


decodeIntDict : Decoder valuetype -> Decoder (IntDict valuetype)
decodeIntDict valueDecoder =
    Decode.map IntDict.fromList <| Decode.list (decodeTuple2 Decode.int valueDecoder)


encodeDuration : Duration -> Encode.Value
encodeDuration dur =
    Encode.int (Duration.inMs dur)


decodeDuration : Decoder Duration
decodeDuration =
    Decode.map Duration.fromInt Decode.int


encodeMoment : Moment -> Encode.Value
encodeMoment dur =
    Encode.int (Moment.toSmartInt dur)


decodeMoment : Decoder Moment
decodeMoment =
    Decode.map Moment.fromSmartInt Decode.int


encodeUnixTimestamp : Moment -> Encode.Value
encodeUnixTimestamp dur =
    Encode.int (Moment.toElmInt dur)


decodeUnixTimestamp : Decoder Moment
decodeUnixTimestamp =
    Decode.map Moment.fromElmInt Decode.int


decodeFuzzyMoment : Decoder FuzzyMoment
decodeFuzzyMoment =
    customDecoder Decode.string SmartTime.Human.Moment.fuzzyFromString


encodeFuzzyMoment : FuzzyMoment -> Encode.Value
encodeFuzzyMoment fuzzy =
    Encode.string <| SmartTime.Human.Moment.fuzzyToString fuzzy
