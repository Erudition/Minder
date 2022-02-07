module SmartTime.Human.Clock exposing (MeridiemBasedHour(..), TimeOfDay, asFractionOfDay, backward, clock, compare, endOfDay, forward, fromStandardString, hour, hourOf12, hourOf12Raw, hourOf12WithPMBool, hourToShortString, hourToString, isMidnight, isNoon, isPM, lastMillisecond, lastSecond, midnight, milliseconds, minute, msSinceMidnight, noon, padInt, parseHMS, second, secondFractional, secondsSinceMidnight, startOfDay, toShortString, toStandardString, truncateMinute)

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
            -- Parser.float accepts numbers like ".123", we'll take that or nothing
            Parser.oneOf [ Parser.float, Parser.succeed 0 ]
    in
    Parser.succeed clock
        |= Parser.backtrackable Parser.possiblyPaddedInt
        -- ^hour
        |. symbol ":"
        |= Parser.strictLengthInt 2 2
        -- ^minute
        |. symbol ":"
        |= Parser.strictLengthInt 2 2
        -- ^second
        |= Parser.map secsFracToMs decimalOptional


parseHM : Parser TimeOfDay
parseHM =
    Parser.succeed clock
        |= Parser.backtrackable Parser.possiblyPaddedInt
        -- ^hour
        |. symbol ":"
        -- minute:
        |= Parser.strictLengthInt 2 2
        -- sec&ms:
        |= Parser.succeed 0
        |= Parser.succeed 0


fromStandardString : String -> Result String TimeOfDay
fromStandardString input =
    -- TODO rewrite for efficiency
    let
        parserHMSResult =
            Parser.run parseHMS input

        parserHMResult =
            Parser.run parseHM input

        bestResult =
            case parserHMSResult of
                Ok _ ->
                    parserHMSResult

                Err _ ->
                    parserHMResult
    in
    Result.mapError Parser.realDeadEndsToString bestResult


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


toShortString : TimeOfDay -> String
toShortString timeOfDay =
    HumanDuration.colonSeparated (HumanDuration.breakdownHM timeOfDay)


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
    if hour time >= 12 then
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


truncateMinute : TimeOfDay -> TimeOfDay
truncateMinute timeSinceDayStart =
    let
        oldTime =
            Duration.breakdown timeSinceDayStart
    in
    clock oldTime.hours oldTime.minutes 0 0


{-| Like `String.fromInt` but pads the integer with zeroes so that it always has two digits.
-}
padInt : Int -> String
padInt num =
    HumanDuration.padNumber 2 (String.fromInt num)



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


{-| The exact end of the day, equivalent to midnight of the next day. Often represented as the time 24:00.

Yes, this feature is supported! And no, the internal type is not complicated by this! Now you can compare moments to the end of the day without silly approximations like 23:59:59 and pretending the day is longer than it is.

Usage Note: Since this `TimeOfDay` is logically equivalent to 00:00 (when dates aren't involved), you can only achieve this `TimeOfDay` by explicitly setting it. You can't arrive at it with any arithmetic operations, it will just be interpreted as midnight.

Warning: Programs outside of this library are not so smart, and will probably interpret this as 00:00. That could mean a whole day of error, so if you need compatibility with some outside system, use the approximations like `lastMillisecond` instead!

-}
endOfDay : TimeOfDay
endOfDay =
    Duration.aDay


{-| The exact start of the day, equivalent to midnight. Often represented as the time 00:00.
-}
startOfDay : TimeOfDay
startOfDay =
    Duration.zero


{-| The last second of the day, just before midnight of the next day.

    endOfDay == 23:59:59.000

Useful as an approximation for `endOfDay`, for apps that work on the granularity of Seconds, and can't handle the double-representation of (00:00 == 24:00), but still want to compare times to the end of the day.

-}
lastSecond : TimeOfDay
lastSecond =
    Duration.subtract Duration.aDay (Duration.fromSeconds 1.0)


{-| The last millisecond of the day, just before midnight of the next day.

    endOfDay == 23:59:59.999

Useful as an approximation for `endOfDay`, for apps that can't handle the double-representation of (00:00 == 24:00) but still want to compare times to the end of the day.

-}
lastMillisecond : TimeOfDay
lastMillisecond =
    Duration.subtract Duration.aDay (Duration.fromMs 1)


noon : TimeOfDay
noon =
    Duration.fromHours 12
