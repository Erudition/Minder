module Task.Entry exposing (..)

import Date exposing (Date)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty as Nonempty exposing (Nonempty)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (Codec, FlatCodec, NullCodec, SkelCodec, WrappedCodec)
import Replicated.Reducer.Register as Reg exposing (RW, Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Result.Extra as Result
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Moment exposing (Moment)
import Task.ActionClass exposing (ActionClass, ActionClassDb, ActionClassID, ActionClassSkel, ParentProperties, makeFullActionClass, parentPropertiesCodec)
import Task.AssignedAction exposing (AssignedAction)
import Task.Series exposing (Series(..))



--  TOPMOST LAYERS: ENTRIES & CONTAINERS OF ASSIGNABLES -------------------------------


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type alias RootEntry =
    NestedOrAssignable


codec =
    nestedOrAssignableCodec


{-| An "Unconstrained" group of tasks has no recurrence rules, but one or more of its children may be containers that do (RecurringParents). UnconstrainedParents may contain infinitely nested UnconstrainedParents, until the level at which a RecurringParent appears.
-}
type alias ContainerOfAssignables =
    { properties : Reg ParentProperties
    , children : RepList NestedOrAssignable
    }


containerOfAssignablesCodec : SkelCodec String ContainerOfAssignables
containerOfAssignablesCodec =
    Codec.record ContainerOfAssignables
        |> Codec.fieldReg ( 1, "properties" ) .properties parentPropertiesCodec
        |> Codec.fieldList ( 2, "children" ) .children nestedOrAssignableCodec
        |> Codec.finishRecord


type NestedOrAssignable
    = AssignableIsDeeper ContainerOfAssignables
    | AssignableIsHere (Reg Assignable)


nestedOrAssignableCodec : Codec.NullCodec String NestedOrAssignable
nestedOrAssignableCodec =
    Codec.customType
        (\leaderIsDeeper leaderIsHere value ->
            case value of
                AssignableIsDeeper wrapperParent ->
                    leaderIsDeeper wrapperParent

                AssignableIsHere leaderParent ->
                    leaderIsHere leaderParent
        )
        |> Codec.variant1 ( 1, "AssignableIsDeeper" ) AssignableIsDeeper (Codec.lazy (\_ -> containerOfAssignablesCodec))
        |> Codec.variant1 ( 2, "AssignableIsHere" ) AssignableIsHere assignableCodec
        |> Codec.finishCustomType



--  MIDDLE LAYER: ASSIGNABLES -------------------------------


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type alias Assignable =
    { properties : Reg ParentProperties
    , recurrenceRules : RW (Maybe Series)

    -- children can't be just a NestedOrAction (though that would make the single case simpler) because retroedits that add a sibling would overwrite the whole thing
    , children : RepList NestedOrAction
    }


assignableCodec : WrappedCodec String (Reg Assignable)
assignableCodec =
    Codec.record Assignable
        |> Codec.fieldReg ( 1, "properties" ) .properties parentPropertiesCodec
        |> Codec.fieldRW ( 2, "recurrenceRules" ) .recurrenceRules (Codec.maybe (Codec.quickEnum Series [])) Nothing
        |> Codec.fieldList ( 3, "children" ) .children nestedOrActionCodec
        |> Codec.finishRegister


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias ContainerOfActions =
    { properties : Reg ParentProperties
    , children : RepList NestedOrAction
    }


containerOfActionsCodec : SkelCodec String ContainerOfActions
containerOfActionsCodec =
    Codec.record ContainerOfActions
        |> Codec.fieldReg ( 1, "properties" ) .properties parentPropertiesCodec
        |> Codec.fieldList ( 2, "children" ) .children nestedOrActionCodec
        |> Codec.finishRecord



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
    = ActionIsHere (Reg ActionClassSkel)
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
        |> Codec.variant1 ( 1, "ActionIsHere" ) ActionIsHere Task.ActionClass.codec
        |> Codec.variant1 ( 2, "ActionIsDeeper" ) ActionIsDeeper (Codec.lazy (\_ -> containerOfActionsCodec))
        |> Codec.finishCustomType



--  TRAVERSE & FLATTEN LAYERS --------------------------------------


{-| Take all the Entries and flatten them into a list of Actions
-}
flattenEntriesToActions : RepList RootEntry -> List ActionClass
flattenEntriesToActions entries =
    List.concatMap traverseEntries (RepList.listValues entries)


traverseEntries : NestedOrAssignable -> List ActionClass
traverseEntries entry =
    insideContainerOfAssignables [] entry


traverseContainerOfAssignables : List (Reg ParentProperties) -> ContainerOfAssignables -> List ActionClass
traverseContainerOfAssignables accumulator parent =
    List.concatMap (insideContainerOfAssignables accumulator) (RepList.listValues parent.children)


insideContainerOfAssignables : List (Reg ParentProperties) -> NestedOrAssignable -> List ActionClass
insideContainerOfAssignables accumulator child =
    case child of
        AssignableIsDeeper parent ->
            traverseContainerOfAssignables (parent.properties :: accumulator) parent

        AssignableIsHere leaderClass ->
            traverseAssignable ((Reg.latest leaderClass).properties :: accumulator) leaderClass


traverseAssignable : List (Reg ParentProperties) -> Reg Assignable -> List ActionClass
traverseAssignable accumulator leaderParent =
    List.concatMap (insideContainerOfActions accumulator (Reg.latest leaderParent).recurrenceRules.get) (RepList.listValues (Reg.latest leaderParent).children)


traverseContainerOfActions : List (Reg ParentProperties) -> Maybe Series -> ContainerOfActions -> List ActionClass
traverseContainerOfActions accumulator recurrenceRules class =
    -- TODO do we need to collect props here
    List.concatMap (insideContainerOfActions accumulator recurrenceRules) (RepList.listValues class.children)


insideContainerOfActions : List (Reg ParentProperties) -> Maybe Series -> NestedOrAction -> List ActionClass
insideContainerOfActions accumulator recurrenceRules child =
    case child of
        ActionIsHere action ->
            -- we've reached the bottom
            List.singleton <| makeFullActionClass accumulator recurrenceRules action

        ActionIsDeeper followerParent ->
            traverseContainerOfActions (followerParent.properties :: accumulator) recurrenceRules followerParent



-- addActionToClass : ActionClassID -> ContainerOfActions -> Change
-- addActionToClass actionClassID classToModify =
--     let
--         taskClassChild =
--             ActionIsHere actionClassID
--     in
--     RepList.insert RepList.Last taskClassChild classToModify.children


initWithClass : Reg ActionClassSkel -> Change.Creator RootEntry
initWithClass actionSkelReg entryListParent =
    let
        -- initContainerOfActions : Change.Creator ContainerOfActions
        -- initContainerOfActions container =
        --     { properties = Codec.new parentPropertiesCodec container
        --     , children = Codec.newWithChanges (Codec.repList nestedOrActionCodec) container taskClassChildrenChanger
        --     }
        taskClassChildrenChanger : RepList NestedOrAction -> List Change
        taskClassChildrenChanger newChildren =
            [ RepList.insert RepList.Last (ActionIsHere actionSkelReg) newChildren
            ]

        assignableChanger : Change.Changer (Reg Assignable)
        assignableChanger newAssignable =
            taskClassChildrenChanger (Reg.latest newAssignable).children

        parentPropertiesChanger : Reg ParentProperties -> List Change
        parentPropertiesChanger newParentProperties =
            [ (Reg.latest newParentProperties).title.set <| Just "Entry title"
            ]
    in
    AssignableIsHere (Codec.newWithChanges assignableCodec (Change.reuseContext "AssignableIsHere" entryListParent) assignableChanger)



-- Todo list left off:
-- - how do I add a new Custom Type value to a RepList when the variant takes a nested type?
-- - how do I refer to the ID of an object that's being created in the same frame I want the reference made? update IDs to be pointers?
