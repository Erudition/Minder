module AppData exposing (AppData, Instance, decodeAppData, encodeAppData, fromScratch, saveDecodeErrors, saveError, saveWarnings)

import Activity.Activity as Activity exposing (..)
import ID
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty exposing (..)
import Porting
import Task.Progress exposing (..)
import Task.Task exposing (..)
import Task.TaskMoment exposing (..)


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
    , todoist : TodoistCache
    }


fromScratch : AppData
fromScratch =
    { uid = 0
    , errors = []
    , tasks = IntDict.empty
    , activities = IntDict.empty
    , timeline = []
    , todoist = emptyTodoistCache
    }


decodeAppData : Decoder AppData
decodeAppData =
    Pipeline.decode AppData
        |> required "uid" Decode.int
        |> optional "errors" (Decode.list Decode.string) []
        |> optional "tasks" (Porting.decodeIntDict decodeTask) IntDict.empty
        |> optional "activities" Activity.decodeStoredActivities IntDict.empty
        |> optional "timeline" (Decode.list decodeSwitch) []
        |> optional "todoist" decodeTodoistCache emptyTodoistCache


encodeAppData : AppData -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Porting.encodeIntDict encodeTask record.tasks )
        , ( "activities", encodeStoredActivities record.activities )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string (List.take 100 record.errors) )
        , ( "timeline", Encode.list encodeSwitch record.timeline )
        , ( "todoist", encodeTodoistCache record.todoist )
        ]


type alias TodoistCache =
    { syncToken : String
    , parentProjectID : Int
    , activityProjectIDs : IntDict ActivityID
    }


emptyTodoistCache : TodoistCache
emptyTodoistCache =
    TodoistCache "*" 1 IntDict.empty


decodeTodoistCache : Decoder TodoistCache
decodeTodoistCache =
    Pipeline.decode TodoistCache
        |> optional "syncToken" Decode.string "*"
        |> required "parentProjectID" Decode.int
        |> required "activityProjectIDs" (Porting.decodeIntDict ID.decode)


encodeTodoistCache : TodoistCache -> Encode.Value
encodeTodoistCache record =
    Encode.object
        [ ( "syncToken", Encode.string record.syncToken )
        , ( "parentProjectID", Encode.int record.parentProjectID )
        , ( "activityProjectIDs", Porting.encodeIntDict ID.encode record.activityProjectIDs )
        ]



-- TODO save time with errors?


saveWarnings : AppData -> Decode.Warnings -> AppData
saveWarnings appData warnings =
    { appData | errors = [ Decode.warningsToString warnings ] ++ appData.errors }


saveDecodeErrors : AppData -> Decode.Errors -> AppData
saveDecodeErrors appData errors =
    saveError appData (Decode.errorsToString errors)


saveError : AppData -> String -> AppData
saveError appData error =
    { appData | errors = error :: appData.errors }
