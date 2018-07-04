module Porting exposing (..)


import Json.Decode exposing (..)
import Json.Encode exposing (..)

import Json.Encode.Extra exposing (..)
import Json.Decode.Extra exposing (..)

import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

-- ours:
import Model exposing (..)


encodeMaybe = Json.Decode.maybe
decodeMaybe = Json.Encode.Extra.maybe



{-- Everything below is pasted verbatim from elm2json.com
    with our model's types as input --}



decodeTask : Json.Decode.Decoder Task
decodeTask =
    Json.Decode.Pipeline.decode Task
        |> Json.Decode.Pipeline.required "title" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "completion" (decodeProgress)
        |> Json.Decode.Pipeline.required "editing" (Json.Decode.bool)
        |> Json.Decode.Pipeline.required "id" (decodeTaskId)
        |> Json.Decode.Pipeline.required "predictedEffort" (decodeDuration)
        |> Json.Decode.Pipeline.required "history" (Json.Decode.list decodeHistoryEntry)
        |> Json.Decode.Pipeline.required "parent" (decodeMaybe decodeTaskId)
        |> Json.Decode.Pipeline.required "tags" (Json.Decode.list Json.Decode.string)
        |> Json.Decode.Pipeline.required "project" (decodeMaybe decodeProjectId)
        |> Json.Decode.Pipeline.required "deadline" (decodeMaybe decodeMomentOrDay)
        |> Json.Decode.Pipeline.required "plannedStart" (decodeMaybe decodeMomentOrDay)
        |> Json.Decode.Pipeline.required "plannedFinish" (decodeMaybe decodeMomentOrDay)
        |> Json.Decode.Pipeline.required "relevanceStarts" (decodeMaybe decodeMomentOrDay)
        |> Json.Decode.Pipeline.required "relevanceEnds" (decodeMaybe decodeMomentOrDay)

encodeTask : Task -> Json.Encode.Value
encodeTask record =
    Json.Encode.object
        [ ("title",  Json.Encode.string <| record.title)
        , ("completion",  encodeProgress <| record.completion)
        , ("editing",  Json.Encode.bool <| record.editing)
        , ("id",  encodeTaskId <| record.id)
        , ("predictedEffort",  encodeDuration <| record.predictedEffort)
        , ("history",  Json.Encode.list <| List.map encodeHistoryEntry <| record.history)
        , ("parent",  encodeMaybe <| encodeTaskId <| record.parent)
        , ("tags",  Json.Encode.list <| List.map Json.Encode.string <| record.tags)
        , ("project",  encodeMaybe <| encodeProjectId <| record.project)
        , ("deadline",  encodeMaybe <| encodeMomentOrDay <| record.deadline)
        , ("plannedStart",  encodeMaybe <| encodeMomentOrDay <| record.plannedStart)
        , ("plannedFinish",  encodeMaybe <| encodeMomentOrDay <| record.plannedFinish)
        , ("relevanceStarts",  encodeMaybe <| encodeMomentOrDay <| record.relevanceStarts)
        , ("relevanceEnds",  encodeMaybe <| encodeMomentOrDay <| record.relevanceEnds)
        ]


decodeHistoryEntry : Json.Decode.Decoder HistoryEntry
decodeHistoryEntry =
    Json.Decode.map0 HistoryEntry


encodeHistoryEntry : HistoryEntry -> Json.Encode.Value
encodeHistoryEntry record =
    Json.Encode.object
        [
        ]

fromStringTaskChange : TaskChange -> Result String String
fromStringTaskChange string =
    case string of
        "CompletionChange Progress" -> Result.Ok CompletionChange Progress
        "Created Moment" -> Result.Ok Created Moment
        "ParentChange TaskId" -> Result.Ok ParentChange TaskId
        "PredictedEffortChange Duration" -> Result.Ok PredictedEffortChange Duration
        "TagsChange" -> Result.Ok TagsChange
        "TitleChange String" -> Result.Ok TitleChange String
        _ -> Result.Err ("Not valid pattern for decoder to TaskChange. Pattern: " ++ (toString string))

decodeTaskChange : Json.Decode.Decoder TaskChange
decodeTaskChange =
    Json.Decode.andThen Json.Decode.string fromStringTaskChange

encodeTaskChange : TaskChange -> Json.Encode.Value
encodeTaskChange =
    toString >> Json.Encode.string

fromStringMomentOrDay : MomentOrDay -> Result String String
fromStringMomentOrDay string =
    case string of
        "AtExactly Moment" -> Result.Ok AtExactly Moment
        "OnDayOf Moment" -> Result.Ok OnDayOf Moment
        _ -> Result.Err ("Not valid pattern for decoder to MomentOrDay. Pattern: " ++ (toString string))

decodeMomentOrDay : Json.Decode.Decoder MomentOrDay
decodeMomentOrDay =
    Json.Decode.andThen Json.Decode.string fromStringMomentOrDay

encodeMomentOrDay : MomentOrDay -> Json.Encode.Value
encodeMomentOrDay =
 toString >> Json.Encode.string

decodeTaskId : Json.Decode.Decoder TaskId
decodeTaskId =
    Json.Decode.map0 TaskId


encodeTaskId : TaskId -> Json.Encode.Value
encodeTaskId record =
    Json.Encode.object
        [
        ]

decodeProjectId : Json.Decode.Decoder ProjectId
decodeProjectId =
    Json.Decode.map0 ProjectId


encodeProjectId : ProjectId -> Json.Encode.Value
encodeProjectId record =
    Json.Encode.object
        [
        ]
