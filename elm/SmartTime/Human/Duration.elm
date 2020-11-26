module SmartTime.Human.Duration exposing (HumanDuration(..), abbreviatedSpaced, abbreviatedWithCommas, breakdownDH, breakdownDHM, breakdownDHMS, breakdownDHMSM, breakdownHM, breakdownHMS, breakdownHMSM, breakdownMS, breakdownMSM, breakdownNonzero, breakdownSM, build, colonSeparated, dur, inLargestExactUnits, inLargestWholeUnits, justNumber, normalize, say, singleLetterSpaced, toDuration, trim, trimToLarge, trimToSmall, withAbbreviation, withDefault, withLetter)

import List.Extra as List
import SmartTime.Duration exposing (..)



{-
   CODE EXAMPLE of no longer needed (from Measure.elm):

   ```
       inHoursMinutes : Duration -> String
       inHoursMinutes duration =
           let
               durationInMs =
                   inMs duration

               hour =
                   3600000

               wholeHours =
                   durationInMs // hour

               wholeMinutes =
                   (durationInMs - (wholeHours * hour)) // 60000

               hoursString =
                   String.fromInt wholeHours ++ "h"

               minutesString =
                   String.fromInt wholeMinutes ++ "m"
           in
           case ( wholeHours, wholeMinutes ) of
               ( 0, 0 ) ->
                   minutesString

               ( _, 0 ) ->
                   hoursString

               ( 0, _ ) ->
                   minutesString

               ( _, _ ) ->
                   hoursString ++ " " ++ minutesString
   ```

-}


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
            scale aDay (toFloat days)

        Hours hours ->
            scale anHour (toFloat hours)

        Minutes minutes ->
            scale aMinute (toFloat minutes)

        Seconds seconds ->
            scale aSecond (toFloat seconds)

        Milliseconds milliseconds ->
            scale aMillisecond (toFloat milliseconds)


