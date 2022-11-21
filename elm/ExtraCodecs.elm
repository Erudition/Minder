module ExtraCodecs exposing (..)

import ID exposing (ID)
import IntDict exposing (IntDict)
import Replicated.Codec as Codec exposing (FlatCodec)
import Replicated.Op.OpID as OpID
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment, Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period(..))
import Replicated.Change exposing (Pointer(..))
import Log


-- id : FlatCodec e (ID userType)
-- id =
--     let
--         iDtoPointerToObjectID givenID =
--             case (ID.read givenID) of
--                 ExistingObjectPointer objectID _ ->
--                     objectID

--                 placeholderPointer ->
--                     -- Log.crashInDev ("ID should always be ObjectID before serializing. Tried to serialize the ID for pointer " ++ Log.dump placeholderPointer) 
--                     ((OpID.fromStringForced ("Uninitialized! " ++ Log.dump placeholderPointer)))
--     in
--     Codec.string
--         |> Codec.map OpID.fromStringForced OpID.toString
--         |> Codec.map (\oid -> ID.tag (ExistingObjectPointer oid identity)) (iDtoPointerToObjectID)


calendarDate : FlatCodec e CalendarDate
calendarDate =
    Codec.int |> Codec.map SmartTime.Human.Calendar.fromRataDie SmartTime.Human.Calendar.toRataDie


timeOfDay : FlatCodec String TimeOfDay
timeOfDay =
    Codec.string |> Codec.mapValid SmartTime.Human.Clock.fromStandardString SmartTime.Human.Clock.toStandardString


duration : FlatCodec String TimeOfDay
duration =
    Codec.int |> Codec.map Duration.fromInt Duration.inMs


humanDuration : FlatCodec String HumanDuration
humanDuration =
    let
        convertAndNormalize durationAsInt =
            HumanDuration.inLargestExactUnits (Duration.fromInt durationAsInt)
    in
    Codec.int |> Codec.map convertAndNormalize (\hd -> Duration.inMs (HumanDuration.dur hd))


fuzzyMoment : FlatCodec String FuzzyMoment
fuzzyMoment =
    Codec.string |> Codec.mapValid HumanMoment.fuzzyFromString HumanMoment.fuzzyToString


moment : FlatCodec String Moment
moment =
    Codec.int |> Codec.map Moment.fromSmartInt Moment.toSmartInt


intDict : FlatCodec String v -> FlatCodec String (IntDict v)
intDict valueCodec =
    let
        keyValuePairCodec =
            Codec.pair Codec.int valueCodec
    in
    Codec.primitiveList keyValuePairCodec |> Codec.map IntDict.fromList IntDict.toList