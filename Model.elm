module Model exposing (Model, ModelAsJson, User, decodeModel, emptyModel, encodeModel, modelFromJson, modelToJson, testModel)

{--Due to the disappointingly un-automated nature of uncustomized Decoders and Encoders in Elm (and the current auto-generators out there being broken for many types), they must be written out by hand for every data type of our app (since all of our app's data will be ported out, and Elm doesn't support porting out even it's own Union types). To make sure we don't foget to update the coders (hard) whenever we change our model (easy), we shall always put them directly below the corresponding type definition. For example:

type Widget = ...
encodeWidget = ...
decodeWidget = ...

Using that nomenclature. Don't change Widget without updating the decoder!
--}

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Model.Task exposing (..)
import Time


{-| Our whole app's Model.
NOTE IF YOU MAKE CHANGES, CHANGE THE DECODER/ENCODER BELOW ACCORDINGLY!
-}
type alias Model =
    { tasks : List Task
    , field : String
    , uid : Int
    , visibility : String
    , errors : List String
    , updateTime : Time.Time
    }


decodeModel : Decode.Decoder Model
decodeModel =
    Decode.map6 Model
        (field "tasks" (Decode.list decodeTask))
        (field "field" Decode.string)
        (field "uid" Decode.int)
        (field "visibility" Decode.string)
        (field "errors" (Decode.list Decode.string))
        (field "updateTime" Decode.float)


encodeModel : Model -> Encode.Value
encodeModel record =
    Encode.object
        [ ( "tasks", Encode.list <| List.map encodeTask <| record.tasks )
        , ( "field", Encode.string <| record.field )
        , ( "uid", Encode.int <| record.uid )
        , ( "visibility", Encode.string <| record.visibility )
        , ( "errors", Encode.list <| List.map Encode.string <| record.errors )
        , ( "updateTime", Encode.float record.updateTime )
        ]


type alias ModelAsJson =
    String


modelFromJson : ModelAsJson -> Result String Model
modelFromJson incomingJson =
    Decode.decodeString decodeModel incomingJson


modelToJson : Model -> ModelAsJson
modelToJson model =
    Encode.encode 0 (encodeModel model)


emptyModel : Model
emptyModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , errors = []
    , updateTime = 0.0
    }


testModel : Model
testModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , errors = []
    , updateTime = 0.0
    }


type alias User =
    Int
