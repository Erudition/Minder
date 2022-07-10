module Task.Progress exposing (Portion, Progress, Unit(..), decodeProgress, decodeUnit, encodeProgress, encodeUnit, getNormalizedPortion, getPortion, getUnits, getWhole, isDiscrete, isMax, maximize, progressFromFloat, setPortion, toString, unitCodec, unitMax, zero)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Replicated.Codec as Codec exposing (Codec, fieldDict, coreRW, fieldList, fieldRW)


{-| Proper Fractions, but with named units
Portion = Part = Numerator
Unit = Whole = Denominator, wrapped with name
-}
type alias Progress =
    ( Portion, Unit )


{-| TODO Lossy! Encoding Units other than percent not implemented!
-}
decodeProgress : Decode.Decoder Progress
decodeProgress =
    Decode.map progressFromFloat Decode.float


encodeProgress : Progress -> Encode.Value
encodeProgress progress =
    Encode.int (getPortion progress)


type alias Portion =
    Int


type Unit
    = Percent
    | Permille
    | Word Int
    | Minute Int
    | CustomUnit ( String, String ) Int


unitCodec : Codec String Unit
unitCodec =
    Codec.customType
        (\percent permille word minute customUnit value ->
            case value of
                Percent ->
                    percent

                Permille ->
                    permille

                Word int ->
                    word int

                Minute int ->
                    minute int

                CustomUnit ( string1, string2 ) int ->
                    customUnit ( string1, string2 ) int
        )
        |> Codec.variant0 ( 1, "Percent" ) Percent
        |> Codec.variant0 ( 2, "Permille" ) Permille
        |> Codec.variant1 ( 3, "Word" ) Word Codec.int
        |> Codec.variant1 ( 3, "Minute" ) Minute Codec.int
        |> Codec.variant2 ( 3, "CustomUnit" ) CustomUnit (Codec.tuple Codec.string Codec.string) Codec.int
        |> Codec.finishCustomType


toString : Progress -> String
toString ( portion, unit ) =
    case unit of
        Percent ->
            String.fromInt portion ++ "%"

        Permille ->
            String.fromInt portion ++ "‰"

        Word target ->
            String.fromInt portion ++ " of " ++ String.fromInt target ++ " words"

        Minute target ->
            String.fromInt portion ++ "/" ++ String.fromInt target ++ "min"

        CustomUnit ( thing, things ) target ->
            String.fromInt portion
                ++ " of "
                ++ String.fromInt target
                ++ (if target > 1 then
                        things

                    else
                        thing
                   )


decodeUnit : Decoder Unit
decodeUnit =
    -- TODO
    Decode.oneOf
        [ Decode.check Decode.string "Percent" <| Decode.succeed Percent
        , Decode.check Decode.string "Permille" <| Decode.succeed Permille

        -- TODO there's more possibilities
        ]


encodeUnit : Unit -> Encode.Value
encodeUnit unit =
    case unit of
        Permille ->
            Encode.string "Permille"

        Percent ->
            Encode.string "Percent"

        Word targetWordCount ->
            Encode.int targetWordCount

        Minute targetTotalMinutes ->
            Encode.int targetTotalMinutes

        CustomUnit ( string1, string2 ) int ->
            Debug.todo "Encode CustomUnits"


setPortion : Progress -> Int -> Progress
setPortion ( part, unit ) newpart =
    ( newpart, unit )


getPortion : Progress -> Int
getPortion ( part, _ ) =
    part


getWhole : Progress -> Int
getWhole ( _, unit ) =
    unitMax unit


getUnits : Progress -> Unit
getUnits ( _, unit ) =
    unit


isDiscrete : Unit -> Bool
isDiscrete _ =
    False


getNormalizedPortion : Progress -> Float
getNormalizedPortion ( part, unit ) =
    toFloat part / toFloat (unitMax unit)


isMax : Progress -> Bool
isMax progress =
    getPortion progress == getWhole progress


maximize : Progress -> Progress
maximize ( _, unit ) =
    ( unitMax unit, unit )


unitMax : Unit -> Portion
unitMax unit =
    case unit of
        Percent ->
            100

        Permille ->
            1000

        Word wordTarget ->
            wordTarget

        Minute minuteTarget ->
            minuteTarget

        CustomUnit ( _, _ ) customTarget ->
            customTarget


progressFromFloat : Float -> Progress
progressFromFloat float =
    ( round float, Percent )


zero : Portion
zero =
    0



-- zeroPercent : ( Fraction, ProgressUnits )
-- zeroPercent = ( (0, 100) , PercentUnits )
--
-- progressToFloat : Progress -> Float
-- progressToFloat ((numerator,denominator), _) = (toFloat numerator) / (toFloat denominator)
--
--
-- setFractionTop : Fraction -> Int -> Fraction
-- setFractionTop (old_top, bottom) new_top = (new_top, bottom)
--
-- setFractionToOne : Fraction -> Fraction
-- setFractionToOne (top, bottom) = (bottom, bottom)
--
-- setProgressInt : Progress -> Int -> Progress
-- setProgressInt (fraction, units) new_numerator =
--     (setFractionTop fraction new_numerator, units)
--
-- setProgressMax : Progress -> Int -> Progress
-- setProgressMax (fraction, units) new_numerator =
--     (setFractionToOne fraction, units)
--
-- progressMax : Progress -> Int
-- progressMax ((_, denominator), _) =
--     denominator
--
-- progressNumerator : Progress -> Int
-- progressNumerator ((numerator, _), _) =
--     numerator
