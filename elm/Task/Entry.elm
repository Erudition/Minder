module Task.Entry exposing (..)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty exposing (Nonempty)
import Porting exposing (..)
import SmartTime.Duration exposing (Duration)
import Task.Class exposing (Class, ClassSkel, makeFullClass)


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type Entry
    = SingletonTask ClassSkel
    | OneoffContainer ConstrainedParent
    | RecurrenceContainer RecurringParent
    | NestedRecurrenceContainer UnconstrainedParent


decodeEntry : Decoder Entry
decodeEntry =
    let
        get id =
            case id of
                "SingletonTask" ->
                    Debug.todo "Cannot decode variant with params: SingletonTask"

                "OneoffContainer" ->
                    Debug.todo "Cannot decode variant with params: OneoffContainer"

                "RecurrenceContainer" ->
                    Debug.todo "Cannot decode variant with params: RecurrenceContainer"

                "NestedRecurrenceContainer" ->
                    Debug.todo "Cannot decode variant with params: NestedRecurrenceContainer"

                _ ->
                    fail ("unknown value for Entry: " ++ id)
    in
    Decode.string |> Decode.andThen get



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
    = Singleton ClassSkel
    | Nested ConstrainedParent


getEntries : List Entry -> List Class
getEntries entries =
    let
        traverseRoot entry =
            case entry of
                SingletonTask taskClass ->
                    [ makeFullClass [] taskClass ]

                OneoffContainer constrainedParent ->
                    traverseConstrainedParent (appendPropsIfMeaningful [] constrainedParent.properties) constrainedParent

                RecurrenceContainer recurringParent ->
                    traverseRecurringParent (appendPropsIfMeaningful [] recurringParent.properties) recurringParent

                NestedRecurrenceContainer unconstrainedParent ->
                    traverseUnconstrainedParent (appendPropsIfMeaningful [] unconstrainedParent.properties) unconstrainedParent

        -- flatten the hierarchy if a container serves no purpose
        appendPropsIfMeaningful oldList newParentProps =
            if newParentProps.title /= Nothing then
                newParentProps :: oldList

            else
                oldList

        traverseConstrainedParent accumulator constrainedParent =
            -- TODO do we need to collect props here
            List.concatMap (traverseConstrainedChild accumulator) (List.Nonempty.toList constrainedParent.children)

        traverseUnconstrainedParent accumulator unconstrainedParent =
            List.concatMap (traverseUnconstrainedChild accumulator) (List.Nonempty.toList unconstrainedParent.children)

        traverseRecurringParent accumulator recurringParent =
            List.concatMap (traverseConstrainedParent accumulator) (List.Nonempty.toList recurringParent.children)

        traverseConstrainedChild accumulator child =
            case child of
                Singleton taskClass ->
                    [ makeFullClass accumulator taskClass ]

                Nested constrainedParent ->
                    traverseConstrainedParent (appendPropsIfMeaningful accumulator constrainedParent.properties) constrainedParent

        traverseUnconstrainedChild accumulator child =
            case child of
                RecursDeeper unconstrainedParent ->
                    traverseUnconstrainedParent (appendPropsIfMeaningful accumulator unconstrainedParent.properties) unconstrainedParent

                RecursHere recurringParent ->
                    traverseRecurringParent (appendPropsIfMeaningful accumulator recurringParent.properties) recurringParent
    in
    List.concatMap traverseRoot entries



-- Task Timing functions


{-| Need to be able to specify multiple of these, as some may not apply.
-}
type RelativeTiming
    = FromDeadline Duration
    | FromToday Duration


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
