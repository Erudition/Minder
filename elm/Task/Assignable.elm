module Task.Assignable exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Maybe.Extra
import Replicated.Change as Change exposing (Change, Changer, Creator)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment, Zone)
import SmartTime.Moment exposing (Moment, TimelineOrder(..))
import SmartTime.Period exposing (Period)
import Task.AssignableSkel as AssignableSkel exposing (AssignableSkel)
import Task.AssignmentSkel as AssignmentSkel exposing (AssignmentSkel)
import Task.Progress as Progress exposing (Progress)
import Task.Project as Project exposing (Project, ProjectID)
import Task.ProjectSkel as ProjectSkel exposing (NestedOrAssignable(..), ProjectID, ProjectSkel)
import Task.Series exposing (Series)
import Task.SubAssignableSkel as SubAssignable exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type Assignable
    = Assignable
        { project : Project
        , reg : Reg AssignableSkel
        , id : AssignableID
        }


type alias AssignableID =
    ID (Reg AssignableSkel)


type alias AssignableDb =
    RepDb (Reg AssignableSkel)


fromSkel : Project -> Reg AssignableSkel -> Assignable
fromSkel project assignableSkelReg =
    Assignable
        { reg = assignableSkelReg -- Reg because we may need earlier versions
        , id = ID.fromPointer (Reg.getPointer assignableSkelReg)
        , project = project
        }


createWithinProject : List (Changer Assignable) -> Project -> Change
createWithinProject changers parentProject =
    let
        assignableSkelChangers : List (Changer (Reg AssignableSkel))
        assignableSkelChangers =
            List.map (Change.mapChanger (fromSkel parentProject)) changers

        assignableSkelCreator : Changer (Reg AssignableSkel) -> Creator NestedOrAssignable
        assignableSkelCreator skelChanger =
            \wrappedContext ->
                AssignableSkel.create "this assignable title was not set upon creation"
                    skelChanger
                    -- TODO debug then just use Change.mapCreator
                    (Change.reuseContext "NestedOrAssignable" wrappedContext)
                    |> AssignableIsHere

        wrappedAssignableCreators : List (Creator NestedOrAssignable)
        wrappedAssignableCreators =
            List.map assignableSkelCreator assignableSkelChangers
    in
    RepList.insertNew RepList.Last wrappedAssignableCreators (Project.children parentProject)


id : Assignable -> AssignableID
id (Assignable metaAssignable) =
    metaAssignable.id


idString : Assignable -> String
idString (Assignable metaAssignable) =
    ID.toString metaAssignable.id


manualAssignments : Assignable -> RepDb (Reg AssignmentSkel)
manualAssignments (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).manualAssignments


title (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).title.get


setTitle newTitle (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).title.set newTitle


importance (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).importance.get


completionUnits (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).completionUnits.get


setImportance newImportance (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).importance.set newImportance


defaultRelevanceStarts (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).defaultRelevanceStarts


defaultRelevanceEnds (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).defaultRelevanceEnds


defaultExternalDeadline (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).defaultExternalDeadline


minEffort (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).minEffort.get


setMinEffort newDur (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).minEffort.set newDur


setEstimatedEffort newDur (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).predictedEffort.set newDur


estimatedEffort (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).predictedEffort.get


maxEffort (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).maxEffort.get


setMaxEffort newDur (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).maxEffort.set newDur


getExtra key (Assignable metaAssignable) =
    RepDict.get key (Reg.latest metaAssignable.reg).extra


setExtra key value (Assignable metaAssignable) =
    RepDict.insert key value (Reg.latest metaAssignable.reg).extra


insertExtras : List ( String, String ) -> Assignable -> Change
insertExtras keyValueList (Assignable metaAssignable) =
    RepDict.bulkInsert keyValueList (Reg.latest metaAssignable.reg).extra


activityID (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).activity.get


activityIDString (Assignable metaAssignable) =
    Maybe.map Activity.idToString (Reg.latest metaAssignable.reg).activity.get


setActivityID newActivityID (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).activity.set newActivityID


children (Assignable metaAssignable) =
    (Reg.latest metaAssignable.reg).children
