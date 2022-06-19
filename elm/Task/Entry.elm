module Task.Entry exposing (..)

import Date exposing (Date)
import Helpers exposing (..)
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty as Nonempty exposing (Nonempty)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (Codec)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Result.Extra as Result
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Moment exposing (Moment)
import Task.ActionClass exposing (ActionClass, ActionClassID, ActionClassSkel, ParentProperties, makeFullActionClass, parentPropertiesCodec)
import Task.Series exposing (Series(..))


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.

We could eliminate all the redundant wrapper containers, but for now it's easier to just say:

  - Every "Entry" is a WrapperContainer.
  - Every TaskClass is in a FollowerContainer, no matter what

-}
type alias Entry =
    SuperProject


decodeEntry : Decoder Entry
decodeEntry =
    customDecoder Decode.value (Result.mapError (\e -> "") << Codec.decodeFromJson superProjectCodec)


encodeEntry entry =
    Codec.encodeToJson superProjectCodec entry



-- ...etc
{- type alias TaskTemplate =
   { title : String
   , completion : Progress
   , id : TaskTemplateID
   , minEffort : Duration
   , predictedEffort : Duration
   , maxEffort : Duration
   , tags : List TagId
   , activity : Maybe ActivityID -- ActionClass
   , deadline : Maybe FuzzyMoment -- ActionClass
   , plannedStart : Maybe FuzzyMoment -- PlannedSession
   , plannedFinish : Maybe FuzzyMoment -- PlannedSession
   , relevanceStarts : Maybe FuzzyMoment -- ActionClass, but relative? & Instance, absolute
   , relevanceEnds : Maybe FuzzyMoment -- ActionClass, but relative? & Instance, absolute
   , importance : Float -- ActionClass
   }
-}


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type alias ProjectClass =
    { properties : ParentProperties
    , recurrenceRules : RW (Maybe Series)
    , children : RepList TaskClass
    }


projectCodec : Codec String ProjectClass
projectCodec =
    Codec.record ProjectClass
        |> Codec.nestedField ( 1, "properties" ) .properties parentPropertiesCodec
        |> Codec.writableField ( 2, "recurrenceRules" ) .recurrenceRules (Codec.maybe (Codec.quickEnum Series [])) Nothing
        |> Codec.listField ( 3, "children" ) .children taskClassCodec
        |> Codec.finishRecord


{-| An "Unconstrained" group of tasks has no recurrence rules, but one or more of its children may be containers that do (RecurringParents). UnconstrainedParents may contain infinitely nested UnconstrainedParents, until the level at which a RecurringParent appears.
-}
type alias SuperProject =
    { properties : ParentProperties
    , children : RepList SuperProjectChild
    }


superProjectCodec : Codec String SuperProject
superProjectCodec =
    Codec.record SuperProject
        |> Codec.nestedField ( 1, "properties" ) .properties parentPropertiesCodec
        |> Codec.listField ( 2, "children" ) .children superProjectChildCodec
        |> Codec.finishRecord


type SuperProjectChild
    = ProjectIsDeeper SuperProject
    | ProjectIsHere ProjectClass


superProjectChildCodec : Codec String SuperProjectChild
superProjectChildCodec =
    Codec.customType
        (\leaderIsDeeper leaderIsHere value ->
            case value of
                ProjectIsDeeper wrapperParent ->
                    leaderIsDeeper wrapperParent

                ProjectIsHere leaderParent ->
                    leaderIsHere leaderParent
        )
        -- Note that removing a variant, inserting a variant before an existing one, or swapping two variants will prevent you from decoding any data you've previously encoded.
        |> Codec.variant1 ( 1, "ProjectIsDeeper" ) ProjectIsDeeper (Codec.lazy (\_ -> superProjectCodec))
        |> Codec.variant1 ( 2, "ProjectIsHere" ) ProjectIsHere projectCodec
        |> Codec.finishCustomType


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias TaskClass =
    { properties : ParentProperties
    , children : RepList TaskClassChild
    }


taskClassCodec : Codec String TaskClass
taskClassCodec =
    Codec.record TaskClass
        |> Codec.nestedField ( 1, "properties" ) .properties parentPropertiesCodec
        |> Codec.listField ( 2, "children" ) .children taskClassChildCodec
        |> Codec.finishRecord



{- every task must be wrapped in a parent, even if it's alone
   parents have instances, not tasks
   ...but then how to track the completion of the subtasks?
   by storing the subtask instances in a separate Dict, each tagged with the parent's instance ID.
    A failed lookup just means an incomplete task, defaults used for everything

   How can we let parents have parents?
   Well, we still only want one set of instances/recurrence in a given tree, so let's make "subparents" that still function as containers but have no recurrence rules or instances. Then any parent can contain either a subtask, or a subparent.

   ...Yeah, but the problem with that, is what if you want recurrence to happen at the level of one of the subparents? Say you have a project that is one-time but one of the sub-projects is supposed to repeat.

-}


type TaskClassChild
    = Singleton ActionClassID
    | Nested TaskClass


taskClassChildCodec : Codec String TaskClassChild
taskClassChildCodec =
    Codec.customType
        (\singleton nested value ->
            case value of
                Singleton classID ->
                    singleton classID

                Nested followerParent ->
                    nested followerParent
        )
        -- Note that removing a variant, inserting a variant before an existing one, or swapping two variants will prevent you from decoding any data you've previously encoded.
        |> Codec.variant1 ( 1, "Singleton" ) Singleton Codec.int
        |> Codec.variant1 ( 2, "Nested" ) Nested (Codec.lazy (\_ -> taskClassCodec))
        |> Codec.finishCustomType


{-| Take all the Entries and flatten them into a list of Classes
-}
getClassesFromEntries : ( List Entry, IntDict.IntDict ActionClassSkel ) -> ( List ActionClass, List Warning )
getClassesFromEntries ( entries, classes ) =
    let
        traverseRootWrappers entry =
            traverseWrapperParent (appendPropsIfMeaningful [] entry.properties) entry

        -- flatten the hierarchy if a container serves no purpose
        appendPropsIfMeaningful oldList newParentProps =
            if newParentProps.title.get /= Nothing then
                newParentProps :: oldList

            else
                oldList

        traverseWrapperParent accumulator parent =
            List.concatMap (traverseWrapperChild accumulator) (RepList.list parent.children)

        traverseLeaderParent accumulator parent =
            List.concatMap (traverseFollowerParent accumulator parent.recurrenceRules.get) (RepList.list parent.children)

        traverseFollowerParent accumulator recurrenceRules parent =
            -- TODO do we need to collect props here
            List.concatMap (traverseFollowerChild accumulator recurrenceRules) (RepList.list parent.children)

        traverseFollowerChild accumulator recurrenceRules child =
            case child of
                Singleton classID ->
                    case IntDict.get classID classes of
                        Just classSkel ->
                            List.singleton <| Ok <| makeFullActionClass accumulator recurrenceRules classSkel

                        Nothing ->
                            List.singleton <| Err <| LookupFailure classID

                Nested followerParent ->
                    traverseFollowerParent (appendPropsIfMeaningful accumulator followerParent.properties) recurrenceRules followerParent

        traverseWrapperChild accumulator child =
            case child of
                ProjectIsDeeper parent ->
                    traverseWrapperParent (appendPropsIfMeaningful accumulator parent.properties) parent

                ProjectIsHere parent ->
                    traverseLeaderParent (appendPropsIfMeaningful accumulator parent.properties) parent
    in
    Result.partition <| List.concatMap traverseRootWrappers entries


type Warning
    = LookupFailure ActionClassID
