module Model exposing (..)

--import Time.TimeZones as TimeZones

import Model.Progress exposing (..)
import Time.DateTime as Moment exposing (DateTime, dateTime, day, hour, millisecond, minute, month, second, year)
import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)


--import String


type alias Moment =
    DateTime


type alias LocalMoment =
    ZonedDateTime


type alias Model =
    { tasks : List Task
    , field : String
    , uid : Int
    , visibility : String
    , errors : List String
    }



{--keep in sync with --}


emptyModel : Model
emptyModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , errors = []
    }


testModel : Model
testModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , errors = []
    }



{--Definition of a single task.
    Working rules:
    * there should be no fields for storing data that can be fully derived from other fields [consistency]
    * combine related fields into a single one with a tuple value [minimalism]
--}


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



{--Additional meta-fields (realized via functions):
    + completed : Bool
--}


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


type alias HistoryEntry =
    ( TaskChange, Moment )



-- possible ways to filter the list of tasks (legacy)


type TaskListFilter
    = AllTasks
    | ActiveTasksOnly
    | CompletedTasksOnly



{--possible activities that can be logged about a task.
    Working rules:
    * names should just be '(exact name of field being changed)+Change' [consistency]
    * value always includes the full value it was changed to at the time, never the delta [consistency]
--}


type TaskChange
    = Created Moment
    | CompletionChange Progress
    | TitleChange String
    | PredictedEffortChange Duration
    | ParentChange TaskId
    | TagsChange


type MomentOrDay
    = AtExactly Moment
    | OnDayOf Moment


type alias TaskId =
    Int


type alias Duration =
    Int



--seconds


type alias ProjectId =
    Int


type alias User =
    Int



-- to be determined
