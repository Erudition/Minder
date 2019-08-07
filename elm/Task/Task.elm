module Task.Task exposing (HistoryEntry, ProjectId, Task, TaskChange(..), TaskId, completed, decodeHistoryEntry, decodeTask, decodeTaskChange, encodeHistoryEntry, encodeTask, encodeTaskChange, newTask, normalizeTitle, prioritize)

import Activity.Activity exposing (ActivityID)
import Date
import ID
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import SmartTime.Moment as Moment exposing (..)
import Task.Progress exposing (..)


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
    , deadline : Maybe FuzzyMoment
    , plannedStart : Maybe FuzzyMoment
    , plannedFinish : Maybe FuzzyMoment
    , relevanceStarts : Maybe FuzzyMoment
    , relevanceEnds : Maybe FuzzyMoment
    , importance : Float
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
        |> Pipeline.required "deadline" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "plannedStart" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "plannedFinish" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "relevanceStarts" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "relevanceEnds" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "importance" Decode.float


encodeTask : Task -> Encode.Value
encodeTask record =
    Encode.object
        [ ( "title", Encode.string <| record.title )
        , ( "completion", encodeProgress <| record.completion )
        , ( "id", Encode.int <| record.id )
        , ( "minEffort", encodeDuration <| record.minEffort )
        , ( "predictedEffort", encodeDuration <| record.predictedEffort )
        , ( "maxEffort", encodeDuration <| record.maxEffort )
        , ( "history", Encode.list encodeHistoryEntry record.history )
        , ( "parent", Encode2.maybe Encode.int record.parent )
        , ( "tags", Encode.list Encode.int record.tags )
        , ( "activity", Encode2.maybe ID.encode record.activity )
        , ( "deadline", Encode2.maybe encodeTaskMoment record.deadline )
        , ( "plannedStart", Encode2.maybe encodeTaskMoment record.plannedStart )
        , ( "plannedFinish", Encode2.maybe encodeTaskMoment record.plannedFinish )
        , ( "relevanceStarts", Encode2.maybe encodeTaskMoment record.relevanceStarts )
        , ( "relevanceEnds", Encode2.maybe encodeTaskMoment record.relevanceEnds )
        , ( "importance", Encode.float <| record.importance )
        ]


decodeTaskMoment : Decoder FuzzyMoment
decodeTaskMoment =
    customDecoder Decode.string HumanMoment.fuzzyFromString


{-| TODO make encoder
-}
encodeTaskMoment : FuzzyMoment -> Encode.Value
encodeTaskMoment fuzzy =
    Encode.string <| HumanMoment.fuzzyToString fuzzy


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
    , deadline = Nothing
    , plannedStart = Nothing
    , plannedFinish = Nothing
    , relevanceStarts = Nothing
    , relevanceEnds = Nothing
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
    | DateChange (Maybe FuzzyMoment)


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
            Encode.object [ ( "DateChange", Encode2.maybe encodeTaskMoment taskMoment ) ]


type alias TaskId =
    Int


type alias ProjectId =
    Int


completed : Task -> Bool
completed task =
    isMax (.completion task)


type alias WithSoonness t =
    { t | soonness : Duration }


prioritize : Moment -> HumanMoment.Zone -> List Task -> List Task
prioritize now zone taskList =
    let
        -- lowest values first
        compareProp prop a b =
            Basics.compare (prop a) (prop b)

        -- highest values first
        comparePropInverted prop a b =
            Basics.compare (prop b) (prop a)
    in
    deepSort [ compareSoonness zone, comparePropInverted .importance ] taskList


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle



-- List.sortWith (compareSoonness zone) <| List.sortBy .importance taskList


type alias CompareFunction a =
    a -> a -> Basics.Order


deepSort : List (CompareFunction a) -> List a -> List a
deepSort compareFuncs listToSort =
    let
        deepCompare funcs a b =
            case funcs of
                [] ->
                    -- No more comparisons to make, give up and say they're equal
                    EQ

                nextCompareFunc :: laterCompareFuncs ->
                    let
                        -- run next comparison
                        check =
                            nextCompareFunc a b
                    in
                    if check == EQ then
                        -- they still look equal, dig deeper
                        deepCompare laterCompareFuncs a b

                    else
                        -- we have a winner, we can stop digging
                        check
    in
    List.sortWith (deepCompare compareFuncs) listToSort


{-| TODO this could be a Moment.Fuzzy function
-}
compareSoonness : HumanMoment.Zone -> CompareFunction Task
compareSoonness zone taskA taskB =
    case ( taskA.deadline, taskB.deadline ) of
        ( Just fuzzyMomentA, Just fuzzyMomentB ) ->
            HumanMoment.compareFuzzyBasic zone Clock.endOfDay fuzzyMomentA fuzzyMomentB

        ( Nothing, Nothing ) ->
            -- whenevers can't be compared
            EQ

        ( Just _, Nothing ) ->
            -- actual times always come before whenevers
            LT

        ( Nothing, Just _ ) ->
            -- whenevers always come after actual times
            GT
