module SmartTime.Human.Clock exposing (MeridiemBasedHour(..), TimeOfDay, backward, clock, compare, forward, hour, hourOf12, hourOf12Raw, hourOf12WithPMBool, hourToShortString, hourToString, isMidnight, isNoon, isPM, midnight, milliseconds, minute, noon, second, secondFractional, totalSeconds)

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


{-| Represent the positions of all the hands of a clock... with a single `Int`!
-}
totalSeconds : TimeOfDay -> Int
totalSeconds timeOfDay =
    Duration.inSecondsRounded timeOfDay



-- getTimeOfDay : Moment -> Zone -> TimeOfDay
-- getTimeOfDay moment zone =
-- let
--     civil =
--         toElmTime moment
--
--     hour =
--         toHour zone civil
--
--     postMeridiem =
--         hour > 12
--
--     hourOf12HrDay =
--         hour - 12
-- in
-- { hour =
--     if postMeridiem then
--         PM hourOf12HrDay
--
--     else
--         AM hour
-- , minute = toMinute zone civil
-- , second = toSecond zone civil
-- , ms = toMillis zone civil
-- , bareHour = hourOf12HrDay
-- , pm = postMeridiem
-- }


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
