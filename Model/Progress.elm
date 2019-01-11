module Model.Progress exposing (Portion, Progress, Unit(..), decodeProgress, encodeProgress, getNormalizedPart, getPortion, getUnits, getWhole, isDiscrete, isMax, progressFromFloat, unitMax)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)


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
    = None
    | Permille
    | Percent
    | Word Int
    | Minute Int
    | CustomUnit ( String, String ) Int


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


getNormalizedPart : Progress -> Float
getNormalizedPart ( part, unit ) =
    toFloat part / toFloat (unitMax unit)


isMax : Progress -> Bool
isMax progress =
    getPortion progress == getWhole progress


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
    ( round float, Percent )



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
