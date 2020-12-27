module Profile exposing (AppInstance, Profile, TodoistIntegrationData, decodeProfile, encodeProfile, fromScratch, saveDecodeErrors, saveError, saveWarnings)

import Activity.Activity as Activity exposing (..)
import ID
import Incubator.Todoist as Todoist
import Incubator.Todoist.Project as TodoistProject
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty exposing (..)
import Porting exposing (decodeIntDict, encodeIntDict, encodeObjectWithoutNothings, normal, omittable, withPresence)
import Task.Class
import Task.Entry
import Task.Instance
import Task.Progress exposing (..)
import Task.Session
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
    }


decodeProfile : Decoder Profile
decodeProfile =
    Pipeline.decode Profile
        |> required "uid" Decode.int
        |> optional "errors" (Decode.list Decode.string) []
        |> optional "taskEntries" (Decode.list Task.Entry.decodeEntry) []
        |> optional "taskClasses" (Porting.decodeIntDict Task.Class.decodeClass) IntDict.empty
        |> optional "taskInstances" (Porting.decodeIntDict Task.Instance.decodeInstance) IntDict.empty
        |> optional "activities" Activity.decodeStoredActivities IntDict.empty
        |> optional "timeline" (Decode.list decodeSwitch) []
        |> optional "todoist" decodeTodoistIntegrationData emptyTodoistIntegrationData


encodeProfile : Profile -> Encode.Value
encodeProfile record =
    Encode.object
        [ ( "taskClasses", Porting.encodeIntDict Task.Class.encodeClass record.taskClasses )
        , ( "taskInstances", Porting.encodeIntDict Task.Instance.encodeInstance record.taskInstances )
        , ( "activities", encodeStoredActivities record.activities )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string (List.take 100 record.errors) )
        , ( "timeline", Encode.list encodeSwitch record.timeline )
        , ( "todoist", encodeTodoistIntegrationData record.todoist )
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
