module SmartTime.Duration exposing (Duration, DurationBreakdown, add, breakdown, combine, difference, fromDays, fromHours, fromInt, fromMinutes, fromSeconds, inDays, inDaysRounded, inHours, inHoursRounded, inMinutes, inMinutesRounded, inMs, inSeconds, inSecondsRounded, inWholeDays, inWholeHours, inWholeMinutes, inWholeSeconds, map, scale, subtract, zero)

{-| Library for working with time and time zones.


# Time

@docs Posix, now, every, posixToMillis, millisToPosix


# Time Zones

@docs Zone, utc, here


# Human Times

@docs toYear, toMonth, toDay, toWeekday, toHour, toMinute, toSecond, toMillis


# Weeks and Months

@docs Weekday, Month


# For Package Authors

@docs customZone, getZoneName, ZoneName

-}

-- Look, ma! No imports!


{-| A `Duration` is an exact amount of time. You can increase or decrease its length by adding other `Duration` values to it.
-}
type Duration
    = Duration Int


type alias DurationBreakdown =
    { days : Int
    , hours : Int
    , minutes : Int
    , seconds : Int
    , milliseconds : Int
    }


{-| Break a duration down into {days, hours, minutes, seconds, milliseconds}.
-}
breakdown : Duration -> DurationBreakdown
breakdown duration =
    let
        all =
            inMs duration

        days =
            all // 86400000

        withoutDays =
            all - (days * 86400000)

        hours =
            withoutDays // 3600000

        withoutHours =
            withoutDays - (hours * 3600000)

        minutes =
            withoutHours // 60000

        withoutMinutes =
            withoutHours - (minutes * 60000)

        seconds =
            withoutMinutes // 1000

        withoutSeconds =
            withoutMinutes - (seconds * 1000)
    in
    { days = days
    , hours = hours
    , minutes = minutes
    , seconds = seconds
    , milliseconds = withoutSeconds
    }


{-| Measure a given `Duration` in `Milliseconds`.
As this is the smallest unit of time measurable in Elm, these will always be whole units.
-}
inMs : Duration -> Int
inMs (Duration int) =
    int


{-| Note: Use the `Milliseconds` constructor function from `HumanDuration` for consistency and readability. This function is mainly for other libraries, like HumanDuration.

Creates a `Duration` straight from a raw number, which in elm is an integer of milliseconds.

-}
fromInt : Int -> Duration
fromInt int =
    Duration int



-- SECONDS


