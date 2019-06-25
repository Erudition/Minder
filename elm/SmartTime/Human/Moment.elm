module SmartTime.Human.Moment exposing (DateSpec(..), DateTime(..), DayPeriod(..), FormatStyle(..), InternalDateTime, Interval(..), OffsetSpec(..), TimeSpec(..), add, calendarDate, ceiling, clamp, compare, compareDates, compareTime, dateFromMatches, dayPeriod, daysSincePreviousWeekday, decrementDay, decrementHours, decrementMilliseconds, decrementMinutes, decrementMonth, decrementSeconds, decrementYear, diff, equal, equalBy, floor, format, formatStyleFromLength, formatTimeOffset, fractionalDay, fromCalendarDate, fromDateAndTime, fromIsoString, fromMatches, fromParts, fromPosix, fromRataDie, fromRawParts, fromSpec, fromUnixTime, fromZonedPosix, getDate, getDateRange, getDatesInMonth, getDay, getDayDiff, getHours, getMilliseconds, getMinutes, getMonth, getSeconds, getTime, getTimezoneOffset, getWeekday, getYear, hour12, incrementDay, incrementHours, incrementMilliseconds, incrementMinutes, incrementMonth, incrementSeconds, incrementYear, isBetween, isLeapYear, isoDateRegex, local, matchToInt, midnight, monthNumber, monthToName, monthToQuarter, msFromTimeParts, offset, offsetFromMatches, offsetFromUtc, ordinalDate, ordinalDay, ordinalSuffix, patternMatches, quarter, quarterToMonth, range, rangeHelp, rollDayBackwards, rollDayForward, setDate, setDay, setHours, setMilliseconds, setMinutes, setMonth, setSeconds, setTime, setYear, sort, time, timeFromMatches, toFormattedString, toFormattedString_, toIsoString, toMillis, toMonths, toPosix, toRataDie, toUtcFormattedString, toUtcIsoString, unixTimeFromRataDie, utc, weekDate, weekNumber, weekYear, weekdayNumber, weekdayToName, withOrdinalSuffix)

import Regex exposing (HowMany(All, AtMost), Regex, regex)
import SmartTime.Duration
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (Clock)


humanize : Moment -> Zone -> ( CalendarDate, Clock )



-- Create


unixTimeFromRataDie : RataDie -> Int
unixTimeFromRataDie rd =
    (rd - 719163) * msPerDay


msFromTimeParts : Int -> Int -> Int -> Int -> Int
msFromTimeParts hh mm ss ms =
    msPerHour * hh + msPerMinute * mm + msPerSecond * ss + ms


{-| Represents a day.
-}
type DateSpec
    = DateMS Int


{-| Create a `DateSpec` from calendar-date parts (year, month, day).
-}
calendarDate : Int -> Month -> Int -> DateSpec
calendarDate y m d =
    DateMS <| unixTimeFromRataDie (RataDie.fromCalendarDate y m d)


{-| Create a `DateSpec` from ordinal-date parts (year, ordinalDay).
-}
ordinalDate : Int -> Int -> DateSpec
ordinalDate y od =
    DateMS <| unixTimeFromRataDie (RataDie.fromOrdinalDate y od)


{-| Create a `DateSpec` from week-date parts (weekYear, weekNumber, weekday).
-}
weekDate : Int -> Int -> Day -> DateSpec
weekDate wy wn wd =
    DateMS <| unixTimeFromRataDie (RataDie.fromWeekDate wy wn wd)


{-| Represents a time of day.
-}
type TimeSpec
    = TimeMS Int


{-| Convenience value for `time 0 0 0 0`.
-}
midnight : TimeSpec
midnight =
    TimeMS 0


{-| Create a `TimeSpec` from time parts (hour, minute, second, millisecond).
-}
time : Int -> Int -> Int -> Int -> TimeSpec
time hh mm ss ms =
    TimeMS <|
        msFromTimeParts
            (hh |> Basics.clamp 0 23)
            (mm |> Basics.clamp 0 59)
            (ss |> Basics.clamp 0 59)
            (ms |> Basics.clamp 0 999)


{-| Represents a time offset from UTC.
-}
type OffsetSpec
    = Offset Int
    | Local


{-| Use UTC (i.e. no offset).
-}
utc : OffsetSpec
utc =
    Offset 0


{-| Use a specific offset from UTC, given in minutes.
-}
offset : Int -> OffsetSpec
offset =
    Offset


{-| Use the local offset.
-}
local : OffsetSpec
local =
    Local


{-| Create a `Date` from a specified day, time of day, and time offset.
Date.fromSpec
(calendarDate 2000 Jan 1)
(time 20 0 0 0)
local
-- <1 January 2000, 20:00, local time>
Date.fromSpec
(weekDate 2009 1 Mon)
midnight
utc
-- <29 December 2008, UTC>
Date.fromSpec
(ordinalDate 2016 218)
(time 20 0 0 0)
(offset -180)
-- <5 August 2016, 23:00, UTC>
When a `Date` is created with a specified time offset (e.g. `offset -180`),
its extractions still reflect the current machine's local time, and
`Date.toTime` still reflects its UTC time.
-}
fromSpec : DateSpec -> TimeSpec -> OffsetSpec -> Date
fromSpec (DateMS dateMS) (TimeMS timeMS) offsetSpec =
    case offsetSpec of
        Offset offset ->
            fromUnixTime (dateMS + timeMS - offset * msPerMinute)

        Local ->
            -- find the local offset
            let
                unixTime =
                    dateMS + timeMS

                offset0 =
                    offsetFromUtc (fromUnixTime unixTime)

                date1 =
                    fromUnixTime (unixTime - offset0 * msPerMinute)

                offset1 =
                    offsetFromUtc date1
            in
            if offset0 == offset1 then
                date1

            else
                -- local offset has changed within `offset0` time period (e.g. DST switch)
                let
                    date2 =
                        fromUnixTime (unixTime - offset1 * msPerMinute)

                    offset2 =
                        offsetFromUtc date2
                in
                if offset1 == offset2 then
                    date2

                else
                    -- `unixTime` is within the lost hour of a local switch
                    date1


fromUnixTime : Int -> Date
fromUnixTime =
    toFloat >> fromTime


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
fromParts : Int -> Month -> Int -> Int -> Int -> Int -> Int -> Date
fromParts y m d hh mm ss ms =
    fromSpec (calendarDate y m d) (time hh mm ss ms) local


{-| Convenience function for creating a `Date` from only the year, month, and
day parts. As with `fromParts`, the day is clamped within the range of days in
the given month.
Date.fromCalendarDate 2001 Feb 29
-- <28 February 2001>
-}
fromCalendarDate : Int -> Month -> Int -> Date
fromCalendarDate y m d =
    fromSpec (calendarDate y m d) midnight local



--------------------------------------------------------------------------------
-- Parse ISO 8601


