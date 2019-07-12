module SmartTime.Human.Calendar exposing
    ( fromRawDay, fromYearMonthDay
    , toMillis
    , year, month, dayOfMonth
    , setYear, setMonth, setDayOfMonth
    , incrementYear, incrementMonth, incrementDay
    , decrementYear, decrementMonth, decrementDay
    , compare
    , getDateRange, getDatesInMonth, subtract, dayOfWeek, sort
    , millisInADay
    , CalendarDate(..), OrdinalDay, Parts, RataDie, WeekNumberingYear(..), addDays, calcDate, clamp, countSpecificDOWBetween, dashSeparated, daysBeforeWeekBasedYear, daysSincePrevious, difference, divideInt, equal, firstDayOfMonth, firstOfYear, fromInts, fromOrdinalDate, fromOrdinalParts, fromParts, fromRataDie, fromRawInts, fromRawIntsForced, fromString, fromWeekDate, fromWeekParts, intIsBetween, is53WeekYear, isBetween, monthBoundariesBetween, monthNumber, ordinalDay, parseDayOfMonth, parseMonth, parseYear, quarter, quarterBoundariesBetween, rollDayBackwards, rollDayForward, shiftMonth, shiftQuarter, shiftYear, timeBetween, toMonths, toNext, toOrdinalDate, toParts, toPrevious, toRataDie, weekBoundariesBetween, weekNumber, weekNumberingYear, withinSameMonth, withinSameQuarter, withinSameWeek, withinSameYear, yearBoundariesBetween
    )

