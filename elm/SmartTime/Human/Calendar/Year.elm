module SmartTime.Human.Calendar.Year exposing (Year(..), compare, daysBefore, fromBCEYear, isBeforeCommonEra, isCommonEra, isLeapYear, parse4DigitYear, toAstronomicalString, toBCEYear, toClassicFormalString, toFormalString, toInt, toString)

import Parser exposing ((|.), (|=), Parser, chompWhile, getChompedString, spaces, symbol)
import ParserExtra as Parser


{-| A year on the Gregorian Calendar.

Again, since we can't use the type system to limit the Int you give, this library does the next best thing - it works for any year! Yes, even negative ones!

What do negative years mean? Just what you'd think - the years B.C.E., or before the Common Era. Hey, who knows, maybe you're an archeologist working with Elm! Two thousand years before 2010 CE (aka 2010 "A.D."), was year 10 CE. Twenty years before that was year 11 BCE.

Yes, that's eleven, not ten, because this whole system was invented long before "zero" was even invented. So the year before 1 AD/BCE is simply 1 BC(E). That makes off-by-one errors for all years below one (it seems the array-index-vs-array-length confusion was not our first foray into off-by-one!), throwing off calculations. Don't worry, we don't do any of that silliness here - there is a proper year zero, just like in ISO8601. "Year zero" is just the one before year 1, so 1 BCE. Do note that this means the year `-0001` is actually 2 BCE, and so on.

-}
type Year
    = Year Int


{-| Extract the Int value of a 'Year'.

    -- date == 26 Aug 1992
    Year.toInt (year date) -- 1992 : Int

-}
toInt : Year -> Int
toInt (Year givenYear) =
    givenYear


isCommonEra : Year -> Bool
isCommonEra (Year y) =
    y >= 1


isBeforeCommonEra : Year -> Bool
isBeforeCommonEra (Year y) =
    y <= 0


toBCEYear : Year -> Int
toBCEYear (Year negativeYear) =
    negate negativeYear + 1


fromBCEYear : Int -> Year
fromBCEYear positiveYear =
    Year (negate positiveYear - 1)


toString : Year -> String
toString ((Year yearInt) as year) =
    if isBeforeCommonEra year then
        String.fromInt (toBCEYear year) ++ " BCE"

    else
        String.fromInt yearInt


toFormalString : Year -> String
toFormalString ((Year yearInt) as year) =
    if isBeforeCommonEra year then
        String.fromInt yearInt ++ " CE"

    else
        String.fromInt (toBCEYear year) ++ " BCE"


toAstronomicalString : Year -> String
toAstronomicalString ((Year yearInt) as year) =
    String.fromInt yearInt


{-| Like `toFormalString`, but uses the Christian Era abbreviations instead.

(Note: AD goes [before the year](https://www.grammar-monster.com/lessons/abbreviations_AD_BC_BCE_CE.htm).)

-}
toClassicFormalString : Year -> String
toClassicFormalString ((Year yearInt) as year) =
    if isBeforeCommonEra year then
        "AD " ++ String.fromInt yearInt

    else
        String.fromInt (toBCEYear year) ++ " BC"


daysBefore : Year -> Int
daysBefore (Year givenYearInt) =
    let
        yearFromZero =
            givenYearInt - 1

        leapYears =
            (yearFromZero // 4) - (yearFromZero // 100) + (yearFromZero // 400)
    in
    365 * yearFromZero + leapYears


{-| Compares two given `Years` and returns an Order.

    Year.compare (Year 2016) (Year 2017) -- LT : Order

    Year.compare (Year 2017) (Year 2016) -- GT : Order

    Year.compare (Year 2015) (Year 2015) -- EQ : Order

-}
compare : Year -> Year -> Order
compare lhs rhs =
    Basics.compare (toInt lhs) (toInt rhs)


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


parse4DigitYear : Parser Year
parse4DigitYear =
    let
        toYearNum : Int -> Parser Year
        toYearNum num =
            Parser.succeed (Year num)
    in
    Parser.strictPaddedInt 4
        |> Parser.andThen toYearNum
