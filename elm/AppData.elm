module AppData exposing (AppData, Instance, decodeAppData, encodeAppData, fromScratch, saveDecodeErrors, saveError, saveWarnings)

import Activity.Activity as Activity exposing (..)
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
    , tokens : Tokens
    }


fromScratch : AppData
fromScratch =
    { uid = 0
    , errors = []
    , tasks = IntDict.empty
    , activities = IntDict.empty
    , timeline = []
    , tokens = emptyTokens
    }


decodeAppData : Decoder AppData
decodeAppData =
    Pipeline.decode AppData
        |> required "uid" Decode.int
        |> optional "errors" (Decode.list Decode.string) []
        |> optional "tasks" (Porting.decodeIntDict decodeTask) IntDict.empty
        |> optional "activities" Activity.decodeStoredActivities IntDict.empty
        |> optional "timeline" (Decode.list decodeSwitch) []
        |> optional "tokens" decodeTokens emptyTokens


encodeAppData : AppData -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Porting.encodeIntDict encodeTask record.tasks )
        , ( "activities", encodeStoredActivities record.activities )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string (List.take 100 record.errors) )
        , ( "timeline", Encode.list encodeSwitch record.timeline )
        , ( "tokens", encodeTokens record.tokens )
        ]


type alias Tokens =
    { todoistSyncToken : String
    , todoistParentProjectID : Int
    }


emptyTokens : Tokens
emptyTokens =
    Tokens "*" 1


decodeTokens : Decoder Tokens
decodeTokens =
    Pipeline.decode Tokens
        |> optional "todoistSyncToken" Decode.string "*"
        |> required "todoistParentProjectID" Decode.int


encodeTokens : Tokens -> Encode.Value
encodeTokens record =
    Encode.object
        [ ( "todoistSyncToken", Encode.string record.todoistSyncToken )
        , ( "todoistParentProjectID", Encode.int record.todoistParentProjectID )
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
