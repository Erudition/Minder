module Model.Progress exposing (..)

type alias Progress = (Part, Unit)
type alias Part = Float
type Unit = None | Permille | Percent | Word Int | Minute Int | CustomUnit (String, String) Int


part : Progress -> Float
part (part, _) = part

whole : Progress -> Int
whole (_, unit) = max unit

units : Progress -> Unit
units (_, unit) = unit

discrete : Unit -> Bool
discrete _ = False

normalizedPart : Progress -> Float
normalizedPart (part, unit) = part / toFloat (max unit)

max : Unit -> Int
max unit = case unit of
    None -> 1
    Percent -> 100
    Permille -> 1000
    Word wordTarget -> wordTarget
    Minute minuteTarget -> minuteTarget
    CustomUnit (_,_) customTarget -> customTarget


progressFromFloat : Float -> Progress
progressFromFloat float = (float, Percent)


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
