module Task.AssignedAction exposing (..)

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
import Task.Action as Action exposing (Action, ActionID)
import Task.AssignableSkel as Assignable exposing (AssignableID, AssignableSkel)
import Task.AssignedActionSkel exposing (AssignedActionSkel)
import Task.Assignment as Assignment exposing (Assignment, AssignmentID(..))
import Task.Progress as Progress exposing (Progress)
import Task.ProjectSkel as Project exposing (NestedOrAssignable(..), ProjectID, ProjectSkel)
import Task.Series exposing (Series)
import Task.SubAssignableSkel as SubAssignable exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


{-| Assignment Action with metadata
-}
type AssignedAction
    = AssignedAction
        { layerTitles : List String
        , action : Action
        , reg : Reg AssignedActionSkel
        , assignment : Assignment
        , id : ActionID
        }


isRelevantNow : Moment -> Zone -> AssignedAction -> Bool
isRelevantNow now zone assignedAction =
    let
        fuzzyNow =
            HumanMoment.Global now

        start =
            Maybe.withDefault fuzzyNow <| relevanceStarts assignedAction

        end =
            Maybe.withDefault fuzzyNow <| relevanceEnds assignedAction

        notBeforeStart =
            HumanMoment.compareFuzzy zone Clock.startOfDay fuzzyNow start /= Earlier

        notAfterEnd =
            HumanMoment.compareFuzzy zone Clock.endOfDay fuzzyNow end /= Later
    in
    notBeforeStart && notAfterEnd


completed : AssignedAction -> Bool
completed assignedAction =
    Progress.isMax ( completion assignedAction, action assignedAction |> Action.completionUnits )


partiallyCompleted : AssignedAction -> Bool
partiallyCompleted assignedAction =
    completion assignedAction > 0


action : AssignedAction -> Action
action (AssignedAction metaAssignedAction) =
    metaAssignedAction.action


title : AssignedAction -> String
title (AssignedAction metaAssignedAction) =
    Action.title metaAssignedAction.action


activityID : AssignedAction -> Maybe ActivityID
activityID (AssignedAction metaAssignedAction) =
    Action.activityID metaAssignedAction.action


activityIDString : AssignedAction -> Maybe String
activityIDString (AssignedAction metaAssignedAction) =
    Action.activityIDString metaAssignedAction.action


progress : AssignedAction -> Progress
progress assignedAction =
    ( completion assignedAction, completionUnits assignedAction )


setCompletion : Progress.Portion -> AssignedAction -> Change
setCompletion newPortion (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.reg).completion.set newPortion


progressMax : AssignedAction -> Progress.Portion
progressMax assignedAction =
    action assignedAction
        |> Action.completionUnits
        |> Progress.unitMax


completion : AssignedAction -> Int
completion (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.reg).completion.get


completionUnits : AssignedAction -> Progress.Unit
completionUnits assignedAction =
    Action.completionUnits (action assignedAction)


relevanceStarts : AssignedAction -> Maybe FuzzyMoment
relevanceStarts (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.reg).relevanceStarts.get


relevanceEnds : AssignedAction -> Maybe FuzzyMoment
relevanceEnds (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.reg).relevanceEnds.get


externalDeadline : AssignedAction -> Maybe FuzzyMoment
externalDeadline (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.reg).externalDeadline.get


minEffort : AssignedAction -> Duration
minEffort assignedAction =
    action assignedAction
        |> Action.minEffort


estimatedEffort : AssignedAction -> Duration
estimatedEffort assignedAction =
    Action.estimatedEffort (action assignedAction)


maxEffort : AssignedAction -> Duration
maxEffort assignedAction =
    Action.maxEffort (action assignedAction)


getExtra : String -> AssignedAction -> Maybe String
getExtra key (AssignedAction metaAssignedAction) =
    RepDict.get key (Reg.latest metaAssignedAction.reg).extra


setExtra : String -> String -> AssignedAction -> Change
setExtra key value (AssignedAction metaAssignedAction) =
    RepDict.insert key value (Reg.latest metaAssignedAction.reg).extra
