module Model.Task exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Model.Moment exposing (..)
import Model.Progress exposing (..)
import Porting exposing (..)
import Time.DateTime as Moment exposing (DateTime, dateTime, day, hour, millisecond, minute, month, second, year, zero)
import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)


--import String


type alias Moment =
    DateTime


type alias LocalMoment =
    ZonedDateTime


{-| Definition of a single task.
Working rules:

  - there should be no fields for storing data that can be fully derived from other fields [consistency]
  - combine related fields into a single one with a tuple value [minimalism]

-}
type alias Task =
    { title : String
    , completion : Progress
    , editing : Bool
    , id : TaskId
    , predictedEffort : Duration
    , history : List HistoryEntry
    , parent : Maybe TaskId
    , tags : List String
    , project : Maybe ProjectId
    , deadline : Maybe MomentOrDay
    , plannedStart : Maybe MomentOrDay
    , plannedFinish : Maybe MomentOrDay
    , relevanceStarts : Maybe MomentOrDay
    , relevanceEnds : Maybe MomentOrDay
    }


decodeTask : Decode.Decoder Task
decodeTask =
    decode Task
        |> required "title" Decode.string
        |> required "completion" decodeProgress
        |> required "editing" Decode.bool
        |> required "id" Decode.int
        |> required "predictedEffort" Decode.int
        |> required "history" (Decode.list decodeHistoryEntry)
        |> required "parent" (Decode.maybe Decode.int)
        |> required "tags" (Decode.list Decode.string)
        |> required "project" (Decode.maybe Decode.int)
        |> required "deadline" (Decode.maybe decodeMomentOrDay)
        |> required "plannedStart" (Decode.maybe decodeMomentOrDay)
        |> required "plannedFinish" (Decode.maybe decodeMomentOrDay)
        |> required "relevanceStarts" (Decode.maybe decodeMomentOrDay)
        |> required "relevanceEnds" (Decode.maybe decodeMomentOrDay)


encodeTask : Task -> Encode.Value
encodeTask record =
    Encode.object
        [ ( "title", Encode.string <| record.title )
        , ( "completion", encodeProgress <| record.completion )
        , ( "editing", Encode.bool <| record.editing )
        , ( "id", Encode.int <| record.id )
        , ( "predictedEffort", Encode.int <| record.predictedEffort )
        , ( "history", Encode.list <| List.map encodeHistoryEntry <| record.history )
        , ( "parent", Encode2.maybe Encode.int record.parent )
        , ( "tags", Encode.list <| List.map Encode.string <| record.tags )
        , ( "project", Encode2.maybe Encode.int record.project )
        , ( "deadline", Encode2.maybe encodeMomentOrDay record.deadline )
        , ( "plannedStart", Encode2.maybe encodeMomentOrDay record.plannedStart )
        , ( "plannedFinish", Encode2.maybe encodeMomentOrDay record.plannedFinish )
        , ( "relevanceStarts", Encode2.maybe encodeMomentOrDay record.relevanceStarts )
        , ( "relevanceEnds", Encode2.maybe encodeMomentOrDay record.relevanceEnds )
        ]


newTask : String -> Int -> Task
newTask description id =
    { title = description
    , editing = False
    , id = id
    , completion = ( 0, Percent )
    , parent = Nothing
    , predictedEffort = 0
    , history = []
    , tags = []
    , project = Just 0
    , deadline = Nothing
    , plannedStart = Nothing
    , plannedFinish = Nothing
    , relevanceStarts = Nothing
    , relevanceEnds = Nothing
    }


{-| Defines a point where something changed in a task.
-}
type alias HistoryEntry =
    ( TaskChange, Moment )


decodeHistoryEntry : Decode.Decoder HistoryEntry
decodeHistoryEntry =
    fail "womp"


encodeHistoryEntry : HistoryEntry -> Encode.Value
encodeHistoryEntry record =
    Encode.object
        []



-- possible ways to filter the list of tasks (legacy)


type TaskListFilter
    = AllTasks
    | ActiveTasksOnly
    | CompletedTasksOnly


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


decodeTaskChange : Decode.Decoder TaskChange
decodeTaskChange =
    decodeTU "TaskChange"
        [ valueC "CompletionChange" (subValue CompletionChange "progress" decodeProgress)
        , valueC "Created" (subValue Created "moment" decodeMoment)
        , valueC "ParentChange" (subValue ParentChange "taskId" Decode.int)
        , valueC "PredictedEffortChange" (subValue PredictedEffortChange "duration" Decode.int)
        , valueC "TagsChange" (succeed TagsChange)
        , valueC "TitleChange" (subValue TitleChange "string" Decode.string)
        ]


encodeTaskChange : TaskChange -> Encode.Value
encodeTaskChange =
    toString >> Encode.string


type alias TaskId =
    Int


type alias ProjectId =
    Int
