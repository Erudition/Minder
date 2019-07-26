module AppData exposing (AppData, Instance, decodeAppData, encodeAppData, fromScratch, saveDecodeErrors, saveError, saveWarnings)

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
import Task.Progress exposing (..)
import Task.Task exposing (..)


{-| TODO "Instance" will be a UUID. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias Instance =
    Int


type alias AppData =
    { uid : Instance
    , errors : List String
    , tasks : IntDict Task
    , activities : StoredActivities
    , timeline : Timeline
    , todoist : TodoistIntegrationData
    }


fromScratch : AppData
fromScratch =
    { uid = 0
    , errors = []
    , tasks = IntDict.empty
    , activities = IntDict.empty
    , timeline = []
    , todoist = emptyTodoistIntegrationData
    }


decodeAppData : Decoder AppData
decodeAppData =
    Pipeline.decode AppData
        |> required "uid" Decode.int
        |> optional "errors" (Decode.list Decode.string) []
        |> optional "tasks" (Porting.decodeIntDict decodeTask) IntDict.empty
        |> optional "activities" Activity.decodeStoredActivities IntDict.empty
        |> optional "timeline" (Decode.list decodeSwitch) []
        |> optional "todoist" decodeTodoistIntegrationData emptyTodoistIntegrationData


encodeAppData : AppData -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Porting.encodeIntDict encodeTask record.tasks )
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
        |> required "activityProjectIDs" decodeIntDict Decode.int


emptyTodoistIntegrationData : TodoistIntegrationData
emptyTodoistIntegrationData =
    { cache = Todoist.emptyCache, parentProjectID = Nothing, activityProjectIDs = IntDict.empty }



-- TODO save time of occurence along with errors?


saveWarnings : AppData -> Decode.Warnings -> AppData
saveWarnings appData warnings =
    { appData | errors = [ Decode.warningsToString warnings ] ++ appData.errors }


saveDecodeErrors : AppData -> Decode.Errors -> AppData
saveDecodeErrors appData errors =
    saveError appData (Decode.errorsToString errors)


saveError : AppData -> String -> AppData
saveError appData error =
    { appData | errors = error :: appData.errors }
