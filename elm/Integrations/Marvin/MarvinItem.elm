module Integrations.Marvin.MarvinItem exposing (..)

import Json.Decode.Exploration exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode exposing (..)
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (Duration(..))
import SmartTime.Human.Calendar exposing (CalendarDate(..))
import SmartTime.Human.Calendar.Month exposing (Month(..))
import SmartTime.Human.Calendar.Year exposing (Year(..))
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Moment
import SmartTime.Moment exposing (Moment(..))
import Task.Class
import Task.Entry
import Task.Instance
import Task.Progress
import Task.SessionSkel exposing (UserPlannedSession)


type alias ItemID =
    Int


type alias UserID =
    Int


type alias CategoryOrProjectID =
    String


type alias LabelID =
    String


type alias CustomSectionID =
    String


type alias TimeBlockID =
    String


type alias RewardID =
    String


{-| Tasks - simplified API

// Time offset in minutes
//
// Added to time to fix time zone issues. So if the user is in Pacific time,
// this would be -8\*60. If the user added a task with +today at 22:00 local
// time 2019-12-05, then we want to create the task on 2019-12-05 and not
// 2019-12-06 (which is the server date).

-}
type alias MarvinItem =
    { id : String
    , done : Bool
    , day : Maybe CalendarDate
    , title : String
    , parentId : Maybe CategoryOrProjectID
    , labelIds : List LabelID
    , firstScheduled : Maybe CalendarDate
    , rank : Int
    , dailySection : Maybe String
    , bonusSection : EssentialOrBonus
    , customSection : Maybe CustomSectionID
    , timeBlockSection : Maybe TimeBlockID
    , note : Maybe String
    , dueDate : Maybe CalendarDate
    , timeEstimate : Maybe Duration
    , isReward : Bool
    , isStarred : Int
    , isFrogged : Int
    , plannedWeek : Maybe CalendarDate
    , plannedMonth : Maybe ( Year, Month )
    , rewardPoints : Float
    , rewardId : Maybe RewardID
    , backburner : Bool
    , reviewDate : Maybe CalendarDate
    , itemSnoozeTime : Maybe Moment
    , permaSnoozeTime : Maybe TimeOfDay
    , timeZoneOffset : Maybe Int
    , startDate : Maybe CalendarDate
    , endDate : Maybe CalendarDate
    , db : String
    , type_ : String
    , times : List Moment
    , taskTime : Maybe TimeOfDay
    }


encodeMarvinItem : MarvinItem -> Encode.Value
encodeMarvinItem task =
    Encode.object <|
        [ ( "_id", Encode.string task.id )
        , ( "done", Encode.bool task.done )
        , ( "day", Encode.maybe encodeCalendarDate task.day )
        , ( "title", Encode.string task.title )
        , ( "parentId", Encode.string (Maybe.withDefault "unassigned" task.parentId) )
        , ( "labelIds", Encode.list Encode.string task.labelIds )
        , ( "firstScheduled", Encode.maybe encodeCalendarDate task.firstScheduled )
        , ( "rank", Encode.int task.rank )
        , ( "dailySection", Encode.maybe Encode.string task.dailySection )
        , ( "bonusSection", encodeEssentialOrBonus task.bonusSection )
        , ( "customSection", Encode.maybe Encode.string task.customSection )
        , ( "timeBlockSection", Encode.maybe Encode.string task.timeBlockSection )
        , ( "note", Encode.maybe Encode.string task.note )
        , ( "dueDate", Encode.maybe encodeCalendarDate task.dueDate )
        , ( "timeEstimate", Encode.maybe encodeDuration task.timeEstimate )
        , ( "isReward", Encode.bool task.isReward )
        , ( "isStarred", Encode.int task.isStarred )
        , ( "isFrogged", Encode.int task.isFrogged )
        , ( "plannedWeek", Encode.maybe encodeCalendarDate task.plannedWeek )
        , ( "plannedMonth", encodeMonth task.plannedMonth )
        , ( "rewardPoints", Encode.float task.rewardPoints )
        , ( "rewardId", Encode.maybe Encode.string task.rewardId )
        , ( "backburner", Encode.bool task.backburner )
        , ( "reviewDate", Encode.maybe encodeCalendarDate task.reviewDate )
        , ( "itemSnoozeTime", Encode.maybe encodeMoment task.itemSnoozeTime )
        , ( "permaSnoozeTime", Encode.maybe encodeTimeOfDay task.permaSnoozeTime )
        , ( "timeZoneOffset", Encode.maybe Encode.int task.timeZoneOffset )
        , ( "startDate", Encode.maybe encodeCalendarDate task.startDate )
        , ( "endDate", Encode.maybe encodeCalendarDate task.endDate )
        , ( "db", Encode.string task.db )
        , ( "type", Encode.string task.type_ )
        , ( "times", Encode.list encodeMoment task.times )
        , ( "taskTime", Encode.maybe encodeTimeOfDay task.taskTime )
        ]


