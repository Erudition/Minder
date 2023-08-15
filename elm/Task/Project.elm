module Task.Project exposing (Project, ProjectID, fromSkel, id)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Maybe.Extra
import Replicated.Change as Change exposing (Change)
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
import Task.SubAssignable as SubAssignable exposing (SubAssignable, SubAssignableID)
import Task.SubAssignableSkel exposing (NestedSubAssignableOrSingleAction(..), SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


{-| Meta Project
-}
type Project
    = Project
        { reg : Reg ProjectSkel
        , id : ProjectID
        }


type alias ProjectID =
    ProjectSkel.ProjectID


fromSkel : Reg ProjectSkel -> Project
fromSkel reg =
    Project
        { reg = reg
        , id = ID.fromPointer (Reg.getPointer reg)
        }


id (Project project) =
    project.id



-- Task helper functions -------------------------------------------------------


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle
