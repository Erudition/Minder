module ExtraCodecs exposing (..)

import ID exposing (ID)
import IntDict exposing (IntDict)
import Replicated.Codec as Codec exposing (Codec)
import Replicated.Op.OpID as OpID
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment, Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period(..))


id : Codec e (ID userType)
id =
    Codec.string
        |> Codec.map OpID.fromStringForced OpID.toString
        |> Codec.map ID.tag ID.read


calendarDate : Codec e CalendarDate
calendarDate =
    Codec.int |> Codec.map SmartTime.Human.Calendar.fromRataDie SmartTime.Human.Calendar.toRataDie


timeOfDay : Codec String TimeOfDay
timeOfDay =
    Codec.string |> Codec.mapValid SmartTime.Human.Clock.fromStandardString SmartTime.Human.Clock.toStandardString


duration : Codec String TimeOfDay
duration =
    Codec.int |> Codec.map Duration.fromInt Duration.inMs


humanDuration : Codec String HumanDuration
humanDuration =
    let
        convertAndNormalize durationAsInt =
            HumanDuration.inLargestExactUnits (Duration.fromInt durationAsInt)
    in
    Codec.int |> Codec.map convertAndNormalize (\hd -> Duration.inMs (HumanDuration.dur hd))


fuzzyMoment : Codec String FuzzyMoment
fuzzyMoment =
    Codec.string |> Codec.mapValid HumanMoment.fuzzyFromString HumanMoment.fuzzyToString


moment : Codec String Moment
moment =
    Codec.int |> Codec.map Moment.fromSmartInt Moment.toSmartInt


intDict : Codec String v -> Codec String (IntDict v)
intDict valueCodec =
    let
        keyValuePairCodec =
            Codec.tuple Codec.int valueCodec
    in
    Codec.immutableList keyValuePairCodec |> Codec.map IntDict.fromList IntDict.toList
