module Task.Assignable exposing (..)

import Activity.Activity exposing (ActivityID)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra exposing (..)
import Replicated.Change exposing (Changer, Context)
import Replicated.Codec as Codec exposing (Codec, coreRW, fieldDict, fieldList, fieldRW, fieldRWM)
import Replicated.Reducer.Register exposing (RW, Reg)
import Replicated.Reducer.RepDb exposing (RepDb)
import Replicated.Reducer.RepDict exposing (RepDict)
import Replicated.Reducer.RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Assignment as Assignment exposing (ManualAssignmentDb)
import Task.Progress as Progress exposing (..)
import Task.RelativeTiming exposing (RelativeTiming(..), relativeTimingCodec)
import Task.SubAssignable exposing (NestedSubAssignableOrSingleAction(..), nestedOrActionCodec)



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
    , children : RepList NestedSubAssignableOrSingleAction
    , manualAssignments : ManualAssignmentDb

    -- future: default Session strategy
    }


new : Context (Reg AssignableSkel) -> String -> Changer (Reg AssignableSkel) -> Reg AssignableSkel
new c title changer =
    Codec.seededNewWithChanges codec c title changer


codec : Codec String ( String, Changer (Reg AssignableSkel) ) Codec.SoloObject (Reg AssignableSkel)
codec =
    Codec.record AssignableSkel
        |> coreRW ( 1, "title" ) .title Codec.string identity
        |> fieldRWM ( 2, "activity" ) .activity Activity.Activity.idCodec
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
        |> Codec.fieldList ( 14, "children" ) .children nestedOrActionCodec
        |> Codec.fieldDb ( 16, "manualAssignments" ) .manualAssignments Assignment.codec
        |> Codec.finishSeededRegister


type alias AssignableID =
    ID (Reg AssignableSkel)


type alias AssignableDb =
    RepDb (Reg AssignableSkel)



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
