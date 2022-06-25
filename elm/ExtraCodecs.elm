module ExtraCodecs exposing (..)

import Replicated.Codec as Codec exposing (Codec)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Moment as Moment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period(..))


calendarDate : Codec e CalendarDate
calendarDate =
    Codec.int |> Codec.map SmartTime.Human.Calendar.fromRataDie SmartTime.Human.Calendar.toRataDie


timeOfDay : Codec String TimeOfDay
timeOfDay =
    Codec.string |> Codec.mapValid SmartTime.Human.Clock.fromStandardString SmartTime.Human.Clock.toStandardString


duration : Codec String TimeOfDay
duration =
    Codec.int |> Codec.map Duration.fromInt Duration.inMs
