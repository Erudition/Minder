module AppData exposing (AppData, Instance, decodeAppData, encodeAppData, fromScratch, saveErrors, saveWarnings)

import Activity.Activity as Activity exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty exposing (..)
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
    , activities : StoredActivities
    , timeline : Timeline
    , tokens : Tokens
    }


fromScratch : AppData
fromScratch =
    { uid = 0
    , errors = []
    , tasks = []
    , activities = []
    , timeline = []
    , tokens = emptyTokens
    }


decodeAppData : Decoder AppData
decodeAppData =
    Pipeline.decode AppData
        |> required "uid" Decode.int
        |> optional "errors" (Decode.list Decode.string) []
        |> optional "tasks" (Decode.list decodeTask) []
        |> optional "activities" Activity.decodeStoredActivities []
        |> optional "timeline" (Decode.list decodeSwitch) []
        |> optional "tokens" decodeTokens emptyTokens


encodeAppData : AppData -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Encode.list encodeTask record.tasks )
        , ( "activities", encodeStoredActivities record.activities )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string (List.take 100 record.errors) )
        , ( "timeline", Encode.list encodeSwitch record.timeline )
        , ( "tokens", encodeTokens record.tokens )
        ]


type alias Tokens =
    { todoistSyncToken : String
    }


emptyTokens : Tokens
emptyTokens =
    Tokens "*"


decodeTokens : Decoder Tokens
decodeTokens =
    Pipeline.decode Tokens
        |> required "todoistSyncToken" Decode.string


encodeTokens : Tokens -> Encode.Value
encodeTokens record =
    Encode.object
        [ ( "todoistSyncToken", Encode.string record.todoistSyncToken )
        ]



-- TODO save time with errors?


saveWarnings : AppData -> Decode.Warnings -> AppData
saveWarnings appData warnings =
    { appData | errors = [ Decode.warningsToString warnings ] ++ appData.errors }


saveErrors : AppData -> Decode.Errors -> AppData
saveErrors appData errors =
    { appData | errors = [ Decode.errorsToString errors ] ++ appData.errors }