isoDateRegex : Regex
isoDateRegex =
    let
        year =
            --yyyy
            --1
            "(\\d{4})"

        cal =
            --      mm            dd
            --2     3             4
            "(\\-)?(\\d{2})(?:\\2(\\d{2}))?"

        week =
            --       ww            d
            --5      6             7
            "(\\-)?W(\\d{2})(?:\\5(\\d))?"

        ord =
            --    ddd
            --    8
            "\\-?(\\d{3})"

        time =
            -- hh               mm             ss          .f              Z      +/-      hh             mm
            -- 9          10    11             12          13              14     15       16             17
            "T(\\d{2})(?:(\\:)?(\\d{2})(?:\\10(\\d{2}))?)?([\\.,]\\d+)?(?:(Z)|(?:([+−\\-])(\\d{2})(?:\\:?(\\d{2}))?))?"
    in
    regex <| "^" ++ year ++ "(?:" ++ cal ++ "|" ++ week ++ "|" ++ ord ++ ")?" ++ "(?:" ++ time ++ ")?$"


matchToInt : Int -> Maybe String -> Int
matchToInt default =
    Maybe.andThen (String.toInt >> Result.toMaybe) >> Maybe.withDefault default


dateFromMatches : String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Maybe String -> Result String DateSpec
dateFromMatches yyyy calMM calDD weekWW weekD ordDDD =
    Result.map (DateMS << unixTimeFromRataDie)
        (let
            y =
                yyyy |> String.toInt |> Result.withDefault 1
         in
         case ( calMM, weekWW ) of
            ( Just _, Nothing ) ->
                RataDie.fromCalendarParts y (calMM |> matchToInt 1) (calDD |> matchToInt 1)

            ( Nothing, Just _ ) ->
                RataDie.fromWeekParts y (weekWW |> matchToInt 1) (weekD |> matchToInt 1)

            _ ->
                RataDie.fromOrdinalParts y (ordDDD |> matchToInt 1)
        )


timeFromMatches : Maybe String -> Maybe String -> Maybe String -> Maybe String -> Result String TimeSpec
timeFromMatches timeHH timeMM timeSS timeF =
    let
        fractional =
            timeF |> Maybe.andThen (Regex.replace All (regex ",") (\_ -> ".") >> String.toFloat >> Result.toMaybe) |> Maybe.withDefault 0.0

        ( hh, mm, ss ) =
            case [ timeHH, timeMM, timeSS ] |> List.map (Maybe.andThen (String.toFloat >> Result.toMaybe)) of
                [ Just hh, Just mm, Just ss ] ->
                    ( hh, mm, ss + fractional )

                [ Just hh, Just mm, Nothing ] ->
                    ( hh, mm + fractional, 0.0 )

                [ Just hh, Nothing, Nothing ] ->
                    ( hh + fractional, 0.0, 0.0 )

                _ ->
                    ( 0.0, 0.0, 0.0 )
    in
    if hh >= 24 then
        Err <| "Invalid time (hours = " ++ toString hh ++ ")"

    else if mm >= 60 then
        Err <| "Invalid time (minutes = " ++ toString mm ++ ")"

    else if ss >= 60 then
        Err <| "Invalid time (seconds = " ++ toString ss ++ ")"

    else
        Ok <| TimeMS (hh * toFloat msPerHour + mm * toFloat msPerMinute + ss * toFloat msPerSecond |> round)


offsetFromMatches : Maybe String -> Maybe String -> Maybe String -> Maybe String -> Result String OffsetSpec
offsetFromMatches tzZ tzSign tzHH tzMM =
    case ( tzZ, tzSign ) of
        ( Just "Z", Nothing ) ->
            Ok utc

        ( Nothing, Just sign ) ->
            let
                hh =
                    tzHH |> matchToInt 0

                mm =
                    tzMM |> matchToInt 0
            in
            if hh > 23 then
                Err <| "Invalid offset (hours = " ++ toString hh ++ ")"

            else if mm > 59 then
                Err <| "Invalid offset (minutes = " ++ toString mm ++ ")"

            else if sign == "+" then
                Ok <| offset (hh * 60 + mm)

            else
                Ok <| offset (hh * -60 - mm)

        _ ->
            Ok local


fromMatches : List (Maybe String) -> Result String Date
fromMatches matches =
    case matches of
        [ Just yyyy, _, calMM, calDD, _, weekWW, weekD, ordDDD, timeHH, _, timeMM, timeSS, timeF, tzZ, tzSign, tzHH, tzMM ] ->
            Result.map3
                fromSpec
                (dateFromMatches yyyy calMM calDD weekWW weekD ordDDD)
                (timeFromMatches timeHH timeMM timeSS timeF)
                (offsetFromMatches tzZ tzSign tzHH tzMM)

        _ ->
            Err "Unexpected matches"


