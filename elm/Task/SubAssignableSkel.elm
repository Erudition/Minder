module Task.SubAssignableSkel exposing (..)

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
import Task.ActionSkel exposing (ActionSkel)
import Task.Progress as Progress exposing (..)
import Task.RelativeTiming exposing (RelativeTiming(..), relativeTimingCodec)


type alias SubAssignableID =
    ID SubAssignableSkel


{-| every task must be wrapped in a parent, even if it's alone
parents have instances, tasks do not
...but then how to track the completion of the subtasks?
by storing the subtask instances in a separate Dict, each tagged with the parent's instance ID.
A failed lookup just means an incomplete task, defaults used for everything

How can we let parents have parents?
Well, we still only want one set of instances/recurrence in a given tree, so let's make "subparents" that still function as containers but have no recurrence rules or instances. Then any parent can contain either a subtask, or a subparent.

...Yeah, but the problem with that, is what if you want recurrence to happen at the level of one of the subparents? Say you have a project that is one-time but one of the sub-projects is supposed to repeat.

-}
type NestedSubAssignableOrSingleAction
    = ActionIsHere (Reg ActionSkel)
    | ActionIsDeeper (Reg SubAssignableSkel)


nestedOrActionCodec : NullCodec String NestedSubAssignableOrSingleAction
nestedOrActionCodec =
    Codec.customType
        (\singleton nested value ->
            case value of
                ActionIsHere action ->
                    singleton action

                ActionIsDeeper followerParent ->
                    nested followerParent
        )
        |> Codec.variant1 ( 1, "ActionIsHere" ) ActionIsHere Task.ActionSkel.codec
        |> Codec.variant1 ( 2, "ActionIsDeeper" ) ActionIsDeeper (Codec.lazy (\_ -> codec))
        |> Codec.finishCustomType


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias SubAssignableSkel =
    { title : RWMaybe String
    , children : RepList NestedSubAssignableOrSingleAction
    }


codec : WrappedCodec String (Reg SubAssignableSkel)
codec =
    Codec.record SubAssignableSkel
        |> Codec.fieldRWM ( 1, "title" ) .title Codec.string
        |> Codec.fieldList ( 2, "children" ) .children nestedOrActionCodec
        |> Codec.finishRegister
