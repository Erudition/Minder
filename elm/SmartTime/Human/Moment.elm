module SmartTime.Human.Moment exposing (DayPeriod(..), FormatStyle(..), Zone, clockTurnBack, clockTurnForward, dayPeriod, extractDate, extractTime, format, formatStyleFromLength, formatTimeOffset, fractionalDay, fromDateAndTime, fromDateAtMidnight, getMilliseconds, getOffsetMinutes, getSeconds, humanize, importElmMonth, localZone, localize, makeZone, ordinalSuffix, patternMatches, setDate, setTime, toFormattedString, toFormattedString_, toIsoString, toUtcFormattedString, toUtcIsoString, today, utc, withOrdinalSuffix)

{-| Human.Moment lets you safely comingle `Moment`s with their messy human counterparts: time zone, calendar date, and time-of-day.

The human version of a `Moment` could be a type called a `DateTime`, which would be a Date and Time combined in some way:

    type DateTime = (CalendarDate, TimeOfDay)

While you can define such a type if you really want to, this module **does not expose such a type**. Why? Because, as the `Time`-renovations of Elm 0.19 set out to encourage, you should **never store human time in your model**. Or in your database, for that matter. Human time is only for the _users_ to see and interact with -- i.e. your `view` function -- it's simply not good for machines to interact with, especially between different systems. It's just too messy! As you read the docs, you will learn why.

So, this library opts for a really great `Moment` type instead! It's pure and simple, you can move it around in a perfectly linear fashion, and not a single one of those helper functions requires you to lug a `Zone` around everywhere. Nice! Check it out in the `Moment` module.

Nevertheless, humans don't think in terms of `Moment`s, they like to push them around based on calendars and clocks. Unfortunately, they also prefer to forget that not only are these systems erratic, and subject to the whim of politicians, but they also apply only to their particular vertical slice of the globe. So, when requiring a `Zone` is unavoidable, the feature is included here, in the "human moment" library.

Are there exceptions? Yes! Like the special cases detailed in the `Clock` and `Calendar` modules, there can be a situation where it makes sense to handle human time alone, without any universal relevance or the context of a `Zone`. For example, for a "daily checklist" app it may make sense to store the due dates of tasks in human time:

    - [] Wake up (08:00)
    - [] Do Yoga (08:15)
    - [] Eat Breakfast (08:45)
    - ...
    - [] Eat Dinner (18:00)
    - [] Floss (22:00)
    - [] Go to bed (23:00)

Unlike meetings and appointments, these data really don't need to be in a fixed time zone. Sure you could store them all with respect to the zone they were created in. But what if the user crosses a few zones one day? Should they be expected to manually change all of their due-times? You could detect the zone change by comparing the current zone to the original, and compensating for the difference. But that means storing `Zones` with your data. **You should never need to do that!** So does this mean we resort to our `DateTime` type, then?

Nope! There is a better way! Check this out:

    type ScheduledMoment
        = Fixed Moment
        | Floating Moment

Then, when changing a fixed time, we do the usual: use the local zone to display the localized interface to the user, and then use the zone again to convert the given time back to Universal. But when reading the `Floating` moments, what if you skipped that first step? By short-cicuiting the zone-shifting, you effectively pretend that the UTC time is already local. So no matter where you are, that `Moment` still shows up as 9 o'clock! This clever trick allows us to once again avoid storing human time.

-}

import Regex exposing (Regex)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Moment as Moment exposing (ElmTime, Moment, commonEraStart)
import Task as Job
import Time as ElmTime
import Time.Extra exposing (Parts, partsToPosix, toOffset)


{-| -}
type alias Zone =
    -- can't use Elm zones because they're not exposed to us
    { defaultOffset : Duration
    , name : String
    , history : List ( Moment, Duration )
    }


utc : Zone
utc =
    { defaultOffset = Duration.fromMinutes 0, name = "Universal", history = [] }


{-| Get the `Zone` where the user is!
-}
localZone : Job.Task x Zone
localZone =
    Job.map3 makeZone ElmTime.getZoneName ElmTime.here ElmTime.now


