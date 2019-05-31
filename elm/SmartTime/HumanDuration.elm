module SmartTime.HumanDuration exposing (HumanDuration(..), breakdownDH, breakdownDHM, breakdownDHMS, breakdownDHMSM, breakdownHM, breakdownHMS, breakdownHMSM, breakdownMS, breakdownMSM, breakdownNonzero, breakdownSM, inLargestExactUnits, inLargestWholeUnits, sum, toDuration)

import SmartTime.Duration exposing (..)


{-| A `HumanDuration` is a plain-English value for units of duration.
-}
type HumanDuration
    = Milliseconds Int
    | Seconds Int
    | Minutes Int
    | Hours Int
    | Days Int -- only fixed amount if using TAI


{-| Make your own `Duration` constant the natural human way.

Typically you only need one unit (e.g. `Minutes 5`). If however you need a more compound duration like "1min 30s" and don't feel like writing `Seconds 90`, the builder function `sum` has got your back.

-}
toDuration : HumanDuration -> Duration
toDuration humanDuration =
    case humanDuration of
        Days days ->
            fromInt (days * 86400000)

        Hours hours ->
            fromInt (hours * 3600000)

        Minutes minutes ->
            fromInt (minutes * 60000)

        Seconds seconds ->
            fromInt (seconds * 1000)

        Milliseconds milliseconds ->
            fromInt milliseconds