decodeMarvinItem : Decoder MarvinItem
decodeMarvinItem =
    succeed MarvinItem
        |> required "_id" string
        |> optional "done" bool False
        |> required "day" (nullable calendarDateDecoder)
        |> required "title" string
        |> optional "parentId" (oneOf [ check string "unassigned" <| succeed Nothing, nullable string ]) Nothing
        |> optional "labelIds" (list string) []
        |> optional "firstScheduled" (nullable calendarDateDecoder) Nothing
        |> required "rank" int
        |> optional "dailySection" (nullable string) Nothing
        |> optional "bonusSection" essentialOrBonusDecoder Essential
        |> optional "customSection" (nullable string) Nothing
        |> optional "timeBlockSection" (nullable string) Nothing
        |> optional "note" (nullable string) Nothing
        |> optional "dueDate" (nullable calendarDateDecoder) Nothing
        |> optional "timeEstimate" (nullable decodeDuration) Nothing
        |> optional "isReward" bool False
        |> optional "isStarred" (oneOf [ check bool False <| succeed 0, int ]) 0
        |> optional "isFrogged" (oneOf [ check bool False <| succeed 0, int ]) 0
        |> optional "plannedWeek" (nullable calendarDateDecoder) Nothing
        |> optional "plannedMonth" (nullable monthDecoder) Nothing
        |> optional "rewardPoints" float 0
        |> optional "rewardId" (nullable string) Nothing
        |> optional "backburner" bool False
        |> optional "reviewDate" (nullable calendarDateDecoder) Nothing
        |> optional "itemSnoozeTime" (nullable decodeMoment) Nothing
        |> optional "permaSnoozeTime" (nullable timeOfDayDecoder) Nothing
        |> optional "timeZoneOffset" (nullable int) Nothing
        |> optional "startDate" (nullable calendarDateDecoder) Nothing
        |> optional "endDate" (nullable calendarDateDecoder) Nothing
        |> required "db" string
        |> optional "type" string ""
        |> optional "times" (list decodeMoment) []
        |> optional "taskTime" (nullable timeOfDayDecoder) Nothing
        |> optionalIgnored "subtasks"
        |> optionalIgnored "reminderTime"
        |> optionalIgnored "autoSnooze"
        |> optionalIgnored "snooze"
        |> optionalIgnored "reminderOffset"
        |> optionalIgnored "masterRank"
        |> optionalIgnored "fixParentId"
        --undocumented^
        |> optionalIgnored "rank_fbfe2f43-3ed1-472a-bea7-d1bc2185ccf6"
        --undocumented^
        |> optionalIgnored "echoedAt"
        |> optionalIgnored "fieldUpdates"
        --undocumented^
        |> optionalIgnored "updatedAt"
        |> optionalIgnored "duration"
        |> optionalIgnored "doneAt"
        --undocumented^
        |> optionalIgnored "completedAt"
        |> optionalIgnored "remind"
        |> optionalIgnored "echo"
        |> optionalIgnored "reminder"
        |> optionalIgnored "remindAt"
        |> optionalIgnored "echoId"
        |> optionalIgnored "recurring"
        |> optionalIgnored "recurringTaskId"
        |> optionalIgnored "createdAt"
        |> optionalIgnored "generatedAt"
        |> optionalIgnored "sectionId"
        |> optionalIgnored "sectionid"
        |> optionalIgnored "_rev"
        |> optionalIgnored "imported"
        |> optionalIgnored "workedOnAt"
        |> optionalIgnored "newRecurringProject"
        |> optionalIgnored ""
        -- yes, really...^
        |> optionalIgnored "dependsOn"
        |> optionalIgnored "ackedDeps"
        |> optionalIgnored "priority"
        |> optionalIgnored "rank_43f625b3-1d08-4f0f-b21e-d0a8d2f707ea"


