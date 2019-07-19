module SmartTime.Human.Calendar.Week exposing (DayOfWeek(..), dayToInt, dayToName, numberToDay)


type DayOfWeek
    = Mon
    | Tue
    | Wed
    | Thu
    | Fri
    | Sat
    | Sun


{-|

    dayOfWeekToInt Mon -- 1

-}
dayToInt : DayOfWeek -> Int
dayToInt d =
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
numberToDay : Int -> DayOfWeek
numberToDay n =
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


dayToName : DayOfWeek -> String
dayToName d =
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
