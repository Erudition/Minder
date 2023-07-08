module Task.Assignable exposing (..)

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
import NativeScript.Notification exposing (Action)
import Replicated.Change as Change exposing (Change, Changer, Context)
import Replicated.Codec as Codec exposing (Codec, SelfSeededCodec, WrappedCodec, coreRW, fieldDict, fieldList, fieldRW, maybeRW)
import Replicated.Reducer.Register as Reg exposing (RW, Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Action as Action exposing (Action, NestedOrAction(..), TrackableLayerProperties, nestedOrActionCodec, trackableLayerPropertiesCodec)
import Task.Progress as Progress exposing (..)
import Task.RelativeTiming as RelativeTiming exposing (RelativeTiming(..), relativeTimingCodec)
import Task.Series



--  MIDDLE LAYER: ASSIGNABLES -------------------------------


{-| A TaskClass is an exact specific task, in general, without a time. If you took a shower yesterday, and you take a shower tomorrow, those are two separate TaskInstances - but they are instances of the same TaskClass ("take a shower").
This way, the same task can be assigned multiple times in life (either automatic recurrence, or by manually adding a new instance) and the program is aware they are the same thing.

Tasks that are only similar, e.g. "take a bath", should be separate TaskClasses.

-}
type alias AssignableSkel =
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
    , children : RepList NestedOrAction
    , layerProperties : Reg TrackableLayerProperties

    -- future: default Session strategy
    }


newAssignableSkel : Context (Reg AssignableSkel) -> String -> Changer (Reg AssignableSkel) -> Reg AssignableSkel
newAssignableSkel c title changer =
    Codec.seededNewWithChanges codec c title changer


codec : Codec String ( String, Changer (Reg AssignableSkel) ) Codec.SoloObject (Reg AssignableSkel)
codec =
    Codec.record AssignableSkel
        |> coreRW ( 1, "title" ) .title Codec.string identity
        |> maybeRW ( 2, "activity" ) .activity Activity.Activity.idCodec
        |> fieldRW ( 3, "completionUnits" ) .completionUnits Progress.unitCodec Progress.Percent
        |> fieldRW ( 4, "minEffort" ) .minEffort Codec.duration Duration.zero
        |> fieldRW ( 5, "predictedEffort" ) .predictedEffort Codec.duration Duration.zero
        |> fieldRW ( 6, "maxEffort" ) .maxEffort Codec.duration Duration.zero
        |> fieldList ( 7, "defaultExternalDeadline" ) .defaultExternalDeadline relativeTimingCodec
        |> fieldList ( 8, "defaultStartBy" ) .defaultStartBy relativeTimingCodec
        |> fieldList ( 9, "defaultFinishBy" ) .defaultFinishBy relativeTimingCodec
        |> fieldList ( 10, "defaultRelevanceStarts" ) .defaultRelevanceStarts relativeTimingCodec
        |> fieldList ( 11, "defaultRelevanceEnds" ) .defaultRelevanceEnds relativeTimingCodec
        |> fieldRW ( 12, "importance" ) .importance Codec.float 1
        |> fieldDict ( 13, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.fieldList ( 3, "children" ) .children nestedOrActionCodec
        |> Codec.fieldReg ( 1, "layerProperties" ) .layerProperties trackableLayerPropertiesCodec
        |> Codec.finishSeededRegister


type alias AssignableID =
    ID (Reg AssignableSkel)


type alias AssignableDb =
    RepDb (Reg AssignableSkel)



-- FULL Task Classes (augmented with entry data) --------------------------


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type alias Assignable =
    { parents : List (Reg TrackableLayerProperties)
    , assignable : Reg AssignableSkel
    , assignableID : AssignableID
    }


makeFull : List (Reg TrackableLayerProperties) -> Reg AssignableSkel -> Assignable
makeFull parentPropsRegList action =
    { parents = parentPropsRegList
    , assignable = action
    , assignableID = ID.fromPointer (Reg.getPointer action)
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



-- Task helper functions -------------------------------------------------------


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle
