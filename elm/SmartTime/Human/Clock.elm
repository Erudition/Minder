module SmartTime.Human.Clock exposing (MeridiemBasedHour(..), TimeOfDay, asFractionOfDay, backward, clock, compare, forward, fromStandardString, hour, hourOf12, hourOf12Raw, hourOf12WithPMBool, hourToShortString, hourToString, isMidnight, isNoon, isPM, midnight, milliseconds, minute, msSinceMidnight, noon, parseHMS, second, secondFractional, secondsSinceMidnight, toStandardString)

import Parser exposing ((|.), (|=), Parser, chompWhile, getChompedString, spaces, symbol)
import ParserExtra as Parser
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), dur)
import SmartTime.Moment as Moment exposing (..)
import Task as Job
import Time as ElmTime exposing (toHour, toMillis, toMinute, toSecond)


type alias TimeOfDay =
    Duration



-- Create
-- unixTimeFromRataDie : RataDie -> Int
-- unixTimeFromRataDie rd =
--     (rd - 719163) * msPerDay
--     -- Duration.scale Duration.aDay days ?


{-| Specify a time of day.
-}
clock : Int -> Int -> Int -> Int -> TimeOfDay
clock hh mm ss ms =
    HumanDuration.build [ Hours hh, Minutes mm, Seconds ss, Milliseconds ms ]


parseHMS : Parser TimeOfDay
parseHMS =
    let
        secsFracToMs frac =
            round (frac * 1000)

        decimalOptional =
            -- Parser.float accepts numbers like ".123"
            Parser.oneOf [ Parser.float, Parser.succeed 0 ]
    in
    Parser.succeed clock
        |= Parser.backtrackable Parser.paddedInt
        -- hour
        |. symbol ":"
        |= Parser.paddedInt
        -- minute
        |. symbol ":"
        |= Parser.paddedInt
        -- second
        |= Parser.map secsFracToMs decimalOptional


fromStandardString : String -> Result String TimeOfDay
fromStandardString input =
    let
        parserResult =
            Parser.run parseHMS input

        stringErrorResult =
            Result.mapError Parser.realDeadEndsToString parserResult
    in
    stringErrorResult


{-| Represent the positions of all the hands of a clock... with a single `Int`!
Returns the clock time as the number of seconds into the day.
-}
secondsSinceMidnight : TimeOfDay -> Int
secondsSinceMidnight timeOfDay =
    Duration.inSecondsRounded timeOfDay


{-| Represent the time of day as a single `Int`! Returns the clock time as the number of milliseconds into the day.
This is a great way to `encode` your `TimeOfDay` values!
-}
msSinceMidnight : TimeOfDay -> Int
msSinceMidnight timeOfDay =
    Duration.inMs timeOfDay


asFractionOfDay : TimeOfDay -> Float
asFractionOfDay time =
    Duration.inDays time


toStandardString : TimeOfDay -> String
toStandardString timeOfDay =
    HumanDuration.colonSeparated (HumanDuration.breakdownHMSM timeOfDay)


isMidnight : TimeOfDay -> Bool
isMidnight givenTime =
    Duration.compare givenTime midnight == EQ


isNoon : TimeOfDay -> Bool
isNoon givenTime =
    Duration.compare givenTime noon == EQ


type MeridiemBasedHour
    = AM Int
    | PM Int


hourToString : MeridiemBasedHour -> String
hourToString meridiemBasedHour =
    case meridiemBasedHour of
        AM hr ->
            String.fromInt hr ++ " AM"

        PM hr ->
            String.fromInt hr ++ " PM"


hourToShortString : MeridiemBasedHour -> String
hourToShortString meridiemBasedHour =
    case meridiemBasedHour of
        AM hr ->
            String.fromInt hr ++ "a"

        PM hr ->
            String.fromInt hr ++ "p"


hourOf12 : TimeOfDay -> MeridiemBasedHour
hourOf12 time =
    if hour time > 12 then
        PM (hourOf12Raw time)

    else
        AM (hourOf12Raw time)


{-| `True` means `PM`.
-}
hourOf12WithPMBool : TimeOfDay -> ( Int, Bool )
hourOf12WithPMBool timeSinceDayStart =
    if hour timeSinceDayStart > 12 then
        -- PM
        ( hourOf12Raw timeSinceDayStart, True )

    else
        -- AM
        ( hourOf12Raw timeSinceDayStart, False )


{-| Use with `pm`.
-}
hourOf12Raw : TimeOfDay -> Int
hourOf12Raw timeSinceDayStart =
    case modBy 12 (hour timeSinceDayStart) of
        0 ->
            12

        otherHour ->
            otherHour


{-| Is it the afternoon?
-}
isPM : TimeOfDay -> Bool
isPM timeSinceDayStart =
    hour timeSinceDayStart > 12


hour : TimeOfDay -> Int
hour timeSinceDayStart =
    (Duration.breakdown timeSinceDayStart).hours


minute : TimeOfDay -> Int
minute timeSinceDayStart =
    (Duration.breakdown timeSinceDayStart).minutes


second : TimeOfDay -> Int
second timeSinceDayStart =
    (Duration.breakdown timeSinceDayStart).seconds


milliseconds : TimeOfDay -> Int
milliseconds timeSinceDayStart =
    (Duration.breakdown timeSinceDayStart).milliseconds


{-| More common to display than seconds:milliseconds.
-}
secondFractional : TimeOfDay -> Float
secondFractional timeSinceDayStart =
    let
        parts =
            Duration.breakdown timeSinceDayStart
    in
    toFloat parts.seconds + (toFloat parts.milliseconds / 1000)



-- Increment values


forward : TimeOfDay -> HumanDuration -> TimeOfDay
forward timeSinceDayStart amountToAdd =
    Duration.add (dur amountToAdd) timeSinceDayStart


backward : TimeOfDay -> HumanDuration -> TimeOfDay
backward timeSinceDayStart amountToAdd =
    Duration.subtract (dur amountToAdd) timeSinceDayStart



-- Compare values


{-| Compare two clocks.

    -- past   == 15:45:24.780
    -- future == 15:45:24.800
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : TimeOfDay -> TimeOfDay -> Order
compare lhs rhs =
    Duration.compare lhs rhs



-- Constants


{-| Returns midnight time.

    midnight == 00:00:00.000

-}
midnight : TimeOfDay
midnight =
    Duration.zero


noon : TimeOfDay
noon =
    Duration.fromHours 12
