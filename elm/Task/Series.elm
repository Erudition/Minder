module Task.Series exposing (..)

import Incubator.IntDict.Extra as IntDict
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import SmartTime.Moment exposing (..)
import SmartTime.Period exposing (Period)



-- SERIES - generate instances based on recurrence rules


type alias Series =
    { id : SeriesID
    , start : FuzzyMoment
    , end : Maybe FuzzyMoment
    , rule : RecurrenceRule
    }


type alias SeriesID =
    Int


type RecurrenceRule
    = RawTime { amount : Duration, start : Moment }
    | EveryNCalendarDays { n : Int, start : CalendarDate } -- Includes multiples, e.g. weeks
    | EveryNSpecificDayOfWeek { n : Int, day : DayOfWeek, start : CalendarDate }
    | EveryNthDayOfEachMonth { n : DayOfMonth, start : CalendarDate, ifOutOfBounds : OutOfMonthBoundsBehavior }
    | EveryCalendarDayOfYear { n : DayOfMonth, start : CalendarDate, ifOutOfBounds : OutOfMonthBoundsBehavior }
    | EveryNthDayOfYear { n : Int, start : CalendarDate } -- Includes multiples, e.g. weeks
    | EveryNthWeekOfYear { n : Int, day : DayOfWeek, start : CalendarDate } -- ISO Week numbers?


type OutOfMonthBoundsBehavior
    = SkipMonth
    | UseLastDay