{-| Attempt to create a `Date` from a string representing a date/time in
[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.
Date.fromIsoString "2000-01-01T00:00:00.000Z"
-- Ok <1 January 2000, UTC>
Date.fromIsoString "2000-01-01"
-- Ok <1 January 2000, local time>
Date.fromIsoString "1/1/2000"
-- Err "Invalid ISO 8601 format"
The given string must represent a valid date/time; unlike the `fromParts`
constructor, any out-of-range parts will fail to produce a `Date`.
Date.fromIsoString "2001-02-29"
-- Err "Invalid calendar date"
When a `Date` is created with a specified time offset (e.g. `"-03:00"`), its
extractions still reflect the current machine's local time, and `Date.toTime`
still reflects its UTC time.
Date.fromIsoString "2000-01-01T20:00-03:00"
-- Ok <1 January 2000, 23:00, UTC>
-}
fromIsoString : String -> Result String Date
fromIsoString s =
    Regex.find (AtMost 1) isoDateRegex s
        |> List.head
        |> Result.fromMaybe "Invalid ISO 8601 format"
        |> Result.andThen (.submatches >> fromMatches)
        |> Result.mapError ((++) ("Failed to create a Date from string '" ++ s ++ "': "))



--------------------------------------------------------------------------------
-- Extract


monthToQuarter : Month -> Int
monthToQuarter m =
    (monthToNumber m + 2) // 3


quarterToMonth : Int -> Month
quarterToMonth q =
    q * 3 - 2 |> numberToMonth


{-| Extract the month number of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 6.
-}
monthNumber : Date -> Int
monthNumber =
    month >> monthToNumber


{-| Extract the quarter of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 2.
-}
quarter : Date -> Int
quarter =
    month >> monthToQuarter


{-| Extract the ordinal day of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 174.
-}
ordinalDay : Date -> Int
ordinalDay date =
    daysBeforeMonth (year date) (month date) + day date


{-| Extract the fractional day of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the float 0.4895833333333333.
-}
fractionalDay : Date -> Float
fractionalDay date =
    let
        timeOfDayMS =
            msFromTimeParts (hour date) (minute date) (second date) (millisecond date)
    in
    toFloat timeOfDayMS / toFloat msPerDay


{-| Extract the weekday number (beginning at 1 for Monday) of a date. Given
the date 23 June 1990 at 11:45 a.m. this returns the integer 6.
-}
weekdayNumber : Date -> Int
weekdayNumber =
    dayOfWeek >> weekdayToNumber


{-| Extract the week number of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 25.
-}
weekNumber : Date -> Int
weekNumber =
    toRataDie >> RataDie.weekNumber


{-| Extract the week-numbering year of a date. Given the date 23 June
1990 at 11:45 a.m. this returns the integer 1990.
-}
weekYear : Date -> Int
weekYear =
    toRataDie >> RataDie.weekYear


{-| Extract the local offset from UTC time, in minutes, of a date. Given a date
with a local offset of UTC-05:00 this returns the integer -300.
-}
offsetFromUtc : Date -> Int
offsetFromUtc date =
    let
        localTime =
            unixTimeFromRataDie (RataDie.fromCalendarDate (year date) (month date) (day date))
                + msFromTimeParts (hour date) (minute date) (second date) (millisecond date)
                |> toFloat

        utcTime =
            date |> toTime
    in
    Basics.floor (localTime - utcTime) // msPerMinute



--------------------------------------------------------------------------------
-- Format


monthToName : Month -> String
monthToName m =
    case m of
        Jan ->
            "January"

        Feb ->
            "February"

        Mar ->
            "March"

        Apr ->
            "April"

        May ->
            "May"

        Jun ->
            "June"

        Jul ->
            "July"

        Aug ->
            "August"

        Sep ->
            "September"

        Oct ->
            "October"

        Nov ->
            "November"

        Dec ->
            "December"


weekdayToName : Day -> String
weekdayToName d =
    case d of
        Mon ->
            "Monday"

        Tue ->
            "Tuesday"

        Wed ->
            "Wednesday"

        Thu ->
            "Thursday"

        Fri ->
            "Friday"

        Sat ->
            "Saturday"

        Sun ->
            "Sunday"


hour12 : Date -> Int
hour12 date =
    case hour date % 12 of
        0 ->
            12

        h ->
            h


type DayPeriod
    = Midnight
    | AM
    | Noon
    | PM


dayPeriod : Date -> DayPeriod
dayPeriod date =
    let
        hh =
            hour date

        onTheHour =
            minute date == 0 && second date == 0 && millisecond date == 0
    in
    if hh == 0 && onTheHour then
        Midnight

    else if hh < 12 then
        AM

    else if hh == 12 && onTheHour then
        Noon

    else
        PM


formatTimeOffset : String -> Bool -> Int -> String
formatTimeOffset separator minutesIsOptional offset =
    let
        sign =
            if offset >= 0 then
                "+"

            else
                "-"

        hh =
            abs offset // 60 |> toString |> String.padLeft 2 '0'

        mm =
            abs offset % 60 |> toString |> String.padLeft 2 '0'
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
            n % 100
    in
    case
        min
            (if nn < 20 then
                nn

             else
                nn % 10
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
    toString n ++ ordinalSuffix n



-- Formatting is based on Date Format Patterns in Unicode Technical Standard #35


{-| Matches a series of pattern characters, or a single-quoted string (which
may contain '' inside, representing an escaped single-quote).
-}
patternMatches : Regex
patternMatches =
    regex "([yYQMwdDEeabhHmsSXx])\\1*|'(?:[^']|'')*?'(?!')"


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


format : Bool -> Date -> String -> String
format asUtc date match =
    let
        char =
            String.left 1 match

        length =
            String.length match
    in
    case char of
        "y" ->
            case length of
                2 ->
                    date |> year |> toString |> String.padLeft length '0' |> String.right 2

                _ ->
                    date |> year |> toString |> String.padLeft length '0'

        "Y" ->
            case length of
                2 ->
                    date |> weekYear |> toString |> String.padLeft length '0' |> String.right 2

                _ ->
                    date |> weekYear |> toString |> String.padLeft length '0'

        "Q" ->
            case length of
                1 ->
                    date |> quarter |> toString

                2 ->
                    date |> quarter |> toString

                3 ->
                    date |> quarter |> toString |> (++) "Q"

                4 ->
                    date |> quarter |> withOrdinalSuffix

                5 ->
                    date |> quarter |> toString

                _ ->
                    ""

        "M" ->
            case length of
                1 ->
                    date |> monthNumber |> toString

                2 ->
                    date |> monthNumber |> toString |> String.padLeft 2 '0'

                3 ->
                    date |> month |> monthToName |> String.left 3

                4 ->
                    date |> month |> monthToName

                5 ->
                    date |> month |> monthToName |> String.left 1

                _ ->
                    ""

        "w" ->
            case length of
                1 ->
                    date |> weekNumber |> toString

                2 ->
                    date |> weekNumber |> toString |> String.padLeft 2 '0'

                _ ->
                    ""

        "d" ->
            case length of
                1 ->
                    date |> day |> toString

                2 ->
                    date |> day |> toString |> String.padLeft 2 '0'

                3 ->
                    date |> day |> withOrdinalSuffix

                -- non-standard
                _ ->
                    ""

        "D" ->
            case length of
                1 ->
                    date |> ordinalDay |> toString

                2 ->
                    date |> ordinalDay |> toString |> String.padLeft 2 '0'

                3 ->
                    date |> ordinalDay |> toString |> String.padLeft 3 '0'

                _ ->
                    ""

        "E" ->
            case formatStyleFromLength length of
                Abbreviated ->
                    date |> dayOfWeek |> weekdayToName |> String.left 3

                Full ->
                    date |> dayOfWeek |> weekdayToName

                Narrow ->
                    date |> dayOfWeek |> weekdayToName |> String.left 1

                Short ->
                    date |> dayOfWeek |> weekdayToName |> String.left 2

                Invalid ->
                    ""

        "e" ->
            case length of
                1 ->
                    date |> weekdayNumber |> toString

                2 ->
                    date |> weekdayNumber |> toString

                _ ->
                    format asUtc date (String.toUpper match)

        "a" ->
            let
                p =
                    date |> dayPeriod

                m =
                    if p == Midnight || p == AM then
                        "A"

                    else
                        "P"
            in
            case formatStyleFromLength length of
                Abbreviated ->
                    m ++ "M"

                Full ->
                    m ++ ".M."

                Narrow ->
                    m

                _ ->
                    ""

        "b" ->
            case formatStyleFromLength length of
                Abbreviated ->
                    case date |> dayPeriod of
                        Midnight ->
                            "mid."

                        AM ->
                            "am"

                        Noon ->
                            "noon"

                        PM ->
                            "pm"

                Full ->
                    case date |> dayPeriod of
                        Midnight ->
                            "midnight"

                        AM ->
                            "a.m."

                        Noon ->
                            "noon"

                        PM ->
                            "p.m."

                Narrow ->
                    case date |> dayPeriod of
                        Midnight ->
                            "md"

                        AM ->
                            "a"

                        Noon ->
                            "nn"

                        PM ->
                            "p"

                _ ->
                    ""

        "h" ->
            case length of
                1 ->
                    date |> hour12 |> toString

                2 ->
                    date |> hour12 |> toString |> String.padLeft 2 '0'

                _ ->
                    ""

        "H" ->
            case length of
                1 ->
                    date |> hour |> toString

                2 ->
                    date |> hour |> toString |> String.padLeft 2 '0'

                _ ->
                    ""

        "m" ->
            case length of
                1 ->
                    date |> minute |> toString

                2 ->
                    date |> minute |> toString |> String.padLeft 2 '0'

                _ ->
                    ""

        "s" ->
            case length of
                1 ->
                    date |> second |> toString

                2 ->
                    date |> second |> toString |> String.padLeft 2 '0'

                _ ->
                    ""

        "S" ->
            date |> millisecond |> toString |> String.padLeft 3 '0' |> String.left length |> String.padRight length '0'

        "X" ->
            if length < 4 && (asUtc || offsetFromUtc date == 0) then
                "Z"

            else
                format asUtc date (String.toLower match)

        "x" ->
            let
                offset =
                    if asUtc then
                        0

                    else
                        offsetFromUtc date
            in
            case length of
                1 ->
                    formatTimeOffset "" True offset

                2 ->
                    formatTimeOffset "" False offset

                3 ->
                    formatTimeOffset ":" False offset

                _ ->
                    ""

        "'" ->
            if match == "''" then
                "'"

            else
                String.slice 1 -1 match |> Regex.replace All (regex "''") (\_ -> "'")

        _ ->
            ""


toFormattedString_ : Bool -> String -> Date -> String
toFormattedString_ asUtc pattern date =
    let
        date_ =
            if asUtc then
                Date.fromTime <| Date.toTime date - (offsetFromUtc date * msPerMinute |> toFloat)

            else
                date
    in
    Regex.replace All patternMatches (.match >> format asUtc date_) pattern


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
toFormattedString : String -> Date -> String
toFormattedString =
    toFormattedString_ False


{-| Convert a date to a string just like `toFormattedString`, but using the UTC
representation instead of the local representation of the date.
-}
toUtcFormattedString : String -> Date -> String
toUtcFormattedString =
    toFormattedString_ True


{-| Convenience function for formatting a date to ISO 8601 (extended
date and time format with local time offset).
Date.toIsoString
(Date.fromParts 2007 Mar 15 13 45 56 67)
-- "2007-03-15T13:45:56.067-04:00"
-- (example has a local offset of UTC-04:00)
-}
toIsoString : Date -> String
toIsoString =
    toFormattedString_ False "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"


{-| Convenience function for formatting a date, in UTC representation, to ISO
8601 (extended date and time format with "Z" for time offset).
Date.toUtcIsoString
(Date.fromParts 2007 Mar 15 13 45 56 67)
-- "2007-03-15T17:45:56.067Z"
-- (example has a local offset of UTC-04:00)
-}
toUtcIsoString : Date -> String
toUtcIsoString =
    toFormattedString_ True "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"



--------------------------------------------------------------------------------
-- Compare


{-| Test the equality of two dates.
-}
equal : Date -> Date -> Bool
equal a b =
    toTime a == toTime b


{-| Compare two dates. This can be used as the compare function for
`List.sortWith`.
-}
compare : Date -> Date -> Order
compare a b =
    Basics.compare (toTime a) (toTime b)


{-| Test if a date is within a given range, inclusive of the range values. The
expression `Date.isBetween min max x` tests if `x` is between `min` and `max`.
-}
isBetween : Date -> Date -> Date -> Bool
isBetween a b x =
    toTime a <= toTime x && toTime x <= toTime b


{-| Clamp a date within a given range. The expression `Date.clamp min max x`
returns one of `min`, `max`, or `x`, ensuring the returned date is not before
`min` and not after `max`.
-}
clamp : Date -> Date -> Date -> Date
clamp minimum maximum date =
    if toTime date < toTime minimum then
        minimum

    else if toTime date > toTime maximum then
        maximum

    else
        date



--------------------------------------------------------------------------------
-- Intervals


{-| Represents an interval of time.
-}
type Interval
    = Year
    | Quarter
    | Month
    | Week
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday
    | Day
    | Hour
    | Minute
    | Second
    | Millisecond


{-| Test if two dates fall within the same interval.
dec31 = Date.fromCalendarDate 1999 Dec 31
jan1 = Date.fromCalendarDate 2000 Jan 1
Date.equalBy Month dec31 jan1 -- False
Date.equalBy Week dec31 jan1 -- True
-}
equalBy : Interval -> Date -> Date -> Bool
equalBy interval date1 date2 =
    case interval of
        Millisecond ->
            toTime date1 == toTime date2

        Second ->
            second date1 == second date2 && equalBy Minute date1 date2

        Minute ->
            minute date1 == minute date2 && equalBy Hour date1 date2

        Hour ->
            hour date1 == hour date2 && equalBy Day date1 date2

        Day ->
            day date1 == day date2 && equalBy Month date1 date2

        Month ->
            month date1 == month date2 && equalBy Year date1 date2

        Year ->
            year date1 == year date2

        Quarter ->
            quarter date1 == quarter date2 && equalBy Year date1 date2

        Week ->
            weekNumber date1 == weekNumber date2 && weekYear date1 == weekYear date2

        weekday ->
            equalBy Day (floor weekday date1) (floor weekday date2)



--------------------------------------------------------------------------------
-- Arithmetic


{-| Add a number of whole intervals to a date.
Date.add Week 2 (Date.fromParts 2007 Mar 15 11 55 0 0)
-- <29 March 2007, 11:55>
When adding Month, Quarter, or Year intervals, day values are clamped at the
end of the month if necessary.
Date.add Month 1 (Date.fromParts 2000 Jan 31 0 0 0 0)
-- <29 February 2000>
-}
add : Interval -> Int -> Date -> Date
add interval n date =
    case interval of
        Millisecond ->
            fromTime <| toTime date + toFloat n

        Second ->
            fromTime <| toTime date + toFloat (n * msPerSecond)

        Minute ->
            fromTime <| toTime date + toFloat (n * msPerMinute)

        Hour ->
            fromTime <| toTime date + toFloat (n * msPerHour)

        Day ->
            let
                ( y, m, d, hh, mm, ss, ms ) =
                    ( year date, month date, day date, hour date, minute date, second date, millisecond date )
            in
            fromSpec (DateMS <| unixTimeFromRataDie (RataDie.fromCalendarDate y m d + n)) (time hh mm ss ms) local

        Month ->
            let
                ( y, mn, d, hh, mm, ss, ms ) =
                    ( year date, monthNumber date, day date, hour date, minute date, second date, millisecond date )

                wholeMonths =
                    12 * (y - 1) + mn - 1 + n
            in
            fromParts (wholeMonths // 12 + 1) (wholeMonths % 12 + 1 |> numberToMonth) d hh mm ss ms

        Year ->
            add Month (n * 12) date

        Quarter ->
            add Month (n * 3) date

        Week ->
            add Day (n * 7) date

        weekday ->
            add Day (n * 7) date


{-| The number of whole months between date and 0001-01-01 plus fraction
representing the current month. Only used for diffing months.
-}
toMonths : Date -> Float
toMonths date =
    let
        ( y, m, d ) =
            ( year date, month date, day date )

        wholeMonths =
            12 * (y - 1) + monthToNumber m - 1
    in
    toFloat wholeMonths + (toFloat d / 100) + (fractionalDay date / 100)


{-| Find the difference, as a number of whole intervals, between two dates.
Date.diff Month
(Date.fromParts 2007 Mar 15 11 55 0 0)
(Date.fromParts 2007 Sep 1 0 0 0 0)
-- 5
-}
diff : Interval -> Date -> Date -> Int
diff interval date1 date2 =
    case interval of
        Millisecond ->
            toTime date2 - toTime date1 |> Basics.floor

        Second ->
            diff Millisecond date1 date2 // msPerSecond

        Minute ->
            diff Millisecond date1 date2 // msPerMinute

        Hour ->
            diff Millisecond date1 date2 // msPerHour

        Day ->
            let
                rdm1 =
                    (date1 |> toRataDie |> toFloat) + (date1 |> fractionalDay)

                rdm2 =
                    (date2 |> toRataDie |> toFloat) + (date2 |> fractionalDay)
            in
            rdm2 - rdm1 |> truncate

        Month ->
            toMonths date2 - toMonths date1 |> truncate

        Year ->
            diff Month date1 date2 // 12

        Quarter ->
            diff Month date1 date2 // 3

        Week ->
            diff Day date1 date2 // 7

        weekday ->
            diff Day (floor weekday date1) (floor weekday date2) // 7



--------------------------------------------------------------------------------
-- Round


daysSincePreviousWeekday : Day -> Date -> Int
daysSincePreviousWeekday wd date =
    (weekdayNumber date + 7 - weekdayToNumber wd) % 7


{-| Round down a date to the beginning of the closest interval. The resulting
date will be less than or equal to the one provided.
Date.floor Hour
(Date.fromParts 1999 Dec 31 23 59 59 999)
-- <31 December 1999, 23:00>
-}
floor : Interval -> Date -> Date
floor interval date =
    case interval of
        Millisecond ->
            date

        Second ->
            fromParts (year date) (month date) (day date) (hour date) (minute date) (second date) 0

        Minute ->
            fromParts (year date) (month date) (day date) (hour date) (minute date) 0 0

        Hour ->
            fromParts (year date) (month date) (day date) (hour date) 0 0 0

        Day ->
            fromCalendarDate (year date) (month date) (day date)

        Month ->
            fromCalendarDate (year date) (month date) 1

        Year ->
            fromCalendarDate (year date) Jan 1

        Quarter ->
            fromCalendarDate (year date) (date |> quarter |> quarterToMonth) 1

        Week ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Mon date)

        Monday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Mon date)

        Tuesday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Tue date)

        Wednesday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Wed date)

        Thursday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Thu date)

        Friday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Fri date)

        Saturday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Sat date)

        Sunday ->
            fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Sun date)


