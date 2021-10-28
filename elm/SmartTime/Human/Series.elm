module SmartTime.Human.Series exposing (..)

{-| A `Series` is set of occurrences.

  - A series is made from recurrence rules, like "every sunday".
  - The set may be infinitely big, since rules may repeat indefinitely.
  - You can query whether a given moment is in the series.
  - You can turn a `Series` into a list of `Moment`s in time.

-}

import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)


type alias Series =
    ()
