module Task.Action exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID exposing (ID)
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
import Task.ActionSkel as ActionSkel exposing (ActionSkel)
import Task.Progress as Progress exposing (Progress)
import Task.Series exposing (Series)
import Task.SubAssignable exposing (SubAssignable)
import Task.SubAssignableSkel as SubAssignable exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


type Action
    = Action
        { subAssignable : SubAssignable
        , reg : Reg ActionSkel
        , id : ActionID
        }


type alias ActionID =
    ID (Reg ActionSkel)


fromSkel : SubAssignable -> Reg ActionSkel -> Action
fromSkel parent skelReg =
    Action
        { reg = skelReg
        , id = ID.fromPointer (Reg.getPointer skelReg)
        , subAssignable = parent
        }


id : Action -> ActionID
id (Action action) =
    action.id


title (Action action) =
    (Reg.latest action.reg).title.get


setTitle newTitle (Action action) =
    (Reg.latest action.reg).title.set newTitle


completionUnits (Action action) =
    (Reg.latest action.reg).completionUnits.get


defaultRelevanceStarts (Action action) =
    (Reg.latest action.reg).defaultRelevanceStarts


defaultRelevanceEnds (Action action) =
    (Reg.latest action.reg).defaultRelevanceEnds


defaultExternalDeadline (Action action) =
    (Reg.latest action.reg).defaultExternalDeadline


minEffort (Action action) =
    (Reg.latest action.reg).minEffort.get


setMinEffort newDur (Action action) =
    (Reg.latest action.reg).minEffort.set newDur


setEstimatedEffort newDur (Action action) =
    (Reg.latest action.reg).predictedEffort.set newDur


estimatedEffort (Action action) =
    (Reg.latest action.reg).predictedEffort.get


maxEffort (Action action) =
    (Reg.latest action.reg).maxEffort.get


setMaxEffort newDur (Action action) =
    (Reg.latest action.reg).maxEffort.set newDur


getExtra key (Action action) =
    RepDict.get key (Reg.latest action.reg).extra


setExtra key value (Action action) =
    RepDict.insert key value (Reg.latest action.reg).extra


activityID (Action action) =
    (Reg.latest action.reg).activity.get


activityIDString (Action action) =
    Maybe.map Activity.idToString (Reg.latest action.reg).activity.get


{-| only use if you need to make bulk changes
-}
reg (Action action) =
    action.reg
