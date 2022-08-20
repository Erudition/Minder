module Profile exposing (AppInstance, Profile, TodoistIntegrationData, currentActivityID, getActivityByID, getInstanceByID, instanceListNow, saveDecodeErrors, saveError, saveWarnings, trackedInstance, userTimeZoneAtMoment)

import Activity.Activity as Activity exposing (..)
import Activity.Switch
import Activity.Timeline exposing (Timeline)
import Environment exposing (Environment)
import ExtraCodecs as Codec
import Helpers exposing (decodeIntDict, encodeIntDict, encodeObjectWithoutNothings, normal, omittable, withPresence)
import ID
import Incubator.Todoist as Todoist
import Incubator.Todoist.Project as TodoistProject
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty exposing (..)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (SymCodec, coreRW, fieldDict, fieldList, fieldRW, maybeRW)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task.ActionClass
import Task.AssignedAction
import Task.Entry
import Task.Progress exposing (..)
import Task.Session
import TimeBlock.TimeBlock as TimeBlock exposing (TimeBlock)
import ZoneHistory exposing (ZoneHistory)


{-| TODO "Instance" will be a UUID. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias AppInstance =
    Int


type alias Profile =
    { errors : RepList String
    , taskEntries : RepList Task.Entry.Entry
    , taskClasses : RepDb Task.ActionClass.ActionClassSkel
    , taskInstances : RepDb Task.AssignedAction.AssignedActionSkel
    , activities : Activity.Store
    , timeline : Timeline

    --, locationHistory : IntDict LocationUpdate
    , todoist : TodoistIntegrationData
    , timeBlocks : RepList TimeBlock
    }



-- codec : SymCodec e Profile
-- codec =
--     Codec.record Profile
--         |> Codec.fieldR ( 1, "uid" ) .uid RC.int 0
--         |> Codec.fieldList  ( 2, "errors" ) .errors (RC.immutableList RC.string)
--         |> RC.fieldR ( 3, "taskEntries" ) .taskEntries (RC.immutableList (Debug.todo "Task.Entry.codec")) []
--         |> RC.fieldR ( 4, "taskClasses" ) .taskClasses (Debug.todo "Task.Class.codec") IntDict.empty
--         |> RC.fieldR ( 5, "taskInstances" ) .taskInstances (Debug.todo "Task.Instance.codec") IntDict.empty
--         |> RC.fieldR ( 6, "activities" ) .activities (Debug.todo "Activity.codec") IntDict.empty
--         |> RC.fieldR ( 7, "timeline" ) .timeline (RC.immutableList (Debug.todo "Activity.Activity.switchCodec")) []
--         |> RC.fieldR ( 7, "todoist" ) .todoist (Debug.todo "Activity.codec")
--         |> Codec.finishRecord


codec : SymCodec String Profile
codec =
    Codec.record Profile
        |> Codec.fieldList ( 1, "errors" ) .errors Codec.string
        |> Codec.fieldList ( 2, "taskEntries" ) .taskEntries Task.Entry.codec
        |> Codec.fieldDb ( 3, "taskClasses" ) .taskClasses Task.ActionClass.codec
        |> Codec.fieldDb ( 4, "taskInstances" ) .taskInstances Task.AssignedAction.codec
        |> Codec.nestedField ( 5, "activities" ) .activities Activity.storeCodec
        |> Codec.fieldList ( 6, "timeline" ) .timeline Activity.Switch.codec
        |> Codec.fieldR ( 7, "todoist" ) .todoist todoistIntegrationDataCodec emptyTodoistIntegrationData
        |> Codec.fieldList ( 8, "timeBlocks" ) .timeBlocks TimeBlock.codec
        |> Codec.finishRecord


type alias TodoistIntegrationData =
    { cache : Todoist.Cache
    , parentProjectID : Maybe TodoistProject.ProjectID
    , activityProjectIDs : IntDict ActivityID
    }


todoistIntegrationDataCodec : SymCodec String TodoistIntegrationData
todoistIntegrationDataCodec =
    -- Codec.record TodoistIntegrationData
    --     |> Codec.fieldR ( 1, "cache" ) Todoist.decodeCache Todoist.emptyCache
    --     |> Codec.maybeR ( 2, "parentProjectID" ) Decode.int
    --     |> Codec.fieldR ( 3, "activityProjectIDs" ) (Codec.intDict Activity.idCodec)
    --     |> Codec.finishRecord
    Debug.todo "todoist codec"


emptyTodoistIntegrationData : TodoistIntegrationData
emptyTodoistIntegrationData =
    { cache = Todoist.emptyCache, parentProjectID = Nothing, activityProjectIDs = IntDict.empty }



-- TODO save time of occurence along with errors?


saveWarnings : Profile -> Decode.Warnings -> Change
saveWarnings appData warnings =
    RepList.append [ Decode.warningsToString warnings ] appData.errors


saveDecodeErrors : Profile -> Decode.Errors -> Change
saveDecodeErrors appData errors =
    saveError appData (Decode.errorsToString errors)


saveError : Profile -> String -> Change
saveError appData error =
    RepList.append [ error ] appData.errors



--- HELPERS


{-| All instances that are not expired or finished.
-}
instanceListNow : Profile -> Environment -> List Task.AssignedAction.AssignedAction
instanceListNow profile env =
    let
        ( fullClasses, warnings ) =
            Task.Entry.getClassesFromEntries ( profile.taskEntries, profile.taskClasses )

        zoneHistory =
            -- TODO
            ZoneHistory.init env.time env.timeZone

        rightNow =
            Period.instantaneous env.time
    in
    Task.AssignedAction.listAllAssignedActions fullClasses profile.taskInstances ( zoneHistory, rightNow )


trackedInstance : Profile -> Environment -> Maybe Task.AssignedAction.AssignedAction
trackedInstance profile env =
    Maybe.andThen (getInstanceByID profile env) (Activity.Timeline.currentInstanceID profile.timeline)


getInstanceByID : Profile -> Environment -> Task.AssignedAction.AssignedActionID -> Maybe Task.AssignedAction.AssignedAction
getInstanceByID profile env instanceID =
    -- TODO optimize
    List.head (List.filter (\i -> Task.AssignedAction.getID i == instanceID) (instanceListNow profile env))


getActivityByID : Profile -> ActivityID -> Activity
getActivityByID profile activityID =
    -- TODO optimize
    Activity.getByID activityID profile.activities


exportExcusedUsageSeconds : Profile -> Moment -> ( ActivityID, Activity ) -> String
exportExcusedUsageSeconds app now ( activityID, activity ) =
    String.fromInt <| Duration.inSecondsRounded (Activity.Timeline.excusedUsage app.timeline now ( activityID, activity ))


exportExcusedLeftSeconds : Profile -> Moment -> ( ActivityID, Activity ) -> String
exportExcusedLeftSeconds app now ( activityID, activity ) =
    String.fromInt <| Duration.inSecondsRounded (Activity.Timeline.excusedLeft app.timeline now ( activityID, activity ))


userTimeZoneAtMoment : Profile -> Environment -> Moment -> Zone
userTimeZoneAtMoment profile env givenMoment =
    if Moment.isSameOrEarlier givenMoment env.time then
        -- TODO look at past history to see where User last moved before this moment
        env.timeZone

    else
        -- TODO look at future plans to see where the User will likely be at this moment
        env.timeZone


currentActivityID : Profile -> ActivityID
currentActivityID profile =
    Activity.Timeline.currentActivityID profile.timeline
