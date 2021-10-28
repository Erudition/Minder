module SmartTime.Human.Calendar.Series exposing (..)

{-| A `CalendarSeries` is a Series based only on `CalendarDate`. Dates in, dates out.
This means no need to pass a time, or more importantly, a `Zone`. This is perfect if you're dealing with data where you don't know (or care) about the zone or time in advance.
-}

import Set exposing (Set)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth, Month)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)



-- SERIES - generate instances based on recurrence rules


type alias CalendarSeries =
    { rules : List CalendarRecurrenceRule -- RRULE
    , additionalDates : List CalendarDate -- RDATE
    , exceptionDates : List CalendarDate -- EXDATE
    , exceptionRules : List CalendarRecurrenceRule -- Bonus feature, not supported by ical standard
    }


{-| A calendar-based recurrence rule.
Deals only with `CalendarDate`s, so no times or zones required.
Consists of a CalendarRecurrencePattern and a CalendarRange.
-}
type alias CalendarRecurrenceRule =
    { pattern : CalendarRecurrencePattern
    , range : CalendarRange
    }


{-| Set the applicable range for a recurrence rule.
Specify a start date, and how you want to stop:

  - recur indefinitely
  - recur until (and including!) an end date
  - recur only a fixed number of times

-}
type CalendarRange
    = Indefinitely { start : CalendarDate }
    | UntilDate { start : CalendarDate, stop : CalendarDate }
    | ThisMany { start : CalendarDate, count : Int }


{-| Calendar-based ways to recur.
-}
type CalendarRecurrencePattern
    = EveryNCalendarDays { n : Int } -- Includes multiples, e.g. weeks
    | EveryNSpecificDayOfWeek { n : Int, day : DayOfWeek }
    | EveryNthDayOfEachMonth { n : DayOfMonth, ifOutOfBounds : OutOfMonthBoundsBehavior }
    | EveryCalendarDayOfYear { n : DayOfMonth, ifOutOfBounds : OutOfMonthBoundsBehavior }
    | EveryNthDayOfYear { n : Int } -- Includes multiples, e.g. weeks
    | EveryNthWeekOfYear { n : Int, day : DayOfWeek } -- ISO Week numbers?


{-| RRULE has "FREQ" which is confusing.
"MONTHLY" rules can be far less frequent than "YEARLY" rules due to the syntax. Yet changing the FREQ would not change the baseline of "start by assuming every day".

Here we're explicit: We fill every day. Then, each rule you set filters out days until you have what you want.

Any empty List means it's ALL good.

-}
type alias CalendarRecurrencePattern2 =
    { interval : List EveryNth -- keep to one for RRULE support
    , months : List Month
    , daysOfMonth : List Int
    , daysOfWeek : List DayOfWeekInstance
    , daysOfYear : List Int
    , weekStart : DayOfWeek
    , filter : WhatToKeep
    }


type EveryNth
    = EveryNthYear Int
    | EveryNthMonth Int
    | EveryNthWeek Int
    | EveryNthDay Int


type DayOfWeekInstance
    = Every DayOfWeek
    | NthOfMonth DayOfWeek Int
    | NthOfYear DayOfWeek Int


type WhatToKeep
    = AllMatches
    | OnlyTheseMatches (Set Int)


type OutOfMonthBoundsBehavior
    = SkipMonth
    | UseLastDay


{-| Repeat every calendar day.
-}
everyDay : CalendarRecurrencePattern
everyDay =
    EveryNCalendarDays { n = 1 }


{-| Repeat every other calendar day.
-}
everyOtherDay : CalendarRecurrencePattern
everyOtherDay =
    EveryNCalendarDays { n = 2 }


{-| Repeat every seven days.
Note: The day of the week will be determined by your start date.
-}
everyWeek : CalendarRecurrencePattern
everyWeek =
    EveryNCalendarDays { n = 7 }
