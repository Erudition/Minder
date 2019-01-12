module Model exposing (Instance, Model, ModelAsJson, decodeModel, emptyModel, encodeModel, modelFromJson, modelToJson, testModel)

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
NOTE IF YOU MAKE CHANGES, CHANGE THE DECODER/ENCODER BELOW ACCORDINGLY!
-}
type alias Model =
    { tasks : List Task
    , field : String
    , uid : Int
    , visibility : String
    , errors : List String
    , updateTime : Time.Posix
    , navKey : Nav.Key
    }


decodeModel : Decode.Decoder Model
decodeModel =
    Decode.map6 Model
        (field "tasks" (Decode.list decodeTask))
        (field "field" Decode.string)
        (field "uid" Decode.int)
        (field "visibility" Decode.string)
        (field "errors" (Decode.list Decode.string))
        (field "updateTime" decodeMoment)


encodeModel : Model -> Encode.Value
encodeModel record =
    Encode.object
        [ ( "tasks", Encode.list encodeTask record.tasks )
        , ( "field", Encode.string record.field )
        , ( "uid", Encode.int record.uid )
        , ( "visibility", Encode.string record.visibility )
        , ( "errors", Encode.list Encode.string record.errors )
        , ( "updateTime", encodeMoment record.updateTime )
        ]


type alias ModelAsJson =
    String


modelFromJson : ModelAsJson -> DecodeResult Model
modelFromJson incomingJson =
    Decode.decodeString decodeModel incomingJson


modelToJson : Model -> ModelAsJson
modelToJson model =
    Encode.encode 0 (encodeModel model)


{-| Should we make this accept the current time?
-}
emptyModel : Model
emptyModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , errors = []
    , updateTime = millisToPosix 0
    }


testModel : Model
testModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , errors = []
    , updateTime = millisToPosix 0
    }


{-| TODO will be UUIDs. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who own it when needed.
-}
type alias Instance =
    Int
