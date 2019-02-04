module Model exposing (Instance, Model, ModelAsJson, decodeModel, emptyModel, encodeModel, modelFromJson, modelToJson)

{--Due to the disappointingly un-automated nature of uncustomized Decoders and Encoders in Elm (and the current auto-generators out there being broken for many types), they must be written out by hand for every data type of our app (since all of our app's data will be ported out, and Elm doesn't support porting out even it's own Union types). To make sure we don't forget to update the coders (hard) whenever we change our model (easy), we shall always put them directly below the corresponding type definition. For example:

type Widget = ...
encodeWidget = ...
decodeWidget = ...

Using that nomenclature. Don't change Widget without updating the decoder!
--}

import Browser.Navigation as Nav
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Model.Task exposing (..)
import Model.TaskMoment exposing (decodeMoment, encodeMoment)
import Time exposing (millisToPosix)


{-| Our whole app's Model.
We originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is completed", all stored in App "Database").
-}
type alias Model =
    { appData : AppData
    , viewState : ViewState
    , updateTime : Time.Posix
    , navkey : Nav.Key
    }


type alias ModelAsJson =
    String


modelFromJson : ModelAsJson -> Nav.Key -> DecodeResult Model
modelFromJson incomingJson navkey =
    Decode.decodeString (decodeModel navkey) incomingJson


modelToJson : Model -> ModelAsJson
modelToJson model =
    Encode.encode 0 (encodeModel model)



-- buildModel : Nav.Key -> Model
-- buildModel key =
--     { tasks = []
--     , field = ""
--     , uid = 0
--     , errors = []
--     , updateTime = millisToPosix 0
--     , viewState = emptyViewState
--     , navkey = key
--     }


{-| TODO will be UUIDs. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias Instance =
    Int


type alias AppData =
    { tasks : List Task
    , uid : Instance
    , errors : List String
    }


decodeAppData =
    Decode.map7 AppData
        (field "tasks" (Decode.list decodeTask))
        (field "field" Decode.string)
        (field "uid" Decode.int)
        (field "errors" (Decode.list Decode.string))
        (field "updateTime" decodeMoment)


encodeAppData : Model -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Encode.list encodeTask record.tasks )
        , ( "field", Encode.string record.field )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string record.errors )
        , ( "updateTime", encodeMoment record.updateTime )
        ]


emptyAppData : AppData
emptyAppData =
    { tasks = [], uid = 0, errors = [] }


type alias ViewState =
    { pane : Pane
    , uid : Int
    }


emptyViewState =
    { pane = TaskList "" Nothing AllTasks }


type Pane
    = TaskList TextboxContents (Maybe ExpandedTask) TaskListFilter


type alias ExpandedTask =
    TaskId


type alias TextboxContents =
    String