makeZone : ElmTime.ZoneName -> ElmTime.Zone -> ElmTime -> Zone
makeZone elmZoneName elmZone now =
    case elmZoneName of
        ElmTime.Name zoneName ->
            { defaultOffset = Duration.fromMinutes (toFloat (getOffsetMinutes elmZone now))
            , name = zoneName
            , history = [] -- should be supported one day
            }

        ElmTime.Offset offsetMinutes ->
            { defaultOffset = Duration.fromMinutes (toFloat offsetMinutes)
            , name = "Unsupported"
            , history = []
            }


{-| Get just the date where the user is. Useful if you are working only with dates.
-}
today : Job.Task x CalendarDate
today =
    Job.map2 extractDate localZone Moment.now


{-| What is the offset from UTC, in minutes, for this `Zone` at this
`Posix` time?
import Time exposing (Month(..))
import Time.Extra exposing (Parts, partsToPosix, toOffset)
toOffset nyc
(partsToPosix nyc (Parts 2018 Sep 26 10 30 0 0))
== -240
-- assuming `nyc` is a `Zone` for America/New\_York
**Note:** It's possible to verify the example above by using time zone data
from the package [justinmimbs/timezone-data][tzdata] to define `nyc`:
import TimeZone
nyc =
TimeZone.america\__new_york ()
[tzdata]: <https://package.elm-lang.org/packages/justinmimbs/timezone-data/latest/>
-}
getOffsetMinutes : ElmTime.Zone -> ElmTime -> Int
getOffsetMinutes zone elmTime =
    let
        zonedDate =
            Calendar.fromRawParts (ElmTime.toYear zone elmTime) (importElmMonth (ElmTime.toMonth zone elmTime)) (ElmTime.toDay zone elmTime)

        zonedTime =
            Clock.clock (ElmTime.toHour zone elmTime) (ElmTime.toMinute zone elmTime) (ElmTime.toSecond zone elmTime) (ElmTime.toMillis zone elmTime)

        combinedMoment =
            fromDateAndTime zonedDate zonedTime

        localMillis =
            ElmTime.posixToMillis (Moment.toElmTime combinedMoment)

        utcMillis =
            ElmTime.posixToMillis elmTime
    in
    (localMillis - utcMillis) // 60000


importElmMonth : ElmTime.Month -> Calendar.Month
importElmMonth elmMonth =
    case elmMonth of
        ElmTime.Jan ->
            Calendar.Jan

        ElmTime.Feb ->
            Calendar.Feb

        ElmTime.Mar ->
            Calendar.Mar

        ElmTime.Apr ->
            Calendar.Apr

        ElmTime.May ->
            Calendar.May

        ElmTime.Jun ->
            Calendar.Jun

        ElmTime.Jul ->
            Calendar.Jul

        ElmTime.Aug ->
            Calendar.Aug

        ElmTime.Sep ->
            Calendar.Sep

        ElmTime.Oct ->
            Calendar.Oct

        ElmTime.Nov ->
            Calendar.Nov

        ElmTime.Dec ->
            Calendar.Dec



-- posixFromDateTime : Zone -> Date -> Int -> Posix
-- posixFromDateTime zone date time =
--     -- find the local offset
--     let
--         millis =
--             (date |> dateToMillis) + time
--
--         offset0 =
--             millis |> millisToPosix |> toOffset zone
--
--         posix1 =
--             (millis - offset0 * 60000) |> millisToPosix
--
--         offset1 =
--             posix1 |> toOffset zone
--     in
--     if offset0 == offset1 then
--         posix1
--
--     else
--         -- local offset has changed within `offset0` time period (e.g. DST switch)
--         let
--             posix2 =
--                 (millis - offset1 * 60000) |> millisToPosix
--
--             offset2 =
--                 posix2 |> toOffset zone
--         in
--         if offset1 == offset2 then
--             posix2
--
--         else
--             -- `millis` is within the lost hour of a local switch
--             posix1


