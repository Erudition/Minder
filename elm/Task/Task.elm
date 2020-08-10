module Task.Task exposing (TaskChange(..), TaskClass, TaskClassID, TaskInstance, TaskInstanceID, completed, decodeTaskChange, decodeTaskInstance, encodeTaskChange, encodeTaskInstance, newTaskClass, normalizeTitle, prioritize)

import Activity.Activity exposing (ActivityID)
import Activity.Evidence exposing (Evidence(..))
import Activity.Template exposing (Template(..))
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
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import SmartTime.Moment as Moment exposing (..)
import Task.Progress as Progress exposing (..)


{-| A TaskClass is an exact specific task, in general, without a time. If you took a shower yesterday, and you take a shower tomorrow, those are two separate TaskInstances - but they are instances of the same TaskClass ("take a shower").
This way, the same task can be assigned multiple times in life (either automatic recurrence, or by manually adding a new instance) and the program is aware they are the same thing.

Tasks that are only similar, e.g. "take a bath", should be separate TaskClasses.

-}
type alias TaskClass =
    { title : String -- Class
    , id : TaskClassID -- Class and Instance
    , activity : Maybe ActivityID

    --, template : TaskTemplate
    , completionUnits : Progress.Unit
    , minEffort : Duration -- Class. can always revise
    , predictedEffort : Duration -- Class. can always revise
    , maxEffort : Duration -- Class. can always revise

    --, tags : List TagId -- Class
    , defaultExternalDeadline : List RelativeTaskTiming
    , defaultStartBy : List RelativeTaskTiming --  THESE ARE NORMALLY SPECIFIED AT THE INSTANCE LEVEL
    , defaultFinishBy : List RelativeTaskTiming
    , defaultRelevanceStarts : List RelativeTaskTiming
    , defaultRelevanceEnds : List RelativeTaskTiming
    , importance : Float -- Class

    -- future: default Session strategy
    }


decodeTaskClass : Decode.Decoder TaskClass
decodeTaskClass =
    decode TaskClass
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "id" decodeTaskClassID
        |> Pipeline.required "activity" (Decode.nullable <| ID.decode)
        |> Pipeline.required "completionUnits" Progress.decodeUnit
        |> Pipeline.required "minEffort" decodeDuration
        |> Pipeline.required "predictedEffort" decodeDuration
        |> Pipeline.required "maxEffort" decodeDuration
        |> Pipeline.required "defaultExternalDeadline" (Decode.list decodeRelativeTaskTiming)
        |> Pipeline.required "defaultStartBy" (Decode.list decodeRelativeTaskTiming)
        |> Pipeline.required "defaultFinishBy" (Decode.list decodeRelativeTaskTiming)
        |> Pipeline.required "defaultRelevanceStarts" (Decode.list decodeRelativeTaskTiming)
        |> Pipeline.required "defaultRelevanceEnds" (Decode.list decodeRelativeTaskTiming)
        |> Pipeline.required "importance" Decode.float


encodeTaskClass : TaskClass -> Encode.Value
encodeTaskClass taskClass =
    object <|
        [ ( "title", Encode.string taskClass.title )
        , ( "id", Encode.int taskClass.id )
        , ( "activity", Encode2.maybe ID.encode taskClass.activity )
        , ( "completionUnits", Progress.encodeUnit taskClass.completionUnits )
        , ( "minEffort", encodeDuration taskClass.minEffort )
        , ( "predictedEffort", encodeDuration taskClass.predictedEffort )
        , ( "maxEffort", encodeDuration taskClass.maxEffort )
        , ( "defaultExternalDeadline", Encode.list encodeRelativeTaskTiming taskClass.defaultExternalDeadline )
        , ( "defaultStartBy", Encode.list encodeRelativeTaskTiming taskClass.defaultStartBy )
        , ( "defaultFinishBy", Encode.list encodeRelativeTaskTiming taskClass.defaultFinishBy )
        , ( "defaultRelevanceStarts", Encode.list encodeRelativeTaskTiming taskClass.defaultRelevanceStarts )
        , ( "defaultRelevanceEnds", Encode.list encodeRelativeTaskTiming taskClass.defaultRelevanceEnds )
        , ( "importance", Encode.float taskClass.importance )
        ]


newTaskClass : String -> Int -> TaskClass
newTaskClass givenTitle newID =
    { title = givenTitle
    , id = newID
    , activity = Nothing
    , completionUnits = Progress.Percent
    , minEffort = Duration.zero
    , predictedEffort = Duration.zero
    , maxEffort = Duration.zero
    , defaultExternalDeadline = []
    , defaultStartBy = []
    , defaultFinishBy = []
    , defaultRelevanceStarts = []
    , defaultRelevanceEnds = []
    , importance = 1
    }


{-| Definition of a single task.
Working rules:

  - there should be no fields for storing data that can be fully derived from other fields [consistency]
  - combine related fields into a single one with a tuple value [minimalism]

-- One particular time that the specific thing will be done, that can be scheduled
-- A class could have NO instances yet - they're calculated on the fly

-}
type alias TaskInstance =
    { class : TaskClassID
    , id : TaskInstanceID
    , completion : Progress.Portion
    , externalDeadline : Maybe FuzzyMoment -- *
    , startBy : Maybe FuzzyMoment -- *
    , finishBy : Maybe FuzzyMoment -- *
    , plannedSessions : List PlannedSession
    , relevanceStarts : Maybe FuzzyMoment -- *
    , relevanceEnds : Maybe FuzzyMoment -- * (*)=An absolute FuzzyMoment if specified, otherwise generated by relative rules from class
    }


