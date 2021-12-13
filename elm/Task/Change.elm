module Task.Change exposing (..)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Helpers exposing (..)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Moment exposing (FuzzyMoment)
import SmartTime.Moment exposing (..)
import Task.Progress exposing (..)


{-| possible activities that can be logged about a task.
Working rules:

  - names should just be '(exact name of field being changed)+Change' [consistency]
  - value always includes the full value it was changed to at the time, never the delta [consistency]

-}
type Change
    = Created Moment
    | CompletionChange Progress
    | TitleChange String
    | PredictedEffortChange Duration
    | ParentChange ClassID
    | TagsChange
    | DateChange (Maybe FuzzyMoment)


decodeChange : Decode.Decoder Change
decodeChange =
    decodeCustom
        [ ( "CompletionChange", subtype CompletionChange "progress" decodeProgress )
        , ( "Created", subtype Created "moment" decodeMoment )
        , ( "ParentChange", subtype ParentChange "taskId" Decode.int )
        , ( "PredictedEffortChange", subtype PredictedEffortChange "duration" decodeDuration )
        , ( "TagsChange", succeed TagsChange )
        , ( "TitleChange", subtype TitleChange "string" Decode.string )
        ]


encodeChange : Change -> Encode.Value
encodeChange theTaskChange =
    case theTaskChange of
        Created moment ->
            Encode.object [ ( "Created", encodeMoment moment ) ]

        CompletionChange progress ->
            Encode.object [ ( "CompletionChange", encodeProgress progress ) ]

        TitleChange string ->
            Encode.object [ ( "TitleChange", Encode.string string ) ]

        PredictedEffortChange duration ->
            Encode.object [ ( "PredictedEffortChange", encodeDuration duration ) ]

        ParentChange taskId ->
            Encode.object [ ( "ParentChange", Encode.int taskId ) ]

        TagsChange ->
            Encode.string "TagsChange"

        DateChange taskMoment ->
            Encode.object [ ( "DateChange", Encode2.maybe encodeTaskMoment taskMoment ) ]