{-| Round up a date to the beginning of the closest interval. The resulting
date will be greater than or equal to the one provided.
Date.ceiling Monday
(Date.fromParts 1999 Dec 31 23 59 59 999)
-- <3 January 2000>
-}
ceiling : Interval -> Date -> Date
ceiling interval date =
    let
        floored =
            date |> floor interval
    in
    if toTime date == toTime floored then
        date

    else
        floored |> add interval 1



--------------------------------------------------------------------------------
-- Lists


{-| Create a list of dates, at rounded intervals, increasing by a step value,
between two dates. The list will start on or after the first date, and end
before the second date.
Date.range Day 2
(Date.fromParts 2007 Mar 15 11 55 0 0)
(Date.fromParts 2007 Mar 22 0 0 0 0)
-- [ <16 March 2007>
-- , <18 March 2007>
-- , <20 March 2007>
-- ]
-}
range : Interval -> Int -> Date -> Date -> List Date
range interval step start end =
    let
        first =
            start |> ceiling interval
    in
    if toTime first < toTime end then
        rangeHelp interval (max 1 step) end [] first

    else
        []


rangeHelp : Interval -> Int -> Date -> List Date -> Date -> List Date
rangeHelp interval step end revList date =
    if toTime date < toTime end then
        rangeHelp interval step end (date :: revList) (date |> add interval step)

    else
        List.reverse revList