{-| Measure a given `Duration` in `Seconds`.

This includes values greater than 60, where for the user interface it may be more natural to express the duration with minutes as well as seconds (because "502 seconds" is hard to immediately interpret in minutes). If that's what you want, `breakdown` can do that for you.

Provides a decimal value for fractions of a second (1.5 sec = 1500 ms). For an integer value instead, `inWholeSeconds` (truncated) and `inSecondsRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inSeconds : Duration -> Float
inSeconds duration =
    toFloat (inMs duration) / 1000


{-| Measure a given `Duration` in whole `Seconds`.

As these are _whole_ seconds, anything less than a second is discarded (even 0.999 of a second), just like using `inSeconds` with `floor`. So if you just want the best approximation as an integer, use `inSecondsRounded` instead.

-}
inWholeSeconds : Duration -> Int
inWholeSeconds duration =
    inMs duration // 1000


{-| Approximate a given `Duration` in an integer number of `Seconds`.

This is more accurate than `inWholeSeconds` 50% of the time, but if displayed to the user (such as for a timer), it can be awkward to see e.g. "1 sec" displayed after only half a second has passed.

-}
inSecondsRounded : Duration -> Int
inSecondsRounded duration =
    round (toFloat (inMs duration) / 1000)



-- MINUTES


{-| Measure a given `Duration` in `Minutes`.

This includes values greater than 60, and even 120, where for the user interface it may be more natural to express the duration with hours and minutes (because "742 minutes long" is unintuitive). If that's what you want, `breakdown` can do that for you.

Provides a decimal value for fractions of a minute (1 min, 30 sec = 1.5 min). For an integer value instead, `inWholeMinutes` (truncated) and `inMinutesRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inMinutes : Duration -> Float
inMinutes duration =
    toFloat (inMs duration) / 60000


{-| Measure a given `Duration` in whole `Minutes`.

As these are _whole_ minutes, anything less than a minute is discarded (even 0.999 of a minute), just like using `inMinutes` with `floor`. So if you just want the best approximation as an integer, use `inMinutesRounded` instead.

-}
inWholeMinutes : Duration -> Int
inWholeMinutes duration =
    inMs duration // 60000


{-| Approximate a given `Duration` in an integer number of `Minutes`.

This is more accurate (by 1) than `inWholeMinutes` 50% of the time, but if displayed to the user (such as for a timer), it can be awkward to see e.g. "1 minute" displayed after only 30 seconds have passed.

-}
inMinutesRounded : Duration -> Int
inMinutesRounded duration =
    round (toFloat (inMs duration) / 60000)



-- HOURS


{-| Measure a given `Duration` in `Hours`.

Provides a decimal value for fractions of an hour (2 hr, 13 min = 2.216666667 hrs). For an integer value instead, `inWholeHours` (truncated) and `inHoursRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inHours : Duration -> Float
inHours duration =
    toFloat (inMs duration) / 3600000


{-| Measure a given `Duration` in whole `Hours`.

As these are _whole_ hours, anything less than an hour is discarded (even 0.999 of an hour), just like using `inHours` with `floor`. So if you just want the best approximation as an integer, use `inHoursRounded` instead.

-}
inWholeHours : Duration -> Int
inWholeHours duration =
    inMs duration // 3600000


{-| Approximate a given `Duration` in an integer number of `Hours`.

This is more accurate (by 1) than `inWholeHours` 50% of the time, but if displayed to the user (such as for a timer), it can be awkward to see e.g. "1 hour" displayed after only 30 minutes have passed.

-}
inHoursRounded : Duration -> Int
inHoursRounded duration =
    round (toFloat (inMs duration) / 3600000)



-- DAYS


{-| Measure a given `Duration` in `Days`.

Provides a decimal value for fractions of a day (12 hr = 0.5 days). For an integer value instead, `inWholeDays` (truncated) and `inDaysRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inDays : Duration -> Float
inDays duration =
    toFloat (inMs duration) / 86400000


{-| Measure a given `Duration` in whole `Days`.

As these are _whole_ Days, anything less than an hour is discarded (even 0.999 of a day), just like using `inDays` with `floor`. So if you just want the best approximation as an integer, use `inDaysRounded` instead.

-}
inWholeDays : Duration -> Int
inWholeDays duration =
    inMs duration // 86400000


{-| Approximate a given `Duration` in an integer number of `Days`.

This is more accurate (by 1) than `inWholeDays` 50% of the time, but if displayed to the user (such as for a timer), it can be awkward to see a greater number of days than the actual amount of midnights that have passed.

-}
inDaysRounded : Duration -> Int
inDaysRounded duration =
    round (toFloat (inMs duration) / 86400000)



-- BASIC ARITHMETIC


{-| Add two durations!
-}
add : Duration -> Duration -> Duration
add (Duration int1) (Duration int2) =
    Duration (int1 + int2)


{-| Subtract two durations. Does the same thing as negating the second one and adding them.

This is subtraction, so order matters. If you want to avoid negatives, use `difference` instead.

-}
subtract : Duration -> Duration -> Duration
subtract (Duration int1) (Duration int2) =
    Duration (int1 - int2)


{-| How different are these two durations?

Does the same thing as subtracting them and taking the absolute value.

-}
difference : Duration -> Duration -> Duration
difference (Duration int1) (Duration int2) =
    Duration <| abs (int1 - int2)


{-| Get the sum of a list of durations, as a final `Duration`.
-}
combine : List Duration -> Duration
combine durationList =
    List.foldl add (Duration 0) durationList


{-| Multiply a Duration by some factor, or take a portion of a duration.
Double a Duration: `scale duration 2`
Half a Duration: `scale duration (1/2)`
It doesn't matter what unit you're thinking in terms of, the output will always be correct.

As you can see, simply use a fraction (e.g. "(1/2)") to get a certain portion of the Duration. This eliminates the need for separate `multiply` and `divide` functions.

-}
scale : Duration -> Float -> Duration
scale (Duration dur) scalar =
    Duration <| round (toFloat dur * scalar)


{-| Map onto a duration any function that deals with `Int`s.
If for some reason the functions provided in this library aren't enough, this is your guy!
-}
map : (Int -> Int) -> Duration -> Duration
map func (Duration int) =
    Duration (func int)


{-| A zero-length duration.

Perhaps you want to use a function that demands a `Duration` on something that returns a `Maybe Duration` - this would be a good fallback to use with `Maybe.withDefault`.

-}
zero : Duration
zero =
    Duration 0



--  CONVERSIONS


{-| Create a duration from a custom floating-point number of milliseconds, with half-millisecond-accuracy.

Useful if you want your users to specify durations in terms of larger units that can have decimals, rather than smaller units or multiple sizes of units.

-}
fromMs : Float -> Duration
fromMs float =
    Duration (round float)


{-| Create a duration from a custom floating-point number of seconds, with half-millisecond-accuracy.

Useful if you want your users to specify durations in terms of larger units that can have decimals, rather than smaller units or multiple sizes of units.

-}
fromSeconds : Float -> Duration
fromSeconds float =
    Duration (round (float * 1000))


{-| Create a duration from a custom floating-point number of minutes, with half-millisecond-accuracy.

Useful if you want your users to specify durations in terms of larger units that can have decimals, rather than smaller units or multiple sizes of units.

-}
fromMinutes : Float -> Duration
fromMinutes float =
    Duration (round (float * 60000))


{-| Create a duration from a custom floating-point number of minutes, with half-millisecond-accuracy.

Useful if you want your users to specify durations in terms of larger units that can have decimals, rather than smaller units or multiple sizes of units.

For example, maybe you're dealing with the hours worked by employees. You want them to enter the number of hours only, but you want to allow fractions of an hour as well, like "8.5 hours" worked. This function will properly turn that into 8 hours and 30 minutes.

-}
fromHours : Float -> Duration
fromHours float =
    Duration (round (float * 3600000))


{-| Create a duration from a custom floating-point number of days, with half-millisecond-accuracy.

Useful if you want your users to specify durations in terms of larger units that can have decimals, rather than smaller units or multiple sizes of units.

-}
fromDays : Float -> Duration
fromDays float =
    Duration (round (float * 86400000))
