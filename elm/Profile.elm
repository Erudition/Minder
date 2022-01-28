module Profile exposing (AppInstance, Profile, TodoistIntegrationData, currentActivityID, decodeProfile, encodeProfile, fromScratch, getActivityByID, getInstanceByID, instanceListNow, saveDecodeErrors, saveError, saveWarnings, trackedInstance, userTimeZoneAtMoment)

import Activity.Activity as Activity exposing (..)
import Activity.Switch exposing (decodeSwitch, encodeSwitch)
import Activity.Timeline exposing (Timeline)
import Environment exposing (Environment)
import Helpers exposing (decodeIntDict, encodeIntDict, encodeObjectWithoutNothings, normal, omittable, withPresence)
import ID
import Incubator.Todoist as Todoist
import Incubator.Todoist.Project as TodoistProject
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty exposing (..)
import Replicated.ReplicaCodec as RC exposing (Codec)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task.Class
import Task.Entry
import Task.Instance
import Task.Progress exposing (..)
import Task.Session
import TimeBlock.TimeBlock as TimeBlock exposing (TimeBlock)
import ZoneHistory exposing (ZoneHistory)


{-| TODO "Instance" will be a UUID. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias AppInstance =
    Int


type alias Profile =
    { uid : AppInstance
    , errors : List String
    , taskEntries : List Task.Entry.Entry
    , taskClasses : IntDict Task.Class.ClassSkel
    , taskInstances : IntDict Task.Instance.InstanceSkel
    , activities : StoredActivities
    , timeline : Timeline

    --, locationHistory : IntDict LocationUpdate
    , todoist : TodoistIntegrationData
    , timeBlocks : List TimeBlock
    }


fromScratch : Profile
fromScratch =
    { uid = 0
    , errors = []
    , taskEntries = []
    , taskClasses = IntDict.empty
    , taskInstances = IntDict.empty
    , activities = IntDict.empty
    , timeline = []
    , todoist = emptyTodoistIntegrationData
    , timeBlocks = []
    }



--codec : Codec e Profile
--codec =
--    RC.record Profile
--        |> RC.fieldR ( 1, "uid" ) .uid RC.int 0
--        |> RC.fieldR ( 2, "errors" ) .errors (RC.list RC.string) []
--        |> RC.fieldR ( 3, "taskEntries" ) .taskEntries (RC.list (Debug.todo "Task.Entry.codec")) []
--        |> RC.fieldR ( 4, "taskClasses" ) .taskClasses (Debug.todo "Task.Class.codec") IntDict.empty
--        |> RC.fieldR ( 5, "taskInstances" ) .taskInstances (Debug.todo "Task.Instance.codec") IntDict.empty
--        |> RC.fieldR ( 6, "activities" ) .activities (Debug.todo "Activity.codec") IntDict.empty
--        |> RC.fieldR ( 7, "timeline" ) .timeline (RC.list (Debug.todo "Activity.Activity.switchCodec")) []
--        |> RC.fieldR ( 7, "todoist" ) .todoist (Debug.todo "Activity.codec")
--        |> RC.finishRecord


decodeProfile : Decoder Profile
decodeProfile =
    Pipeline.decode Profile
        |> required "uid" Decode.int
        |> optional "errors" (Decode.list Decode.string) []
        |> optional "taskEntries" (Decode.list Task.Entry.decodeEntry) []
        |> optional "taskClasses" (Helpers.decodeIntDict Task.Class.decodeClass) IntDict.empty
        |> optional "taskInstances" (Helpers.decodeIntDict Task.Instance.decodeInstance) IntDict.empty
        |> optional "activities" Activity.decodeStoredActivities IntDict.empty
        |> optional "timeline" (Decode.list decodeSwitch) []
        |> optional "todoist" decodeTodoistIntegrationData emptyTodoistIntegrationData
        |> optional "timeBlocks" (Decode.list TimeBlock.decodeTimeBlock) []


encodeProfile : Profile -> Encode.Value
encodeProfile record =
    Encode.object
        [ ( "taskClasses", Helpers.encodeIntDict Task.Class.encodeClass record.taskClasses )
        , ( "taskInstances", Helpers.encodeIntDict Task.Instance.encodeInstance record.taskInstances )
        , ( "taskEntries", Encode.list Task.Entry.encodeEntry record.taskEntries )
        , ( "activities", encodeStoredActivities record.activities )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string (List.take 100 record.errors) )
        , ( "timeline", Encode.list encodeSwitch record.timeline )
        , ( "todoist", encodeTodoistIntegrationData record.todoist )
        , ( "timeBlocks", Encode.list TimeBlock.encodeTimeBlock record.timeBlocks )
        ]


type alias TodoistIntegrationData =
    { cache : Todoist.Cache
    , parentProjectID : Maybe TodoistProject.ProjectID
    , activityProjectIDs : IntDict ActivityID
    }


encodeTodoistIntegrationData : TodoistIntegrationData -> Encode.Value
encodeTodoistIntegrationData data =
    encodeObjectWithoutNothings
        [ normal ( "cache", Todoist.encodeCache data.cache )
        , omittable ( "parentProjectID", Encode.int, data.parentProjectID )
        , normal ( "activityProjectIDs", encodeIntDict ID.encode data.activityProjectIDs )
        ]


decodeTodoistIntegrationData : Decoder TodoistIntegrationData
decodeTodoistIntegrationData =
    decode TodoistIntegrationData
        |> required "cache" Todoist.decodeCache
        |> withPresence "parentProjectID" Decode.int
        |> required "activityProjectIDs" (decodeIntDict ID.decode)


emptyTodoistIntegrationData : TodoistIntegrationData
emptyTodoistIntegrationData =
    { cache = Todoist.emptyCache, parentProjectID = Nothing, activityProjectIDs = IntDict.empty }



-- TODO save time of occurence along with errors?


saveWarnings : Profile -> Decode.Warnings -> Profile
saveWarnings appData warnings =
    { appData | errors = [ Decode.warningsToString warnings ] ++ appData.errors }


saveDecodeErrors : Profile -> Decode.Errors -> Profile
saveDecodeErrors appData errors =
    saveError appData (Decode.errorsToString errors)


saveError : Profile -> String -> Profile
saveError appData error =
    { appData | errors = error :: appData.errors }



--- HELPERS


instanceListNow : Profile -> Environment -> List Task.Instance.Instance
instanceListNow profile env =
    -- TODO figure out where to put this
    let
        ( fullClasses, warnings ) =
            Task.Entry.getClassesFromEntries ( profile.taskEntries, profile.taskClasses )

        zoneHistory =
            -- TODO
            ZoneHistory.init env.time env.timeZone

        rightNow =
            Period.instantaneous env.time
    in
    Task.Instance.listAllInstances fullClasses profile.taskInstances ( zoneHistory, rightNow )


trackedInstance : Profile -> Environment -> Maybe Task.Instance.Instance
trackedInstance profile env =
    Maybe.andThen (getInstanceByID profile env) (Activity.Timeline.currentInstanceID profile.timeline)


getInstanceByID : Profile -> Environment -> Task.Instance.InstanceID -> Maybe Task.Instance.Instance
getInstanceByID profile env instanceID =
    -- TODO optimize
    List.head (List.filter (\i -> Task.Instance.getID i == instanceID) (instanceListNow profile env))


getActivityByID : Profile -> ActivityID -> Activity
getActivityByID profile activityID =
    -- TODO optimize
    Activity.getActivity activityID (allActivities profile.activities)


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
