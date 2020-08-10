module Task.TaskEntry exposing (..)

import Activity.Activity exposing (ActivityID)
import Date
import ID
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import List.Nonempty exposing (Nonempty, map)
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import SmartTime.Moment as Moment exposing (..)
import Task.Progress as Progress exposing (..)


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type TaskEntry
    = SingletonTask TaskClass
    | OneoffContainer ConstrainedParent
    | RecurrenceContainer RecurringParent
    | NestedRecurrenceContainer UnconstrainedParent


type RelativeTaskTiming
    = FromDeadline Duration
    | FromToday Duration



-- ...etc
{- type alias TaskTemplate =
   { title : String
   , completion : Progress
   , id : TaskTemplateID
   , minEffort : Duration
   , predictedEffort : Duration
   , maxEffort : Duration
   , tags : List TagId
   , activity : Maybe ActivityID -- Class
   , deadline : Maybe FuzzyMoment -- Class
   , plannedStart : Maybe FuzzyMoment -- PlannedSession
   , plannedFinish : Maybe FuzzyMoment -- PlannedSession
   , relevanceStarts : Maybe FuzzyMoment -- Class, but relative? & Instance, absolute
   , relevanceEnds : Maybe FuzzyMoment -- Class, but relative? & Instance, absolute
   , importance : Float -- Class
   }
-}


type alias ParentProperties =
    { title : Maybe String -- Can have no title if it's just a singleton task
    }


type RecurrenceRule
    = CalendarRepeat Int --TODO


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type alias RecurringParent =
    { properties : ParentProperties
    , recurrenceRules : List RecurrenceRule
    , children : Nonempty ConstrainedParent
    }


{-| An "Unconstrained" group of tasks has no recurrence rules, but one or more of its children may be containers that do (RecurringParents). UnconstrainedParents may contain infinitely nested UnconstrainedParents, until the level at which a RecurringParent appears.
-}
type alias UnconstrainedParent =
    { properties : ParentProperties
    , children : Nonempty UnconstrainedChild
    }


type UnconstrainedChild
    = RecursDeeper UnconstrainedParent
    | RecursHere RecurringParent


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias ConstrainedParent =
    { properties : ParentProperties
    , children : Nonempty ConstrainedChild
    }



{- every task must be wrapped in a parent, even if it's alone
   parents have instances, not tasks
   ...but then how to track the completion of the subtasks?
   by storing the subtask instances in a separate Dict, each tagged with the parent's instance ID.
    A failed lookup just means an incomplete task, defaults used for everything

   How can we let parents have parents?
   Well, we still only want one set of instances/recurrence in a given tree, so let's make "subparents" that still function as containers but have no recurrence rules or instances. Then any parent can contain either a subtask, or a subparent.

   ...Yeah, but the problem with that, is what if you want recurrence to happen at the level of one of the subparents? Say you have a project that is one-time but one of the sub-projects is supposed to repeat.

-}


type ConstrainedChild
    = Singleton TaskClass
    | Nested ConstrainedParent



-- A very specific thing to be done, potentially multiple times in life


type alias TaskClass =
    { title : String -- Class

    --, template : TaskTemplate
    , completionUnits : Progress.Unit

    --, id : TaskId -- Class and Instance
    , minEffort : Duration -- Class. can always revise
    , predictedEffort : Duration -- Class. can always revise
    , maxEffort : Duration -- Class. can always revise

    --, history : List HistoryEntry -- remove?
    --, tags : List TagId -- Class
    , activity : Maybe ActivityID -- Class
    , defaultDeadline : List RelativeTaskTiming
    , defaultPlannedStart : List RelativeTaskTiming --  THESE ARE NORMALLY SPECIFIED AT THE INSTANCE LEVEL
    , defaultPlannedFinish : List RelativeTaskTiming
    , defaultRelevanceStarts : List RelativeTaskTiming
    , defaultRelevanceEnds : List RelativeTaskTiming
    , importance : Float -- Class
    }



-- One particular time that the specific thing will be done, that can be scheduled
-- A class could have NO instances yet - they're calculated on the fly


type alias TaskInstance =
    { class : TaskClassID
    , completion : Progress.Portion
    , id : TaskId -- Class and Instance
    , deadline : Maybe FuzzyMoment
    , plannedStart : Maybe FuzzyMoment -- PlannedSession
    , plannedFinish : Maybe FuzzyMoment -- PlannedSession
    , relevanceStarts : Maybe FuzzyMoment --  absolute
    , relevanceEnds : Maybe FuzzyMoment --  absolute
    }


getEntries : List TaskEntry -> List TaskClass
getEntries entries =
    let
        traverseRoot entry =
            case entry of
                SingletonTask taskClass ->
                    [ taskClass ]

                OneoffContainer constrainedParent ->
                    traverseConstrainedParent constrainedParent

                RecurrenceContainer recurringParent ->
                    traverseRecurringParent recurringParent

                NestedRecurrenceContainer unconstrainedParent ->
                    traverseUnconstrainedParent unconstrainedParent

        traverseConstrainedParent constrainedParent =
            List.concatMap traverseConstrainedChild (List.Nonempty.toList constrainedParent.children)

        traverseConstrainedChild child =
            case child of
                Singleton taskClass ->
                    [ taskClass ]

                Nested constrainedParent ->
                    traverseConstrainedParent constrainedParent

        traverseUnconstrainedParent unconstrainedParent =
            List.concatMap traverseUnconstrainedChild (List.Nonempty.toList unconstrainedParent.children)

        traverseUnconstrainedChild child =
            case child of
                RecursDeeper unconstrainedParent ->
                    traverseUnconstrainedParent unconstrainedParent

                RecursHere recurringParent ->
                    traverseRecurringParent recurringParent

        traverseRecurringParent recurringParent =
            List.concatMap traverseConstrainedParent (List.Nonempty.toList recurringParent.children)
    in
    List.concatMap traverseRoot entries