--------------------------------------------------------------------------------
-- Rata Die


{-| -}
toRataDie : Date -> Int
toRataDie date =
    RataDie.fromCalendarDate (year date) (month date) (day date)


{-| -}
fromRataDie : Int -> Date
fromRataDie rd =
    fromSpec (DateMS <| unixTimeFromRataDie rd) midnight local



--- From DateTime


{-| The [DateTime](DateTime#) module was introduced in order to keep track of both the
[Date](Calendar#Date) and [Time](Clock#Time). The `DateTime`
consists of a `Day`, `Month`, `Year`, `Hours`, `Minutes`, `Seconds` and `Milliseconds`.
You can construct a `DateTime` either by using a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix)
or by using an existing [Date](Calendar#Date) and [Time](Clock#Time) combination. Otherwise
you can _**attempt**_ to construct a `DateTime` by using a combination of a
[RawDate](Calendar#RawDate) and a [RawClock](Clock#RawClock).

@docs DateTime


# Creating a `DateTime`

@docs fromPosix, fromRawParts, fromDateAndTime


# Conversions

@docs toPosix, toMillis


# Accessors

@docs getDate, getTime, getYear, getMonth, getDay, getHours, getMinutes, getSeconds, getMilliseconds


# Setters

@docs setDate, setTime, setYear, setMonth, setDay, setHours, setMinutes, setSeconds, setMilliseconds


# Increment values

@docs incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrement values

@docs decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Compare values

@docs compare, compareDates, compareTime


# Utilities

@docs getTimezoneOffset, getDateRange, getDatesInMonth, getDayDiff, getWeekday, isLeapYear, sort


# Exposed for Testing Purposes

@docs rollDayBackwards, rollDayForward

-}


{-| An instant in time, composed of a calendar date, clock time and time zone.
-}
type DateTime
    = DateTime InternalDateTime


{-| The internal representation of `DateTime` and its constituent parts.
-}
type alias InternalDateTime =
    { date : Calendar.Date
    , time : Clock.Time
    }



-- Creating a `DateTime`


{-| Create a `DateTime` from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.

    fromPosix (Time.millisToPosix 0)
    -- DateTime { date = Date { day = Day 1, month = Jan, year = Year 1970 }, time = Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } } : DateTime

    fromPosix (Time.millisToPosix 1566795954000)
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 5, minutes = Minute 5, seconds = Second 54, milliseconds = Millisecond 0 } } : DateTime

-}
fromPosix : Time.Posix -> DateTime
fromPosix timePosix =
    DateTime
        { date = Calendar_.fromPosix timePosix
        , time = Clock_.fromPosix timePosix
        }


{-| Create a `DateTime` from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time and
a [timezone](https://package.elm-lang.org/packages/elm/time/latest/Time#Zone). This function shouldn't be exposed to the consumer because
of the reasons outlined on this [issue](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/issues/2).
-}
fromZonedPosix : Time.Zone -> Time.Posix -> DateTime
fromZonedPosix zone posix =
    DateTime
        { date = Calendar_.fromZonedPosix zone posix
        , time = Clock_.fromZonedPosix zone posix
        }


{-| Attempts to construct a new `DateTime` object from its raw constituent parts. Returns `Nothing` if
any parts or their combination would result in an invalid [DateTime](DateTime#DateTime).

    fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Just (DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 }}) : Maybe DateTime

    fromRawParts { day = 29, month = Feb, year = 2019 } { hours = 16, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Nothing : Maybe DateTime

    fromRawParts { day = 15, month = Nov, year = 2019 } { hours = 24, minutes = 20, seconds = 40, milliseconds = 0 }
    -- Nothing : Maybe DateTime

-}
fromRawParts : Calendar.RawDate -> Clock.RawTime -> Maybe DateTime
fromRawParts rawDate rawTime =
    Maybe.map2
        (\date time ->
            DateTime (InternalDateTime date time)
        )
        (Calendar.fromRawParts rawDate)
        (Clock.fromRawParts rawTime)


{-| Create a [DateTime](DateTime#DateTime) by combining a [Date](Calendar#Date) and [Time](Clock#Time).

    -- date == 26 Aug 2019
    -- time == 12:30:45.000

    fromDateAndTime date time
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 } } : DateTime

-}
fromDateAndTime : Calendar.Date -> Clock.Time -> DateTime
fromDateAndTime date time =
    DateTime
        { date = date
        , time = time
        }



