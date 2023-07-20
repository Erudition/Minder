module Profile exposing (AppInstance, Profile, TodoistIntegrationData, assignments, codec, currentActivityID, getActivityByID, saveDecodeErrors, saveError, saveWarnings, userTimeZoneAtMoment)

import Activity.Activity as Activity exposing (..)
import Activity.Timeline exposing (Timeline)
import ExtraCodecs as Codec
import Incubator.Todoist as Todoist
import Incubator.Todoist.Project as TodoistProject
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode exposing (..)
import List.Nonempty exposing (..)
import Replicated.Change exposing (Change)
import Replicated.Codec as Codec exposing (SkelCodec)
import Replicated.Reducer.RepDb exposing (RepDb)
import Replicated.Reducer.RepList as RepList exposing (InsertionPoint(..), RepList)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period
import Task.Meta exposing (Assignment)
import Task.Progress exposing (..)
import Task.Project
import TimeBlock.TimeBlock as TimeBlock exposing (TimeBlock)
import ZoneHistory


{-| TODO "Instance" will be a UUID. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias AppInstance =
    Int


type alias Profile =
    { errors : RepList String
    , projects : RepDb Task.ProjectSkel.Project
    , activities : Activity.Store
    , timeline : Timeline

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
        |> Codec.fieldRec ( 6, "timeline" ) .timeline Activity.Timeline.codec
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


{-| All actions that are not unready or expired or finished.
-}
assignments : Profile -> Task.Meta.Query -> List Assignment
assignments profile query =
    let
        assignables =
            Task.Meta.projectToAssignableLayers profile.projects
    in
    Task.Meta.assignablesToAssignments assignables query


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
    Activity.Timeline.currentActivityID profile.timeline
