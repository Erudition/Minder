module Profile exposing (AppInstance, Profile, TodoistIntegrationData, assignments, codec, currentActivityID, currentAssignmentID, currentSession, currentlyTracking, getActivityByID, getAssignmentByID, saveDecodeErrors, saveError, saveWarnings, userTimeZoneAtMoment)

import Activity.Activity as Activity exposing (..)
import Activity.HistorySession exposing (HistorySession, Timeline)
import Dict.Any as AnyDict exposing (AnyDict)
import ExtraCodecs as Codec
import Incubator.Todoist as Todoist
import Incubator.Todoist.Project as TodoistProject
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode exposing (..)
import List.Extra
import List.Nonempty exposing (..)
import Replicated.Change exposing (Change)
import Replicated.Codec as Codec exposing (SkelCodec)
import Replicated.Reducer.Register as Reg exposing (Reg(..))
import Replicated.Reducer.RepDb exposing (RepDb)
import Replicated.Reducer.RepList as RepList exposing (InsertionPoint(..), RepList)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period
import Task.Assignment as Assignment exposing (AssignmentID)
import Task.Meta exposing (Assignment)
import Task.Progress exposing (..)
import Task.Project
import TimeBlock.TimeBlock as TimeBlock exposing (TimeBlock)
import TimeTrackable exposing (TimeTrackable)
import ZoneHistory


{-| TODO "Instance" will be a UUID. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias AppInstance =
    Int


type alias Profile =
    { errors : RepList String
    , projects : RepDb (Reg Task.Project.ProjectSkel)
    , activities : Activity.Store
    , timeline : RepList Activity.HistorySession.HistorySession

    --, locationHistory : IntDict LocationUpdate
    , todoist : TodoistIntegrationData
    , timeBlocks : RepList TimeBlock
    }


codec : SkelCodec String Profile
codec =
    Codec.record Profile
        |> Codec.fieldList ( 1, "errors" ) .errors Codec.string
        |> Codec.fieldDb ( 2, "projects" ) .projects Task.Project.codec
        |> Codec.fieldRec ( 5, "activities" ) .activities Activity.storeCodec
        |> Codec.fieldList ( 6, "timeline" ) .timeline Activity.HistorySession.codec
        |> Codec.fieldReg ( 7, "todoist" ) .todoist (Codec.lazy (\_ -> todoistIntegrationDataCodec))
        |> Codec.fieldList ( 8, "timeBlocks" ) .timeBlocks TimeBlock.codec
        |> Codec.finishRecord


type alias TodoistIntegrationData =
    { cache : Todoist.Cache
    , parentProjectID : Maybe TodoistProject.ProjectID
    , activityProjectIDs : IntDict ActivityID
    }


todoistIntegrationDataCodec : SkelCodec String TodoistIntegrationData
todoistIntegrationDataCodec =
    Codec.record TodoistIntegrationData
        |> Codec.fieldReg ( 1, "cache" ) .cache (Codec.lazy (\_ -> Todoist.cacheCodec))
        |> Codec.maybeR ( 2, "parentProjectID" ) .parentProjectID Codec.int
        |> Codec.field ( 3, "activityProjectIDs" ) .activityProjectIDs (Codec.intDict Activity.idCodec) IntDict.empty
        |> Codec.finishRecord



-- TODO save time of occurence along with errors?


saveWarnings : Profile -> Decode.Warnings -> Change
saveWarnings appData warnings =
    RepList.append Last [ Decode.warningsToString warnings ] appData.errors


saveDecodeErrors : Profile -> Decode.Errors -> Change
saveDecodeErrors appData errors =
    saveError appData (Decode.errorsToString errors)


saveError : Profile -> String -> Change
saveError appData error =
    RepList.append Last [ error ] appData.errors



--- HELPERS


getAssignmentByID : Profile -> AssignmentID -> Maybe Assignment
getAssignmentByID profile assignmentID =
    let
        assignmentListTemp =
            -- TODO use a real dict
            assignments profile Task.Meta.AllSaved
    in
    List.Extra.find (\ass -> Task.Meta.assignmentID ass == assignmentID) assignmentListTemp



-- TODO


{-| All actions that are not unready or expired or finished.
-}
assignments : Profile -> Task.Meta.Query -> List Assignment
assignments profile query =
    let
        projectLayers =
            Task.Meta.projectToAssignableLayers profile.projects

        assignableList =
            AnyDict.values projectLayers.assignables
    in
    List.concatMap (Task.Meta.assignableToAssignments query) assignableList


getActivityByID : Profile -> ActivityID -> Activity
getActivityByID profile activityID =
    -- TODO optimize
    Activity.getByID activityID profile.activities


userTimeZoneAtMoment : Profile -> ( Moment, HumanMoment.Zone ) -> Moment -> Zone
userTimeZoneAtMoment _ ( time, timeZone ) givenMoment =
    if Moment.isSameOrEarlier givenMoment time then
        -- TODO look at past history to see where User last moved before this moment
        timeZone

    else
        -- TODO look at future plans to see where the User will likely be at this moment
        timeZone


currentActivityID : Profile -> ActivityID
currentActivityID profile =
    Activity.HistorySession.currentActivityID (RepList.listValues profile.timeline)


currentAssignmentID : Profile -> Maybe Assignment.AssignmentID
currentAssignmentID profile =
    Activity.HistorySession.currentAssignmentID (RepList.listValues profile.timeline)


currentlyTracking : Profile -> TimeTrackable
currentlyTracking profile =
    Activity.HistorySession.currentlyTracking (RepList.listValues profile.timeline)


currentSession : Profile -> Maybe HistorySession
currentSession profile =
    Activity.HistorySession.current (RepList.listValues profile.timeline)
