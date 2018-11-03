module Model.Progress exposing (Part, Progress, Unit(..), decodeProgress, encodeProgress, getNormalizedPart, getPart, getUnits, getWhole, isDiscrete, progressFromFloat, unitMax)

import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)


type alias Progress =
    ( Part, Unit )


decodeProgress : Decode.Decoder Progress
decodeProgress =
    Decode.map progressFromFloat Decode.float


encodeProgress : Progress -> Encode.Value
encodeProgress progress =
    Encode.float (getPart progress)


type alias Part =
    Float


type Unit
    = None
    | Permille
    | Percent
    | Word Int
    | Minute Int
    | CustomUnit ( String, String ) Int


getPart : Progress -> Float
getPart ( part, _ ) =
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


getNormalizedPart : Progress -> Float
getNormalizedPart ( part, unit ) =
    part / toFloat (unitMax unit)


unitMax : Unit -> Int
unitMax unit =
    case unit of
        None ->
            1

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
    ( float, Percent )



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