encodeCalendarDate : CalendarDate -> Encode.Value
encodeCalendarDate date =
    Encode.string <| SmartTime.Human.Calendar.toStandardString date


calendarDateDecoder : Decoder CalendarDate
calendarDateDecoder =
    customDecoder string SmartTime.Human.Calendar.fromNumberString


type EssentialOrBonus
    = Essential
    | Bonus


encodeEssentialOrBonus : EssentialOrBonus -> Encode.Value
encodeEssentialOrBonus essentialOrBonus =
    case essentialOrBonus of
        Essential ->
            Encode.string "Essential"

        Bonus ->
            Encode.string "Bonus"


essentialOrBonusDecoder : Decoder EssentialOrBonus
essentialOrBonusDecoder =
    let
        get id =
            case id of
                "Essential" ->
                    succeed Essential

                "Bonus" ->
                    succeed Bonus

                _ ->
                    fail ("unknown value for EssentialOrBonus: " ++ id)
    in
    string |> andThen get


encodeMonth : Maybe ( Year, Month ) -> Encode.Value
encodeMonth maybeMonth =
    case maybeMonth of
        Just ( year, month ) ->
            Encode.string (SmartTime.Human.Calendar.Year.toString year ++ (String.fromInt <| SmartTime.Human.Calendar.Month.toInt month))

        Nothing ->
            Encode.null


monthDecoder : Decoder ( Year, Month )
monthDecoder =
    let
        fakeDate twoPartString =
            SmartTime.Human.Calendar.fromNumberString (twoPartString ++ "-01")

        toYearAndMonth date =
            ( SmartTime.Human.Calendar.year date, SmartTime.Human.Calendar.month date )

        output input =
            Result.map toYearAndMonth (fakeDate input)
    in
    customDecoder string output


encodeTimeOfDay : TimeOfDay -> Encode.Value
encodeTimeOfDay clock =
    Encode.string <| SmartTime.Human.Clock.toStandardString clock


timeOfDayDecoder : Decoder TimeOfDay
timeOfDayDecoder =
    customDecoder string SmartTime.Human.Clock.fromStandardString


toDocketTaskNaive : Int -> MarvinItem -> { entry : Task.Entry.Entry, class : Task.Class.ClassSkel, instance : Task.Instance.InstanceSkel }
toDocketTaskNaive classCounter marvinItem =
    let
        classID =
            classCounter + 1

        entry =
            Task.Entry.newRootEntry classID

        classBase =
            Task.Class.newClassSkel marvinItem.title classID

        finalClass =
            { classBase
                | predictedEffort = Maybe.withDefault Duration.zero marvinItem.timeEstimate
                , importance = toFloat marvinItem.isStarred
            }

        instanceBase =
            Task.Instance.newInstanceSkel classCounter finalClass

        plannedSessionList : List UserPlannedSession
        plannedSessionList =
            case ( marvinItem.taskTime, marvinItem.timeEstimate, marvinItem.day ) of
                ( Just plannedTime, Just plannedDuration, Just plannedDay ) ->
                    -- creates a new PlannedSession
                    List.singleton ( SmartTime.Human.Moment.Floating ( plannedDay, plannedTime ), plannedDuration )

                _ ->
                    []

        finalInstance =
            { instanceBase
                | completion =
                    if marvinItem.done then
                        100

                    else
                        0
                , externalDeadline = Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.dueDate
                , startBy = Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.startDate
                , finishBy = Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.endDate
                , plannedSessions = plannedSessionList
            }
    in
    { entry = entry, class = finalClass, instance = finalInstance }
