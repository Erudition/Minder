module AppData exposing (AppData, Instance, decodeAppData, encodeAppData, fromScratch, saveErrors, saveWarnings)

import Activity exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
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
    , tasks : List Task
    , activities : UserActivities
    }


fromScratch : AppData
fromScratch =
    { uid = 0
    , errors = []
    , tasks = []
    , activities = []
    }


decodeAppData : Decoder AppData
decodeAppData =
    Decode.map4 AppData
        (field "uid" Decode.int)
        (field "errors" (Decode.list Decode.string))
        (field "tasks" (Decode.list decodeTask))
        (field "activities" (Decode.list Activity.decodeCustomizations))


encodeAppData : AppData -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Encode.list encodeTask record.tasks )
        , ( "activites", Encode.list encodeActivity record.activities )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string record.errors )
        ]



-- TODO save time with errors?


saveWarnings : AppData -> Decode.Warnings -> AppData
saveWarnings appData warnings =
    { appData | errors = appData.errors ++ [ Decode.warningsToString warnings ] }


saveErrors : AppData -> Decode.Errors -> AppData
saveErrors appData errors =
    { appData | errors = appData.errors ++ [ Decode.errorsToString errors ] }