decodeTaskInstance : Decode.Decoder TaskInstance
decodeTaskInstance =
    decode TaskInstance
        |> Pipeline.required "class" decodeTaskClassID
        |> Pipeline.required "id" decodeTaskInstanceID
        |> Pipeline.required "completion" Decode.int
        |> Pipeline.required "externalDeadline" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "startBy" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "finishBy" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "plannedSessions" (Decode.list decodePlannedSession)
        |> Pipeline.required "relevanceStarts" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "relevanceEnds" (Decode.nullable decodeTaskMoment)


encodeTaskInstance : TaskInstance -> Encode.Value
encodeTaskInstance taskInstance =
    Encode.object <|
        [ ( "class", Encode.int taskInstance.class )
        , ( "id", Encode.int taskInstance.id )
        , ( "completion", Encode.int taskInstance.completion )
        , ( "externalDeadline", Encode2.maybe encodeTaskMoment taskInstance.externalDeadline )
        , ( "startBy", Encode2.maybe encodeTaskMoment taskInstance.startBy )
        , ( "finishBy", Encode2.maybe encodeTaskMoment taskInstance.finishBy )
        , ( "plannedSessions", Encode.list encodePlannedSession taskInstance.plannedSessions )
        , ( "relevanceStarts", Encode2.maybe encodeTaskMoment taskInstance.relevanceStarts )
        , ( "relevanceEnds", Encode2.maybe encodeTaskMoment taskInstance.relevanceEnds )
        ]



--encodeTaskInstance record =
--    Encode.object
--        [ ( "title", Encode.string <| record.title )
--        , ( "completion", encodeProgress <| record.completion )
--        , ( "id", Encode.int <| record.id )
--        , ( "minEffort", encodeDuration <| record.minEffort )
--        , ( "predictedEffort", encodeDuration <| record.predictedEffort )
--        , ( "maxEffort", encodeDuration <| record.maxEffort )
--        , ( "history", Encode.list encodeHistoryEntry record.history )
--        , ( "parent", Encode2.maybe Encode.int record.parent )
--        , ( "tags", Encode.list Encode.int record.tags )
--        , ( "activity", Encode2.maybe ID.encode record.activity )
--        , ( "deadline", Encode2.maybe encodeTaskMoment record.externalDeadline )
--        , ( "plannedStart", Encode2.maybe encodeTaskMoment record.plannedStart )
--        , ( "plannedFinish", Encode2.maybe encodeTaskMoment record.plannedFinish )
--        , ( "relevanceStarts", Encode2.maybe encodeTaskMoment record.relevanceStarts )
--        , ( "relevanceEnds", Encode2.maybe encodeTaskMoment record.relevanceEnds )
--        , ( "importance", Encode.float <| record.importance )
--        ]


decodeTaskMoment : Decoder FuzzyMoment
decodeTaskMoment =
    customDecoder Decode.string HumanMoment.fuzzyFromString


{-| TODO make encoder
-}
encodeTaskMoment : FuzzyMoment -> Encode.Value
encodeTaskMoment fuzzy =
    Encode.string <| HumanMoment.fuzzyToString fuzzy


type alias TagId =
    Int


type alias PlannedSession =
    ( FuzzyMoment, Duration )


decodePlannedSession : Decoder PlannedSession
decodePlannedSession =
    Debug.todo "decode plannedSessions"


encodePlannedSession : PlannedSession -> Encode.Value
encodePlannedSession plannedSession =
    Debug.todo "encode plannedSessions"


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
    | ParentChange TaskClassID
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


type alias TaskClassID =
    Int


decodeTaskClassID : Decoder TaskClassID
decodeTaskClassID =
    Decode.int


encodeTaskClassID : TaskClassID -> Encode.Value
encodeTaskClassID taskClassID =
    Encode.int taskClassID


type alias TaskInstanceID =
    Int


decodeTaskInstanceID : Decoder TaskInstanceID
decodeTaskInstanceID =
    Decode.int


encodeTaskInstanceID : TaskInstanceID -> Encode.Value
encodeTaskInstanceID taskInstanceID =
    Encode.int taskInstanceID


{-| Need to be able to specify multiple of these, as some may not apply.
-}
type RelativeTaskTiming
    = FromDeadline Duration
    | FromToday Duration


decodeRelativeTaskTiming : Decoder RelativeTaskTiming
decodeRelativeTaskTiming =
    Debug.todo "decode relativetasktimings"


encodeRelativeTaskTiming : RelativeTaskTiming -> Encode.Value
encodeRelativeTaskTiming relativeTaskTiming =
    case relativeTaskTiming of
        FromDeadline duration ->
            encodeDuration duration

        FromToday duration ->
            encodeDuration duration



-- TASK HELPER FUNCTIONS


completed : TaskInstance -> Bool
completed task =
    isMax (.completion task)


type alias WithSoonness t =
    { t | soonness : Duration }


prioritize : Moment -> HumanMoment.Zone -> List TaskInstance -> List TaskInstance
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
compareSoonness : HumanMoment.Zone -> CompareFunction TaskInstance
compareSoonness zone taskA taskB =
    case ( taskA.externalDeadline, taskB.externalDeadline ) of
        ( Just fuzzyMomentA, Just fuzzyMomentB ) ->
            HumanMoment.compareFuzzyLateness zone Clock.endOfDay fuzzyMomentA fuzzyMomentB

        ( Nothing, Nothing ) ->
            -- whenevers can't be compared
            EQ

        ( Just _, Nothing ) ->
            -- actual times always come before whenevers
            LT

        ( Nothing, Just _ ) ->
            -- whenevers always come after actual times
            GT
