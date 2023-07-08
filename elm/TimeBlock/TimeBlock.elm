module TimeBlock.TimeBlock exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import ExtraCodecs as Codec
import Helpers exposing (customDecoder)
import ID
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (decode)
import Json.Encode as Encode
import Replicated.Codec as Codec exposing (Codec, SelfSeededCodec)
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


type alias TimeBlockSeed =
    { focus : Focus
    , date : CalendarDate
    , startTime : TimeOfDay
    , duration : Duration
    }


codec : Codec String TimeBlockSeed Codec.SoloObject TimeBlock
codec =
    Codec.record TimeBlock
        |> Codec.coreRW ( 1, "focus" ) .focus focusCodec .focus
        |> Codec.coreRW ( 2, "date" ) .date Codec.calendarDate .date
        |> Codec.coreRW ( 3, "startTime" ) .startTime Codec.timeOfDay .startTime
        |> Codec.coreRW ( 4, "duration" ) .duration Codec.duration .duration
        |> Codec.finishSeededRecord


focusCodec : Codec.NullCodec String Focus
focusCodec =
    Codec.customType
        (\activityEncoder tagEncoder value ->
            case value of
                Activity activityID ->
                    activityEncoder activityID

                Tag tagID ->
                    tagEncoder tagID
        )
        |> Codec.variant1 ( 0, "Activity" ) Activity Activity.idCodec
        |> Codec.variant1 ( 1, "Tag" ) Tag Codec.string
        |> Codec.finishCustomType


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
