module Porting exposing (..)


import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

import Json.Encode.Extra exposing (..)
import Json.Decode.Extra exposing (..)

import Json.Decode.Pipeline as Pipeline exposing (decode, required, optional, hardcoded)

-- ours:
import Model exposing (..)
import Model.Progress exposing (..)

import Time.DateTime exposing (DateTime)
import Time.Iso8601 exposing (toDateTime)
import Time.Iso8601ErrorMsg exposing (renderText)
{------------------------------------------------------------------------}
{-- ENCODING AND DECODING TO AND FROM JSON FOR PORTING DATA IN AND OUT --}

type alias ModelAsJson = String
modelFromJson : ModelAsJson -> Result String Model
modelFromJson incomingJson =
  Decode.decodeString decodeModel incomingJson

modelToJson : Model -> ModelAsJson
modelToJson model =
    Encode.encode 0 (encodeModel model)

decodeMaybe : Decoder a -> Decoder (Maybe a)
decodeMaybe = Decode.maybe
encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe = Json.Encode.Extra.maybe

type alias Moment = DateTime


decodeModel : Decode.Decoder Model
decodeModel =
    Decode.map5 Model
        (field "tasks" (Decode.list decodeTask))
        (field "field" Decode.string)
        (field "uid" Decode.int)
        (field "visibility" Decode.string)
        (field "errors" (Decode.list Decode.string))

encodeModel : Model -> Encode.Value
encodeModel record =
    Encode.object
        [ ("tasks",  Encode.list <| List.map encodeTask <| record.tasks)
        , ("field",  Encode.string <| record.field)
        , ("uid",  Encode.int <| record.uid)
        , ("visibility",  Encode.string <| record.visibility)
        , ("errors",  Encode.list <| List.map Encode.string <| record.errors)
        ]

decodeTask : Decode.Decoder Model.Task
decodeTask =
    decode Task
        |> Pipeline.required "title" (Decode.string)
        |> Pipeline.required "completion" (decodeProgress)
        |> Pipeline.required "editing" (Decode.bool)
        |> Pipeline.required "id" (Decode.int)
        |> Pipeline.required "predictedEffort" (Decode.int)
        |> Pipeline.required "history" (Decode.list decodeHistoryEntry)
        |> Pipeline.required "parent" (decodeMaybe Decode.int)
        |> Pipeline.required "tags" (Decode.list Decode.string)
        |> Pipeline.required "project" (decodeMaybe Decode.int)
        |> Pipeline.required "deadline" (decodeMaybe decodeMomentOrDay)
        |> Pipeline.required "plannedStart" (decodeMaybe decodeMomentOrDay)
        |> Pipeline.required "plannedFinish" (decodeMaybe decodeMomentOrDay)
        |> Pipeline.required "relevanceStarts" (decodeMaybe decodeMomentOrDay)
        |> Pipeline.required "relevanceEnds" (decodeMaybe decodeMomentOrDay)

encodeTask : Task -> Encode.Value
encodeTask record =
    Encode.object
        [ ("title",  Encode.string <| record.title)
        , ("completion",  encodeProgress <| record.completion)
        , ("editing",  Encode.bool <| record.editing)
        , ("id",  Encode.int <| record.id)
        , ("predictedEffort",  Encode.int <| record.predictedEffort)
        , ("history",  Encode.list <| List.map encodeHistoryEntry <| record.history)
        , ("parent",  Json.Encode.Extra.maybe Encode.int record.parent)
        , ("tags",  Encode.list <| List.map Encode.string <| record.tags)
        , ("project",  encodeMaybe Encode.int record.project)
        , ("deadline",  encodeMaybe encodeMomentOrDay record.deadline)
        , ("plannedStart",  encodeMaybe encodeMomentOrDay record.plannedStart)
        , ("plannedFinish",  encodeMaybe encodeMomentOrDay record.plannedFinish)
        , ("relevanceStarts",  encodeMaybe encodeMomentOrDay record.relevanceStarts)
        , ("relevanceEnds",  encodeMaybe encodeMomentOrDay record.relevanceEnds)
        ]


type alias Rectangle = { width : Int, height : Int }

type alias Circle = { radius: Int }

type Shape
    = ShapeRectangle Rectangle
    | ShapeCircle Circle



decodeShape : Decoder Shape
decodeShape =
  oneOf
    [ decodeRectangle |> andThen (\x -> decode (ShapeRectangle x))
    , decodeCircle |> andThen (\x -> decode (ShapeCircle x))
    ]



decodeRectangle : Decoder Rectangle
decodeRectangle =
    decode Rectangle
        |> required "width" Decode.int
        |> required "height" Decode.int




decodeCircle : Decoder Circle
decodeCircle =
    decode Circle
         |> required "radius" Decode.int

