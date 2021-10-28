module Task.Entry exposing (..)

import Date exposing (Date)
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty as Nonempty exposing (Nonempty)
import Porting exposing (..)
import Result.Extra as Result
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Moment exposing (Moment)
import Task.Class exposing (Class, ClassID, ClassSkel, ParentProperties, makeFullClass)
import Task.Series exposing (Series)


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.

We could eliminate all the redundant wrapper containers, but for now it's easier to just say:

  - Every "Entry" is a WrapperContainer.
  - Every TaskClass is in a FollowerContainer, no matter what

-}
type alias Entry =
    WrapperParent


newRootEntry : ClassID -> Entry
newRootEntry classID =
    let
        parentProps =
            ParentProperties <| Just "none"

        outsideWrap =
            WrapperParent parentProps (Nonempty.fromElement (LeaderIsHere leader))

        leader =
            LeaderParent parentProps Nothing (Nonempty.fromElement follower)

        follower =
            FollowerParent parentProps (Nonempty.fromElement (Singleton classID))
    in
    outsideWrap


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


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type alias LeaderParent =
    { properties : ParentProperties
    , recurrenceRules : Maybe Series
    , children : Nonempty FollowerParent
    }


{-| An "Unconstrained" group of tasks has no recurrence rules, but one or more of its children may be containers that do (RecurringParents). UnconstrainedParents may contain infinitely nested UnconstrainedParents, until the level at which a RecurringParent appears.
-}
type alias WrapperParent =
    { properties : ParentProperties
    , children : Nonempty WrapperChild
    }


type WrapperChild
    = LeaderIsDeeper WrapperParent
    | LeaderIsHere LeaderParent


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias FollowerParent =
    { properties : ParentProperties
    , children : Nonempty FollowerChild
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


type FollowerChild
    = Singleton ClassID
    | Nested FollowerParent


{-| Take all the Entries and flatten them into a list of Classes
-}
getClassesFromEntries : ( List Entry, IntDict.IntDict ClassSkel ) -> ( List Class, List Warning )
getClassesFromEntries ( entries, classes ) =
    let
        traverseRootWrappers entry =
            Nonempty.toList <| traverseWrapperParent (appendPropsIfMeaningful [] entry.properties) entry

        -- flatten the hierarchy if a container serves no purpose
        appendPropsIfMeaningful oldList newParentProps =
            if newParentProps.title /= Nothing then
                newParentProps :: oldList

            else
                oldList

        traverseWrapperParent accumulator parent =
            Nonempty.concatMap (traverseWrapperChild accumulator) parent.children

        traverseLeaderParent accumulator parent =
            Nonempty.concatMap (traverseFollowerParent accumulator parent.recurrenceRules) parent.children

        traverseFollowerParent accumulator recurrenceRules parent =
            -- TODO do we need to collect props here
            Nonempty.concatMap (traverseFollowerChild accumulator recurrenceRules) parent.children

        traverseFollowerChild accumulator recurrenceRules child =
            case child of
                Singleton classID ->
                    case IntDict.get classID classes of
                        Just classSkel ->
                            Nonempty.fromElement <| Ok <| makeFullClass accumulator recurrenceRules classSkel

                        Nothing ->
                            Nonempty.fromElement <| Err <| LookupFailure classID

                Nested followerParent ->
                    traverseFollowerParent (appendPropsIfMeaningful accumulator followerParent.properties) recurrenceRules followerParent

        traverseWrapperChild accumulator child =
            case child of
                LeaderIsDeeper parent ->
                    traverseWrapperParent (appendPropsIfMeaningful accumulator parent.properties) parent

                LeaderIsHere parent ->
                    traverseLeaderParent (appendPropsIfMeaningful accumulator parent.properties) parent
    in
    Result.partition <| List.concatMap traverseRootWrappers entries


type Warning
    = LookupFailure ClassID
