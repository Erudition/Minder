module ExtraCodecs exposing (..)

import ID exposing (ID)
import IntDict exposing (IntDict)
import Log
import Replicated.Change exposing (Pointer(..))
import Replicated.Codec as Codec exposing (Codec, PrimitiveCodec)
import Replicated.Op.ID as OpID
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment, Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period(..))


calendarDate : PrimitiveCodec e CalendarDate
calendarDate =
    Codec.int |> Codec.map SmartTime.Human.Calendar.fromRataDie SmartTime.Human.Calendar.toRataDie


timeOfDay : PrimitiveCodec String TimeOfDay
timeOfDay =
    Codec.string |> Codec.mapValid SmartTime.Human.Clock.fromStandardString SmartTime.Human.Clock.toStandardString


duration : PrimitiveCodec String TimeOfDay
duration =
    Codec.int |> Codec.map Duration.fromInt Duration.inMs


humanDuration : PrimitiveCodec String HumanDuration
humanDuration =
    let
        convertAndNormalize durationAsInt =
            HumanDuration.inLargestExactUnits (Duration.fromInt durationAsInt)
    in
    Codec.int |> Codec.map convertAndNormalize (\hd -> Duration.inMs (HumanDuration.dur hd))


fuzzyMoment : PrimitiveCodec String FuzzyMoment
fuzzyMoment =
    Codec.string |> Codec.mapValid HumanMoment.fuzzyFromString HumanMoment.fuzzyToString


moment : PrimitiveCodec String Moment
moment =
    Codec.int |> Codec.map Moment.fromSmartInt Moment.toSmartInt


intDict : Codec e s o v -> Codec.NullCodec e (IntDict v)
intDict valueCodec =
    let
        keyValuePairCodec =
            Codec.pair Codec.int valueCodec
    in
    Codec.list keyValuePairCodec |> Codec.map IntDict.fromList IntDict.toList
