module SmartTime.Human.Calendar.Month exposing (Month(..), compareMonths, daysBeforeMonth, daysInMonth, firstOfMonth, getFollowingMonths, monthToNumber, months, numberToMonth, rollMonthBackwards)

import Array exposing (Array)


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


{-| Gets the following month from the given month.

    nextMonth Dec -- Jan : Month

    nextMonth Nov -- Dec : Month

-}
nextMonth : Month -> Month
nextMonth givenMonth =
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


{-| Gets next month from the given month.

    rollMonthBackwards Jan -- Dec : Month

    rollMonthBackwards Dec -- Nov : Month

-}
rollBackwards : Month -> Month
rollBackwards givenMonth =
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


{-| Compares two given `Months` and returns an Order.

    compareMonths Jan Feb -- LT : Order

    compareMonths Dec Feb -- GT : Order

    compareMonths Aug Aug --EQ : Order

-}
compare : Month -> Month -> Order
compare lhs rhs =
    Basics.compare (monthToInt lhs) (monthToInt rhs)


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


{-| Get the last day of the given `Year` and `Month`.

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
    (monthToNumber m + 2) // 3


fromQuarter : Int -> Month
fromQuarter q =
    q * 3 - 2 |> numberToMonth


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


{-| Compares two given `Days` and returns an Order.

    compareDays (DayOfMonth 28) (DayOfMonth 29) -- LT : Order

    compareDays (DayOfMonth 28) (DayOfMonth 15) -- GT : Order

    compareDays (DayOfMonth 15) (DayOfMonth 15) -- EQ : Order

-}
compareDays : DayOfMonth -> DayOfMonth -> Order
compareDays lhs rhs =
    Basics.compare (dayToInt lhs) (dayToInt rhs)
