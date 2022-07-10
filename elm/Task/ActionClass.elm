module Task.ActionClass exposing (..)

import Activity.Activity exposing (ActivityID)
import Dict exposing (Dict)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (Decoder)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (Codec, dictField, essentialWritable, listField, writableField)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Progress as Progress exposing (..)
import Task.Series


{-| A TaskClass is an exact specific task, in general, without a time. If you took a shower yesterday, and you take a shower tomorrow, those are two separate TaskInstances - but they are instances of the same TaskClass ("take a shower").
This way, the same task can be assigned multiple times in life (either automatic recurrence, or by manually adding a new instance) and the program is aware they are the same thing.

Tasks that are only similar, e.g. "take a bath", should be separate TaskClasses.

-}
type alias ActionClassSkel =
    { title : RW String -- ActionClass
    , activity : RW (Maybe ActivityID)

    --, template : TaskTemplate
    , completionUnits : RW Progress.Unit
    , minEffort : RW Duration -- Class. can always revise
    , predictedEffort : RW Duration -- Class. can always revise
    , maxEffort : RW Duration -- Class. can always revise

    --, tags : List TagId -- ActionClass
    , defaultExternalDeadline : RepList RelativeTiming
    , defaultStartBy : RepList RelativeTiming --  THESE ARE NORMALLY SPECIFIED AT THE INSTANCE LEVEL
    , defaultFinishBy : RepList RelativeTiming
    , defaultRelevanceStarts : RepList RelativeTiming
    , defaultRelevanceEnds : RepList RelativeTiming
    , importance : RW Float -- ActionClass
    , extra : RepDict String String

    -- future: default Session strategy
    }


actionClassSkelCodec : Codec String ActionClassSkel
actionClassSkelCodec =
    Codec.record ActionClassSkel
        |> essentialWritable ( 1, "title" ) .title Codec.string
        |> writableField ( 2, "activity" ) .activity (Codec.maybe ID.codec) Nothing
        |> writableField ( 3, "completionUnits" ) .completionUnits Progress.unitCodec Progress.Percent
        |> writableField ( 4, "minEffort" ) .minEffort Codec.duration Duration.zero
        |> writableField ( 5, "predictedEffort" ) .predictedEffort Codec.duration Duration.zero
        |> writableField ( 6, "maxEffort" ) .maxEffort Codec.duration Duration.zero
        |> listField ( 7, "defaultExternalDeadline" ) .defaultExternalDeadline relativeTimingCodec
        |> listField ( 8, "defaultStartBy" ) .defaultStartBy relativeTimingCodec
        |> listField ( 9, "defaultFinishBy" ) .defaultFinishBy relativeTimingCodec
        |> listField ( 10, "defaultRelevanceStarts" ) .defaultRelevanceStarts relativeTimingCodec
        |> listField ( 11, "defaultRelevanceEnds" ) .defaultRelevanceEnds relativeTimingCodec
        |> writableField ( 12, "importance" ) .importance Codec.float 1
        |> dictField ( 13, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.finishRecord


type alias ActionClassID =
    ID ActionClassSkel



-- FULL Task Classes (augmented with entry data) --------------------------


type alias ParentProperties =
    { title : RW (Maybe String) -- Can have no title if it's just a singleton task
    }


parentPropertiesCodec : Codec String ParentProperties
parentPropertiesCodec =
    Codec.record ParentProperties
        |> writableField ( 1, "title" ) .title (Codec.maybe Codec.string) Nothing
        |> Codec.finishRecord


{-| A fully spec'ed-out version of a ActionClass
-}
type alias ActionClass =
    { parents : List ParentProperties
    , recurrence : Maybe Task.Series.Series
    , class : ActionClassSkel
    , classID : ID ActionClassSkel
    , remove : Change
    }


makeFullActionClass : List ParentProperties -> Maybe Task.Series.Series -> RepDb.Member ActionClassSkel -> ActionClass
makeFullActionClass parentList recurrenceRules classSkelMember =
    { parents = parentList
    , recurrence = recurrenceRules
    , class = classSkelMember.value
    , classID = classSkelMember.id
    , remove = classSkelMember.remove
    }



-- Task Moments ------------------------------------------------------------


decodeTaskMoment : Decode.Decoder FuzzyMoment
decodeTaskMoment =
    customDecoder Decode.string HumanMoment.fuzzyFromString


{-| TODO make encoder
-}
encodeTaskMoment : FuzzyMoment -> Encode.Value
encodeTaskMoment fuzzy =
    Encode.string <| HumanMoment.fuzzyToString fuzzy


type alias TagId =
    Int



-- Task Timing functions


{-| Need to be able to specify multiple of these, as some may not apply.
-}
type RelativeTiming
    = FromDeadline Duration
    | FromToday Duration


relativeTimingCodec : Codec String RelativeTiming
relativeTimingCodec =
    Codec.customType
        (\fromDeadline fromToday value ->
            case value of
                FromDeadline duration ->
                    fromDeadline duration

                FromToday duration ->
                    fromToday duration
        )
        |> Codec.variant1 ( 1, "FromDeadline" ) FromDeadline Codec.duration
        |> Codec.variant1 ( 2, "FromToday" ) FromToday Codec.duration
        |> Codec.finishCustomType


decodeRelativeTiming : Decoder RelativeTiming
decodeRelativeTiming =
    Decode.map FromDeadline decodeDuration


encodeRelativeTiming : RelativeTiming -> Encode.Value
encodeRelativeTiming relativeTaskTiming =
    case relativeTaskTiming of
        FromDeadline duration ->
            encodeDuration duration

        FromToday duration ->
            encodeDuration duration



-- Task helper functions -------------------------------------------------------


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle
