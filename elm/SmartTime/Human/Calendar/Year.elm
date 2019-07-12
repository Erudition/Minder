module SmartTime.Human.Calendar.Year exposing (compareYears, daysBeforeYear, firstOfYear, is53WeekYear, year)

{-| A year on the Gregorian Calendar.

Again, since we can't use the type system to limit the Int you give, this library does the next best thing - it works for any year! Yes, even negative ones!

What do negative years mean? Just what you'd think - the years B.C.E., or before the Common Era. Hey, who knows, maybe you're an archeologist working with Elm! Two thousand years before 2010 CE (aka 2010 "A.D."), was year 10 CE. Twenty years before that was year 11 BCE.

Yes, that's eleven, not ten, because this whole system was invented long before "zero" was even invented. So the year before 1 AD/BCE is simply 1 BC(E). That makes off-by-one errors for all years below one (it seems the array-index-vs-array-length confusion was not our first foray into off-by-one!), throwing off calculations. Don't worry, we don't do any of that silliness here - there is a proper year zero, just like in ISO8601. "Year zero" is just the one before year 1, so 1 BCE. Do note that this means the year `-0001` is actually 2 BCE, and so on.

-}


type Year
    = Year Int


{-| Extract the Int value of a 'Year'.

    -- date == 26 Aug 1992
    yearToInt (year date) -- 1992 : Int

-}
yearToInt : Year -> Int
yearToInt (Year givenYear) =
    givenYear


daysBeforeYear : Year -> Int
daysBeforeYear (Year givenYearInt) =
    let
        y =
            givenYearInt - 1

        leapYears =
            (y // 4) - (y // 100) + (y // 400)
    in
    365 * y + leapYears


is53WeekYear : Year -> Bool
is53WeekYear givenYear =
    let
        jan1 =
            dayOfWeek (firstOfYear givenYear)
    in
    -- any year starting on Thursday and any leap year starting on Wednesday
    jan1 == Thu || (jan1 == Wed && isLeapYear givenYear)


{-| Compares two given `Years` and returns an Order.

    compareYears (Year 2016) (Year 2017) -- LT : Order

    compareYears (Year 2017) (Year 2016) -- GT : Order

    compareYears (Year 2015) (Year 2015) -- EQ : Order

-}
compareYears : Year -> Year -> Order
compareYears lhs rhs =
    Basics.compare (yearToInt lhs) (yearToInt rhs)


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
