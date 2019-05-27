module Time.Duration exposing (Duration(..), duration)

import Time exposing (..)
import Time.Extra exposing (..)



{- A `Duration` is an exact amount of time. You can increase or decrease its length by adding other `Duration` values to it. -}


type Duration
    = Zero
    | Milliseconds Int
    | Seconds Int
    | Minutes Int
    | Hours Int
    | Days Int -- only fixed amount if using TAI


{-| Make your own `Duration` constant by combining several units.

Typically you only need one unit (e.g. `Minutes 5`), in which case you can just use that instead! If however you need a more compound duration like "1min 30s" and don't feel like writing `Seconds 90`, this builder function has got your back.

Examples:
2hr 45min == `sum [Hours 1, Minutes 45]`
17min 30sec 450ms == `sum [Minutes 17, Seconds 1, Milliseconds 450]`
5d 45min == `sum [Days 5, Minutes 45]`

This robust function can handle nonstandard possibilities that this library will never output, such as empty lists (use `Zero` instead!), duplicate units (combine them!), out-of-order entries (it's essentially a `Set`), and values that should have been grouped into larger units. However, if you're just trying to add two durations, just use `add`!

-}
sum : List Duration -> Duration
sum list =
    Milliseconds <| List.sum (List.map inMs list)


{-| Break a duration down into a human-readable list of smaller time units, the natural way.

For consistency, the list will start with the largest nonzero unit and extend all the way down to milliseconds. If you want to ignore all zero values instead (even when between two nonzero units), try `breakdownNonzero`.

If you just don't need milliseconds, use `breakdownToSec`.

-}
breakdown : Duration -> List Duration
breakdown duration =
    let
        ( days, hours, minutes, seconds, milliseconds ) =
            breakdownDHMSM duration
    in
    if days > 0 then
        [ Days days, Hours hours, Minutes minutes, Seconds seconds, Milliseconds milliseconds ]

    else if hours > 0 then
        [ Hours hours, Minutes minutes, Seconds seconds, Milliseconds milliseconds ]

    else if minutes > 0 then
        [ Minutes minutes, Seconds seconds, Milliseconds milliseconds ]

    else if seconds > 0 then
        [ Seconds seconds, Milliseconds milliseconds ]

    else if milliseconds > 0 then
        [ Milliseconds milliseconds ]

    else
        [ Zero ]


{-| Break a duration down into (days, hours, minutes, seconds, milliseconds).
-}
breakdownDHMSM : Duration -> ( Int, Int, Int, Int, Int )
breakdownDHMSM duration =
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
            withoutHours - (minutes - 60000)

        seconds =
            withoutMinutes // 1000

        withoutSeconds =
            withoutMinutes - (seconds * 1000)
    in
    ( days, hours, minutes, seconds, withoutSeconds )


{-| Break a duration down into (days, hours, minutes, seconds).
-}
breakdownDHMS : Duration -> ( Int, Int, Int, Int )
breakdownDHMS duration =
    let
        ( days, hours, minutes, seconds, _ ) =
            breakdownDHMSM duration
    in
    ( days, hours, minutes, seconds )


{-| Break a duration down into (days, hours, minutes).
-}
breakdownDHM : Duration -> ( Int, Int, Int )
breakdownDHM duration =
    let
        ( days, hours, minutes, _, _ ) =
            breakdownDHMSM duration
    in
    ( days, hours, minutes )


{-| Break a duration down into (days, hours).
-}
breakdownDH : Duration -> ( Int, Int )
breakdownDH duration =
    let
        ( days, hours, _, _, _ ) =
            breakdownDHMSM duration
    in
    ( days, hours )


{-| Break a duration down into (hours, minutes, seconds, milliseconds).
-}
breakdownHMSM : Duration -> ( Int, Int, Int, Int )
breakdownHMSM duration =
    let
        ( _, _, minutes, seconds, milliseconds ) =
            breakdownDHMSM duration
    in
    ( inWholeHours duration, minutes, seconds, milliseconds )


{-| Break a duration down into (hours, minutes, seconds).
-}
breakdownHMS : Duration -> ( Int, Int, Int )
breakdownHMS duration =
    let
        ( _, _, minutes, seconds, _ ) =
            breakdownDHMSM duration
    in
    ( inWholeHours duration, minutes, seconds )


{-| Break a duration down into (hours, minutes).
-}
breakdownHM : Duration -> ( Int, Int )
breakdownHM duration =
    let
        ( _, _, minutes, _, _ ) =
            breakdownDHMSM duration
    in
    ( inWholeHours duration, minutes )


{-| Break a duration down into (minutes, seconds, milliseconds).
-}
breakdownMSM : Duration -> ( Int, Int, Int )
breakdownMSM duration =
    let
        ( _, _, _, seconds, milliseconds ) =
            breakdownDHMSM duration
    in
    ( inWholeMinutes duration, seconds, milliseconds )


{-| Break a duration down into (minutes, seconds).
-}
breakdownMS : Duration -> ( Int, Int )
breakdownMS duration =
    let
        ( _, _, _, seconds, _ ) =
            breakdownDHMSM duration
    in
    ( inWholeMinutes duration, seconds )


{-| Break a duration down into (seconds, milliseconds).
-}
breakdownSM : Duration -> ( Int, Int )
breakdownSM duration =
    let
        ( _, _, _, _, milliseconds ) =
            breakdownDHMSM duration
    in
    ( inWholeSeconds duration, milliseconds )


{-| Measure a given `Duration` in `Milliseconds`.
As this is the smallest unit of time measurable in Elm, these will always be whole units.
-}
inMs : Duration -> Int
inMs duration =
    case duration of
        Days days ->
            days * 86400000

        Hours hours ->
            hours * 3600000

        Minutes minutes ->
            minutes * 60000

        Seconds seconds ->
            seconds * 1000

        Milliseconds milliseconds ->
            milliseconds

        Zero ->
            0



-- SECONDS


{-| Measure a given `Duration` in `Seconds`.

This includes values greater than 60, where for the user interface it may be more natural to express the duration with minutes as well as seconds (because "502 seconds" is hard to immediately interpret in minutes). If that's what you want, `breakdown` can do that for you.

Provides a decimal value for fractions of a second (1.5 sec = 1500 ms). For an integer value instead, `inWholeSeconds` (truncated) and `inSecondsRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inSeconds : Duration -> Float
inSeconds duration =
    inMs duration / 1000


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
    round (inMs duration / 1000)



-- MINUTES


{-| Measure a given `Duration` in `Minutes`.

This includes values greater than 60, and even 120, where for the user interface it may be more natural to express the duration with hours and minutes (because "742 minutes long" is unintuitive). If that's what you want, `breakdown` can do that for you.

Provides a decimal value for fractions of a minute (1 min, 30 sec = 1.5 min). For an integer value instead, `inWholeMinutes` (truncated) and `inMinutesRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inMinutes : Duration -> Float
inMinutes duration =
    inMs duration / 60000


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
    round (inMs duration / 60000)



-- HOURS


{-| Measure a given `Duration` in `Hours`.

Provides a decimal value for fractions of an hour (2 hr, 13 min = 2.216666667 hrs). For an integer value instead, `inWholeHours` (truncated) and `inHoursRounded` (rounded) are provided to save time.

If you are displaying this value to the user, you may want to use it with `truncate` to make sure the decimal cannot be undesirably long.

-}
inHours : Duration -> Float
inHours duration =
    inMs duration / 3600000


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
    round (inMs duration / 3600000)



-- OUTPUT IN SINGLE TIME UNIT


{-| Express a time in terms of only one unit (the largest possible), ignoring all of the smaller units.

If an event's duration is around 4 days, for example, you probably don't care that it's actually 4 `Days`, 2 `Hours`, 30 `Minutes`, 0 `Seconds`, and 0 `Milliseconds`. This function will drop all of that and just give you `Days 4`.

On the other hand, for a film of duration 1 hour 59 minutes, you'd get `Hours 1`, which is not very accurate. So if you'd rather drop down to minutes in that case, use `inLargestExactUnits` instead.

-}
inLargestWholeUnits : Duration -> Duration
inLargestWholeUnits duration =
    Maybe.withDefault Zero <| List.head (breakdown duration)


{-| Express a duration in terms of only one unit (the largest possible), while keeping exact precision.

If a film's duration is exactly 2 hours, for example, you probably don't care that it's actually 0 `Days`, 2 `Hours`, 0 `Minutes`, 0 `Seconds`, 0 `Milliseconds`. This function will drop all of that and just give you `Hours 2`.

On the other hand, for a film of duration of 1 hour 30 minutes, you'd get `Minutes 90`, because that's the biggest unit that we can use without losing information. If you would rather lose info and just capture the "essence" (largest chunks) of a duration, `inLargestWholeUnits` is what you're looking for!

-}
inLargestExactUnits : Duration -> Duration
inLargestExactUnits duration =
    let
        partsSmallToBig =
            List.reverse (breakdown duration)

        smallestPart =
            Maybe.withDefault Zero (List.head partsSmallToBig)
    in
    case smallestPart of
        Zero ->
            Zero

        Days days ->
            -- no greater unit to absorb
            Days days

        Hours hours ->
            -- turns days into hours first
            inWholeHours duration

        Minutes minutes ->
            -- and so on
            inWholeMinutes duration

        Seconds seconds ->
            inWholeSeconds duration

        Milliseconds milliseconds ->
            inMs duration