-- Conversions


{-| Converts a `DateTime` to a posix time. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive posix time.** Otherwise the
result will be a **negative posix time**.

    -- dateTime  == 25 Dec 2019 19:23:45.000
    toPosix dateTime -- Posix 1577301825000 : Posix

    -- dateTime2 == 1 Jan 1970 00:00:00.000 : Posix
    toPosix dateTime2 -- Posix 0

    -- dateTime3 == 8 Jan 1920 04:36:15.000
    toPosix dateTime3 -- Posix -1577301825000 : Posix

-}
toPosix : DateTime -> Time.Posix
toPosix =
    Time.millisToPosix << toMillis


{-| Convers a `DateTime` to the equivalent milliseconds. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive number** representing the milliseconds
that have elapsed since the Epoch. Otherwise the result will be a negative number representing the milliseconds required in order to reach the Epoch.

    -- dateTime  == 25 Dec 2019 19:23:45.000
    toMillis dateTime -- 1577301825000 : Int

    -- dateTime2 == 1 Jan 1970 00:00:00.000
    toMillis dateTime2 -- 0 : Int

    -- dateTime3 == 8 Jan 1920 04:36:15.000
    toMillis dateTime3 -- -1577301825000 : Int

-}
toMillis : DateTime -> Int
toMillis (DateTime { date, time }) =
    Calendar.toMillis date + Clock.toMillis time



-- Accessors