{-| The [Calendar](Calendar#) module was introduced in order to keep track of the `Calendar Date` concept.
It has no knowledge of `Time` therefore it can only represent a [Date](Calendar#Date)
which consists of a `DayOfMonth`, a `Month` and a `Year`. You can construct a `Calendar Date` either
from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time or by
using its [Raw constituent parts](Calendar#RawDate). You can use a `Date` and the
Calendar's utilities as a standalone or you can combine a [Date](Calendar#Date) and a
[Time](Clock#Time) in order to get a [DateTime](DateTime#DateTime) which can then be converted into
a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix).


# Type definition

@docs Date, RawParts


# Creating values

@docs fromPosix, fromRawPartsForced, fromRawDay, fromYearMonthDay, dayOfMonthFromInt


# Conversions

@docs toPosix, toMillis, monthToInt, dayToInt


# Accessors

@docs year, month, dayOfMonth


# Setters

@docs setYear, setMonth, setDayOfMonth


# Increment value

@docs incrementYear, incrementMonth, incrementDay


# Decrement values

@docs decrementYear, decrementMonth, decrementDay


# Compare values

@docs compare


# Utilities

@docs getDateRange, getDatesInMonth, subtract, getFollowingMonths, getPrecedingMonths, dayOfWeek, isLeapYear, Month.lastDay, millisInYear, sort


# Constants

@docs months, millisInADay


# Exposed for Testing Purposes

@docs Year, Month, DayOfMonth
@docs millisSinceEpoch, millisSinceStartOfTheYear, millisSinceStartOfTheMonth
@docs fromZonedPosix

-}

-- Point to add: Does not involve `Clock` at all!
-- Add: Look what this used to be!
-- getDateRange : CalendarDate -> CalendarDate -> List CalendarDate
-- getDateRange startDate endDate =
--     let
--         ( startPosix, endPosix ) =
--             ( toPosix startDate
--             , toPosix endDate
--             )
--
--         posixDiff =
--             posixToMillis endPosix - posixToMillis startPosix
--
--         daysDiff =
--             posixDiff // 1000 // 60 // 60 // 24
--     in
--     if daysDiff > 0 then
--         getDateRange_ daysDiff startDate []
--
--     else
--         getDateRange_ (abs daysDiff) endDate []
--
--
-- {-| Internal helper function for getDateRange.
-- -}
-- getDateRange_ : Int -> CalendarDate -> List CalendarDate -> List CalendarDate
-- getDateRange_ daysCount prevDate res =
--     let
--         updatedRes =
--             res ++ [ prevDate ]
--     in
--     if daysCount > 0 then
--         let
--             ( updatedDaysCount, updatedPrevDate ) =
--                 ( daysCount - 1
--                 , incrementDay prevDate
--                 )
--         in
--         getDateRange_ updatedDaysCount updatedPrevDate updatedRes
--
--     else
--         updatedRes

import Parser exposing ((|.), (|=), Parser, chompWhile, getChompedString, spaces, symbol)
import SmartTime.Duration as Duration exposing (Duration, subtract)
import SmartTime.Human.Calendar.Month as Month exposing (DayOfMonth, Month)
import SmartTime.Human.Calendar.Week as Week exposing (DayOfWeek)
import SmartTime.Human.Calendar.Year as Year exposing (Year)
import SmartTime.Moment as Moment exposing (Moment)



-- ESSENTIALS  -------------------------------------------------------------------


{-| A full ([Gregorian](https://en.wikipedia.org/wiki/Gregorian_calendar)) calendar date.

Unlike other Date libraries, the date is internally stored in its most efficient form - a single `Int`.

Since we can't use the type system to rule out invalid years, this type is built to handle any date you throw at it - even dates before the Gregorian calendar was introduced! (Such dates are actually said to be on the "propleptic" Gregorian Calendar, produced by extending the Gregorian formula backwards from 1582.) Before that most places used the "Julian calendar" instead - and if you're some sort of historian working with Elm who wants Julian support, let me know and I'll be happy to add it!

Note that the ISO standard says you should only use proleptic dates "with prior agreement with your information interchange partners". That said, if you're both using this library, everything will just work!

Nomenclature: We could have called this type "Day", but "Tuesday" could be called a "day", and so could "a 24-hour period", and so could the "3rd" in "March 3rd, 2023". This name avoids that ambiguity. We could also have called this "Date", but in many programming contexts this implies a type of data that specifies more than just a calendar day (i.e. a "DateTime" or a `Moment` in reality), such as how you can get the current time in JS with `new Date()` or how the unix command to get the unix time is `date`. [Another Elm library](https://package.elm-lang.org/packages/justinmimbs/elm-date-extra/3.0.0/Date-Extra) even combines this with a timezone! This name avoids any such implication.

-}
type CalendarDate
    = CalendarDate RataDie


{-| Increments the `DayOfMonth` in a given [Date](Calendar#Date). Will also increment `Month` and `Year` where applicable.

    -- date  == 25 Aug 2019
    incrementDay date -- 26 Aug 2019 : Date

    -- date2 == 31 Dec 2019
    incrementDay date2 -- 1 Jan 2020 : Date

**Note:** Its safe to get the next day by using milliseconds here because we are responsible
for transforming the given date to millis and parsing it from millis. The incrementYear + incrementMonth
are totally different cases and they both have respectively different edge cases and implementations.

-}
incrementDay : CalendarDate -> CalendarDate
incrementDay (CalendarDate date) =
    CalendarDate (date + 1)


{-| Decrements the `DayOfMonth` in a given [CalendarDate](Calendar#CalendarDate). Will also decrement `Month` and `Year` where applicable.

    -- date  == 27 Aug 2019
    decrementDay date -- 26 Aug 2019 : CalendarDate

    -- date2 == 1 Jan 2020
    decrementDay date2 -- 31 Dec 2019 : CalendarDate

**Note:** Its safe to get the previous day by using milliseconds here because we are responsible
for transforming the given date to millis and parsing it from millis. The decrementYear + decrementMonth
are totally different cases and they both have respectively different edge cases and implementations.

-}
decrementDay : CalendarDate -> CalendarDate
decrementDay (CalendarDate date) =
    CalendarDate (date - 1)


{-| Add (or subtract, if negative given) a number of `Days` to a `CalendarDate`.

Only use this if you're working with date alone (not dates from `Moment`s) or you are already doing several other date operations on a `Moment`; otherwise just use `Duration.addDays`, since adding Days is always a pure and linear operation in this library!

-}
addDays : Int -> CalendarDate -> CalendarDate
addDays amountToAdd (CalendarDate date) =
    CalendarDate (date + amountToAdd)


{-| Increments the `Month` in a given [Date](Calendar#Date). It will also roll over to the next year where applicable.

    -- date  == 15 Sep 2019
    incrementMonth date -- 15 Oct 2019 : Date

    -- date2 == 15 Dec 2019
    incrementMonth date2 -- 15 Jan 2020 : Date

    -- date3 == 31 Jan 2019
    incrementMonth date3 -- 28 Feb 2019 : Date

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `DayOfMonth` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `DayOfMonth` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : CalendarDate -> CalendarDate
incrementMonth givenDate =
    let
        updatedMonth =
            nextMonth (month givenDate)

        updatedYear =
            case updatedMonth of
                Jan ->
                    Year (Year.toInt (year givenDate) + 1)

                _ ->
                    year givenDate

        lastDayOfUpdatedMonth =
            Month.lastDay updatedYear updatedMonth

        updatedDay =
            case compareDays (dayOfMonth givenDate) lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    dayOfMonth givenDate
    in
    fromParts
        { year = updatedYear
        , month = updatedMonth
        , day = updatedDay
        }


{-| Decrements the `Year` in a given [Date](Calendar#Date) while preserving the `Month` and `DayOfMonth` parts.

    -- date  == 31 Jan 2019
    decrementYear date -- 31 Jan 2018 : Date

    -- date2 == 29 Feb 2020
    decrementYear date2 -- 28 Feb 2019 : Date

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `DayOfMonth` parts.
On the second example we see that the `DayOfMonth` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

**Note 2:** Here we cannot rely on transforming the date to millis and removing a year because of the
edge case restrictions such as current year might be a leap year and the given date may contain the
29th of February but on the previous year, February would only have 28 days.

-}
decrementYear : CalendarDate -> CalendarDate
decrementYear givenDate =
    let
        updatedYear =
            Year (Year.toInt (year givenDate) - 1)

        lastDayOfUpdatedMonth =
            Month.lastDay updatedYear (month givenDate)

        updatedDay =
            case compareDays (dayOfMonth givenDate) lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    dayOfMonth givenDate
    in
    fromParts
        { year = updatedYear
        , month = month givenDate
        , day = updatedDay
        }


{-| Decrements the `Month` in a given [Date](Calendar#Date). It will also roll backwards to the previous year where applicable.

    -- date  == 15 Sep 2019
    decrementMonth date -- 15 Aug 2019 : Date

    -- date2 == 15 Jan 2020
    decrementMonth date2 -- 15 Dec 2019 : Date

    -- date3 == 31 Dec 2019
    decrementMonth date3 -- 30 Nov 2019 : Date

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `DayOfMonth` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `DayOfMonth` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : CalendarDate -> CalendarDate
decrementMonth givenDate =
    let
        updatedMonth =
            rollMonthBackwards (month givenDate)

        updatedYear =
            case updatedMonth of
                Dec ->
                    Year (Year.toInt (year givenDate) - 1)

                _ ->
                    year givenDate

        lastDayOfUpdatedMonth =
            Month.lastDay updatedYear updatedMonth

        updatedDay =
            case compareDays (dayOfMonth givenDate) lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    dayOfMonth givenDate
    in
    fromParts
        { year = updatedYear
        , month = updatedMonth
        , day = updatedDay
        }


{-| Extract the week number of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 25.
-}
weekNumber : CalendarDate -> Int
weekNumber date =
    let
        (CalendarDate rd) =
            date

        week1Day1 =
            daysBeforeWeekBasedYear (weekNumberingYear date) + 1
    in
    (rd - week1Day1) // 7 + 1



-- CREATING YOUR OWN -----------------------------------------------------------


{-| Attempt to create a `Date` from its constituent Year and Month by using its raw day.
Returns `Nothing` if any parts or their combination would form an invalid date.

    fromRawDay (Year 2018) Dec 25 -- Just (Date { day = DayOfMonth 25, month = Dec, year = Year 2018 }) : Maybe Date

    fromRawDay (Year 2020) Feb 29 -- Just (Date { day = DayOfMonth 11, month = Feb, year = Year 2020 }) : Maybe Date

    fromRawDay (Year 2019) Feb 29 -- Nothing : Maybe Date

-}
fromRawDay : Year -> Month -> Int -> Maybe CalendarDate
fromRawDay givenYear givenMonth day =
    dayOfMonthFromInt givenYear givenMonth day
        |> Maybe.andThen (fromYearMonthDay givenYear givenMonth)


{-| Attempt to create a `Date` from its constituent parts.
Returns `Nothing` if the combination would form an invalid date.

    fromYearMonthDay (Year 2018) Dec (DayOfMonth 25) -- Just (Date { year = (Year 2018), month = Dec, day = (DayOfMonth 25)}) : Maybe Date

    fromYearMonthDay (Year 2020) Feb (DayOfMonth 29) -- Just (Date { day = DayOfMonth 29, month = Feb, year = Year 2020 }) : Maybe Date

    fromYearMonthDay (Year 2019) Feb (DayOfMonth 29) -- Nothing : Maybe Date

-}
fromYearMonthDay : Year -> Month -> DayOfMonth -> Maybe CalendarDate
fromYearMonthDay y m d =
    let
        maxDay =
            Month.lastDay y m
    in
    case compareDays d maxDay of
        GT ->
            Nothing

        _ ->
            Just (fromRawPartsForced { year = y, month = m, day = d })


{-| Takes the `Parts` of a `CalendarDate` as parameters, except they're all raw `Int`s so you don't have to wrap them yourself.

The input is validated, and then the resulting date is validated. If both succeed, you get a `CalendarDate`!

If not, you'll just get `Nothing`, and you won't be told why. So, only use this if you're in a hurry. For more control over failures, consider using `fromParts` instead.

-}
fromRawInts : Int -> Int -> Int -> Maybe CalendarDate
fromRawInts yearInt monthInt dayInt =
    let
        givenYear =
            Year yearInt

        givenMonth =
            numberToMonth monthInt

        validMonthInt =
            monthInt >= 1 && monthInt <= 12

        validDayOfMonth =
            -- is dayInt in bounds for this Year+Month combo?
            dayInt <= daysInMonth givenYear givenMonth && dayInt > 0
    in
    if validDayOfMonth && validMonthInt then
        CalendarDate <|
            Year.daysBefore givenYear
                + Month.daysBefore givenYear givenMonth
                + dayInt

    else
        Nothing


{-| Take raw calendar parts like `fromRawInts`, and clamp the day so that you get a valid `CalendarDate` no matter what -- even if it's a poor approximation of the date you intended! Great for those who want to live on the edge, or just hate `Maybe`s, or just want to hardcode a known-valid date in a one-liner.

The third `Int` (the `DayOfMonth`) will be clamped to the number of days in the Year&Month combination given.

-}
fromRawIntsForced : Int -> Int -> Int -> CalendarDate
fromRawIntsForced yearInt monthInt dayInt =
    let
        givenYear =
            Year yearInt

        givenMonth =
            numberToMonth monthInt
    in
    CalendarDate <|
        Year.daysBefore givenYear
            + Month.daysBefore givenYear givenMonth
            + (dayInt |> Basics.clamp 1 (daysInMonth givenYear givenMonth))


{-| Get a `CalendarDate` from a string like these:

    "1994/12/27" -- Ok (December 27, 1994)

    "1776-5-11"

    "2013.09.11"

    "34 2 20" -- Yes, that's the `Year 34` CE.

As with the universal technical standard, the parts are in biggest-smallest order.

The parser can fail, with a nice error message:

-- Example

Or the successfully parsed date may not actually exist:

-- Example

-}
fromNumberString : String -> Result (List Parser.DeadEnd) CalendarDate
fromNumberString =
    let
        parserResult =
            Parser.run (Parser.oneOf [ separated "/", separated "-", separated ".", separated " " ])

        stringErrorResult =
            Result.mapError Parser.deadEndsToString parserResult
    in
    parserResult |> Result.andThen (Result.fromMaybe "The parsed date was not valid.")


separatedYMD : String -> Parser (Maybe CalendarDate)
separatedYMD separator =
    Parser.succeed (fromParts << Parts)
        |. spaces
        |= Year.parse4DigitYear
        |. symbol separator
        |= Month.parseMonth
        |. symbol separator
        |= Month.parseDayOfMonth



-- CALENDAR PARTS


{-| A CalendarDate in convenient record-form, waiting to be validated.

You can construct this yourself, and even validate parts of it early with functions like `intToDay`. But you need all three parts to know whether you have a valid date -- because something like "2000 Jan 31" is valid while "2000 Apr 31" is not, and "2000 Feb 29" is valid while "2001 Feb 29" is not. So when you're ready, pass this record into `fromParts` to get a real `CalendarDate`.

-}
type alias Parts =
    { year : Year
    , month : Month
    , day : DayOfMonth
    }


fromParts : Parts -> CalendarDate
fromParts parts =
    Debug.todo "fromParts"


{-| -}
toParts : CalendarDate -> Parts
toParts (CalendarDate rd) =
    let
        date =
            CalendarDate rd |> toOrdinalDate
    in
    calcDate date.year Jan date.ordinalDay


{-| Recursively adds up months to get to the given date number.
-}
calcDate : Year -> Month -> OrdinalDay -> Parts
calcDate givenYear givenMonth dayCounter =
    let
        monthSize =
            daysInMonth givenYear givenMonth

        monthsLeftToGo =
            -- was `monthAsNumber < 12`
            givenMonth /= Dec

        monthOverFlow =
            -- if the day count fits in the month, this must be the month!
            -- otherwise, it's a later month
            dayCounter > monthSize
    in
    if monthsLeftToGo && monthOverFlow then
        let
            nextMonthToCheck =
                -- was `monthAsNumber + 1 |> numberToMonth`
                nextMonth givenMonth

            remainingDaysToCount =
                dayCounter - monthSize
        in
        calcDate givenYear nextMonthToCheck remainingDaysToCount

    else
        { year = Year.toInt givenYear
        , month = givenMonth
        , day = dayCounter
        }



-- YEARS ---------------------------------------------------------------


{-| Increments the `Year` in a given [Date](Calendar#Date) while preserving the `Month` and `DayOfMonth` parts.

    -- date  == 31 Jan 2019
    incrementYear date -- 31 Jan 2020 : Date

    -- date2 == 29 Feb 2020
    incrementYear date2 -- 28 Feb 2021 : Date

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `DayOfMonth` parts.
On the second example we see that the `DayOfMonth` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

---

**Note 2:** Here we cannot rely on transforming the date to millis and adding a year because
of the edge case restrictions such as current year might be a leap year and the given date may
contain the 29th of February but on the next year, February would only have 28 days.

-}
incrementYear : CalendarDate -> CalendarDate
incrementYear givenDate =
    let
        (CalendarDate rd) =
            givenDate

        updatedYear =
            Year (Year.toInt (year givenDate) + 1)

        lastDayOfUpdatedMonth =
            Month.lastDay updatedYear (month givenDate)

        updatedDay =
            case compareDays (dayOfMonth givenDate) lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    dayOfMonth givenDate
    in
    fromParts
        { year = updatedYear
        , month = month givenDate
        , day = updatedDay
        }


{-| Attempts to set the `Year` part of a [Date](Calendar#Date).

    -- date == 29 Feb 2020
    setYear 2024 date -- Just (29 Feb 2024) : Maybe Date

    setYear 2019 date -- Nothing : Maybe Date

-}
setYear : Int -> CalendarDate -> Maybe CalendarDate
setYear givenYear date =
    Debug.todo "set year"


{-| Extract the `Year` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    year date -- Year 2019 : Year

    Year.toInt (year date) -- 2019 : Int

-}
year : CalendarDate -> Year
year (CalendarDate rd) =
    let
        ( n400, r400 ) =
            -- 400 * 365 + 97
            divideInt rd 146097

        ( n100, r100 ) =
            -- 100 * 365 + 24
            divideInt r400 36524

        ( n4, r4 ) =
            -- 4 * 365 + 1
            divideInt r100 1461

        ( n1, r1 ) =
            divideInt r4 365

        n =
            if r1 == 0 then
                0

            else
                1
    in
    Year <| n400 * 400 + n100 * 100 + n4 * 4 + n1 + n


firstOfYear : Year -> CalendarDate
firstOfYear givenYear =
    CalendarDate <| Year.daysBefore givenYear + 1


is53WeekYear : Year -> Bool
is53WeekYear givenYear =
    -- Can't be in `Year` because of dependencies
    let
        jan1 =
            dayOfWeek (firstOfYear givenYear)
    in
    -- any year starting on Thursday and any leap year starting on Wednesday
    jan1 == Thu || (jan1 == Wed && isLeapYear givenYear)



-- MONTHS ----------------------------------------------------------------


{-| Extract the `Month` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    month date -- Dec : Month

-}
month : CalendarDate -> Month
month =
    toParts >> .month


{-| Attempts to set the `Month` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setMonth Aug date -- Just (31 Aug 2019) : Maybe Date

    setMonth Apr date -- Nothing : Maybe Date

-}
setMonth : Month -> CalendarDate -> Maybe CalendarDate
setMonth givenMonth date =
    Debug.todo "Set month"


{-| Extract the `DayOfMonth` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    dayOfMonth date -- DayOfMonth 25 : DayOfMonth

    dayToInt (dayOfMonth date) -- 25 : Int

-}
dayOfMonth : CalendarDate -> DayOfMonth
dayOfMonth =
    toParts >> .day


{-| Attempts to set the `DayOfMonth` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setDayOfMonth 25 date -- Just (25 Jan 2019) : Maybe Date

    setDayOfMonth 32 date -- Nothing : Maybe Date

-}
setDayOfMonth : Int -> CalendarDate -> Maybe CalendarDate
setDayOfMonth day date =
    Debug.todo "setDayOfMonth"


firstDayOfMonth : Year -> Month -> CalendarDate
firstDayOfMonth givenYear givenMonth =
    CalendarDate <| Year.daysBefore givenYear + Month.daysBefore givenYear givenMonth + 1



-- WEEKS ----------------------------------------------------------------------
-- Week Arithmetic
-- Days of the week


{-| Returns the weekday of a specific [CalendarDate](Calendar#CalendarDate).

    -- date == 26 Aug 2019
    dayOfWeek date -- Mon : DayOfWeek

-}
dayOfWeek : CalendarDate -> DayOfWeek
dayOfWeek (CalendarDate rd) =
    let
        dayNum =
            case modBy rd 7 of
                0 ->
                    7

                n ->
                    n
    in
    numberToDayOfWeek dayNum



-- ALTERNATE REPRESENTATIONS ---------------------------------------------------
-- ORDINAL DAYS


{-| The "ordinal day" of a date.

Pairs with a `Year` for an alternate representation of `CalendarDate`s:

    Jan 1 -> 1
    Dec 31 -> 365

See? It's just the number of days _into the year_. That way you don't have to deal with month boundaries.

-}
type alias OrdinalDay =
    Int


{-| Extract the ordinal day of a date. Given the date 23 June 1990 this returns the integer 174.

Remember that an `OrdinalDay` is meaningless without it's `Year`, thanks to leap years.

-}
ordinalDay : CalendarDate -> OrdinalDay
ordinalDay givenDate =
    let
        dayOfWeekAsInt =
            dayOfWeekToInt (dayOfWeek givenDate)
    in
    Month.daysBefore (year givenDate) (month givenDate) + dayOfWeekAsInt


{-| -}
toOrdinalDate : CalendarDate -> { year : Year, ordinalDay : OrdinalDay }
toOrdinalDate (CalendarDate rd) =
    let
        givenYear =
            year (CalendarDate rd)
    in
    { year = givenYear
    , ordinalDay = rd - Year.daysBefore givenYear
    }



-- RATA DIE


type alias RataDie =
    Int


{-| -}
toRataDie : CalendarDate -> Int
toRataDie (CalendarDate int) =
    int


{-| -}
fromRataDie : Int -> CalendarDate
fromRataDie =
    CalendarDate



-- WEEK-BASED YEAR


type WeekNumberingYear
    = WeekNumberingYear Int


{-| Extract the week-numbering year of a date. Given the date 23 June
1990 at 11:45 a.m. this returns the integer 1990.
-}
weekNumberingYear : CalendarDate -> WeekNumberingYear
weekNumberingYear givenDate =
    let
        (CalendarDate rd) =
            givenDate

        dayOfWeekAsInt =
            dayOfWeekToInt (dayOfWeek givenDate)

        (Year actuallyWeekBasedYear) =
            -- `year <thursday of this week>`
            year (CalendarDate (rd + (4 - dayOfWeekAsInt)))
    in
    WeekNumberingYear actuallyWeekBasedYear


daysBeforeWeekBasedYear : WeekNumberingYear -> Int
daysBeforeWeekBasedYear (WeekNumberingYear wby) =
    let
        jan4 =
            Year.daysBefore (Year wby) + 4

        dayOfWeekAsInt date =
            dayOfWeekToInt (dayOfWeek date)
    in
    jan4 - dayOfWeekAsInt (CalendarDate jan4)



-- Extraneous TBD -------------------------------------------------------------


{-| Transforms a [Date](Calendar#Date) into milliseconds.

    date = fromRawPartsForced { day = 25, month = Dec, year = 2019 }
    Maybe.map toMillis date -- Just 1577232000000 == 25 Dec 2019 00:00:00.000

    want = 1566795954000 -- 26 Aug 2019 05:05:54.000
    got = toMillis (fromPosix (millisToPosix want)) -- 1566777600000 == 26 Aug 2019 00:00:00.000

    want == got -- False

Notice that transforming a **date** to milliseconds will always get you midnight hours.
The first example above will return a timestamp that equals to **Wed 25th of December 2019 00:00:00.000**
and the second example will return a timestamp that equals to **26th of August 2019 00:00:00.000** even though
the timestamp we provided in the [fromPosix](Calendar#fromPosix) was equal to **26th of August 2019 05:05:54.000**

-}



-- TODO remove?


toMillis : CalendarDate -> Int
toMillis date =
    millisSinceEpoch (year date)
        + millisSinceStartOfTheYear (year date) (month date)
        + millisSinceStartOfTheMonth (dayOfMonth date)



-- Compare values
-- Utilities


{-| Returns an incrementally sorted [CalendarDate](Calendar#CalendarDate) list based on the **start** and **end** date parameters.
_**The resulting list will include both start and end dates**_.

    -- start == 26 Feb 2020
    -- end   == 1 Mar 2020

    getDateRange start end
    -- [ 26 Feb 2020, 27 Feb 2020, 28 Feb 2020, 29 Feb 2020, 1  Mar 2020 ] : List CalendarDate

    getDateRange end start
    -- [ 26 Feb 2020, 27 Feb 2020, 28 Feb 2020, 29 Feb 2020, 1  Mar 2020 ] : List CalendarDate

-}
getDateRange : CalendarDate -> CalendarDate -> List CalendarDate
getDateRange (CalendarDate startDate) (CalendarDate endDate) =
    List.map CalendarDate (List.range startDate endDate)


{-| Returns a list of [Dates](Calendar#CalendarDate) for the given `Year` and `Month` combination.

    -- date == 26 Aug 2019

    getDatesInMonth date
    -- [ 1 Aug 2019, 2 Aug 2019, 3 Aug 2019, ..., 29 Aug 2019, 30 Aug 2019, 31 Aug 2019 ] : List CalendarDate

-}
getDatesInMonth : CalendarDate -> List CalendarDate
getDatesInMonth givenDate =
    let
        lastDayOfTheMonth =
            dayToInt (Month.lastDay (year givenDate) (month givenDate))
    in
    List.map
        CalendarDate
        (List.range 1 lastDayOfTheMonth)


{-| Get the difference in days between two `CalendarDate`s. We can have a negative difference of days as can be seen in the examples below.

    -- past   == 24 Aug 2019
    -- future == 26 Aug 2019
    subtract past future -- 2  : Int

    subtract future past -- -2 : Int

-}
subtract : CalendarDate -> CalendarDate -> Int
subtract (CalendarDate startDate) (CalendarDate endDate) =
    startDate - endDate


{-| Returns the number of days between two `CalendarDate`s, regardless of order.

This means that unlike `subtract`, result will never be negative.

-}
difference : CalendarDate -> CalendarDate -> Int
difference (CalendarDate startDate) (CalendarDate endDate) =
    abs (startDate - endDate)


{-| Sorts incrementally a list of [Dates](Calendar#CalendarDate).

    -- past   == 26 Aug 1920
    -- epoch  == 1 Jan 1970
    -- future == 25 Dec 2020

    sort [ future, past, epoch ]
    -- [ 26 Aug 1920, 1 Jan 1970, 25 Dec 2020 ] : List CalendarDate

-}
sort : List CalendarDate -> List CalendarDate
sort =
    List.sortBy toMillis



-- Constants


{-| The number of seconds in a day.

(It's 86 400, by the way. It may help to think of this song...)

-}
millisInADay : Int
millisInADay =
    1000 * 60 * 60 * 24



-- calculations


{-| integer division, returning (Quotient, Remainder)
-}
divideInt : Int -> Int -> ( Int, Int )
divideInt a b =
    ( a // b, remainderBy a b )



-- constructors, strict


fromOrdinalParts : Year -> OrdinalDay -> Result String CalendarDate
fromOrdinalParts givenYear givenOrdinalDay =
    if
        (givenOrdinalDay |> intIsBetween 1 365)
            || (givenOrdinalDay == 366 && isLeapYear givenYear)
    then
        Ok <| CalendarDate <| Year.daysBefore givenYear + givenOrdinalDay

    else
        Err <| "Invalid ordinal date (" ++ String.fromInt (Year.toInt givenYear) ++ ", " ++ String.fromInt givenOrdinalDay ++ ")"


fromInts : Int -> Int -> Int -> Result String CalendarDate
fromInts givenYearInt mn d =
    let
        givenYear =
            Year givenYearInt
    in
    if
        (mn |> intIsBetween 1 12)
            && (d |> intIsBetween 1 (daysInMonth givenYear (mn |> numberToMonth)))
    then
        Ok <| CalendarDate <| Year.daysBefore givenYear + Month.daysBefore givenYear (mn |> numberToMonth) + d

    else
        Err <| "Invalid calendar date (" ++ String.fromInt givenYearInt ++ ", " ++ String.fromInt mn ++ ", " ++ String.fromInt d ++ ")"


fromWeekParts : WeekNumberingYear -> Int -> Int -> Result String CalendarDate
fromWeekParts givenWBY wn wdn =
    let
        (WeekNumberingYear wby) =
            givenWBY
    in
    if
        (wdn |> intIsBetween 1 7)
            && ((wn |> intIsBetween 1 52)
                    || (wn == 53 && is53WeekYear (Year wby))
               )
    then
        Ok <| CalendarDate <| daysBeforeWeekBasedYear givenWBY + (wn - 1) * 7 + wdn

    else
        Err <| "Invalid week date (" ++ String.fromInt wby ++ ", " ++ String.fromInt wn ++ ", " ++ String.fromInt wdn ++ ")"


intIsBetween : Int -> Int -> Int -> Bool
intIsBetween a b x =
    a <= x && x <= b



-- constructors, clamping


fromOrdinalDate : Year -> Int -> CalendarDate
fromOrdinalDate givenYear od =
    let
        daysInY =
            if isLeapYear givenYear then
                366

            else
                365
    in
    CalendarDate (Year.daysBefore givenYear + (od |> Basics.clamp 1 daysInY))


fromWeekDate : WeekNumberingYear -> Int -> DayOfWeek -> CalendarDate
fromWeekDate givenWBY wn wd =
    let
        (WeekNumberingYear wy) =
            givenWBY

        weeksInWY =
            if is53WeekYear (Year wy) then
                53

            else
                52
    in
    CalendarDate <| daysBeforeWeekBasedYear givenWBY + ((wn |> Basics.clamp 1 weeksInWY) - 1) * 7 + (wd |> dayOfWeekToInt)



-- From elsewhere
--------------------------------------------------------------------------------
-- Extract


{-| Extract the month number of a date. Given the date 23 June 1990 this returns the integer 6.
-}
monthNumber : CalendarDate -> Int
monthNumber =
    month >> Month.toInt


{-| Extract the quarter of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 2.
-}
quarter : CalendarDate -> Int
quarter =
    month >> Month.toQuarter



-- COMPARISONS -------------------------------------------------------------NOTE


{-| Test the equality of two dates.

Note: There are also fuzzier forms of "sameness" available:
withinSameWeek
withinSameMonth
withinSameQuarter
withinSameYear

-}
equal : CalendarDate -> CalendarDate -> Bool
equal (CalendarDate a) (CalendarDate b) =
    a == b


{-| Compare two dates. This can be used as the compare function for
`List.sortWith`.
-}
compare : CalendarDate -> CalendarDate -> Order
compare (CalendarDate a) (CalendarDate b) =
    Basics.compare a b


{-| Test if a date is within a given range, inclusive of the range values. The
expression `Calendar.isBetween min max x` tests if `x` is between `min` and `max`.
-}
isBetween : CalendarDate -> CalendarDate -> CalendarDate -> Bool
isBetween (CalendarDate a) (CalendarDate b) (CalendarDate x) =
    a <= x && x <= b


withinSameYear : CalendarDate -> CalendarDate -> Bool
withinSameYear date1 date2 =
    year date1 == year date2


withinSameQuarter : CalendarDate -> CalendarDate -> Bool
withinSameQuarter date1 date2 =
    quarter date1 == quarter date2 && withinSameYear date1 date2


withinSameMonth : CalendarDate -> CalendarDate -> Bool
withinSameMonth date1 date2 =
    month date1 == month date2 && withinSameYear date1 date2


withinSameWeek : CalendarDate -> CalendarDate -> Bool
withinSameWeek date1 date2 =
    weekNumber date1 == weekNumber date2 && weekNumberingYear date1 == weekNumberingYear date2


monthBoundariesBetween : CalendarDate -> CalendarDate -> Int
monthBoundariesBetween date1 date2 =
    toMonths date2 - toMonths date1 |> truncate


yearBoundariesBetween : CalendarDate -> CalendarDate -> Int
yearBoundariesBetween date1 date2 =
    monthBoundariesBetween date1 date2 // 12


quarterBoundariesBetween : CalendarDate -> CalendarDate -> Int
quarterBoundariesBetween date1 date2 =
    -- TODO this is not correct!
    monthBoundariesBetween date1 date2 // 3


{-| Tells you how many new calendar weeks (starting on Sunday) you will enter when moving from one date to the other.

...But it's really just an alias for `countSpecificDOWBetween Sunday`, so if you want your weeks to start on `Monday`, feel free to switch to `countSpecificDOWBetween Monday`.

-}
weekBoundariesBetween date1 date2 =
    -- wrong!? this is the number of weeks between!
    -- diff Day date1 date2 // 7
    countSpecificDOWBetween Sun date1 date2


{-| How many Tuesdays are between two dates? How about thursdays?
This can figure that out for you. You specify the DayOfWeek, it adds them up.
-}
countSpecificDOWBetween : DayOfWeek -> CalendarDate -> CalendarDate -> Int
countSpecificDOWBetween dow date1 date2 =
    difference (toPrevious dow date1) (toPrevious dow date2) // 7



-- RANGES ----------------------------------------------------------------------


{-| Get the exact `Duration` between two dates!

If you're using this library for all of your date/time logic, this output will always be exactly correct, regardless of time zone, thanks to `Moment`'s pure (leap-second-free) approach.

(With other libraries however, you may be slightly off, because leap seconds happen at the same `Moment` globally and thus on different dates -- which may here be amplified to being off by entire days!)

-}
timeBetween : CalendarDate -> CalendarDate -> Duration
timeBetween calendarDate calendarDate2 =
    Duration.fromDays <| toFloat (subtract calendarDate calendarDate2)


{-| Clamp a date within a given range. The expression `Calendar.clamp min max x`
returns one of `min`, `max`, or `x`, ensuring the returned date is not before
`min` and not after `max`.
-}
clamp : CalendarDate -> CalendarDate -> CalendarDate -> CalendarDate
clamp (CalendarDate minimum) (CalendarDate maximum) (CalendarDate compareTo) =
    if compareTo < minimum then
        CalendarDate minimum

    else if compareTo > maximum then
        CalendarDate maximum

    else
        CalendarDate compareTo



--------------------------------------------------------------------------------
-- CalendarUnits
--- The question of "are these dates within 7 days of each other?" is fundamentally different from the question "are these dates in the same calendar week?". This section can help answer questions like the second one.
-- {-| Represents the various goalposts on a calendar.
-- Note that these are NOT units of time (in fact only `Week` could represent a non-changing unit of time). They are ranges of Dates, based on the way the calendar is shaped.
--
-- For example, if today is Tuesday, and you have the date for this
--
-- -}
--
--
-- type Boundaries
--     = Year
--     | Quarter
--     | Month
--     | Week
-- PTA : withinSameYear vs equalBy , conciseness
-- MOVING DATES ------------------------------------------------------------NOTE
-- NOTE shiftWeek unnecessary because you can just add `Days 7`


{-| Add a number of whole intervals to a date.
Calendar.add Week 2 (Calendar.fromParts 2007 Mar 15 11 55 0 0)
-- <29 March 2007, 11:55>
When adding Month, Quarter, or Year intervals, day values are clamped at the
end of the month if necessary.
Calendar.add Month 1 (Calendar.fromParts 2000 Jan 31 0 0 0 0)
-- <29 February 2000>
-}
shiftMonth : Int -> CalendarDate -> CalendarDate
shiftMonth shiftBy date =
    let
        (Year yearInt) =
            year date

        wholeMonths =
            12 * (yearInt - 1) + monthNumber date - 1 + shiftBy
    in
    fromParts
        { year = Year (wholeMonths // 12 + 1)
        , month = modBy 12 wholeMonths + 1 |> numberToMonth
        , day = dayOfMonth date
        }


shiftYear : Int -> CalendarDate -> CalendarDate
shiftYear n date =
    -- TODO No! this will not go from Feb 29 -> Feb 29 for example
    shiftMonth (n * 12) date


shiftQuarter : Int -> CalendarDate -> CalendarDate
shiftQuarter n date =
    -- TODO same as above
    shiftMonth (n * 3) date



-- "ROUNDING" DATES ------------------------------------------------------------


{-| How many days since last Tuesday?

    daysSincePrevious Tue today
    -- == 3

Returns the number of days since the last time it was the given `dayOfWeek`, from the standpoint of the given date.

-}
daysSincePrevious : DayOfWeek -> CalendarDate -> Int
daysSincePrevious givenDoW givenDate =
    let
        dayOfWeekAsInt =
            dayOfWeekToInt (dayOfWeek givenDate)
    in
    modBy 7 (dayOfWeekAsInt + 7 - dayOfWeekToInt givenDoW)


{-| Slide a date back to the given `DayOfWeek`.
-}
toPrevious : DayOfWeek -> CalendarDate -> CalendarDate
toPrevious givenDoW givenDate =
    let
        (CalendarDate givenDateRD) =
            givenDate
    in
    CalendarDate (givenDateRD - daysSincePrevious givenDoW givenDate)


{-| Slide a date forward to the given `DayOfWeek`.
-}
toNext : DayOfWeek -> CalendarDate -> CalendarDate
toNext givenDoW givenDate =
    let
        (CalendarDate givenDateRD) =
            givenDate
    in
    -- Don't call it cheating!
    toPrevious givenDoW (CalendarDate (givenDateRD + 7))



-- EXTRANEOUS ------------------------------------------------------------------


{-| The number of whole months between date and 0001-01-01 plus fraction
representing the current month. Only used for diffing months.
-}
toMonths : CalendarDate -> Float
toMonths date =
    --TODO don't expose
    let
        ( DayOfMonth dayInt, Year yearInt ) =
            ( dayOfMonth date, year date )

        wholeMonths =
            12 * (yearInt - 1) + Month.toInt (month date) - 1
    in
    -- TODO why was it: toFloat wholeMonths + (toFloat d / 100) + (fractionalDay date / 100)
    toFloat wholeMonths + (toFloat dayInt / 100)



-- {-| Round down a date to the beginning of the closest interval. The resulting
-- date will be less than or equal to the one provided.
-- Calendar.floor Hour
-- (Calendar.fromParts 1999 Dec 31 23 59 59 999)
-- -- <31 December 1999, 23:00>
-- -}
-- floor : CalendarUnit -> CalendarDate -> CalendarDate
-- floor interval date =
--     case interval of
--         Millisecond ->
--             date
--
--         Second ->
--             fromParts (year date) (month date) (day date) (hour date) (minute date) (second date) 0
--
--         Minute ->
--             fromParts (year date) (month date) (day date) (hour date) (minute date) 0 0
--
--         Hour ->
--             fromParts (year date) (month date) (day date) (hour date) 0 0 0
--
--         Day ->
--             fromCalendarDate (year date) (month date) (day date)
--
--         Month ->
--             fromCalendarDate (year date) (month date) 1
--
--         Year ->
--             fromCalendarDate (year date) Jan 1
--
--         Quarter ->
--             fromCalendarDate (year date) (date |> quarter |> quarterToMonth) 1
--
--         Week ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Mon date)
--
--         Monday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Mon date)
--
--         Tuesday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Tue date)
--
--         Wednesday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Wed date)
--
--         Thursday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Thu date)
--
--         Friday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Fri date)
--
--         Saturday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Sat date)
--
--         Sunday ->
--             fromRataDie ((date |> toRataDie) - daysSincePreviousWeekday Sun date)
--
--
-- {-| Round up a date to the beginning of the closest interval. The resulting
-- date will be greater than or equal to the one provided.
-- Calendar.ceiling Monday
-- (Calendar.fromParts 1999 Dec 31 23 59 59 999)
-- -- <3 January 2000>
-- -}
-- ceiling : CalendarUnit -> CalendarDate -> CalendarDate
-- ceiling interval date =
--     let
--         floored =
--             date |> floor interval
--     in
--     if toTime date == toTime floored then
--         date
--
--     else
--         floored |> add interval 1
--
-- {-| Returns the year milliseconds since Epoch. This basically
-- means that it will return the milliseconds that have elapsed from
-- the 1st Jan 1970 00:00:00.000 till the 1st Jan of the given `Year`.
--
-- **Note:** This function is intended to be used along with
-- millisSinceStartOfTheYear and millisSinceStartOfTheMonth in order
-- to get the total milliseconds elapsed since Epoch (1 Jan 1970 00:00:00.000).
--
--     millisSinceEpoch (Year 1970) -- 0 : Int
--
--     millisSinceEpoch (Year 1971) -- 31536000000 : Int
--
--     millisSinceEpoch (Year 2019) -- 1546300800000 : Int
--
-- -}
-- millisSinceEpoch : Year -> Int
-- millisSinceEpoch (Year givenYear) =
--     let
--         epochYear =
--             1970
--
--         getTotalMillis =
--             List.sum << List.map millisInYear << List.map Year
--     in
--     if givenYear >= 1970 then
--         -- We chose (givenYear - 1) here because we want the milliseconds
--         -- in the start of the target year in order to add
--         -- the months + days + hours + minutes + secs + millis if we want to.
--         getTotalMillis (List.range epochYear (givenYear - 1))
--
--     else
--         -- We chose (epochYear - 1) here because we want to
--         -- get the total milliseconds of all the previous years,
--         -- including the target year which we'll then add
--         -- the months + days + hours + minutes + secs + millis in millis
--         -- in order to get the desired outcome.
--         -- Example: Target date = 26 Aug 1950.
--         -- totalMillis from 1/1/1950 - 1/1/1969 = -631152000000
--         -- 26 Aug date millis = 20476800000
--         -- Resulting millis will be = -631152000000 + 20476800000 == -610675200000 == 26 Aug 1950
--         Basics.negate <| getTotalMillis (List.range givenYear (epochYear - 1))
--
--
-- {-| Returns the month milliseconds since the start of a given year. This basically
-- means that it will return the milliseconds that have elapsed since the start of the
-- given year till the 1st of the given month.
--
-- **Note:** This function is intended to be used along with millisSinceEpoch and
-- millisSinceStartOfTheMonth.
--
--     millisSinceStartOfTheYear (Year 2018) Jan -- 0 : Int
--
--     millisSinceStartOfTheYear (Year 2018) Dec -- 28857600000 : Int
--
-- -}
-- millisSinceStartOfTheYear : Year -> Month -> Int
-- millisSinceStartOfTheYear givenYear givenMonth =
--     List.foldl
--         (\m res ->
--             res + (millisInADay * dayToInt (Month.lastDay givenYear m))
--         )
--         0
--         (getPrecedingMonths givenMonth)
--
--
-- {-| Returns the `DayOfMonth` milliseconds since the start of a given month. This basically
-- means that it will return the milliseconds that have elapsed since the 1st day of
-- the given month till the given `DayOfMonth` at midnight hours.
--
-- **Note:** This function is intended to be used along with millisSinceEpoch and
-- millisSinceStartOfTheYear.
--
--     millisSinceStartOfTheMonth (DayOfMonth 1) -- 0 : Int
--
--     millisSinceStartOfTheMonth (DayOfMonth 15) -- 1209600000 : Int
--
-- -}
-- millisSinceStartOfTheMonth : DayOfMonth -> Int
-- millisSinceStartOfTheMonth day =
--     -- -1 on the day because we are currently on that day and it hasn't passed yet.
--     -- We also need time in order to construct the full posix.
--     millisInADay * (dayToInt day - 1)
--
--
-- {-| Returns the milliseconds in a year.
-- -}
-- millisInYear : Year -> Int
-- millisInYear givenYear =
--     if isLeapYear givenYear then
--         millisInADay * 366
--
--     else
--         millisInADay * 365
