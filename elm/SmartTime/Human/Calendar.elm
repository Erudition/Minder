module SmartTime.Human.Calendar exposing
    ( CalendarParts
    , fromRawParts, fromRawDay, fromYearMonthDay, dayOfMonthFromInt
    , toMillis, yearToInt, monthToInt, dayToInt
    , year, month, dayOfMonth
    , setYear, setMonth, setDayOfMonth
    , incrementYear, incrementMonth, incrementDay
    , decrementYear, decrementMonth, decrementDay
    , compare, compareYears, compareMonths, compareDays
    , getDateRange, getDatesInMonth, subtract, getFollowingMonths, getPrecedingMonths, dayOfWeek, isLeapYear, lastDayOf, millisInYear, sort
    , months, millisInADay
    , Year(..), Month(..), DayOfMonth(..)
    , millisSinceEpoch, millisSinceStartOfTheYear, millisSinceStartOfTheMonth
    , CalendarDate(..), DayOfWeek(..), OrdinalDay, WeekBasedYear(..), clamp, countSpecificDOWBetween, dayOfWeekToInt, daysBeforeMonth, daysBeforeWeekBasedYear, daysBeforeYear, daysInMonth, daysSincePreviousWeekday, difference, divideInt, equal, fromInts, fromMoment, fromOrdinalDate, fromOrdinalParts, fromParts, fromRataDie, fromWeekDate, fromWeekParts, intIsBetween, is53WeekYear, isBetween, monthBoundariesBetween, monthNumber, monthToName, monthToNumber, monthToQuarter, numberToDayOfWeek, numberToMonth, ordinalDay, quarter, quarterBoundariesBetween, quarterToMonth, rollDayBackwards, rollDayForward, rollMonthBackwards, rollMonthForward, shiftMonth, shiftQuarter, shiftYear, timeBetween, toMonths, toParts, toRataDie, weekBasedYear, weekBoundariesBetween, weekNumber, weekdayNumber, weekdayToName, withinSameMonth, withinSameQuarter, withinSameWeek, withinSameYear, yearBoundariesBetween
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

@docs Date, CalendarParts


# Creating values

@docs fromPosix, fromRawParts, fromRawDay, fromYearMonthDay, dayOfMonthFromInt


# Conversions

@docs toPosix, toMillis, yearToInt, monthToInt, dayToInt


# Accessors

@docs year, month, dayOfMonth


# Setters

@docs setYear, setMonth, setDayOfMonth


# Increment value

@docs incrementYear, incrementMonth, incrementDay


# Decrement values

@docs decrementYear, decrementMonth, decrementDay


# Compare values

@docs compare, compareYears, compareMonths, compareDays


# Utilities

@docs getDateRange, getDatesInMonth, subtract, getFollowingMonths, getPrecedingMonths, dayOfWeek, isLeapYear, lastDayOf, millisInYear, sort


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

import Array exposing (Array)
import Debug exposing (todo)
import SmartTime.Duration as Duration exposing (Duration, subtract)
import SmartTime.Moment as Moment exposing (Moment)


{-| A full ([Gregorian](https://en.wikipedia.org/wiki/Gregorian_calendar)) calendar date.

Unlike other Date libraries, the date is internally stored in its most efficient form - a single `Int`.

Since we can't use the type system to rule out invalid years, this type is built to handle any date you throw at it - even dates before the Gregorian calendar was introduced! (Such dates are actually said to be on the "propleptic" Gregorian Calendar, produced by extending the Gregorian formula backwards from 1582.) Before that most places used the "Julian calendar" instead - and if you're some sort of historian working with Elm who wants Julian support, let me know and I'll be happy to add it!

Note that the ISO standard says you should only use proleptic dates "with prior agreement with your information interchange partners". That said, if you're both using this library, everything will just work!

Nomenclature: We could have called this type "Day", but "Tuesday" could be called a "day", and so could "a 24-hour period", and so could the "3rd" in "March 3rd, 2023". This name avoids that ambiguity. We could also have called this "Date", but in many programming contexts this implies a type of data that specifies more than just a calendar day (i.e. a "DateTime" or a `Moment` in reality), such as how you can get the current time in JS with `new Date()` or how the unix command to get the unix time is `date`. [Another Elm library](https://package.elm-lang.org/packages/justinmimbs/elm-date-extra/3.0.0/Date-Extra) even combines this with a timezone! This name avoids any such implication.

-}
type CalendarDate
    = CalendarDate Int


type DayOfWeek
    = Mon
    | Tue
    | Wed
    | Thu
    | Fri
    | Sat
    | Sun


{-| The internal representation of Date and its constituent parts.
-}
type alias CalendarParts =
    { year : Year
    , month : Month
    , day : DayOfMonth
    }


toParts : CalendarDate -> CalendarParts
toParts date =
    { year = year date, month = month date, day = dayOfMonth date }


fromParts : CalendarParts -> CalendarDate
fromParts calendarParts =
    todo "fromParts"


fromRawParts : Int -> Month -> Int -> CalendarDate
fromRawParts y m d =
    CalendarDate <| daysBeforeYear (Year y) + daysBeforeMonth (Year y) m + (d |> Basics.clamp 1 (daysInMonth (Year y) m))


{-| A year on the Gregorian Calendar.

Again, since we can't use the type system to limit the Int you give, this library does the next best thing - it works for any year! Yes, even negative ones!

What do negative years mean? Just what you'd think - the years B.C.E., or before the Common Era. Hey, who knows, maybe you're an archeologist working with Elm! Two thousand years before 2010 CE (aka 2010 "A.D."), was year 10 CE. Twenty years before that was year 11 BCE.

Yes, that's eleven, not ten, because this whole system was invented long before "zero" was even invented. So the year before 1 AD/BCE is simply 1 BC(E). That makes off-by-one errors for all years below one (it seems the array-index-vs-array-length confusion was not our first foray into off-by-one!), throwing off calculations. Don't worry, we don't do any of that silliness here - there is a proper year zero, just like in ISO8601. "Year zero" is just the one before year 1, so 1 BCE. Do note that this means the year `-0001` is actually 2 BCE, and so on.

-}
type Year
    = Year Int


{-| A calendar month.
-}
type Month
    = Jan
    | Feb
    | Mar
    | Apr
    | May
    | Jun
    | Jul
    | Aug
    | Sep
    | Oct
    | Nov
    | Dec


{-| The number that marks a day in a month - an integer from 1 to 31 (or sometimes 29 or 30 or even 28).

Nomenclature: We could have called this type "Day", but "Tuesday" could also be called a "day", and so could "a 24-hour period", and so could "2020 December 25th". This name avoids that ambiguity.

-}
type DayOfMonth
    = DayOfMonth Int



-- Creating a `Date`


{-| Construct a [Date](Calendar#Date) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Date { day = DayOfMonth 1, month = Jan, year = Year 1970 } : Date

    fromPosix (Time.millisToPosix 1566795954000)
    -- Date { day = DayOfMonth 26, month = Aug, year = Year 2019 } : Date

    fromPosix (Time.millisToPosix 1566777600000)
    -- Date { day = DayOfMonth 26, month = Aug, year = Year 2019 } : Date

Notice that in the second and third examples the timestamps that are used are different but the resulting [Dates](Calendar#Date) are identical.
This is because the [Calendar](Calendar#) module doesn't have any knowledge of `Time` which means that if we attempt to convert both of these dates back [toMillis](Calendar#toMillis)
they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime#fromPosix) function provided in the [DateTime](DateTime#)
module if you need to preserve both `Date` and `Time`.

-}
fromMoment : Moment -> CalendarDate
fromMoment moment =
    todo "fromMoment"


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
            lastDayOf y m
    in
    case compareDays d maxDay of
        GT ->
            Nothing

        _ ->
            Just (fromParts { year = y, month = m, day = d })


{-| Attempt to construct a 'DayOfMonth' from an Int value. Currently the validity
of the day is based on the validity of the 'Date' object being created.
This means that given a valid year & month we check for the 'Date' max valid day.
Then the given Int needs to be greater than 0 and less than the max valid day
for the given year && month combination.
( 1 >= day >= maxValidDay )

    dayOfMonthFromInt (Year 2018) Dec 25 -- Just (DayOfMonth 25) : Maybe DayOfMonth

    dayOfMonthFromInt (Year 2020) Feb 29 -- Just (DayOfMonth 29) : Maybe DayOfMonth

    dayOfMonthFromInt (Year 2019) Feb 29 -- Nothing : Maybe DayOfMonth

-}
dayOfMonthFromInt : Year -> Month -> Int -> Maybe DayOfMonth
dayOfMonthFromInt givenYear givenMonth day =
    let
        maxValidDay =
            dayToInt (lastDayOf givenYear givenMonth)
    in
    if day > 0 && Basics.compare day maxValidDay /= GT then
        Just (DayOfMonth day)

    else
        Nothing



-- Conversions


{-| Transforms a [Date](Calendar#Date) into milliseconds.

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map toMillis date -- Just 1577232000000 == 25 Dec 2019 00:00:00.000

    want = 1566795954000 -- 26 Aug 2019 05:05:54.000
    got = toMillis (fromPosix (millisToPosix want)) -- 1566777600000 == 26 Aug 2019 00:00:00.000

    want == got -- False

Notice that transforming a **date** to milliseconds will always get you midnight hours.
The first example above will return a timestamp that equals to **Wed 25th of December 2019 00:00:00.000**
and the second example will return a timestamp that equals to **26th of August 2019 00:00:00.000** even though
the timestamp we provided in the [fromPosix](Calendar#fromPosix) was equal to **26th of August 2019 05:05:54.000**

-}
toMillis : CalendarDate -> Int
toMillis date =
    millisSinceEpoch (year date)
        + millisSinceStartOfTheYear (year date) (month date)
        + millisSinceStartOfTheMonth (dayOfMonth date)


{-| Extract the Int value of a 'Year'.

    -- date == 26 Aug 1992
    yearToInt (year date) -- 1992 : Int

-}
yearToInt : Year -> Int
yearToInt (Year givenYear) =
    givenYear


{-| Convert a given [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month) to an integer starting from 1.

    monthToInt Jan -- 1 : Int

    monthToInt Aug -- 8 : Int

Note: Obviously this function can be implemented in a dozen different approaches but decided to keep it simple.

-}
monthToInt : Month -> Int
monthToInt givenMonth =
    case givenMonth of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


{-| Extract the Int part of a 'DayOfMonth'.

    -- date == 26 Aug 1992
    dayToInt (dayOfMonth date) -- 26 : Int

-}
dayToInt : DayOfMonth -> Int
dayToInt (DayOfMonth day) =
    day



-- Accessors


{-| Extract the `Month` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    month date -- Dec : Month

-}
month : CalendarDate -> Month
month date =
    todo "get month"


{-| Extract the `DayOfMonth` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    dayOfMonth date -- DayOfMonth 25 : DayOfMonth

    dayToInt (dayOfMonth date) -- 25 : Int

-}
dayOfMonth : CalendarDate -> DayOfMonth
dayOfMonth date =
    todo "get DayOfMonth"


{-| Returns the weekday of a specific [CalendarDate](Calendar#CalendarDate).

    -- date == 26 Aug 2019
    dayOfWeek date -- Mon : DayOfWeek

-}
dayOfWeek : CalendarDate -> DayOfWeek
dayOfWeek date =
    todo "get DayOfWeek"



-- Setters


{-| Attempts to set the `Year` part of a [Date](Calendar#Date).

    -- date == 29 Feb 2020
    setYear 2024 date -- Just (29 Feb 2024) : Maybe Date

    setYear 2019 date -- Nothing : Maybe Date

-}
setYear : Int -> CalendarDate -> Maybe CalendarDate
setYear givenYear date =
    todo "set year"


{-| Attempts to set the `Month` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setMonth Aug date -- Just (31 Aug 2019) : Maybe Date

    setMonth Apr date -- Nothing : Maybe Date

-}
setMonth : Month -> CalendarDate -> Maybe CalendarDate
setMonth givenMonth date =
    todo "Set month"


{-| Attempts to set the `DayOfMonth` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setDayOfMonth 25 date -- Just (25 Jan 2019) : Maybe Date

    setDayOfMonth 32 date -- Nothing : Maybe Date

-}
setDayOfMonth : Int -> CalendarDate -> Maybe CalendarDate
setDayOfMonth day date =
    todo "setDayOfMonth"



-- Increment values


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
            Year (yearToInt (year givenDate) + 1)

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear (month givenDate)

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
            rollMonthForward (month givenDate)

        updatedYear =
            case updatedMonth of
                Jan ->
                    Year (yearToInt (year givenDate) + 1)

                _ ->
                    year givenDate

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear updatedMonth

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


{-| Gets next month from the given month.

    rollMonthForward Dec -- Jan : Month

    rollMonthForward Nov -- Dec : Month

-}
rollMonthForward : Month -> Month
rollMonthForward givenMonth =
    case givenMonth of
        Jan ->
            Feb

        Feb ->
            Mar

        Mar ->
            Apr

        Apr ->
            May

        May ->
            Jun

        Jun ->
            Jul

        Jul ->
            Aug

        Aug ->
            Sep

        Sep ->
            Oct

        Oct ->
            Nov

        Nov ->
            Dec

        Dec ->
            Jan


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



-- Decrement values


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
            Year (yearToInt (year givenDate) - 1)

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear (month givenDate)

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
                    Year (yearToInt (year givenDate) - 1)

                _ ->
                    year givenDate

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear updatedMonth

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


{-| Gets next month from the given month.

    rollMonthBackwards Jan -- Dec : Month

    rollMonthBackwards Dec -- Nov : Month

-}
rollMonthBackwards : Month -> Month
rollMonthBackwards givenMonth =
    case givenMonth of
        Jan ->
            Dec

        Feb ->
            Jan

        Mar ->
            Feb

        Apr ->
            Mar

        May ->
            Apr

        Jun ->
            May

        Jul ->
            Jun

        Aug ->
            Jul

        Sep ->
            Aug

        Oct ->
            Sep

        Nov ->
            Oct

        Dec ->
            Nov


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



-- Compare values


{-| Compares two given `Years` and returns an Order.

    compareYears (Year 2016) (Year 2017) -- LT : Order

    compareYears (Year 2017) (Year 2016) -- GT : Order

    compareYears (Year 2015) (Year 2015) -- EQ : Order

-}
compareYears : Year -> Year -> Order
compareYears lhs rhs =
    Basics.compare (yearToInt lhs) (yearToInt rhs)


{-| Compares two given `Months` and returns an Order.

    compareMonths Jan Feb -- LT : Order

    compareMonths Dec Feb -- GT : Order

    compareMonths Aug Aug --EQ : Order

-}
compareMonths : Month -> Month -> Order
compareMonths lhs rhs =
    Basics.compare (monthToInt lhs) (monthToInt rhs)


{-| Compares two given `Days` and returns an Order.

    compareDays (DayOfMonth 28) (DayOfMonth 29) -- LT : Order

    compareDays (DayOfMonth 28) (DayOfMonth 15) -- GT : Order

    compareDays (DayOfMonth 15) (DayOfMonth 15) -- EQ : Order

-}
compareDays : DayOfMonth -> DayOfMonth -> Order
compareDays lhs rhs =
    Basics.compare (dayToInt lhs) (dayToInt rhs)



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
            dayToInt (lastDayOf (year givenDate) (month givenDate))
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


{-| Returns a list with all the following months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getFollowingMonths Aug -- [ Sep, Oct, Nov, Dec ] : List Month

    getFollowingMonths Dec -- [] : List Month

-}
getFollowingMonths : Month -> List Month
getFollowingMonths givenMonth =
    Array.toList <|
        Array.slice (monthToInt givenMonth) 12 months


{-| Returns a list with all the preceding months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getPrecedingMonths May -- [ Jan, Feb, Mar, Apr ] : List Month

    getPrecedingMonths Jan -- [] : List Month

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths givenMonth =
    Array.toList <|
        Array.slice 0 (monthToInt givenMonth - 1) months


{-| Checks if the `Year` part of the given [CalendarDate](Calendar#CalendarDate) is a leap year.

    -- date  == 25 Dec 2019
    isLeapYear (year date) -- False

    -- date2 == 25 Dec 2020
    isLeapYear (year date2) -- True

-}
isLeapYear : Year -> Bool
isLeapYear (Year int) =
    -- y % 4 == 0 && y % 100 /= 0 || y % 400 == 0
    (modBy 4 int == 0) && ((modBy 400 int == 0) || not (modBy 100 int == 0))


{-| Get the last day of the given `Year` and `Month`.

    lastDayOf (Year 2018) Dec -- 31 : Int

    lastDayOf (Year 2019) Feb -- 28 : Int

    lastDayOf (Year 2020) Feb -- 29 : Int

-}
lastDayOf : Year -> Month -> DayOfMonth
lastDayOf givenYear givenMonth =
    case givenMonth of
        Jan ->
            DayOfMonth 31

        Feb ->
            if isLeapYear givenYear then
                DayOfMonth 29

            else
                DayOfMonth 28

        Mar ->
            DayOfMonth 31

        Apr ->
            DayOfMonth 30

        May ->
            DayOfMonth 31

        Jun ->
            DayOfMonth 30

        Jul ->
            DayOfMonth 31

        Aug ->
            DayOfMonth 31

        Sep ->
            DayOfMonth 30

        Oct ->
            DayOfMonth 31

        Nov ->
            DayOfMonth 30

        Dec ->
            DayOfMonth 31


{-| Returns the year milliseconds since Epoch. This basically
means that it will return the milliseconds that have elapsed from
the 1st Jan 1970 00:00:00.000 till the 1st Jan of the given `Year`.

**Note:** This function is intended to be used along with
millisSinceStartOfTheYear and millisSinceStartOfTheMonth in order
to get the total milliseconds elapsed since Epoch (1 Jan 1970 00:00:00.000).

    millisSinceEpoch (Year 1970) -- 0 : Int

    millisSinceEpoch (Year 1971) -- 31536000000 : Int

    millisSinceEpoch (Year 2019) -- 1546300800000 : Int

-}
millisSinceEpoch : Year -> Int
millisSinceEpoch (Year givenYear) =
    let
        epochYear =
            1970

        getTotalMillis =
            List.sum << List.map millisInYear << List.map Year
    in
    if givenYear >= 1970 then
        -- We chose (givenYear - 1) here because we want the milliseconds
        -- in the start of the target year in order to add
        -- the months + days + hours + minutes + secs + millis if we want to.
        getTotalMillis (List.range epochYear (givenYear - 1))

    else
        -- We chose (epochYear - 1) here because we want to
        -- get the total milliseconds of all the previous years,
        -- including the target year which we'll then add
        -- the months + days + hours + minutes + secs + millis in millis
        -- in order to get the desired outcome.
        -- Example: Target date = 26 Aug 1950.
        -- totalMillis from 1/1/1950 - 1/1/1969 = -631152000000
        -- 26 Aug date millis = 20476800000
        -- Resulting millis will be = -631152000000 + 20476800000 == -610675200000 == 26 Aug 1950
        Basics.negate <| getTotalMillis (List.range givenYear (epochYear - 1))


{-| Returns the month milliseconds since the start of a given year. This basically
means that it will return the milliseconds that have elapsed since the start of the
given year till the 1st of the given month.

**Note:** This function is intended to be used along with millisSinceEpoch and
millisSinceStartOfTheMonth.

    millisSinceStartOfTheYear (Year 2018) Jan -- 0 : Int

    millisSinceStartOfTheYear (Year 2018) Dec -- 28857600000 : Int

-}
millisSinceStartOfTheYear : Year -> Month -> Int
millisSinceStartOfTheYear givenYear givenMonth =
    List.foldl
        (\m res ->
            res + (millisInADay * dayToInt (lastDayOf givenYear m))
        )
        0
        (getPrecedingMonths givenMonth)


{-| Returns the `DayOfMonth` milliseconds since the start of a given month. This basically
means that it will return the milliseconds that have elapsed since the 1st day of
the given month till the given `DayOfMonth` at midnight hours.

**Note:** This function is intended to be used along with millisSinceEpoch and
millisSinceStartOfTheYear.

    millisSinceStartOfTheMonth (DayOfMonth 1) -- 0 : Int

    millisSinceStartOfTheMonth (DayOfMonth 15) -- 1209600000 : Int

-}
millisSinceStartOfTheMonth : DayOfMonth -> Int
millisSinceStartOfTheMonth day =
    -- -1 on the day because we are currently on that day and it hasn't passed yet.
    -- We also need time in order to construct the full posix.
    millisInADay * (dayToInt day - 1)


{-| Returns the milliseconds in a year.
-}
millisInYear : Year -> Int
millisInYear givenYear =
    if isLeapYear givenYear then
        millisInADay * 366

    else
        millisInADay * 365


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


{-| Returns a list of all the `Months` in Calendar order.
-}
months : Array Month
months =
    Array.fromList
        [ Jan
        , Feb
        , Mar
        , Apr
        , May
        , Jun
        , Jul
        , Aug
        , Sep
        , Oct
        , Nov
        , Dec
        ]


{-| The number of seconds in a day.

(It's 86 400, by the way. It may help to think of this song...)

-}
millisInADay : Int
millisInADay =
    1000 * 60 * 60 * 24


{-|

    daysInMonth 2000 Feb -- 29

    daysInMonth 2001 Feb -- 28

-}
daysInMonth : Year -> Month -> Int
daysInMonth givenYear m =
    case m of
        Jan ->
            31

        Feb ->
            if isLeapYear givenYear then
                29

            else
                28

        Mar ->
            31

        Apr ->
            30

        May ->
            31

        Jun ->
            30

        Jul ->
            31

        Aug ->
            31

        Sep ->
            30

        Oct ->
            31

        Nov ->
            30

        Dec ->
            31


{-|

    daysBeforeMonth 2000 Mar -- 60

    daysBeforeMonth 2001 Mar -- 59

-}
daysBeforeMonth : Year -> Month -> Int
daysBeforeMonth givenYear m =
    let
        leapDays =
            if isLeapYear givenYear then
                1

            else
                0
    in
    case m of
        Jan ->
            0

        Feb ->
            31

        Mar ->
            59 + leapDays

        Apr ->
            90 + leapDays

        May ->
            120 + leapDays

        Jun ->
            151 + leapDays

        Jul ->
            181 + leapDays

        Aug ->
            212 + leapDays

        Sep ->
            243 + leapDays

        Oct ->
            273 + leapDays

        Nov ->
            304 + leapDays

        Dec ->
            334 + leapDays


{-|

    monthToNumber Jan -- 1

-}
monthToNumber : Month -> Int
monthToNumber m =
    case m of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


{-|

    numberToMonth 1 -- Jan

-}
numberToMonth : Int -> Month
numberToMonth n =
    case max 1 n of
        1 ->
            Jan

        2 ->
            Feb

        3 ->
            Mar

        4 ->
            Apr

        5 ->
            May

        6 ->
            Jun

        7 ->
            Jul

        8 ->
            Aug

        9 ->
            Sep

        10 ->
            Oct

        11 ->
            Nov

        _ ->
            Dec


{-|

    dayOfWeekToInt Mon -- 1

-}
dayOfWeekToInt : DayOfWeek -> Int
dayOfWeekToInt d =
    case d of
        Mon ->
            1

        Tue ->
            2

        Wed ->
            3

        Thu ->
            4

        Fri ->
            5

        Sat ->
            6

        Sun ->
            7


{-|

    numberToDayOfWeek 1 -- Mon

-}
numberToDayOfWeek : Int -> DayOfWeek
numberToDayOfWeek n =
    case max 1 n of
        1 ->
            Mon

        2 ->
            Tue

        3 ->
            Wed

        4 ->
            Thu

        5 ->
            Fri

        6 ->
            Sat

        _ ->
            Sun



-- calculations


{-| Extract the `Year` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    year date -- Year 2019 : Year

    yearToInt (year date) -- 2019 : Int

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


{-| integer division, returning (Quotient, Remainder)
-}
divideInt : Int -> Int -> ( Int, Int )
divideInt a b =
    ( a // b, remainderBy a b )


{-| Extract the weekday number (beginning at 1 for Monday) of a date. Given
the date 23 June 1990 at 11:45 a.m. this returns the integer 6.
-}
weekdayNumber : CalendarDate -> Int
weekdayNumber (CalendarDate rd) =
    case modBy rd 7 of
        0 ->
            7

        n ->
            n


daysBeforeYear : Year -> Int
daysBeforeYear (Year givenYearInt) =
    let
        y =
            givenYearInt - 1

        leapYears =
            (y // 4) - (y // 100) + (y // 400)
    in
    365 * y + leapYears


daysBeforeWeekBasedYear : WeekBasedYear -> Int
daysBeforeWeekBasedYear (WeekBasedYear wby) =
    let
        jan4 =
            daysBeforeYear (Year wby) + 4
    in
    jan4 - weekdayNumber (CalendarDate jan4)


is53WeekYear : Int -> Bool
is53WeekYear y =
    let
        whatIsThis =
            daysBeforeYear (Year y) + 1

        wdnJan1 =
            weekdayNumber (CalendarDate whatIsThis)
    in
    -- any year starting on Thursday and any leap year starting on Wednesday
    wdnJan1 == 4 || (wdnJan1 == 3 && isLeapYear (Year y))


type WeekBasedYear
    = WeekBasedYear Int


{-| Extract the week-numbering year of a date. Given the date 23 June
1990 at 11:45 a.m. this returns the integer 1990.
-}
weekBasedYear : CalendarDate -> WeekBasedYear
weekBasedYear date =
    let
        (CalendarDate rd) =
            date

        (Year actuallyWeekBasedYear) =
            -- `year <thursday of this week>`
            year (CalendarDate (rd + (4 - weekdayNumber date)))
    in
    WeekBasedYear actuallyWeekBasedYear


{-| Extract the week number of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 25.
-}
weekNumber : CalendarDate -> Int
weekNumber date =
    let
        (CalendarDate rd) =
            date

        week1Day1 =
            daysBeforeWeekBasedYear (weekBasedYear date) + 1
    in
    (rd - week1Day1) // 7 + 1



-- constructors, strict


fromOrdinalParts : Year -> OrdinalDay -> Result String CalendarDate
fromOrdinalParts givenYear givenOrdinalDay =
    if
        (givenOrdinalDay |> intIsBetween 1 365)
            || (givenOrdinalDay == 366 && isLeapYear givenYear)
    then
        Ok <| CalendarDate <| daysBeforeYear givenYear + givenOrdinalDay

    else
        Err <| "Invalid ordinal date (" ++ String.fromInt (yearToInt givenYear) ++ ", " ++ String.fromInt givenOrdinalDay ++ ")"


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
        Ok <| CalendarDate <| daysBeforeYear givenYear + daysBeforeMonth givenYear (mn |> numberToMonth) + d

    else
        Err <| "Invalid calendar date (" ++ String.fromInt givenYearInt ++ ", " ++ String.fromInt mn ++ ", " ++ String.fromInt d ++ ")"


fromWeekParts : WeekBasedYear -> Int -> Int -> Result String CalendarDate
fromWeekParts givenWBY wn wdn =
    let
        (WeekBasedYear wby) =
            givenWBY
    in
    if
        (wdn |> intIsBetween 1 7)
            && ((wn |> intIsBetween 1 52)
                    || (wn == 53 && is53WeekYear wby)
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
    CalendarDate (daysBeforeYear givenYear + (od |> Basics.clamp 1 daysInY))


fromWeekDate : WeekBasedYear -> Int -> DayOfWeek -> CalendarDate
fromWeekDate givenWBY wn wd =
    let
        (WeekBasedYear wy) =
            givenWBY

        weeksInWY =
            if is53WeekYear wy then
                53

            else
                52
    in
    CalendarDate <| daysBeforeWeekBasedYear givenWBY + ((wn |> Basics.clamp 1 weeksInWY) - 1) * 7 + (wd |> dayOfWeekToInt)



-- From elsewhere
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
monthNumber : CalendarDate -> Int
monthNumber =
    month >> monthToNumber


{-| Extract the quarter of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 2.
-}
quarter : CalendarDate -> Int
quarter =
    month >> monthToQuarter


{-| the ordinal day of a date
-}
type alias OrdinalDay =
    Int


{-| Extract the ordinal day of a date. Given the date 23 June 1990 at
11:45 a.m. this returns the integer 174.
-}
ordinalDay : CalendarDate -> OrdinalDay
ordinalDay givenDate =
    let
        dayOfWeekAsInt =
            dayOfWeekToInt (dayOfWeek givenDate)
    in
    daysBeforeMonth (year givenDate) (month givenDate) + dayOfWeekAsInt



-- Me: huh?
-- {-| Extract the local offset from UTC time, in minutes, of a date. Given a date
-- with a local offset of UTC-05:00 this returns the integer -300.
-- -}
-- offsetFromUtc : CalendarDate -> Int
-- offsetFromUtc date =
--     let
--         localTime =
--             unixTimeFromRataDie (fromCalendarDate (year date) (month date) (day date))
--                 + msFromTimeParts (hour date) (minute date) (second date) (millisecond date)
--                 |> toFloat
--
--         utcTime =
--             date |> toTime
--     in
--     Basics.floor (localTime - utcTime) // msPerMinute
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


weekdayToName : DayOfWeek -> String
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


{-| Helper function that decides if we should 'roll' the CalendarDate forward due to a Clock.Time change.
-}
rollDayForward : Bool -> CalendarDate -> CalendarDate
rollDayForward shouldRoll date =
    if shouldRoll then
        incrementDay date

    else
        date


{-| Helper function that decides if we should 'roll' the CalendarDate backwards due to a Clock.Time change.
-}
rollDayBackwards : Bool -> CalendarDate -> CalendarDate
rollDayBackwards shouldRoll date =
    if shouldRoll then
        decrementDay date

    else
        date



--------------------------------------------------------------------------------
-- Rata Die


{-| -}
toRataDie : CalendarDate -> Int
toRataDie (CalendarDate int) =
    int


{-| -}
fromRataDie : Int -> CalendarDate
fromRataDie =
    CalendarDate



--------------------------------------------------------------------------------
-- Compare


{-| Test the equality of two dates.
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


{-| Get the exact `Duration` between two dates, which is the same regardless of time zone.
-}
timeBetween : CalendarDate -> CalendarDate -> Duration
timeBetween calendarDate calendarDate2 =
    Duration.fromDays <| toFloat (subtract calendarDate calendarDate2)



--------------------------------------------------------------------------------
-- CalendarUnits
--- The question of "are these dates within 7 days of each other?" is fundamentally different from the question "are these dates in the same calendar week?". This section can help answer questions like the second one.


{-| Represents the various goalposts on a calendar.
Note that these are NOT units of time (in fact only `Week` could represent a non-changing unit of time). They are ranges of Dates, based on the way the calendar is shaped.

For example, if today is Tuesday, and you have the date for this

-}



-- type Boundaries
--     = Year
--     | Quarter
--     | Month
--     | Week
-- PTA : withinSameYear vs equalBy , conciseness


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
    weekNumber date1 == weekNumber date2 && weekBasedYear date1 == weekBasedYear date2



--------------------------------------------------------------------------------
-- Arithmetic


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
    shiftMonth (n * 12) date


shiftQuarter : Int -> CalendarDate -> CalendarDate
shiftQuarter n date =
    shiftMonth (n * 3) date



-- NOTE shiftWeek unnecessary because you can just add `Days 7`


{-| The number of whole months between date and 0001-01-01 plus fraction
representing the current month. Only used for diffing months.
-}
toMonths : CalendarDate -> Float
toMonths date =
    let
        ( DayOfMonth dayInt, Year yearInt ) =
            ( dayOfMonth date, year date )

        wholeMonths =
            12 * (yearInt - 1) + monthToNumber (month date) - 1
    in
    -- TODO why was it: toFloat wholeMonths + (toFloat d / 100) + (fractionalDay date / 100)
    toFloat wholeMonths + (toFloat dayInt / 100)


{-| Find the difference, as a number of whole intervals, between two dates.
Calendar.diff Month
(Calendar.fromParts 2007 Mar 15 11 55 0 0)
(Calendar.fromParts 2007 Sep 1 0 0 0 0)
-- 5
-}



-- diff : CalendarUnit -> CalendarDate -> CalendarDate -> Int
-- diff interval date1 date2 =


monthBoundariesBetween : CalendarDate -> CalendarDate -> Int
monthBoundariesBetween date1 date2 =
    toMonths date2 - toMonths date1 |> truncate


yearBoundariesBetween : CalendarDate -> CalendarDate -> Int
yearBoundariesBetween date1 date2 =
    monthBoundariesBetween date1 date2 // 12


quarterBoundariesBetween : CalendarDate -> CalendarDate -> Int
quarterBoundariesBetween date1 date2 =
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
    -- diff Day (floor weekday date1) (floor weekday date2) // 7
    todo "count"



--------------------------------------------------------------------------------
-- Round


daysSincePreviousWeekday : DayOfWeek -> CalendarDate -> Int
daysSincePreviousWeekday wd date =
    modBy 7 (weekdayNumber date + 7 - dayOfWeekToInt wd)



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
