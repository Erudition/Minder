module SmartTime.Human.Calendar.Month exposing (DayOfMonth(..), Month(..), clampToValidDayOfMonth, compare, compareBasic, compareDays, dayOfMonthValidFor, dayToInt, daysBefore, fromInt, fromIntSafe, fromQuarter, getMonthsAfter, getMonthsBefore, intToAlwaysValidDay, intToDay, intToDayForced, lastDay, length, monthList, months, next, parseDayOfMonth, parseMonthInt, previous, toInt, toName, toQuarter)

import Array exposing (Array)
import Parser exposing ((|.), (|=), Parser, chompWhile, getChompedString, spaces, symbol)
import ParserExtra as Parser
import SmartTime.Human.Calendar.Year as Year exposing (Year)
import SmartTime.Moment exposing (TimelineOrder(..))


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


{-| Convert a given `Month` to an integer starting from 1.

    monthToInt Jan -- 1 : Int

    monthToInt Aug -- 8 : Int

-}
toInt : Month -> Int
toInt givenMonth =
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


{-| Gets the following month from the given month.

    Month.next Dec -- Jan : Month

    Month.next Nov -- Dec : Month

-}
next : Month -> Month
next givenMonth =
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


{-| Gets next month from the given month.

    previous Jan -- Dec : Month

    previous Dec -- Nov : Month

-}
previous : Month -> Month
previous givenMonth =
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


{-| An array of all the `Months` in Calendar order.

`Array` is faster than `List` for almost every operation, especially those you'd likely want to use on Months.

-}
months : Array Month
months =
    Array.fromList monthList


{-| A list of all the `Months` in Calendar order.

For numerous intense operations involving this list, use the Array, `months`. It's faster.

-}
monthList : List Month
monthList =
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


compare : Month -> Month -> TimelineOrder
compare lhs rhs =
    case Basics.compare (toInt lhs) (toInt rhs) of
        GT ->
            Later

        LT ->
            Earlier

        EQ ->
            Coincident


{-| The number of days in the given `Month`.

    Month.length (Year 2000) Feb -- 29

    Month.length (Year 2001) Feb -- 28

-}
length : Year -> Month -> Int
length givenYear m =
    case m of
        Jan ->
            31

        Feb ->
            if Year.isLeapYear givenYear then
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

    Month.daysBefore 2000 Mar -- 60

    Month.daysBefore 2001 Mar -- 59

-}
daysBefore : Year -> Month -> Int
daysBefore givenYear m =
    let
        leapDays =
            if Year.isLeapYear givenYear then
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

    Month.fromInt 1 -- Jan

-}
fromInt : Int -> Month
fromInt n =
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


{-| A safer `fromInt` that doesn't swallow out-of-bounds input.

    Month.fromIntSafe 12 -- Dec

    Month.fromIntSafe 14 -- Nothing

    Month.fromIntSafe 0 -- Nothing

    Month.fromIntSafe -74 -- Nothing

Perhaps you want to validate some user input or server response, failing on invalid data.

-}
fromIntSafe : Int -> Maybe Month
fromIntSafe n =
    case n of
        1 ->
            Just Jan

        2 ->
            Just Feb

        3 ->
            Just Mar

        4 ->
            Just Apr

        5 ->
            Just May

        6 ->
            Just Jun

        7 ->
            Just Jul

        8 ->
            Just Aug

        9 ->
            Just Sep

        10 ->
            Just Oct

        11 ->
            Just Nov

        12 ->
            Just Dec

        _ ->
            Nothing


{-| Compares two given `Months` and returns a Basics.Order.

    compareMonths Jan Feb -- LT : Order

    compareMonths Dec Feb -- GT : Order

    compareMonths Aug Aug --EQ : Order

-}
compareBasic : Month -> Month -> Order
compareBasic lhs rhs =
    Basics.compare (toInt lhs) (toInt rhs)


{-| Returns a list with all the following months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getFollowingMonths Aug -- [ Sep, Oct, Nov, Dec ] : List Month

    getFollowingMonths Dec -- [] : List Month

-}
getMonthsAfter : Month -> List Month
getMonthsAfter givenMonth =
    Array.toList <|
        Array.slice (toInt givenMonth) 12 months


{-| Returns a list with all the preceding months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getPrecedingMonths May -- [ Jan, Feb, Mar, Apr ] : List Month

    getPrecedingMonths Jan -- [] : List Month

-}
getMonthsBefore : Month -> List Month
getMonthsBefore givenMonth =
    Array.toList <|
        Array.slice 0 (toInt givenMonth - 1) months


{-| Get the last day of the given `Month`.

Of course, it could be a leap year, so you need to provide a `Year` as well:

    Month.lastDay (Year 2018) Dec -- 31 : Int

    Month.lastDay (Year 2019) Feb -- 28 : Int

    Month.lastDay (Year 2020) Feb -- 29 : Int

-}
lastDay : Year -> Month -> DayOfMonth
lastDay givenYear givenMonth =
    case givenMonth of
        Jan ->
            DayOfMonth 31

        Feb ->
            if Year.isLeapYear givenYear then
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


toQuarter : Month -> Int
toQuarter m =
    (toInt m + 2) // 3