{-| Make your own `Duration` constant by combining several units.

Typically you only need one unit (e.g. `Minutes 5`), in which case you can just use that instead! If however you need a more compound duration like "1min 30s" and don't feel like writing `Seconds 90`, this builder function has got your back.

Examples:
2hr 45min == `sum [Hours 2, Minutes 45]`
17min 30sec 450ms == `sum [Minutes 17, Seconds 1, Milliseconds 450]`
5d 45min == `sum [Days 5, Minutes 45]`

This robust function can handle nonstandard possibilities that this library will never output, such as duplicate units (combine them!), out-of-order entries (it's essentially a `Set`), and values that should have been grouped into larger units. However, if you're just trying to add two durations, just use `add`!

-}
build : List HumanDuration -> Duration
build list =
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
    Maybe.withDefault (Milliseconds 0) <| List.head (breakdownNonzero duration)


{-| Express a duration in terms of only one unit (the largest possible), while keeping exact precision.

If a film's duration is exactly 2 hours, for example, you probably don't care that it's actually 0 `Days`, 2 `Hours`, 0 `Minutes`, 0 `Seconds`, 0 `Milliseconds`. This function will drop all of that and just give you `Hours 2`.

On the other hand, for a film of duration of 1 hour 30 minutes, you'd get `Minutes 90`, because that's the biggest unit that we can use without losing information. If you would rather lose info and just capture the "essence" (largest chunks) of a duration, `inLargestWholeUnits` is what you're looking for!

-}
inLargestExactUnits : Duration -> HumanDuration
inLargestExactUnits duration =
    let
        smallestPartMaybe =
            List.last (breakdownDHMSM duration)

        smallestPart =
            Maybe.withDefault (Milliseconds 0) smallestPartMaybe
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


{-| Trim the fat off a breakdown list, just like String.trim does with whitespace. Units with value 0 will be removed from the front and back of the list, but preserved if sandwiched between nonzero units.

Note: The `trim` function works like `String.trim`, which can trim the input down to nothing -- if your value is e.g. `[Days 0, Hours 0, Seconds 0]`, you'll get [], which may be formatted as an empty string. This could lead to broken UI text such as "You were in the call for ." if you do not check for it when formatting. This may be what you want, but if you'd rather fallback to a default unit, check out the variants `trimToSmall` and `trimToLarge`, or the `withDefault` function.

-}
trim : List HumanDuration -> List HumanDuration
trim humanDurationList =
    let
        isZero humanDuration =
            case humanDuration of
                -- Makes sure not to strip negative values
                Days 0 ->
                    True

                Hours 0 ->
                    True

                Minutes 0 ->
                    True

                Seconds 0 ->
                    True

                Milliseconds 0 ->
                    True

                _ ->
                    False
    in
    -- Feedback Wanted: This is clever and neat, but is it the most efficient?
    List.dropWhile isZero humanDurationList |> List.dropWhileRight isZero


{-| Like `trim`, but in case all units are zero, leaves the smallest unit in the list.

This answers the question of "which unit do I leave behind?" when you try to trim a list like `[Days 0, Hours 0, Seconds 0]` without leaving the list empty. With `trimToSmall` you'd get 0 seconds, with `trimToLarge` you'd get 0 days, and with `withDefault (Hours 0)` you'd get 0 hours.

Note: It's still possible to get an empty list, though, by supplying an empty list. To avoid this, see `withDefault`.

-}
trimToSmall : List HumanDuration -> List HumanDuration
trimToSmall humanDurationList =
    let
        trimmed =
            trim humanDurationList
    in
    if List.isEmpty trimmed then
        let
            smallestUnit =
                List.last humanDurationList

            singletonList =
                Maybe.map List.singleton smallestUnit
        in
        Maybe.withDefault [] singletonList

    else
        trimmed


{-| Like `trim`, but in case all units are zero, leaves the largest unit in the list.

This answers the question of "which unit do I leave behind?" when you try to trim a list like `[Days 0, Hours 0, Seconds 0]` without leaving the list empty. With `trimToLarge` you'd get 0 days, with `trimToSmall` you'd get 0 seconds, and with `withDefault (Hours 0)` you'd get 0 hours.

Note: It's still possible to get an empty list, though, by supplying an empty list. To avoid this, see `withDefault`.

-}
trimToLarge : List HumanDuration -> List HumanDuration
trimToLarge humanDurationList =
    let
        trimmed =
            trim humanDurationList
    in
    if List.isEmpty trimmed then
        let
            largestUnit =
                List.head humanDurationList

            singletonList =
                Maybe.map List.singleton largestUnit
        in
        Maybe.withDefault [] singletonList

    else
        trimmed


{-| Substitutes a default value in case a unit list is empty.

Note that most functions of this library cannot return empty lists.

-}
withDefault : HumanDuration -> List HumanDuration -> List HumanDuration
withDefault fallback humanDurationList =
    if List.isEmpty humanDurationList then
        [ fallback ]

    else
        humanDurationList



-- ENGLISH


{-| Render a HumanDuration list in english, in a compact single-letter, single-space form, like `5h 32m 15s`.

    Best used with hours/minutes or hours/minutes/seconds.

-}
singleLetterSpaced : List HumanDuration -> String
singleLetterSpaced humanDurationList =
    String.concat <| List.intersperse " " (List.map withLetter humanDurationList)


{-| Render a HumanDuration list in english, in a single-space form with abbreviated unit names, like `5hr 32min 15sec`.

    Best used with combinations including days, hours, minutes, and seconds.

-}
abbreviatedSpaced : List HumanDuration -> String
abbreviatedSpaced humanDurationList =
    String.concat <| List.intersperse " " (List.map withAbbreviation humanDurationList)


{-| Render a HumanDuration list in english, in a comma-separated form with abbreviated unit names, like `5hr, 32min, 15sec`.

    Best used with combinations including days, hours, minutes, and seconds.

-}
abbreviatedWithCommas : List HumanDuration -> String
abbreviatedWithCommas humanDurationList =
    String.concat <| List.intersperse ", " (List.map withAbbreviation humanDurationList)


{-| Render a HumanDuration list in a compact, standard colon-separated form, like `5:32:15`.

    Best used with hours/minutes or hours/minutes/seconds.

    Note that this function uses a period before Milliseconds, to remove ambiguity  (and because it's a more commonly accepted form). Effectively, this means the millisecond value is shown as the decimal part of the seconds value.

-}
colonSeparated : List HumanDuration -> String
colonSeparated breakdownList =
    let
        separate list =
            String.concat <| List.intersperse ":" (List.map justNumberPadded list)
    in
    case List.last breakdownList of
        Just (Milliseconds ms) ->
            let
                withoutLast =
                    Maybe.withDefault [] <| List.init breakdownList
            in
            separate withoutLast ++ "." ++ padNumber 3 (String.fromInt ms)

        _ ->
            separate breakdownList



-- PER-UNIT FUNCTIONS


{-| -}
justNumber : HumanDuration -> String
justNumber unit =
    case unit of
        Milliseconds int ->
            String.fromInt int

        Seconds int ->
            String.fromInt int

        Minutes int ->
            String.fromInt int

        Hours int ->
            String.fromInt int

        Days int ->
            String.fromInt int


{-| -}
justNumberPadded : HumanDuration -> String
justNumberPadded unit =
    case unit of
        Milliseconds int ->
            padNumber 3 <| String.fromInt int

        Seconds int ->
            padNumber 2 <| String.fromInt int

        Minutes int ->
            padNumber 2 <| String.fromInt int

        Hours int ->
            padNumber 2 <| String.fromInt int

        Days int ->
            padNumber 2 <| String.fromInt int


padNumber : Int -> String -> String
padNumber targetLength numString =
    -- Is there a library function out there that does this already?
    let
        -- no numbers have less than one digit
        minLength =
            Basics.clamp 1 targetLength targetLength

        zerosToAdd =
            minLength - String.length numString
    in
    String.repeat zerosToAdd "0" ++ numString


{-| Render a single HumanDuration in english, for mapping onto a list of `HumanDuration` values (`singleLetterSpaced` does this for you!).

So `Minutes 5` becomes "5m", `Hours 3` becomes "3h", etcetera.

Conveniently, this form is also readable in Spanish and other languages as well!

Note that this function uses a two-letter abbreviation for Milliseconds, "ms", to remove ambiguity with minutes (and because it's a more commonly accepted form).

-}
withLetter : HumanDuration -> String
withLetter unit =
    case unit of
        Milliseconds int ->
            String.fromInt int ++ "ms"

        Seconds int ->
            String.fromInt int ++ "s"

        Minutes int ->
            String.fromInt int ++ "m"

        Hours int ->
            String.fromInt int ++ "h"

        Days int ->
            String.fromInt int ++ "d"


{-| Render a single HumanDuration in english, for mapping onto a list of `HumanDuration` values (`abbreviatedSpaced` does this for you!).

So `Minutes 5` becomes "5min", `Hours 3` becomes "3hr", etcetera.

Conveniently, this form is also readable in Spanish and other languages as well!

-}
withAbbreviation : HumanDuration -> String
withAbbreviation unit =
    case unit of
        Milliseconds int ->
            String.fromInt int ++ "ms"

        Seconds int ->
            String.fromInt int ++ "sec"

        Minutes int ->
            String.fromInt int ++ "min"

        Hours int ->
            String.fromInt int ++ "hr"

        Days int ->
            String.fromInt int ++ "d"



-- SHORTHAND ---------------------------------------------------------------NOTE


{-| Super-quick shorthand for `toDuration`, best when exposed. This is great while prototyping if you are building a lot of constants in your code.
-}
dur : HumanDuration -> Duration
dur =
    toDuration


{-| Super-quick shorthand for `toDuration << singleLetterSpaced`, best when exposed. This is great while prototyping if you are putting out a lot of text that involves HumanDurations.
-}
say : Duration -> String
say =
    breakdownNonzero >> abbreviatedSpaced
