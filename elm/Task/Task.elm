module Task.Task exposing (HistoryEntry, ProjectId, Task, TaskChange(..), TaskId, completed, decodeHistoryEntry, decodeTask, decodeTaskChange, encodeHistoryEntry, encodeTask, encodeTaskChange, newTask)

import Activity.Activity exposing (ActivityID)
import Date
import ID
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Moment as Moment exposing (..)
import Task.Progress exposing (..)
import Task.TaskMoment exposing (TaskMoment(..), decodeTaskMoment, encodeTaskMoment)


{-| Definition of a single task.
Working rules:

  - there should be no fields for storing data that can be fully derived from other fields [consistency]
  - combine related fields into a single one with a tuple value [minimalism]

-}
type alias Task =
    { title : String
    , completion : Progress
    , id : TaskId
    , minEffort : Duration
    , predictedEffort : Duration
    , maxEffort : Duration
    , history : List HistoryEntry
    , parent : Maybe TaskId
    , tags : List TagId
    , activity : Maybe ActivityID
    , deadline : TaskMoment
    , plannedStart : TaskMoment
    , plannedFinish : TaskMoment
    , relevanceStarts : TaskMoment
    , relevanceEnds : TaskMoment
    , importance : Int
    }


decodeTask : Decode.Decoder Task
decodeTask =
    decode Task
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "completion" decodeProgress
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "minEffort" decodeDuration
        |> Pipeline.required "predictedEffort" decodeDuration
        |> Pipeline.required "maxEffort" decodeDuration
        |> Pipeline.required "history" (Decode.list decodeHistoryEntry)
        |> Pipeline.required "parent" (Decode.nullable Decode.int)
        |> Pipeline.required "tags" (Decode.list Decode.int)
        |> Pipeline.required "activity" (Decode.nullable ID.decode)
        |> Pipeline.required "deadline" decodeTaskMoment
        |> Pipeline.required "plannedStart" decodeTaskMoment
        |> Pipeline.required "plannedFinish" decodeTaskMoment
        |> Pipeline.required "relevanceStarts" decodeTaskMoment
        |> Pipeline.required "relevanceEnds" decodeTaskMoment
        |> Pipeline.required "importance" Decode.int


encodeTask : Task -> Encode.Value
encodeTask record =
    Encode.object
        [ ( "title", Encode.string <| record.title )
        , ( "completion", encodeProgress <| record.completion )
        , ( "id", Encode.int <| record.id )
        , ( "minEffort", encodeDuration <| record.predictedEffort )
        , ( "predictedEffort", encodeDuration <| record.predictedEffort )
        , ( "maxEffort", encodeDuration <| record.predictedEffort )
        , ( "history", Encode.list encodeHistoryEntry record.history )
        , ( "parent", Encode2.maybe Encode.int record.parent )
        , ( "tags", Encode.list Encode.int record.tags )
        , ( "activity", Encode2.maybe ID.encode record.activity )
        , ( "deadline", encodeTaskMoment record.deadline )
        , ( "plannedStart", encodeTaskMoment record.plannedStart )
        , ( "plannedFinish", encodeTaskMoment record.plannedFinish )
        , ( "relevanceStarts", encodeTaskMoment record.relevanceStarts )
        , ( "relevanceEnds", encodeTaskMoment record.relevanceEnds )
        , ( "importance", Encode.int <| record.id )
        ]


newTask : String -> Int -> Task
newTask description id =
    { title = description
    , id = id
    , completion = ( 0, Percent )
    , parent = Nothing
    , maxEffort = Duration.zero
    , predictedEffort = Duration.zero
    , minEffort = Duration.zero
    , history = []
    , tags = []
    , activity = Nothing
    , deadline = Unset
    , plannedStart = Unset
    , plannedFinish = Unset
    , relevanceStarts = Unset
    , relevanceEnds = Unset
    , importance = 0
    }


type alias TagId =
    Int


{-| Defines a point where something changed in a task.
-}
type alias HistoryEntry =
    ( TaskChange, Moment )



-- TODO


decodeHistoryEntry : Decode.Decoder HistoryEntry
decodeHistoryEntry =
    fail "womp"


encodeHistoryEntry : HistoryEntry -> Encode.Value
encodeHistoryEntry record =
    Encode.object
        []


{-| possible activities that can be logged about a task.
Working rules:

  - names should just be '(exact name of field being changed)+Change' [consistency]
  - value always includes the full value it was changed to at the time, never the delta [consistency]

-}
type TaskChange
    = Created Moment
    | CompletionChange Progress
    | TitleChange String
    | PredictedEffortChange Duration
    | ParentChange TaskId
    | TagsChange
    | DateChange TaskMoment


decodeTaskChange : Decode.Decoder TaskChange
decodeTaskChange =
    decodeCustom
        [ ( "CompletionChange", subtype CompletionChange "progress" decodeProgress )
        , ( "Created", subtype Created "moment" decodeMoment )
        , ( "ParentChange", subtype ParentChange "taskId" Decode.int )
        , ( "PredictedEffortChange", subtype PredictedEffortChange "duration" decodeDuration )
        , ( "TagsChange", succeed TagsChange )
        , ( "TitleChange", subtype TitleChange "string" Decode.string )
        ]


encodeTaskChange : TaskChange -> Encode.Value
encodeTaskChange theTaskChange =
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
            Encode.object [ ( "DateChange", encodeTaskMoment taskMoment ) ]


type alias TaskId =
    Int


type alias ProjectId =
    Int


completed : Task -> Bool
completed task =
    isMax (.completion task)