{-| Make your own `Duration` constant by combining several units.

Typically you only need one unit (e.g. `Minutes 5`), in which case you can just use that instead! If however you need a more compound duration like "1min 30s" and don't feel like writing `Seconds 90`, this builder function has got your back.

Examples:
2hr 45min == `sum [Hours 2, Minutes 45]`
17min 30sec 450ms == `sum [Minutes 17, Seconds 1, Milliseconds 450]`
5d 45min == `sum [Days 5, Minutes 45]`

This robust function can handle nonstandard possibilities that this library will never output, such as duplicate units (combine them!), out-of-order entries (it's essentially a `Set`), and values that should have been grouped into larger units. However, if you're just trying to add two durations, just use `add`!

-}
sum : List HumanDuration -> Duration
sum list =
    fromInt <| List.sum (List.map normalize list)


{-| Break a duration down into a human-readable list of smaller time units, skipping unit groups with a value of zero.

This will always give the smallest correct list of time units, turning 5 days and 17 minutes into `[Days 5, Minutes 17]`. However, for displaying multiple durations to users, you may find it more natural and consistent to say "5 days, 0 hours and 17 minutes".

-}
breakdownNonzero : Duration -> List HumanDuration
breakdownNonzero duration =
    let
        { days, hours, minutes, seconds, milliseconds } =
            breakdown duration

        makeOptional ( tagger, amount ) =
            if amount > 0 then
                Just (tagger amount)

            else
                Nothing

        maybeList =
            List.map makeOptional
                [ ( Days, days )
                , ( Hours, hours )
                , ( Minutes, minutes )
                , ( Seconds, seconds )
                , ( Milliseconds, milliseconds )
                ]
    in
    List.filterMap identity maybeList


{-| Break a duration down into a human-readable list of smaller time units, the natural way.

For consistency, the list will start with the largest nonzero unit and extend all the way down to milliseconds. If you want to ignore all zero values instead (even when between two nonzero units), try `breakdownNonzero`.

Breaks a duration down into the list of whole units [ `Days`, `Hours`, `Minutes`, `Seconds`, `Milliseconds` ] for easy mapping.

-}
breakdownDHMSM : Duration -> List HumanDuration
breakdownDHMSM duration =
    let
        { days, hours, minutes, seconds, milliseconds } =
            breakdown duration
    in
    [ Days days, Hours hours, Minutes minutes, Seconds seconds, Milliseconds milliseconds ]


{-| Like the standard `breakdownDHMSM`, but stops short of providing a `Milliseconds` value. Typically, showing milliseconds is overkill, especially if it's part of a currently running clock.

If don't need seconds either, use `breakdownDHM`.

Breaks a duration down into the list of whole units [ `Days`, `Hours`, `Minutes`, `Seconds` ] for easy mapping.

-}
breakdownDHMS : Duration -> List HumanDuration
breakdownDHMS duration =
    let
        { days, hours, minutes, seconds } =
            breakdown duration
    in
    [ Days days, Hours hours, Minutes minutes, Seconds seconds ]


{-| Like the standard `breakdownDHMSM`, but stops short of providing a `Seconds` or a `Milliseconds` value. Typically, showing these is overkill, especially if it's part of a currently running clock.

To keep the seconds, use `breakdownDHMS`.

Breaks a duration down into the list of whole units [ `Days`, `Hours`, `Minutes` ] for easy mapping.

-}
breakdownDHM : Duration -> List HumanDuration
breakdownDHM duration =
    let
        { days, hours, minutes } =
            breakdown duration
    in
    [ Days days, Hours hours, Minutes minutes ]


{-| If `breakdownDHMS` and `breakdownDHM` don't go far enough for you, this function will chop off the minutes as well, leaving only `Hours` and `Days`.

This is included for completeness, but chances are you'd be better served by another helper instead, like `inWholeHours` or `breakdownDH`.

Break a duration down into the list of whole units [ `Days`, `Hours` ] for easy mapping.

-}
breakdownDH : Duration -> List HumanDuration
breakdownDH duration =
    let
        { days, hours } =
            breakdown duration
    in
    [ Days days, Hours hours ]


{-| Break a duration down into the list of whole units [ `Hours`, `Minutes`, `Seconds`, `Milliseconds` ] for easy mapping.
-}
breakdownHMSM : Duration -> List HumanDuration
breakdownHMSM duration =
    let
        { days, hours, minutes, seconds, milliseconds } =
            breakdown duration
    in
    [ Hours (inWholeHours duration), Minutes minutes, Seconds seconds, Milliseconds milliseconds ]


{-| Break a duration down into the list of whole units [ `Hours`, `Minutes`, `Seconds` ] for easy mapping.
-}
breakdownHMS : Duration -> List HumanDuration
breakdownHMS duration =
    let
        { minutes, seconds } =
            breakdown duration
    in
    [ Hours (inWholeHours duration), Minutes minutes, Seconds seconds ]


{-| Break a duration down into the list of whole units [`Hours`, `Minutes`] for easy mapping.
-}
breakdownHM : Duration -> List HumanDuration
breakdownHM duration =
    let
        { minutes } =
            breakdown duration
    in
    [ Hours (inWholeHours duration), Minutes minutes ]


{-| Break a duration down into the list of whole units [ `Minutes`, `Seconds`, `Milliseconds` ] for easy mapping.
-}
breakdownMSM : Duration -> List HumanDuration
breakdownMSM duration =
    let
        { seconds, milliseconds } =
            breakdown duration
    in
    [ Minutes (inWholeMinutes duration), Seconds seconds, Milliseconds milliseconds ]


{-| Break a duration down into the list of whole units [ `Minutes`, `Seconds` ] for easy mapping.
-}
breakdownMS : Duration -> List HumanDuration
breakdownMS duration =
    let
        { seconds } =
            breakdown duration
    in
    [ Minutes (inWholeMinutes duration), Seconds seconds ]


{-| Break a duration down into the list of whole units [ `Seconds`, `Milliseconds` ] for easy mapping.
-}
breakdownSM : Duration -> List HumanDuration
breakdownSM duration =
    let
        { milliseconds } =
            breakdown duration
    in
    [ Seconds (inWholeSeconds duration), Milliseconds milliseconds ]


{-| Used internally for dealing with `HumanDuration`s.
-}
normalize : HumanDuration -> Int
normalize human =
    inMs (toDuration human)



-- OUTPUT IN SINGLE TIME UNIT


{-| Express a time in terms of only one unit (the largest possible), ignoring all of the smaller units.

If an event's duration is around 4 days, for example, you probably don't care that it's actually 4 `Days`, 2 `Hours`, 30 `Minutes`, 0 `Seconds`, and 0 `Milliseconds`. This function will drop all of that and just give you `Days 4`.

On the other hand, for a film of duration 1 hour 59 minutes, you'd get `Hours 1`, which is not very accurate. So if you'd rather drop down to minutes in that case, use `inLargestExactUnits` instead.

-}
inLargestWholeUnits : Duration -> HumanDuration
inLargestWholeUnits duration =
    Maybe.withDefault (Milliseconds 0) <| List.head (breakdownDHMSM duration)


{-| Express a duration in terms of only one unit (the largest possible), while keeping exact precision.

If a film's duration is exactly 2 hours, for example, you probably don't care that it's actually 0 `Days`, 2 `Hours`, 0 `Minutes`, 0 `Seconds`, 0 `Milliseconds`. This function will drop all of that and just give you `Hours 2`.

On the other hand, for a film of duration of 1 hour 30 minutes, you'd get `Minutes 90`, because that's the biggest unit that we can use without losing information. If you would rather lose info and just capture the "essence" (largest chunks) of a duration, `inLargestWholeUnits` is what you're looking for!

-}
inLargestExactUnits : Duration -> HumanDuration
inLargestExactUnits duration =
    let
        partsSmallToBig =
            List.reverse (breakdownDHMSM duration)

        smallestPart =
            Maybe.withDefault (Milliseconds 0) (List.head partsSmallToBig)
    in
    case smallestPart of
        Days days ->
            -- no greater unit to absorb
            Days days

        Hours hours ->
            -- turns days into hours first
            Hours (inWholeHours duration)

        Minutes minutes ->
            -- and so on
            Minutes (inWholeMinutes duration)

        Seconds seconds ->
            Seconds (inWholeSeconds duration)

        Milliseconds milliseconds ->
            Milliseconds (inMs duration)
