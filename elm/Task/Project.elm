module Task.Project exposing (Project, ProjectID, children, createTopLevel, createTopLevelSkel, fromSkel, id, idString, setTitle, title)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Maybe.Extra
import Replicated.Change as Change exposing (Change, Changer)
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
import Task.Progress as Progress exposing (Progress)
import Task.ProjectSkel as ProjectSkel exposing (NestedOrAssignable(..), ProjectID, ProjectSkel)
import Task.Series exposing (Series)
import ZoneHistory exposing (ZoneHistory)


{-| Meta Project.
opaque type to allow easy refactoring - don't expose the reg!
-}
type Project
    = Project
        { reg : Reg ProjectSkel
        , id : ProjectID
        , parentProjectMaybe : Maybe Project
        }


type alias ProjectID =
    ProjectSkel.ProjectID


fromSkel : Maybe Project -> Reg ProjectSkel -> Project
fromSkel parentMaybe skelReg =
    Project
        { reg = skelReg
        , id = ID.fromPointer (Reg.getPointer skelReg)
        , parentProjectMaybe = parentMaybe
        }


id (Project project) =
    project.id


idString (Project project) =
    ID.toString project.id


title (Project project) =
    (Reg.latest project.reg).title.get


setTitle newTitle (Project project) =
    (Reg.latest project.reg).title.set newTitle


createTopLevel : Change.Changer Project -> Change.Creator Project
createTopLevel projectChanger =
    let
        skelWrapper =
            fromSkel Nothing

        projectSkelChanger : Changer (Reg ProjectSkel)
        projectSkelChanger =
            Change.mapChanger skelWrapper projectChanger
    in
    ProjectSkel.create projectSkelChanger
        |> Change.mapCreator skelWrapper


createTopLevelSkel : Change.Changer Project -> Change.Creator (Reg ProjectSkel)
createTopLevelSkel projectChanger =
    let
        skelWrapper =
            fromSkel Nothing

        projectSkelChanger : Changer (Reg ProjectSkel)
        projectSkelChanger =
            Change.mapChanger skelWrapper projectChanger
    in
    ProjectSkel.create projectSkelChanger


children : Project -> RepList NestedOrAssignable
children (Project project) =
    (Reg.latest project.reg).children



-- Task helper functions -------------------------------------------------------


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle
