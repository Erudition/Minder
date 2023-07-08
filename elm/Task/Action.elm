module Task.Action exposing (..)

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
import Replicated.Codec as Codec exposing (Codec, NullCodec, SkelCodec, WrappedCodec, coreRW, fieldDict, fieldList, fieldRW, maybeRW)
import Replicated.Reducer.Register as Reg exposing (RW, Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Progress as Progress exposing (..)
import Task.RelativeTiming as RelativeTiming exposing (RelativeTiming(..), relativeTimingCodec)
import Task.Series



--  BOTTOM LAYER: ACTIONS --------------------------------------


{-| every task must be wrapped in a parent, even if it's alone
parents have instances, tasks do not
...but then how to track the completion of the subtasks?
by storing the subtask instances in a separate Dict, each tagged with the parent's instance ID.
A failed lookup just means an incomplete task, defaults used for everything

How can we let parents have parents?
Well, we still only want one set of instances/recurrence in a given tree, so let's make "subparents" that still function as containers but have no recurrence rules or instances. Then any parent can contain either a subtask, or a subparent.

...Yeah, but the problem with that, is what if you want recurrence to happen at the level of one of the subparents? Say you have a project that is one-time but one of the sub-projects is supposed to repeat.

-}
type NestedOrAction
    = ActionIsHere (Reg ActionSkel)
    | ActionIsDeeper ContainerOfActions


nestedOrActionCodec : NullCodec String NestedOrAction
nestedOrActionCodec =
    Codec.customType
        (\singleton nested value ->
            case value of
                ActionIsHere action ->
                    singleton action

                ActionIsDeeper followerParent ->
                    nested followerParent
        )
        |> Codec.variant1 ( 1, "ActionIsHere" ) ActionIsHere codec
        |> Codec.variant1 ( 2, "ActionIsDeeper" ) ActionIsDeeper (Codec.lazy (\_ -> containerOfActionsCodec))
        |> Codec.finishCustomType


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias ContainerOfActions =
    { layerProperties : Reg TrackableLayerProperties
    , children : RepList NestedOrAction
    }


type alias ContainerOfActionsID =
    ID ContainerOfActions


containerOfActionsCodec : SkelCodec String ContainerOfActions
containerOfActionsCodec =
    Codec.record ContainerOfActions
        |> Codec.fieldReg ( 1, "layerProperties" ) .layerProperties trackableLayerPropertiesCodec
        |> Codec.fieldList ( 2, "children" ) .children nestedOrActionCodec
        |> Codec.finishRecord



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
    , layerProperties : Reg TrackableLayerProperties

    -- future: default Session strategy
    }


newActionSkel : Context (Reg ActionSkel) -> String -> Changer (Reg ActionSkel) -> Reg ActionSkel
newActionSkel c title changer =
    Codec.seededNewWithChanges codec c title changer


codec : Codec String ( String, Changer (Reg ActionSkel) ) Codec.SoloObject (Reg ActionSkel)
codec =
    Codec.record ActionSkel
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
        |> fieldDict ( 13, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.fieldReg ( 1, "layerProperties" ) .layerProperties trackableLayerPropertiesCodec
        |> Codec.finishSeededRegister



-- METAACTIONS --------------------------------


type alias ActionID =
    ID (Reg ActionSkel)


type alias Action =
    { parents : List (Reg TrackableLayerProperties)
    , action : Reg ActionSkel
    , actionID : ActionID
    }


makeFull : List (Reg TrackableLayerProperties) -> Reg ActionSkel -> Action
makeFull parentPropsRegList action =
    { parents = parentPropsRegList
    , action = action
    , actionID = ID.fromPointer (Reg.getPointer action)
    }



-- FOR ALL TRACKABLE LAYERS (assignables down to actions)


type alias TrackableLayerProperties =
    { title : RW (Maybe String) -- Can have no title if it's just a singleton task
    }


trackableLayerPropertiesCodec : WrappedCodec String (Reg TrackableLayerProperties)
trackableLayerPropertiesCodec =
    Codec.record TrackableLayerProperties
        |> fieldRW ( 1, "title" ) .title (Codec.maybe Codec.string) Nothing
        |> Codec.finishRegister