{-| Extract the [Date](Calendar#Date) from a `DateTime`.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getDate dateTime -- 25 Dec 2019 : Calendar.Date

-}
getDate : DateTime -> Calendar.Date
getDate (DateTime { date }) =
    date


{-| Extract the [Time](Clock#Time) from a `DateTime`.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getTime dateTime -- 16:45:30.000 : Clock.Time

-}
getTime : DateTime -> Clock.Time
getTime (DateTime { time }) =
    time


{-| Extract the `Year` part of a `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getYear dateTime -- 2019 : Int

-}
getYear : DateTime -> Int
getYear =
    Calendar.getYear << getDate


{-| Extract the `Month` part of a `DateTime` as a [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month).

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMonth dateTime -- Dec : Time.Month

-}
getMonth : DateTime -> Time.Month
getMonth =
    Calendar.getMonth << getDate


{-| Extract the `Day` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getDay dateTime -- 25 : Int

-}
getDay : DateTime -> Int
getDay =
    Calendar.getDay << getDate


{-| Extract the `Hour` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getHours dateTime -- 16 : Int

-}
getHours : DateTime -> Int
getHours =
    Clock.getHours << getTime


{-| Extract the `Minute` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMinutes dateTime -- 45 : Int

-}
getMinutes : DateTime -> Int
getMinutes =
    Clock.getMinutes << getTime


{-| Extract the `Second` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getSeconds dateTime -- 30 : Int

-}
getSeconds : DateTime -> Int
getSeconds =
    Clock.getSeconds << getTime


{-| Extract the `Millisecond` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMilliseconds dateTime -- 0 : Int

-}
getMilliseconds : DateTime -> Int
getMilliseconds =
    Clock.getMilliseconds << getTime



-- Setters


{-| Sets the `Date` part of a [DateTime#DateTime].

    -- date == 26 Aug 2019
    -- dateTime == 25 Dec 2019 16:45:30.000
    setDate date dateTime -- 26 Aug 2019 16:45:30.000

-}
setDate : Calendar.Date -> DateTime -> DateTime
setDate date (DateTime { time }) =
    DateTime
        { date = date
        , time = time
        }


{-| Sets the `Time` part of a [DateTime#DateTime].

    -- dateTime == 25 Dec 2019 16:45:30.000
    setTime Clock.midnight dateTime -- 25 Dec 2019 00:00:00.000

-}
setTime : Clock.Time -> DateTime -> DateTime
setTime time (DateTime { date }) =
    DateTime
        { date = date
        , time = time
        }


{-| Attempts to set the `Year` part of a [Calendar.Date](Calendar#Date) in a `DateTime`.

    -- dateTime == 29 Feb 2020 15:30:30.000
    setYear 2024 dateTime -- Just (29 Feb 2024 15:30:30.000) : Maybe DateTime

    setYear 2019 dateTime -- Nothing : Maybe DateTime

-}
setYear : Int -> DateTime -> Maybe DateTime
setYear year dateTime =
    Maybe.map (\y -> setDate y dateTime) <|
        Calendar.setYear year (getDate dateTime)


{-| Attempts to set the `Month` part of a [Calendar.Date](Calendar#Date) in a `DateTime`.

    -- dateTime == 31 Jan 2019 15:30:30.000
    setMonth Aug dateTime -- Just (31 Aug 2019 15:30:30.000) : Maybe DateTime

    setMonth Apr dateTime -- Nothing : Maybe DateTime

-}
setMonth : Time.Month -> DateTime -> Maybe DateTime
setMonth month dateTime =
    Maybe.map (\m -> setDate m dateTime) <|
        Calendar.setMonth month (getDate dateTime)


{-| Attempts to set the `Day` part of a [Calendar.Date](Calendar#Date) in a `DateTime`.

    -- dateTime == 31 Jan 2019 15:30:30.000
    setDay 25 dateTime -- Just (25 Jan 2019 15:30:30.000) : Maybe DateTime

    setDay 32 dateTime -- Nothing : Maybe DateTime

-}
setDay : Int -> DateTime -> Maybe DateTime
setDay day dateTime =
    Maybe.map (\d -> setDate d dateTime) <|
        Calendar.setDay day (getDate dateTime)


{-| Attempts to set the `Hours` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setHours 23 dateTime -- Just (2 Jul 2019 23:00:00.000) : Maybe DateTime

    setHours 24 dateTime -- Nothing : Maybe DateTime

-}
setHours : Int -> DateTime -> Maybe DateTime
setHours hours dateTime =
    Maybe.map (\h -> setTime h dateTime) <|
        Clock.setHours hours (getTime dateTime)


{-| Attempts to set the `Minutes` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setMinutes 36 dateTime -- Just (2 Jul 2019 12:36:00.000) : Maybe DateTime

    setMinutes 60 dateTime -- Nothing : Maybe DateTime

-}
setMinutes : Int -> DateTime -> Maybe DateTime
setMinutes minutes dateTime =
    Maybe.map (\m -> setTime m dateTime) <|
        Clock.setMinutes minutes (getTime dateTime)


{-| Attempts to set the `Seconds` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setSeconds 20 dateTime -- Just (2 Jul 2019 12:00:20.000) : Maybe DateTime

    setSeconds 60 dateTime -- Nothing : Maybe DateTime

-}
setSeconds : Int -> DateTime -> Maybe DateTime
setSeconds seconds dateTime =
    Maybe.map (\s -> setTime s dateTime) <|
        Clock.setSeconds seconds (getTime dateTime)


{-| Attempts to set the `Milliseconds` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setMilliseconds 589 dateTime -- Just (2 Jul 2019 12:00:00.589) : Maybe DateTime

    setMilliseconds 1000 dateTime -- Nothing : Maybe DateTime

-}
setMilliseconds : Int -> DateTime -> Maybe DateTime
setMilliseconds milliseconds dateTime =
    Maybe.map (\m -> setTime m dateTime) <|
        Clock.setMilliseconds milliseconds (getTime dateTime)



-- Increment values


{-| Increments the `Year` in a given [DateTime](DateTime#DateTime) while preserving the `Month`, and `Day` parts.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 31 Jan 2019 15:30:45.100
    incrementYear dateTime -- 31 Jan 2020 15:30:45.100 : DateTime

    -- dateTime2 == 29 Feb 2020 15:30:45.100
    incrementYear dateTime2 -- 28 Feb 2021 15:30:45.100 : DateTime

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date in the `DateTime`
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
incrementYear : DateTime -> DateTime
incrementYear (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementYear date
        , time = time
        }


{-| Increments the `Month` in a given [DateTime](DateTime#DateTime). It will also roll over to the next year where applicable.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 15 Sep 2019 15:30:45.100
    incrementMonth dateTime -- 15 Oct 2019 15:30:45.100 : DateTime

    -- dateTime2 == 15 Dec 2019 15:30:45.100
    incrementMonth dateTime2 -- 15 Jan 2020 15:30:45.100 : DateTime

    -- dateTime3 == 30 Jan 2019 15:30:45.100
    incrementMonth dateTime3 -- 28 Feb 2019 15:30:45.100 : DateTime

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `Day` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `Day` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : DateTime -> DateTime
incrementMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementMonth date
        , time = time
        }


{-| Increments the `Day` in a given [DateTime](DateTime#DateTime). Will also increment `Month` and `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementDay dateTime -- 26 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 15:30:45.100
    incrementDay dateTime2 -- 1 Jan 2020 15:30:45.100 : DateTime

-}
incrementDay : DateTime -> DateTime
incrementDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementDay date
        , time = time
        }


{-| Increments the `Hours` in a given [DateTime](DateTime#DateTime). Will also increment `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementHours dateTime -- 25 Aug 2019 16:30:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:00:00.000
    incrementHours dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementHours : DateTime -> DateTime
incrementHours (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementHours time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }


{-| Increments the `Minutes` in a given [DateTime](DateTime#DateTime). Will also increment `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementMinutes dateTime -- 25 Aug 2019 15:31:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:00.000
    incrementMinutes dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementMinutes : DateTime -> DateTime
incrementMinutes (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementMinutes time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }


{-| Increments the `Seconds` in a given [DateTime](DateTime#DateTime). Will also increment `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementSeconds dateTime -- 25 Aug 2019 15:30:46.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:59.000
    incrementSeconds dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementSeconds : DateTime -> DateTime
incrementSeconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementSeconds time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }


{-| Increments the `Milliseconds` in a given [DateTime](DateTime#DateTime). Will also increment `Seconds`, `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementMilliseconds dateTime -- 25 Aug 2019 15:30:45:101 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:59.999
    incrementMilliseconds dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementMilliseconds : DateTime -> DateTime
incrementMilliseconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementMilliseconds time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }



-- Decrement values


{-| Decrements the `Year` in a given [DateTime](DateTime#DateTime) while preserving the `Month` and `Day`.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 31 Jan 2019 15:30:45.100
    decrementYear dateTime -- 31 Jan 2018 15:30:45.100 : DateTime

    -- dateTime2 == 29 Feb 2020 15:30:45.100
    decrementYear dateTime2 -- 28 Feb 2019 15:30:45.100 : DateTime

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date in the `DateTime`
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
decrementYear : DateTime -> DateTime
decrementYear (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementYear date
        , time = time
        }


{-| Decrements the `Month` in a given [DateTime](DateTime#DateTime). It will also roll backwards to the previous year where applicable.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 15 Sep 2019 15:30:45.100
    decrementMonth dateTime -- 15 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 15 Jan 2020 15:30:45.100
    decrementMonth dateTime2 -- 15 Dec 2019 15:30:45.100 : DateTime

    -- dateTime3 == 31 Dec 2019 15:30:45.100
    decrementMonth dateTime3 -- 30 Nov 2019 15:30:45.100 : DateTime

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `Day` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `Day` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : DateTime -> DateTime
decrementMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementMonth date
        , time = time
        }


{-| Decrements the `Day` in a given [DateTime](DateTime#DateTime). Will also decrement `Month` and `Year` where applicable.

    -- dateTime  == 27 Aug 2019 15:30:45.100
    decrementDay dateTime -- 26 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 1 Jan 2020 15:30:45.100
    decrementDay dateTime2 -- 31 Dec 2019 15:30:45.100 : DateTime

-}
decrementDay : DateTime -> DateTime
decrementDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementDay date
        , time = time
        }


{-| Decrements the `Hours` in a given [DateTime](DateTime#DateTime). Will also decrement `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementHours dateTime -- 25 Aug 2019 14:30:45.100 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementHours dateTime2 -- 31 Dec 2019 23:00:00.000 : DateTime

-}
decrementHours : DateTime -> DateTime
decrementHours (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementHours time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }


{-| Decrements the `Minutes` in a given [DateTime](DateTime#DateTime). Will also decrement `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementMinutes dateTime -- 25 Aug 2019 15:29:45.100 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementMinutes dateTime2 -- 31 Dec 2019 23:59:00.000 : DateTime

-}
decrementMinutes : DateTime -> DateTime
decrementMinutes (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementMinutes time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }


{-| Decrements the `Seconds` in a given [DateTime](DateTime#DateTime). Will also decrement `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementSeconds dateTime -- 25 Aug 2019 15:30:44.100 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementSeconds dateTime2 -- 31 Dec 2019 23:59:59.000 : DateTime

-}
decrementSeconds : DateTime -> DateTime
decrementSeconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementSeconds time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }


{-| Decrements the `Milliseconds` in a given [DateTime](DateTime#DateTime). Will also decrement `Seconds`, `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementMilliseconds dateTime -- 25 Aug 2019 15:30:45.099 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementMilliseconds dateTime2 -- 31 Dec 2019 23:59:59.999 : DateTime

-}
decrementMilliseconds : DateTime -> DateTime
decrementMilliseconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementMilliseconds time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }



-- Compare values


{-| Compares the two given [DateTimes](DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- past   == 25 Aug 2019 12:15:45.250
    -- future == 26 Aug 2019 12:15:45.250
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : DateTime -> DateTime -> Order
compare (DateTime lhs) (DateTime rhs) =
    case Calendar.compare lhs.date rhs.date of
        EQ ->
            Clock.compare lhs.time rhs.time

        ord ->
            ord


{-| Compares the [Date](Calendar#Date) part of two given [DateTime](DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- dateTime  == 25 Aug 2019 12:15:45.250
    -- dateTime2 == 25 Aug 2019 21:00:00.000
    -- dateTime3 == 26 Aug 2019 12:15:45.250
    compare dateTime dateTime2 -- EQ : Order

    compare dateTime dateTime3 -- LT : Order

    compare dateTime3 dateTime2 -- GT : Order

-}
compareDates : DateTime -> DateTime -> Order
compareDates (DateTime lhs) (DateTime rhs) =
    Calendar.compare lhs.date rhs.date


{-| Compares the [Time](Clock#Time) part of two given [DateTime](DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- dateTime  == 25 Aug 2019 12:15:45.250
    -- dateTime2 == 25 Aug 2019 21:00:00.000
    -- dateTime3 == 26 Aug 2019 12:15:45.250
    compare dateTime dateTime3 -- EQ : Order

    compare dateTime dateTime2 -- LT : Order

    compare dateTime2 dateTime3 -- GT : Order

-}
compareTime : DateTime -> DateTime -> Order
compareTime (DateTime lhs) (DateTime rhs) =
    Clock.compare lhs.time rhs.time



-- Utilities


{-| Returns the Timezone Offset in Milliseconds. This function can be
used in order to form a `DateTime` that actually matches each users local `DateTime`.


    dateTime =
        DateTime.fromPosix posix

    offset =
        DateTime.getTimezoneOffset zone posix

    zonedDateTime =
        DateTime.fromPosix (posix + offset)

    -- zone == GMT+1100
    -- posix == 1554660000000 -- 2019-04-07 18:00:00 UTC
    -- dateTime == 2019-04-07 18:00:00 UTC
    -- zonedDateTime == 2019-04-08 05:00:00 GMT+1100

_The above example shows the difference between getting a `DateTime` in **UTC** and in **GMT+1100.**_

**Note:** Timezones ( and local times ) should only be used for date representation purposes and never
for storing or modeling. If you use getTimezoneOffset for constructing a _**local today**_ `DateTime`,
remember to convert it back to UTC when storing it in a database.

-}
getTimezoneOffset : Time.Zone -> Time.Posix -> Int
getTimezoneOffset zone posix =
    let
        ( dateTime, zonedDateTime ) =
            ( fromPosix posix
            , fromZonedPosix zone posix
            )
    in
    toMillis zonedDateTime - toMillis dateTime


{-| Returns an incrementally sorted [DateTime](DateTime#DateTime) list based on the **start** and **end** `DateTime` parameters.
The `Time` parts of the resulting list will be equal to the `Time` argument that was provided.
_**The resulting list will include both start and end dates**_.

    -- start       == 26 Feb 2020 12:30:45.000
    -- end         == 1  Mar 2020 16:30:45.000
    -- defaultTime == 21:00:00.000

    getDateRange start end defaultTime
    -- [ 26 Feb 2020 21:00:00.000, 27 Feb 2020 21:00:00.000, 28 Feb 2020 21:00:00.000, 29 Feb 2020 21:00:00.000, 1 Mar 2020 21:00:00.000 ] : List DateTime

-}
getDateRange : DateTime -> DateTime -> Clock.Time -> List DateTime
getDateRange (DateTime start) (DateTime end) time =
    List.map
        (\date ->
            DateTime { date = date, time = time }
        )
        (Calendar.getDateRange start.date end.date)


{-| Returns a list of [DateTimes](DateTime#DateTime) for the given `Year` and `Month` combination.
The `Time` parts of the resulting list will be equal to the `Time` portion of the [DateTime](DateTime#DateTime)
that was provided.

    -- dateTime == 26 Aug 2019 21:00:00.000

    getDatesInMonth dateTime
    --   [ 1  Aug 2019  21:00:00.000
    --   , 2  Aug 2019  21:00:00.000
    --   , 3  Aug 2019  21:00:00.000
    --   ...
    --   , 29 Aug 2019 21:00:00.000
    --   , 30 Aug 2019 21:00:00.000
    --   , 31 Aug 2019 21:00:00.000
    --   ] : List DateTime

-}
getDatesInMonth : DateTime -> List DateTime
getDatesInMonth (DateTime { date, time }) =
    List.map
        (\date_ ->
            DateTime { date = date_, time = time }
        )
        (Calendar.getDatesInMonth date)


{-| Returns the difference in days between two [DateTimes](DateTime#DateTime).
We can have a negative difference of days as can be seen in the examples below.

    -- dateTime  == 24 Aug 2019 12:00:00.000
    -- dateTime2 == 24 Aug 2019 21:00:00.000
    -- dateTime3 == 26 Aug 2019 15:45:00.000
    getDayDiff dateTime dateTime2 -- 0 : Int

    getDayDiff dateTime dateTime3 -- 2  : Int

    getDayDiff dateTime3 dateTime -- -2 : Int

-}
getDayDiff : DateTime -> DateTime -> Int
getDayDiff (DateTime lhs) (DateTime rhs) =
    Calendar.getDayDiff lhs.date rhs.date


{-| Returns the weekday of a specific [DateTime](DateTime#DateTime).

    -- dateTime == 26 Aug 2019 12:30:45.000
    getWeekday dateTime -- Mon : Weekday

-}
getWeekday : DateTime -> Time.Weekday
getWeekday (DateTime dateTime) =
    Calendar.getWeekday dateTime.date


{-| Checks if the `Year` part of the given [DateTime](DateTime#DateTime) is a leap year.

    -- dateTime  == 25 Dec 2019 21:00:00.000
    isLeapYear dateTime -- False

    -- dateTime2 == 25 Dec 2020 12:00:00.000
    isLeapYear dateTime2 -- True

-}
isLeapYear : DateTime -> Bool
isLeapYear (DateTime { date, time }) =
    Calendar.isLeapYear date


{-| Sorts incrementally a list of [DateTime](DateTime#DateTime).

    -- dateTime  == 26 Aug 1920 12:30:45.000
    -- dateTime2 == 26 Aug 1920 21:00:00.000
    -- dateTime3 == 1  Jan 1970 00:00:00.000
    -- dateTime4 == 1  Jan 1970 14:40:20.120
    -- dateTime5 == 25 Dec 2020 14:40:20.120
    -- dateTime6 == 25 Dec 2020 14:40:20.150

    sort [ dateTime4, dateTime2, dateTime6, dateTime5, dateTime, dateTime3 ]
    -- [ 26 Aug 1920 12:30:45.000
    -- , 26 Aug 1920 21:00:00.000
    -- , 1  Jan 1970 00:00:00.000
    -- , 1  Jan 1970 14:40:20.120
    -- , 25 Dec 2020 14:40:20.120
    -- , 25 Dec 2020 14:40:20.120
    -- ] : List DateTime

-}
sort : List DateTime -> List DateTime
sort =
    List.sortBy toMillis


{-| Helper function that decides if we should 'roll' the Calendar.Date forward due to a Clock.Time change.
-}
rollDayForward : Bool -> Calendar.Date -> Calendar.Date
rollDayForward shouldRoll date =
    if shouldRoll then
        Calendar.incrementDay date

    else
        date


{-| Helper function that decides if we should 'roll' the Calendar.Date backwards due to a Clock.Time change.
-}
rollDayBackwards : Bool -> Calendar.Date -> Calendar.Date
rollDayBackwards shouldRoll date =
    if shouldRoll then
        Calendar.decrementDay date

    else
        date