fromQuarter : Int -> Month
fromQuarter q =
    q * 3 - 2 |> fromInt


toName : Month -> String
toName m =
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



------------------------------------------------------------------------------
-- Days of the month ---------------------------------------------------------


{-| The number that marks a day in a month - an integer from 1 to 31.

Of course, not all months have a full 31 days, so being wrapped in this type does not mean this `DayOfMonth` is valid!

Nomenclature: We could have called this type "Day", but "Tuesday" could also be called a "day", and so could "a 24-hour period", and so could "2020 December 25th". This name avoids that ambiguity.

-}
type DayOfMonth
    = DayOfMonth Int


{-| Extract the Int part of a 'DayOfMonth'.

    -- date == 26 Aug 1992
    dayToInt (dayOfMonth date) -- 26 : Int

-}
dayToInt : DayOfMonth -> Int
dayToInt (DayOfMonth day) =
    day


{-| Declare an `Int` as a `DayOfMonth`, or get `Nothing` if the number is greater than any month can hold (31).

Note that this does not necessarily mean this is a valid day of a certain month! Half of the months have less than 31 days, and there's no way to know how many days February has without knowing the year. So you can't know if a `CalendarDate` is valid without all three parts! That's what fromRawParts is for.

This function is useful if you want to move some of the error-handling logic for the `DayOfMonth` to the place where you receive the input ("fail fast"!) instead of the place where all three parts come together to be validated together.

-}
intToDay : Int -> Maybe DayOfMonth
intToDay int =
    if int >= 1 && int <= 31 then
        Just (DayOfMonth int)

    else
        Nothing


{-| Gives you a `DayOfMonth` no matter what - even if you pass in `72` or `-305` (clamping those to `DayOfMonth 31` and `DayOfMonth 1`, respectively).

Obviously this is dangerous, as it will silently swallow out-of-bounds errors in you code, which is hard to debug! You should consider using `intToDay` instead. Or, wait until you have all three parts and use `fromParts`, which will give you a truly validated date. This function will not, because the validity of a `DayOfMonth` depends on both the `Month` and the `Year`.

That said, if you're feeling confident that your `Int` is valid (especially if it's between 1 and 28), this is a great way to avoid dealing with `Maybe`. A great example is when you're hardcoding values:

    var firstOfTheMonth =
        intToDayForced 1

-}
intToDayForced : Int -> DayOfMonth
intToDayForced int =
    DayOfMonth (clamp 1 31 int)


{-| Gives you a _valid_ `DayOfMonth` no matter what - which means you can't use 29, 30, or 31 (as a month may not have them). Otherwise, it's the same as `intToDayForced`.
-}
intToAlwaysValidDay : Int -> DayOfMonth
intToAlwaysValidDay int =
    DayOfMonth (clamp 1 28 int)


{-| Construct a `DayOfMonth` that's guaranteed valid for the given `Month` in the given `Year`. It is only guaranteed valid for this specific combination, however.

    dayOfMonthFromInt (Year 2018) Dec 25 -- Just (DayOfMonth 25) : Maybe DayOfMonth

    dayOfMonthFromInt (Year 2020) Feb 29 -- Just (DayOfMonth 29) : Maybe DayOfMonth

    dayOfMonthFromInt (Year 2019) Feb 29 -- Nothing : Maybe DayOfMonth

-}
dayOfMonthValidFor : Year -> Month -> Int -> Maybe DayOfMonth
dayOfMonthValidFor givenYear givenMonth day =
    let
        maxValidDay =
            dayToInt (lastDay givenYear givenMonth)
    in
    if day > 0 && Basics.compare day maxValidDay /= GT then
        Just (DayOfMonth day)

    else
        Nothing


{-| Clamp a `DayOfMonth` so it's guaranteed valid for the given `Month` in the given `Year`. It is only guaranteed valid for this specific combination, however.
-}
clampToValidDayOfMonth : Year -> Month -> DayOfMonth -> DayOfMonth
clampToValidDayOfMonth givenYear givenMonth (DayOfMonth originalDay) =
    let
        targetMonthLength =
            length givenYear givenMonth
    in
    DayOfMonth (Basics.clamp 1 targetMonthLength originalDay)


{-| Compares two given `Days` and returns an Order.

    compareDays (DayOfMonth 28) (DayOfMonth 29) -- LT : Order

    compareDays (DayOfMonth 28) (DayOfMonth 15) -- GT : Order

    compareDays (DayOfMonth 15) (DayOfMonth 15) -- EQ : Order

-}
compareDays : DayOfMonth -> DayOfMonth -> Order
compareDays lhs rhs =
    Basics.compare (dayToInt lhs) (dayToInt rhs)


parseMonthInt : Parser Month
parseMonthInt =
    let
        checkMonth : Int -> Parser Month
        checkMonth givenInt =
            if givenInt >= 1 && givenInt <= 12 then
                Parser.succeed (fromInt givenInt)

            else
                Parser.problem <| "A month number should be from 1 to 12, but I got " ++ String.fromInt givenInt ++ " instead?"
    in
    Parser.possiblyPaddedInt |> Parser.andThen checkMonth


parseDayOfMonth : Parser DayOfMonth
parseDayOfMonth =
    Parser.map DayOfMonth Parser.possiblyPaddedInt