{-| Create a `Date` from the following parts, given in local time:

  - year
  - month
  - day
  - hour
  - minute
  - second
  - millisecond

```
import Date exposing (Month(..))
import Date.Extra as Date
Date.fromParts 1999 Dec 31 23 59 59 999
-- <31 December 1999, 23:59:59.999, local time>
```

Out-of-range parts are clamped.
Date.fromParts 2001 Feb 29 24 60 60 1000
-- <28 February 2001, 23:59:59.999>

-}
fromDateAtMidnight : CalendarDate -> Zone -> Moment
fromDateAtMidnight calendarDate zone =
    Debug.todo "date with midnight"



-- --------------------------------------------------------------------------------
-- -- Parse ISO 8601
--
--
-- isoDateRegex : Regex
-- isoDateRegex =
--     let
--         year =
--             --yyyy
--             --1
--             "(\\d{4})"
--
--         cal =
--             --      mm            dd
--             --2     3             4
--             "(\\-)?(\\d{2})(?:\\2(\\d{2}))?"
--
--         week =
--             --       ww            d
--             --5      6             7
--             "(\\-)?W(\\d{2})(?:\\5(\\d))?"
--
--         ord =
--             --    ddd
--             --    8
--             "\\-?(\\d{3})"
--
--         time =
--             -- hh               mm             ss          .f              Z      +/-      hh             mm
--             -- 9          10    11             12          13              14     15       16             17
--             "T(\\d{2})(?:(\\:)?(\\d{2})(?:\\10(\\d{2}))?)?([\\.,]\\d+)?(?:(Z)|(?:([+−\\-])(\\d{2})(?:\\:?(\\d{2}))?))?"
--     in
--     Regex.fromString <| "^" ++ year ++ "(?:" ++ cal ++ "|" ++ week ++ "|" ++ ord ++ ")?" ++ "(?:" ++ time ++ ")?$"
--
--
-- matchToInt : Int -> Maybe String -> Int
-- matchToInt default =
--     Maybe.andThen (String.toInt >> Result.toMaybe) >> Maybe.withDefault default
--
--
-- dateFromMatches : String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Result String CalendarDate
-- dateFromMatches yyyy calMM calDD weekWW weekD ordDDD =
--     Result.map Moment.fromUnixTime
--         (let
--             y =
--                 yyyy |> String.toInt |> Result.withDefault 1
--          in
--          case ( calMM, weekWW ) of
--             ( Just _, Nothing ) ->
--                 Calendar.fromRawParts y (calMM |> matchToInt 1) (calDD |> matchToInt 1)
--
--             ( Nothing, Just _ ) ->
--                 Calendar.fromWeekParts y (weekWW |> matchToInt 1) (weekD |> matchToInt 1)
--
--             _ ->
--                 Calendar.fromOrdinalParts y (ordDDD |> matchToInt 1)
--         )
--
--
-- timeFromMatches : Maybe String -> Maybe String -> Maybe String -> Maybe String -> Result String Clock.TimeOfDay
-- timeFromMatches timeHH timeMM timeSS timeF =
--     let
--         fractional =
--             timeF |> Maybe.andThen (Regex.replace Regex.All (regex ",") (\_ -> ".") >> String.toFloat >> Result.toMaybe) |> Maybe.withDefault 0.0
--
--         ( hh, mm, ss ) =
--             case [ timeHH, timeMM, timeSS ] |> List.map (Maybe.andThen (String.toFloat >> Result.toMaybe)) of
--                 [ Just hh, Just mm, Just ss ] ->
--                     ( hh, mm, ss + fractional )
--
--                 [ Just hh, Just mm, Nothing ] ->
--                     ( hh, mm + fractional, 0.0 )
--
--                 [ Just hh, Nothing, Nothing ] ->
--                     ( hh + fractional, 0.0, 0.0 )
--
--                 _ ->
--                     ( 0.0, 0.0, 0.0 )
--     in
--     if hh >= 24 then
--         Err <| "Invalid time (hours = " ++ String.fromInt hh ++ ")"
--
--     else if mm >= 60 then
--         Err <| "Invalid time (minutes = " ++ String.fromInt mm ++ ")"
--
--     else if ss >= 60 then
--         Err <| "Invalid time (seconds = " ++ String.fromInt ss ++ ")"
--
--     else
--         Ok <| TimeMS (hh * toFloat msPerHour + mm * toFloat msPerMinute + ss * toFloat msPerSecond |> round)
--
--
-- offsetFromMatches : Maybe String -> Maybe String -> Maybe String -> Maybe String -> Result String OffsetSpec
-- offsetFromMatches tzZ tzSign tzHH tzMM =
--     case ( tzZ, tzSign ) of
--         ( Just "Z", Nothing ) ->
--             Ok utc
--
--         ( Nothing, Just sign ) ->
--             let
--                 hh =
--                     tzHH |> matchToInt 0
--
--                 mm =
--                     tzMM |> matchToInt 0
--             in
--             if hh > 23 then
--                 Err <| "Invalid offset (hours = " ++ String.fromInt hh ++ ")"
--
--             else if mm > 59 then
--                 Err <| "Invalid offset (minutes = " ++ String.fromInt mm ++ ")"
--
--             else if sign == "+" then
--                 Ok <| offset (hh * 60 + mm)
--
--             else
--                 Ok <| offset (hh * -60 - mm)
--
--         _ ->
--             Ok local
--
--
-- fromMatches : List (Maybe String) -> Result String Date
-- fromMatches matches =
--     case matches of
--         [ Just yyyy, _, calMM, calDD, _, weekWW, weekD, ordDDD, timeHH, _, timeMM, timeSS, timeF, tzZ, tzSign, tzHH, tzMM ] ->
--             Result.map3
--                 fromSpec
--                 (dateFromMatches yyyy calMM calDD weekWW weekD ordDDD)
--                 (timeFromMatches timeHH timeMM timeSS timeF)
--                 (offsetFromMatches tzZ tzSign tzHH tzMM)
--
--         _ ->
--             Err "Unexpected matches"
--
--
-- {-| Attempt to create a `Date` from a string representing a date/time in
-- [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.
-- Date.fromIsoString "2000-01-01T00:00:00.000Z"
-- -- Ok <1 January 2000, UTC>
-- Date.fromIsoString "2000-01-01"
-- -- Ok <1 January 2000, local time>
-- Date.fromIsoString "1/1/2000"
-- -- Err "Invalid ISO 8601 format"
-- The given string must represent a valid date/time; unlike the `fromParts`
-- constructor, any out-of-range parts will fail to produce a `Date`.
-- Date.fromIsoString "2001-02-29"
-- -- Err "Invalid calendar date"
-- When a `Date` is created with a specified time offset (e.g. `"-03:00"`), its
-- extractions still reflect the current machine's local time, and `Date.toTime`
-- still reflects its UTC time.
-- Date.fromIsoString "2000-01-01T20:00-03:00"
-- -- Ok <1 January 2000, 23:00, UTC>
-- -}
-- fromIsoString : String -> Result String Date
-- fromIsoString s =
--     Regex.find (AtMost 1) isoDateRegex s
--         |> List.head
--         |> Result.fromMaybe "Invalid ISO 8601 format"
--         |> Result.andThen (.submatches >> fromMatches)
--         |> Result.mapError ((++) ("Failed to create a Date from string '" ++ s ++ "': "))
--


type DayPeriod
    = Midnight
    | AM
    | Noon
    | PM


dayPeriod : Zone -> Moment -> DayPeriod
dayPeriod zone moment =
    let
        time =
            extractTime zone moment
    in
    if Clock.isMidnight time then
        Midnight

    else if not (Clock.isPM time) then
        AM

    else if Clock.isNoon time then
        Noon

    else
        PM


formatTimeOffset : String -> Bool -> Int -> String
formatTimeOffset separator minutesIsOptional givenOffset =
    let
        sign =
            if givenOffset >= 0 then
                "+"

            else
                "-"

        hh =
            abs givenOffset // 60 |> String.fromInt |> String.padLeft 2 '0'

        mm =
            abs (modBy 60 givenOffset) |> String.fromInt |> String.padLeft 2 '0'
    in
    if minutesIsOptional && mm == "00" then
        sign ++ hh

    else
        sign ++ hh ++ separator ++ mm


ordinalSuffix : Int -> String
ordinalSuffix n =
    let
        -- use 2-digit number
        nn =
            modBy 100 n
    in
    case
        min
            (if nn < 20 then
                nn

             else
                modBy 10 nn
            )
            4
    of
        1 ->
            "st"

        2 ->
            "nd"

        3 ->
            "rd"

        _ ->
            "th"


withOrdinalSuffix : Int -> String
withOrdinalSuffix n =
    String.fromInt n ++ ordinalSuffix n



-- Formatting is based on Date Format Patterns in Unicode Technical Standard #35


{-| Matches a series of pattern characters, or a single-quoted string (which
may contain '' inside, representing an escaped single-quote).
-}
patternMatches : Regex
patternMatches =
    Maybe.withDefault Regex.never (Regex.fromString "([yYQMwdDEeabhHmsSXx])\\1*|'(?:[^']|'')*?'(?!')")


type FormatStyle
    = Abbreviated
    | Full
    | Narrow
    | Short
    | Invalid


formatStyleFromLength : Int -> FormatStyle
formatStyleFromLength length =
    case length of
        1 ->
            Abbreviated

        2 ->
            Abbreviated

        3 ->
            Abbreviated

        4 ->
            Full

        5 ->
            Narrow

        6 ->
            Short

        _ ->
            Invalid


format : Bool -> Moment -> String -> String
format asUtc date match =
    -- let
    --     char =
    --         String.left 1 match
    --
    --     length =
    --         String.length match
    -- in
    -- case char of
    --     "y" ->
    --         case length of
    --             2 ->
    --                 date |> year |> String.fromInt |> String.padLeft length '0' |> String.right 2
    --
    --             _ ->
    --                 date |> year |> String.fromInt |> String.padLeft length '0'
    --
    --     "Y" ->
    --         case length of
    --             2 ->
    --                 date |> weekYear |> String.fromInt |> String.padLeft length '0' |> String.right 2
    --
    --             _ ->
    --                 date |> weekYear |> String.fromInt |> String.padLeft length '0'
    --
    --     "Q" ->
    --         case length of
    --             1 ->
    --                 date |> quarter |> String.fromInt
    --
    --             2 ->
    --                 date |> quarter |> String.fromInt
    --
    --             3 ->
    --                 date |> quarter |> String.fromInt |> (++) "Q"
    --
    --             4 ->
    --                 date |> quarter |> withOrdinalSuffix
    --
    --             5 ->
    --                 date |> quarter |> String.fromInt
    --
    --             _ ->
    --                 ""
    --
    --     "M" ->
    --         case length of
    --             1 ->
    --                 date |> monthNumber |> String.fromInt
    --
    --             2 ->
    --                 date |> monthNumber |> String.fromInt |> String.padLeft 2 '0'
    --
    --             3 ->
    --                 date |> month |> monthToName |> String.left 3
    --
    --             4 ->
    --                 date |> month |> monthToName
    --
    --             5 ->
    --                 date |> month |> monthToName |> String.left 1
    --
    --             _ ->
    --                 ""
    --
    --     "w" ->
    --         case length of
    --             1 ->
    --                 date |> weekNumber |> String.fromInt
    --
    --             2 ->
    --                 date |> weekNumber |> String.fromInt |> String.padLeft 2 '0'
    --
    --             _ ->
    --                 ""
    --
    --     "d" ->
    --         case length of
    --             1 ->
    --                 date |> day |> String.fromInt
    --
    --             2 ->
    --                 date |> day |> String.fromInt |> String.padLeft 2 '0'
    --
    --             3 ->
    --                 date |> day |> withOrdinalSuffix
    --
    --             -- non-standard
    --             _ ->
    --                 ""
    --
    --     "D" ->
    --         case length of
    --             1 ->
    --                 date |> ordinalDay |> String.fromInt
    --
    --             2 ->
    --                 date |> ordinalDay |> String.fromInt |> String.padLeft 2 '0'
    --
    --             3 ->
    --                 date |> ordinalDay |> String.fromInt |> String.padLeft 3 '0'
    --
    --             _ ->
    --                 ""
    --
    --     "E" ->
    --         case formatStyleFromLength length of
    --             Abbreviated ->
    --                 date |> dayOfWeek |> weekdayToName |> String.left 3
    --
    --             Full ->
    --                 date |> dayOfWeek |> weekdayToName
    --
    --             Narrow ->
    --                 date |> dayOfWeek |> weekdayToName |> String.left 1
    --
    --             Short ->
    --                 date |> dayOfWeek |> weekdayToName |> String.left 2
    --
    --             Invalid ->
    --                 ""
    --
    --     "e" ->
    --         case length of
    --             1 ->
    --                 date |> weekdayNumber |> String.fromInt
    --
    --             2 ->
    --                 date |> weekdayNumber |> String.fromInt
    --
    --             _ ->
    --                 format asUtc date (String.toUpper match)
    --
    --     "a" ->
    --         let
    --             p =
    --                 date |> dayPeriod
    --
    --             m =
    --                 if p == Midnight || p == AM then
    --                     "A"
    --
    --                 else
    --                     "P"
    --         in
    --         case formatStyleFromLength length of
    --             Abbreviated ->
    --                 m ++ "M"
    --
    --             Full ->
    --                 m ++ ".M."
    --
    --             Narrow ->
    --                 m
    --
    --             _ ->
    --                 ""
    --
    --     "b" ->
    --         case formatStyleFromLength length of
    --             Abbreviated ->
    --                 case date |> dayPeriod of
    --                     Midnight ->
    --                         "mid."
    --
    --                     AM ->
    --                         "am"
    --
    --                     Noon ->
    --                         "noon"
    --
    --                     PM ->
    --                         "pm"
    --
    --             Full ->
    --                 case date |> dayPeriod of
    --                     Midnight ->
    --                         "midnight"
    --
    --                     AM ->
    --                         "a.m."
    --
    --                     Noon ->
    --                         "noon"
    --
    --                     PM ->
    --                         "p.m."
    --
    --             Narrow ->
    --                 case date |> dayPeriod of
    --                     Midnight ->
    --                         "md"
    --
    --                     AM ->
    --                         "a"
    --
    --                     Noon ->
    --                         "nn"
    --
    --                     PM ->
    --                         "p"
    --
    --             _ ->
    --                 ""
    --
    --     "h" ->
    --         case length of
    --             1 ->
    --                 date |> hour12 |> String.fromInt
    --
    --             2 ->
    --                 date |> hour12 |> String.fromInt |> String.padLeft 2 '0'
    --
    --             _ ->
    --                 ""
    --
    --     "H" ->
    --         case length of
    --             1 ->
    --                 date |> hour |> String.fromInt
    --
    --             2 ->
    --                 date |> hour |> String.fromInt |> String.padLeft 2 '0'
    --
    --             _ ->
    --                 ""
    --
    --     "m" ->
    --         case length of
    --             1 ->
    --                 date |> minute |> String.fromInt
    --
    --             2 ->
    --                 date |> minute |> String.fromInt |> String.padLeft 2 '0'
    --
    --             _ ->
    --                 ""
    --
    --     "s" ->
    --         case length of
    --             1 ->
    --                 date |> second |> String.fromInt
    --
    --             2 ->
    --                 date |> second |> String.fromInt |> String.padLeft 2 '0'
    --
    --             _ ->
    --                 ""
    --
    --     "S" ->
    --         date |> millisecond |> String.fromInt |> String.padLeft 3 '0' |> String.left length |> String.padRight length '0'
    --
    --     "X" ->
    --         if length < 4 && (asUtc || offsetFromUtc date == 0) then
    --             "Z"
    --
    --         else
    --             format asUtc date (String.toLower match)
    --
    --     "x" ->
    --         let
    --             offset =
    --                 if asUtc then
    --                     0
    --
    --                 else
    --                     offsetFromUtc date
    --         in
    --         case length of
    --             1 ->
    --                 formatTimeOffset "" True offset
    --
    --             2 ->
    --                 formatTimeOffset "" False offset
    --
    --             3 ->
    --                 formatTimeOffset ":" False offset
    --
    --             _ ->
    --                 ""
    --
    --     "'" ->
    --         if match == "''" then
    --             "'"
    --
    --         else
    --             String.slice 1 -1 match |> Regex.replace All (regex "''") (\_ -> "'")
    --
    --     _ ->
    --         ""
    Debug.todo "format"


toFormattedString_ : Bool -> String -> Moment -> String
toFormattedString_ asUtc pattern moment =
    -- let
    --     date_ =
    --         if asUtc then
    --             extractDate zone <| thing
    --
    --         else
    --             Debug.todo "moment"
    --
    --     thing =
    --         -- was: Date.toTime moment - (offsetFromUtc date * msPerMinute |> toFloat)
    --         Debug.todo "fix this"
    -- in
    -- -- Regex.replace All patternMatches (.match >> format asUtc date_) pattern
    Debug.todo "format string"


{-| Convert a date to a string using a pattern as a template.
Date.toFormattedString
"EEEE, MMMM d, y 'at' h:mm a"
(Date.fromParts 2007 Mar 15 13 45 56 67)
-- "Thursday, March 15, 2007 at 1:45 PM"
Each alphabetic character in the pattern represents date or time information;
the number of times a character is repeated specifies the form of the name to
use (e.g. "Tue", "Tuesday") or the padding of numbers (e.g. "1", "01").
Formatting characters are escaped within single-quotes; a single-quote is
escaped as a sequence of two single-quotes, whether appearing inside or outside
an escaped sequence.
Patterns are based on Date Format Patterns in [Unicode Technical
Standard #35](http://www.unicode.org/reports/tr35/tr35-43/tr35-dates.html#Date_Format_Patterns).
Only the following subset of formatting characters are available:
"y" -- year
"Y" -- week-numbering year
"Q" -- quarter
"M" -- month
"w" -- week number
"d" -- day
"D" -- ordinal day
"E" -- day of week
"e" -- weekday number / day of week
"a" -- day period (AM, PM)
"b" -- day period (am, pm, noon, midnight)
"h" -- hour (12-hour clock)
"H" -- hour (24-hour clock)
"m" -- minute
"s" -- second
"S" -- fractional second
"X" -- time offset, using "Z" when offset is 0
"x" -- time offset
The non-standard pattern field "ddd" is available to indicate the day of the
month with an ordinal suffix (e.g. "1st", "15th"), as the current standard does
not include such a field.
Date.toFormattedString
"MMMM ddd, y"
(Date.fromParts 2007 Mar 15 13 45 56 67)
-- "March 15th, 2007"
-}
toFormattedString : String -> Moment -> String
toFormattedString =
    toFormattedString_ False


{-| Convert a date to a string just like `toFormattedString`, but using the UTC
representation instead of the local representation of the date.
-}
toUtcFormattedString : String -> Moment -> String
toUtcFormattedString =
    toFormattedString_ True


{-| Convenience function for formatting a date to ISO 8601 (extended
date and time format with local time offset).
Date.toIsoString
(Date.fromParts 2007 Mar 15 13 45 56 67)
-- "2007-03-15T13:45:56.067-04:00"
-- (example has a local offset of UTC-04:00)
-}
toIsoString : Moment -> String
toIsoString =
    toFormattedString_ False "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"


{-| Convenience function for formatting a date, in UTC representation, to ISO
8601 (extended date and time format with "Z" for time offset).
Date.toUtcIsoString
(Date.fromParts 2007 Mar 15 13 45 56 67)
-- "2007-03-15T17:45:56.067Z"
-- (example has a local offset of UTC-04:00)
-}
toUtcIsoString : Moment -> String
toUtcIsoString =
    toFormattedString_ True "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"



--- From DateTime


{-| Create a [CalendarDate](CalendarDate#CalendarDate) by combining a [Date](Calendar#Date) and [Time](Clock#Time).

    -- date == 26 Aug 2019
    -- time == 12:30:45.000

    fromDateAndTime date time
    -- CalendarDate { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 } } : CalendarDate

-}
fromDateAndTime : CalendarDate -> TimeOfDay -> Moment
fromDateAndTime date time =
    Debug.todo "from Date Time"



-- Accessors


{-| Extract the local date and time from a `Moment`.
Feel free to ditch the part you don't need:

    -- moment == 25 Dec 2019 16:45:30.000



    ( date, _ ) =
        humanize moment

    -- date == 25 Dec 2019 : CalendarDate

But if you really only need the Date or the Time, consider just using the `fromMoment` functions in `Clock` or `Calendar`, respectively.

-}
humanize : Zone -> Moment -> ( CalendarDate, TimeOfDay )
humanize zone moment =
    let
        localMomentDur =
            localize zone moment

        daysSinceEpoch =
            Duration.inWholeDays localMomentDur

        remaining =
            Duration.subtract localMomentDur (Duration.fromDays (toFloat daysSinceEpoch))
    in
    ( Calendar.fromRataDie daysSinceEpoch, remaining )


extractDate : Zone -> Moment -> CalendarDate
extractDate zone moment =
    Tuple.first (humanize zone moment)


extractTime : Zone -> Moment -> TimeOfDay
extractTime zone moment =
    Tuple.second (humanize zone moment)


localize : Zone -> Moment -> Duration
localize zone moment =
    let
        momentAsDur =
            Moment.toDuration moment Moment.TAI commonEraStart

        zoneOffset =
            -- TODO use `zone`
            0
    in
    Duration.add momentAsDur (Duration.fromMinutes zoneOffset)



-- NO ZONE REQUIRED


{-| Extract the `Second` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getSeconds dateTime -- 30 : Int

-}
getSeconds : Moment -> Int
getSeconds =
    Clock.second << extractTime utc


{-| Extract the `Millisecond` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMilliseconds dateTime -- 0 : Int

-}
getMilliseconds : Moment -> Int
getMilliseconds =
    Clock.milliseconds << extractTime utc



-- Setters


{-| Sets the `Date` part of a [DateTime#DateTime].

    -- date == 26 Aug 2019
    -- dateTime == 25 Dec 2019 16:45:30.000
    setDate date dateTime -- 26 Aug 2019 16:45:30.000

-}
setDate : CalendarDate -> Zone -> Moment -> Moment
setDate date zone moment =
    Debug.todo "setDate"


{-| Sets the `Time` part of a [DateTime#DateTime].

    -- dateTime == 25 Dec 2019 16:45:30.000
    setTime Clock.midnight dateTime -- 25 Dec 2019 00:00:00.000

-}
setTime : TimeOfDay -> Zone -> Moment -> Moment
setTime time zone moment =
    Debug.todo "setTime"


clockTurnBack : TimeOfDay -> Zone -> Moment -> Moment
clockTurnBack timeOfDay zone moment =
    let
        newMoment =
            setTime timeOfDay zone moment
    in
    if Moment.compare newMoment moment == Moment.Earlier then
        newMoment

    else
        -- if the new time is not earlier than the old one, force it to be
        Moment.past newMoment Duration.aDay


clockTurnForward : TimeOfDay -> Zone -> Moment -> Moment
clockTurnForward timeOfDay zone moment =
    let
        newMoment =
            setTime timeOfDay zone moment
    in
    if Moment.compare newMoment moment == Moment.Later then
        newMoment

    else
        -- if the new time is not later than the old one, force it to be
        Moment.future newMoment Duration.aDay



-- Utilities


{-| Extract the fractional day of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the float 0.4895833333333333.
-}
fractionalDay : CalendarDate -> Float
fractionalDay date =
    -- let
    --     timeOfDayMS =
    --         msFromTimeParts (hour date) (minute date) (second date) (millisecond date)
    -- in
    -- toFloat timeOfDayMS / toFloat msPerDay
    Debug.todo "fractionalDay"
