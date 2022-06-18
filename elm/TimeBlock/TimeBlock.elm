module TimeBlock.TimeBlock exposing (..)

import Activity.Activity exposing (ActivityID)
import Helpers exposing (customDecoder)
import ID
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (decode)
import Json.Encode as Encode
import Replicated.Codec as Codec exposing (Codec)
import Replicated.Reducer.Register as Register exposing (RW)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Moment as Moment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period(..))
import Tag exposing (Tag, TagID)


type alias TimeBlock =
    { focus : RW Focus
    , date : RW CalendarDate
    , startTime : RW TimeOfDay
    , duration : RW Duration
    }


type Focus
    = Activity ActivityID
    | Tag TagID


decodeTimeBlock : Decode.Decoder TimeBlock
decodeTimeBlock =
    customDecoder Decode.value (Result.mapError (\e -> "") << Codec.decodeFromJson codec)


encodeTimeBlock : TimeBlock -> Encode.Value
encodeTimeBlock timeBlock =
    Codec.encodeToJson codec timeBlock


codec : Codec String TimeBlock
codec =
    Codec.record TimeBlock
        |> Codec.fieldRW ( 1, "focus" ) .focus focusCodec (Activity (ID.ID 0))
        |> Codec.fieldRW ( 2, "date" ) .date dateCodec (Debug.todo "date")
        |> Codec.fieldRW ( 3, "startTime" ) .startTime timeCodec (Debug.todo "date")
        |> Codec.fieldRW ( 4, "duration" ) .duration durationCodec (Debug.todo "duration")
        |> Codec.finishRecord


focusCodec : Codec e Focus
focusCodec =
    Codec.customType
        (\activityEncoder tagEncoder value ->
            case value of
                Activity activityID ->
                    activityEncoder activityID

                Tag tagID ->
                    tagEncoder tagID
        )
        -- Note that removing a variant, inserting a variant before an existing one, or swapping two variants will prevent you from decoding any data you've previously encoded.
        |> Codec.variant1 ( 0, "Activity" ) Activity (Codec.map ID.tag ID.read Codec.int)
        |> Codec.variant1 ( 1, "Tag" ) Tag Codec.string
        |> Codec.finishCustomType


dateCodec : Codec e CalendarDate
dateCodec =
    Codec.int |> Codec.map SmartTime.Human.Calendar.fromRataDie SmartTime.Human.Calendar.toRataDie


timeCodec : Codec String TimeOfDay
timeCodec =
    Codec.string |> Codec.mapValid SmartTime.Human.Clock.fromStandardString SmartTime.Human.Clock.toStandardString


durationCodec : Codec String TimeOfDay
durationCodec =
    Codec.int |> Codec.map Duration.fromInt Duration.inMs


getPeriod : Zone -> TimeBlock -> Period
getPeriod zone timeBlock =
    let
        start =
            Moment.fromDateAndTime zone timeBlock.date.get timeBlock.startTime.get
    in
    Period.fromStart start timeBlock.duration.get


{-| Returns what activities are supposed to be worked on now, as well as the time when this information goes out of date
-}
relevantNow : Moment -> Zone -> List TimeBlock -> ( List Focus, Maybe Moment )
relevantNow now zone timeBlocks =
    let
        nowBlocks =
            List.filter isNow timeBlocks

        isNow block =
            Period.isWithin (getPeriod zone block) now

        endTime block =
            Period.end (getPeriod zone block)

        endingSoonestFirst =
            List.sortWith Moment.compareLateness <| List.map endTime nowBlocks
    in
    ( List.map (.focus >> .get) nowBlocks, List.head endingSoonestFirst )
