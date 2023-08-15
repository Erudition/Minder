module Task.ActionSkel exposing (..)

import Activity.Activity exposing (ActivityID)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode exposing (..)
import Json.Encode.Extra exposing (..)
import Replicated.Change exposing (Changer, Context)
import Replicated.Codec as Codec exposing (Codec, NullCodec, SkelCodec, WrappedCodec, coreRW, fieldDict, fieldList, fieldRW, fieldRWM)
import Replicated.Reducer.Register exposing (RW, RWMaybe, Reg)
import Replicated.Reducer.RepDict exposing (RepDict)
import Replicated.Reducer.RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import Task.Progress as Progress exposing (..)
import Task.RelativeTiming exposing (RelativeTiming(..), relativeTimingCodec)



--  BOTTOM LAYER: ACTIONS --------------------------------------
-- Single actions --------------------------------


{-| A TaskClass is an exact specific task, in general, without a time. If you took a shower yesterday, and you take a shower tomorrow, those are two separate TaskInstances - but they are instances of the same TaskClass ("take a shower").
This way, the same task can be assigned multiple times in life (either automatic recurrence, or by manually adding a new instance) and the program is aware they are the same thing.

Tasks that are only similar, e.g. "take a bath", should be separate TaskClasses.

-}
type alias ActionSkel =
    { title : RW String -- ActionClass
    , activity : RW (Maybe ActivityID)

    --, template : TaskTemplate
    , completionUnits : RW Progress.Unit
    , minEffort : RW Duration
    , predictedEffort : RW Duration
    , maxEffort : RW Duration
    , defaultExternalDeadline : RepList RelativeTiming
    , defaultStartBy : RepList RelativeTiming
    , defaultFinishBy : RepList RelativeTiming
    , defaultRelevanceStarts : RepList RelativeTiming
    , defaultRelevanceEnds : RepList RelativeTiming
    , extra : RepDict String String

    -- future: default Session strategy
    }


type alias ActionID =
    ID (Reg ActionSkel)


newActionSkel : Context (Reg ActionSkel) -> String -> Changer (Reg ActionSkel) -> Reg ActionSkel
newActionSkel c title changer =
    Codec.seededNewWithChanges codec c title changer


codec : Codec String ( String, Changer (Reg ActionSkel) ) Codec.SoloObject (Reg ActionSkel)
codec =
    Codec.record ActionSkel
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
        |> fieldDict ( 13, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.finishSeededRegister