decodeHistoryEntry : Decode.Decoder HistoryEntry
decodeHistoryEntry =
    Decode.map2 (,)
        (Decode.index 0
        (Decode.string
            |> Decode.andThen
                (\string ->
                    case string of
                        "Created" ->
                            decodeCreated

                        "CompletionChange" ->
                            decodeCompletionChange

                        "TitleChange" ->
                            decodeTitleChange

                        "PredictedEffortChange" ->
                            decodePredictedEffortChange

                        "ParentChange" ->
                            decodeParentChange

                        "TagsChange" ->
                            Decode.succeed TagsChange

                        _ ->
                            Decode.fail "Invalid TaskChange"
                )
        ))
        (Decode.index 1
        (Decode.string
            |> Decode.andThen
                (\string ->
                    case string of
                        "DateTime" ->
                            decodeMoment

                        _ ->
                            Decode.fail "Invalid Moment"
                )
        ))


arrayAsTuple2 : Decoder a -> Decoder b -> Decoder (a, b)
arrayAsTuple2 a b =
    index 0 a
        |> andThen (\aVal -> index 1 b
        |> andThen (\bVal -> Decode.succeed (aVal, bVal)))


encodeHistoryEntry : HistoryEntry -> Encode.Value
encodeHistoryEntry record =
    Encode.object
        [
        ]

decodeCompletionChange : Decoder TaskChange
decodeCompletionChange =
  Decode.map CompletionChange (field "progress" decodeProgress)

decodeCreated : Decoder TaskChange
decodeCreated =
  Decode.map Created (field "moment" decodeMoment)

decodeParentChange : Decoder TaskChange
decodeParentChange =
  Decode.map ParentChange (field "taskId" Decode.int)

decodePredictedEffortChange : Decoder TaskChange
decodePredictedEffortChange =
  Decode.map PredictedEffortChange (field "duration" Decode.int)

decodeTitleChange : Decoder TaskChange
decodeTitleChange =
  Decode.map TitleChange (field "string" Decode.string)

-- CompletionChange 100
--
-- giveColor : Color completion
-- giveColor p = if p > .5 then Blue else Red
--
--
-- set Task color to (giveColor Model.progress)
--
-- type Maybe = Nothing | a
--
-- Just 12
--
-- {"tag": "CompletionChange"
--  "moment": 100}

decodeTaskChange : Decode.Decoder TaskChange
decodeTaskChange =
      let
          fallthrough string =
              Result.Err ("Not valid pattern for decoder to MomentOrDay. Pattern: " ++ (toString string))
      in
          oneOf
            [ when tag ((==) "CompletionChange") decodeCompletionChange
            , when tag ((==) "Created") decodeCreated
            , when tag ((==) "ParentChange") decodeParentChange
            , when tag ((==) "PredictedEffortChange") decodePredictedEffortChange
            , when tag ((==) "TagsChange") (succeed TagsChange)
            , when tag ((==) "TitleChange") decodeTitleChange
            , Decode.string |> andThen (fromResult << fallthrough)
            ]

encodeTaskChange : TaskChange -> Encode.Value
encodeTaskChange =
    toString >> Encode.string

tag : Decoder String
tag =
    field "tag" Decode.string

decodeAtExactly : Decoder MomentOrDay
decodeAtExactly =
  Decode.map AtExactly (Decode.field "moment" decodeMoment)

decodeOnDayOf : Decoder MomentOrDay
decodeOnDayOf =
  Decode.map OnDayOf (Decode.field "moment" decodeMoment)



decodeMomentOrDay : Decoder MomentOrDay
decodeMomentOrDay =
    let
        fallthrough string =
            Result.Err ("Not valid pattern for decoder to MomentOrDay. Pattern: " ++ (toString string))
    in
        oneOf
          [ when tag ((==) "AtExactly") decodeAtExactly
          , when tag ((==) "OnDayOf") decodeOnDayOf
          , Decode.string |> andThen (fromResult << fallthrough)
          ]


encodeMomentOrDay : MomentOrDay -> Encode.Value
encodeMomentOrDay =
 toString >> Encode.string

decodeProgress : Decode.Decoder Progress
decodeProgress =
    Decode.map progressFromFloat Decode.float

encodeProgress : Progress -> Encode.Value
encodeProgress progress =
    Encode.float (part progress)

customDecoder : Decoder b -> (b -> Result String a) -> Decoder a
customDecoder primitiveDecoder customDecoderFunction =
   Decode.andThen
             (\a ->
                   case customDecoderFunction a of
                      Ok b -> Decode.succeed b
                      Err err -> Decode.fail err
             )
             primitiveDecoder

decodeMoment : Decode.Decoder Moment
decodeMoment =
    let
        convert n =
            fromResult (Result.mapError Time.Iso8601ErrorMsg.renderText (Time.Iso8601.toDateTime n))
            -- Decoders must have String errors
    in
        Decode.string |> andThen convert

encodeMoment : Moment -> Encode.Value
encodeMoment moment =
    Encode.string (Time.Iso8601.fromDateTime moment)
