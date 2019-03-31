module AppData exposing (AppData, decodeAppData, default, encodeAppData)

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
    }


default : List String -> AppData
default errors =
    { uid = 0
    , errors = errors
    , tasks = []
    }


decodeAppData : Decoder AppData
decodeAppData =
    Decode.map3 AppData
        (field "uid" Decode.int)
        (field "errors" (Decode.list Decode.string))
        (field "tasks" (Decode.list decodeTask))


encodeAppData : AppData -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Encode.list encodeTask record.tasks )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string record.errors )
        ]
