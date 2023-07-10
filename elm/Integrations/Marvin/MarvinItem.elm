module Integrations.Marvin.MarvinItem exposing (..)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import Dict exposing (Dict)
import Helpers exposing (..)
import ID
import IntDict
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode exposing (..)
import List.Extra as List
import Maybe.Extra
import Profile exposing (Profile)
import Regex
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (Codec)
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb(..))
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration(..))
import SmartTime.Human.Calendar exposing (CalendarDate(..))
import SmartTime.Human.Calendar.Month exposing (Month(..))
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Human.Calendar.Year exposing (Year(..))
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Moment
import SmartTime.Moment as Moment exposing (Moment(..))
import SmartTime.Period as Period exposing (Period(..))
import Task.Assignable
import Task.Assignment
import Task.Meta exposing (..)
import Task.Progress
import Task.Project
import Task.SessionSkel exposing (UserPlannedSession)
import TimeBlock.TimeBlock as TimeBlock exposing (TimeBlock)
import ZoneHistory exposing (ZoneHistory)


type alias ItemID =
    String


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


type ItemType
    = Task
    | Project
    | Category


encodeItemType : ItemType -> Value
encodeItemType itemType =
    case itemType of
        Task ->
            Encode.string "task"

        Project ->
            Encode.string "project"

        Category ->
            Encode.string "category"


decodeItemType : Decoder ItemType
decodeItemType =
    let
        get id =
            case id of
                "task" ->
                    succeed Task

                "project" ->
                    succeed Project

                "category" ->
                    succeed Category

                _ ->
                    fail ("unknown value for ItemType: " ++ id)
    in
    string |> andThen get


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
    , rev : String
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
    , times : List Moment
    , taskTime : Maybe TimeOfDay
    , pinId : Maybe String
    , recurringTaskId : Maybe String
    , masterRank : Float
    , createdAt : Moment
    , doneAt : Maybe Moment
    , updatedAt : Maybe Moment
    , fieldUpdates : Dict String Moment
    }


encodeMarvinItem : MarvinItem -> Encode.Value
encodeMarvinItem task =
    encodeObjectWithoutNothings
        [ normal ( "_id", Encode.string task.id )
        , normal ( "_rev", Encode.string task.rev )
        , omittableBool ( "done", Encode.bool, task.done )
        , omittable ( "day", encodeCalendarDate, task.day )
        , normal ( "title", Encode.string task.title )
        , normal ( "parentId", Encode.string (Maybe.withDefault "unassigned" task.parentId) )
        , omittableList ( "labelIds", Encode.string, task.labelIds )
        , normal ( "firstScheduled", Maybe.withDefault (Encode.string "unassigned") (Maybe.map encodeCalendarDate task.firstScheduled) )
        , normal ( "rank", Encode.int task.rank )
        , omittable ( "dailySection", Encode.string, task.dailySection )
        , normal ( "bonusSection", encodeEssentialOrBonus task.bonusSection )
        , omittable ( "customSection", Encode.string, task.customSection )
        , omittable ( "timeBlockSection", Encode.string, task.timeBlockSection )
        , omittable ( "note", Encode.string, task.note )
        , omittable ( "dueDate", encodeCalendarDate, task.dueDate )
        , omittable ( "timeEstimate", encodeDuration, task.timeEstimate )
        , omittableBool ( "isReward", Encode.bool, task.isReward )
        , omittableNum ( "isStarred", Encode.int, task.isStarred )
        , omittableNum ( "isFrogged", Encode.int, task.isFrogged )
        , omittable ( "plannedWeek", encodeCalendarDate, task.plannedWeek )
        , omittable ( "plannedMonth", encodeMonth, task.plannedMonth )
        , omittableNum ( "rewardPoints", Encode.float, task.rewardPoints )
        , omittable ( "rewardId", Encode.string, task.rewardId )
        , omittableBool ( "backburner", Encode.bool, task.backburner )
        , omittable ( "reviewDate", encodeCalendarDate, task.reviewDate )
        , omittable ( "itemSnoozeTime", encodeUnixTimestamp, task.itemSnoozeTime )
        , omittable ( "permaSnoozeTime", encodeTimeOfDay, task.permaSnoozeTime )
        , omittable ( "timeZoneOffset", Encode.int, task.timeZoneOffset )
        , omittable ( "startDate", encodeCalendarDate, task.startDate )
        , omittable ( "endDate", encodeCalendarDate, task.endDate )
        , normal ( "db", Encode.string task.db )
        , omittableList ( "times", encodeUnixTimestamp, task.times )
        , omittable ( "taskTime", encodeTimeOfDay, task.taskTime )
        , omittableNum ( "masterRank", Encode.float, task.masterRank )
        , normal ( "createdAt", encodeUnixTimestamp task.createdAt )
        , omittable ( "doneAt", encodeUnixTimestamp, task.doneAt )
        , omittable ( "updatedAt", encodeUnixTimestamp, task.updatedAt )
        , normal ( "fieldUpdates", Encode.dict identity encodeUnixTimestamp task.fieldUpdates )
        ]


decodeMarvinItem : Decoder MarvinItem
decodeMarvinItem =
    succeed MarvinItem
        |> required "_id" string
        |> optional "_rev" string "unknown"
        |> optional "done" bool False
        |> optional "day" (oneOf [ check string "unassigned" <| succeed Nothing, nullable calendarDateDecoder ]) Nothing
        |> required "title" string
        |> optional "parentId" (oneOf [ check string "unassigned" <| succeed Nothing, nullable string ]) Nothing
        |> optional "labelIds" (list string) []
        |> optional "firstScheduled" (oneOf [ check string "unassigned" <| succeed Nothing, nullable calendarDateDecoder ]) Nothing
        |> optional "rank" int 0
        |> optional "dailySection" (nullable string) Nothing
        |> optional "bonusSection" essentialOrBonusDecoder Essential
        |> optional "customSection" (nullable string) Nothing
        |> optional "timeBlockSection" (nullable string) Nothing
        |> optional "note" (nullable string) Nothing
        |> optional "dueDate" (oneOf [ check string "" <| succeed Nothing, nullable calendarDateDecoder ]) Nothing
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
        |> optional "itemSnoozeTime" (nullable decodeUnixTimestamp) Nothing
        |> optional "permaSnoozeTime" (nullable timeOfDayDecoder) Nothing
        |> optional "timeZoneOffset" (nullable int) Nothing
        |> optional "startDate" (nullable calendarDateDecoder) Nothing
        |> optional "endDate" (nullable calendarDateDecoder) Nothing
        |> optional "db" string ""
        |> optional "times" (list decodeUnixTimestamp) []
        |> optional "taskTime" (nullable timeOfDayDecoder) Nothing
        |> optional "pinID" (nullable string) Nothing
        |> optional "recurringTaskId" (nullable string) Nothing
        |> optional "masterRank" float 0
        |> required "createdAt" decodeUnixTimestamp
        |> optional "doneAt" (nullable decodeUnixTimestamp) Nothing
        |> optional "updatedAt" (nullable decodeUnixTimestamp) Nothing
        |> optional "fieldUpdates" (Decode.dict decodeUnixTimestamp) Dict.empty
        |> optionalIgnored "subtasks"
        |> optionalIgnored "reminderTime"
        |> optionalIgnored "autoSnooze"
        |> optionalIgnored "snooze"
        |> optionalIgnored "reminderOffset"
        |> optionalIgnored "fixParentId"
        --undocumented^
        |> optionalIgnored "rank_fbfe2f43-3ed1-472a-bea7-d1bc2185ccf6"
        --undocumented^
        |> optionalIgnored "echoedAt"
        --undocumented^
        |> optionalIgnored "duration"
        --undocumented^
        |> optionalIgnored "completedAt"
        |> optionalIgnored "remind"
        |> optionalIgnored "echo"
        |> optionalIgnored "reminder"
        |> optionalIgnored "remindAt"
        |> optionalIgnored "echoId"
        |> optionalIgnored "recurring"
        |> optionalIgnored "createdAt"
        |> optionalIgnored "generatedAt"
        |> optionalIgnored "sectionId"
        |> optionalIgnored "sectionid"
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


encodeMonth : ( Year, Month ) -> Encode.Value
encodeMonth ( year, month ) =
    Encode.string (SmartTime.Human.Calendar.Year.toString year ++ (String.fromInt <| SmartTime.Human.Calendar.Month.toInt month))


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


toDocketItem : Profile -> MarvinItem -> List Change
toDocketItem profile marvinItem =
    case marvinItem.db of
        "Tasks" ->
            toDocketTask profile marvinItem

        _ ->
            projectToDocketActivity profile.activities marvinItem


projectToDocketActivity : Activity.Store -> MarvinItem -> List Change
projectToDocketActivity activities marvinCategory =
    let
        nameMatch act =
            List.member marvinCategory.title (Activity.getNames act)

        matchingActivities =
            List.filter nameMatch (Activity.allUnhidden activities)

        activityChanges : List Change
        activityChanges =
            case List.head matchingActivities of
                Just activity ->
                    [ Activity.setExternalID "marvinCategory" marvinCategory.id activity ]

                Nothing ->
                    []
    in
    activityChanges


{-| Generate/update the Docket Entry, Class, and Instance from a Marvin Item
-}
toDocketTask : Profile -> MarvinItem -> List Change
toDocketTask profile marvinItem =
    let
        -- TODO we shouldn't calculate the whole assignable/assignment list on every item import. Figure it out above, then pass to this function
        existingAssignables =
            Task.Meta.entriesToAssignables profile.projects

        existingAssignablesWithMarvinLink =
            Dict.fromList <| List.filterMap pairAssignableWithMarvinIDMaybe existingAssignables

        pairAssignableWithMarvinIDMaybe ass =
            case Task.Meta.assignableGetExtra "marvinGeneratorID" ass of
                Just marvinID ->
                    Just ( marvinID, Task.Meta.assignableID ass )

                Nothing ->
                    Nothing

        marvinGeneratorIDMaybe =
            Maybe.Extra.or marvinItem.recurringTaskId marvinItem.pinId

        existingAssignableIDMaybe =
            -- look for an existing class that's linked to a marvin generator.
            Dict.get marvinGeneratorID existingAssignablesWithMarvinLink

        derivedMarvinGeneratorID =
            -- instance ID like 2021-11-11_b5946420-afe1-488e-adb0-3633b1905095
            -- becomes just b5946420-afe1-488e-adb0-3633b1905095
            List.last (String.split "_" marvinItem.id)

        marvinGeneratorID =
            Maybe.withDefault marvinItem.id (Maybe.Extra.or marvinGeneratorIDMaybe derivedMarvinGeneratorID)

        addClassExtras =
            [ ( "marvinID", marvinItem.id )
            , ( "marvinGeneratorID", marvinGeneratorID )
            ]

        assignableChanges assignable =
            [ assignable.predictedEffort.set <| Maybe.withDefault Duration.zero marvinItem.timeEstimate

            --, assignable.importance.set <| toFloat marvinItem.isStarred
            , assignable.activity.set <| determineClassActivity marvinItem profile.activities
            , RepDict.bulkInsert addClassExtras assignable.extra
            ]

        -- ASSIGNMENTS
        query =
            Task.Meta.AllSaved

        existingAssignments =
            assignablesToAssignments existingAssignables query

        existingAssignmentsWithMarvinLink : Dict String Task.Assignment.AssignmentID
        existingAssignmentsWithMarvinLink =
            Dict.fromList <| List.filterMap pairAssignmentWithMarvinIDMaybe existingAssignments

        pairAssignmentWithMarvinIDMaybe assignment =
            case assignmentGetExtra "marvinID" assignment of
                Just marvinID ->
                    Just ( marvinID, assignmentID assignment )

                Nothing ->
                    Nothing

        existingAssignmentIDMaybe =
            -- look for an existing class that's linked to a marvin generator.
            Dict.get marvinItem.id existingAssignmentsWithMarvinLink

        plannedSessionList : List UserPlannedSession
        plannedSessionList =
            case ( Maybe.map Duration.isPositive marvinItem.timeEstimate, marvinItem.timeEstimate ) of
                ( Just True, Just plannedDuration ) ->
                    case ( marvinItem.taskTime, marvinItem.day ) of
                        ( Just plannedTime, Just plannedDay ) ->
                            -- creates a new PlannedSession
                            List.singleton ( SmartTime.Human.Moment.Floating ( plannedDay, plannedTime ), plannedDuration )

                        ( Just _, Nothing ) ->
                            []

                        ( Nothing, Just plannedDay ) ->
                            List.singleton ( SmartTime.Human.Moment.Floating ( plannedDay, SmartTime.Human.Clock.endOfDay ), plannedDuration )

                        ( Nothing, Nothing ) ->
                            []

                ( Just False, _ ) ->
                    []

                _ ->
                    []

        boolAsString bool =
            if bool then
                "True"

            else
                "False"

        addInstanceExtras =
            List.filterMap identity
                [ Just ( "marvinCouchdbRev", marvinItem.rev )
                , Just ( "marvinID", marvinItem.id )
                , Maybe.map (\n -> ( "marvinNote", n )) marvinItem.note
                , Maybe.map (\d -> ( "marvinDay", SmartTime.Human.Calendar.toStandardString d )) marvinItem.day
                , Maybe.map (\p -> ( "marvinParentID", p )) marvinItem.parentId
                , Maybe.map (\d -> ( "marvinFirstScheduled", SmartTime.Human.Calendar.toStandardString d )) marvinItem.firstScheduled
                , Just ( "marvinRank", String.fromInt marvinItem.rank )
                , Just ( "marvinLabels", String.join " " marvinItem.labelIds )
                , Just ( "marvinEssentialOrBonus", Encode.encode 0 (encodeEssentialOrBonus marvinItem.bonusSection) )
                , Maybe.map (\d -> ( "marvinCustomSection", d )) marvinItem.customSection
                , Maybe.map (\d -> ( "marvinTimeBlockSection", d )) marvinItem.timeBlockSection
                , Maybe.map (\d -> ( "marvinDueDate", SmartTime.Human.Calendar.toStandardString d )) marvinItem.dueDate
                , Just ( "marvinIsReward", boolAsString marvinItem.isReward )
                , Just ( "marvinIsStarred", String.fromInt marvinItem.isStarred )
                , Just ( "marvinIsFrogged", String.fromInt marvinItem.isFrogged )
                , Maybe.map (\d -> ( "marvinRewardID", d )) marvinItem.rewardId
                , Just ( "marvinBackburner", boolAsString marvinItem.backburner )
                , Maybe.map (\d -> ( "marvinReviewDate", SmartTime.Human.Calendar.toStandardString d )) marvinItem.reviewDate
                , Maybe.map (\d -> ( "marvinItemSnoozeTime", SmartTime.Human.Moment.toStandardString d )) marvinItem.itemSnoozeTime
                , Maybe.map (\d -> ( "marvinPermaSnoozeTime", SmartTime.Human.Clock.toStandardString d )) marvinItem.permaSnoozeTime
                , Maybe.map (\d -> ( "marvinTimeZoneOffset", String.fromInt d )) marvinItem.timeZoneOffset
                , Maybe.map (\d -> ( "marvinStartDate", SmartTime.Human.Calendar.toStandardString d )) marvinItem.startDate
                , Maybe.map (\d -> ( "marvinEndDate", SmartTime.Human.Calendar.toStandardString d )) marvinItem.endDate
                , Just ( "marvinDb", marvinItem.db )
                , Maybe.map (\d -> ( "marvinTaskTime", SmartTime.Human.Clock.toStandardString d )) marvinItem.taskTime
                , Maybe.map (\p -> ( "marvinPinID", p )) marvinItem.pinId
                , Maybe.map (\p -> ( "marvinRecurringTaskID", p )) marvinItem.recurringTaskId
                , Just ( "marvinMasterRank", String.fromFloat marvinItem.masterRank )
                , Just ( "marvinCreatedAt", SmartTime.Human.Moment.toStandardString marvinItem.createdAt )
                , Maybe.map (\d -> ( "marvinDoneAt", SmartTime.Human.Moment.toStandardString d )) marvinItem.doneAt
                , Just ( "marvinFieldUpdates", Encode.encode 0 (Encode.dict identity encodeUnixTimestamp marvinItem.fieldUpdates) )
                , Just ( "marvinTimes", Encode.encode 0 (Encode.list encodeUnixTimestamp marvinItem.times) )
                ]

        assignmentChanges : Reg Task.Assignment.AssignmentSkel -> List Change
        assignmentChanges assignment =
            let
                instance =
                    Reg.latest assignment
            in
            [ instance.completion.set <|
                if marvinItem.done then
                    100

                else
                    0
            , instance.externalDeadline.set <| Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.dueDate
            , instance.startBy.set <| Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.startDate
            , instance.finishBy.set <|
                Maybe.Extra.or
                    (Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.endDate)
                    (Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.day)

            -- TODO , RepList.append RepList.Last plannedSessionList instance.plannedSessions
            , instance.relevanceStarts.set <|
                if Maybe.Extra.isJust marvinItem.recurringTaskId then
                    Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.day

                else
                    Nothing
            , instance.relevanceEnds.set <|
                if Maybe.Extra.isJust marvinItem.recurringTaskId then
                    Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.day

                else
                    Nothing
            , RepDict.bulkInsert addInstanceExtras instance.extra
            ]

        finalInstanceChanges =
            case Maybe.andThen (\assignmentIDToMatch -> List.find (\ass -> assignmentID ass == assignmentIDToMatch) existingAssignments) existingAssignmentIDMaybe of
                Just existingAssignment ->
                    assignmentChanges (assignmentReg existingAssignment)

                Nothing ->
                    []

        finalEntryAndClassChanges =
            case Maybe.andThen (\assignableIDToMatch -> List.find (\ass -> assignableID ass == assignableIDToMatch) existingAssignables) existingAssignableIDMaybe of
                Just existingAssignable ->
                    assignableChanges (Reg.latest (assignableReg existingAssignable))

                Nothing ->
                    let
                        newEntry c =
                            Task.Project.initProjectWithAssignable (createAssignable (Change.reuseContext "action" c)) c

                        createAssignable : Change.Creator (Reg Task.Assignable.AssignableSkel)
                        createAssignable c =
                            let
                                newAssignableChanger : Reg Task.Assignable.AssignableSkel -> List Change
                                newAssignableChanger newAssignable =
                                    RepDb.addNew
                                        (\c2 -> Task.Assignment.newWithChanges assignmentChanges (Change.reuseContext marvinItem.id c2))
                                        (Reg.latest newAssignable).manualAssignments
                                        :: assignableChanges (Reg.latest newAssignable)
                            in
                            Task.Assignable.new (Change.reuseContext marvinItem.id c) marvinItem.title newAssignableChanger
                    in
                    [ RepList.insertNew RepList.Last [ newEntry ] profile.projects
                    ]
    in
    finalInstanceChanges ++ finalEntryAndClassChanges


fromDocket : Task.Meta.Assignment -> Maybe MarvinItem
fromDocket instance =
    let
        idMaybe =
            Task.Meta.assignmentGetExtra "marvinID" instance

        revMaybe =
            Task.Meta.assignmentGetExtra "marvinCouchdbRev" instance

        toDate =
            Maybe.andThen (SmartTime.Human.Calendar.fromNumberString >> Result.toMaybe)

        toBool boolString =
            boolString == "True"

        useDecoder decoder string =
            Result.toMaybe (strict (Decode.decodeString decoder string))
    in
    case ( idMaybe, revMaybe ) of
        ( Just id, Just rev ) ->
            Just
                { id = id
                , rev = rev
                , done = Task.Meta.assignmentCompleted instance
                , day = toDate <| Task.Meta.assignmentGetExtra "marvinDay" instance
                , title = Task.Meta.assignmentTitle instance
                , parentId = Task.Meta.assignmentGetExtra "marvinParentID" instance
                , labelIds = Maybe.withDefault [] <| Maybe.map String.words <| Task.Meta.assignmentGetExtra "marvinLabels" instance
                , firstScheduled = toDate <| Task.Meta.assignmentGetExtra "marvinFirstScheduled" instance
                , rank = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Task.Meta.assignmentGetExtra "marvinRank" instance
                , dailySection = Task.Meta.assignmentGetExtra "marvinDailySection" instance
                , bonusSection = Maybe.withDefault Essential <| Maybe.andThen (useDecoder essentialOrBonusDecoder) (Task.Meta.assignmentGetExtra "marvinEssentialOrBonus" instance)
                , customSection = Task.Meta.assignmentGetExtra "marvinCustomSection" instance
                , timeBlockSection = Task.Meta.assignmentGetExtra "marvinTimeBlockSection" instance
                , note = Task.Meta.assignmentGetExtra "marvinNote" instance
                , dueDate = toDate <| Task.Meta.assignmentGetExtra "marvinDueDate" instance
                , timeEstimate = Just <| Task.Meta.assignmentEstimatedEffort instance
                , isReward = Maybe.withDefault False <| Maybe.map toBool <| Task.Meta.assignmentGetExtra "marvinIsReward" instance
                , isStarred = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Task.Meta.assignmentGetExtra "marvinIsStarred" instance
                , isFrogged = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Task.Meta.assignmentGetExtra "marvinIsFrogged" instance
                , plannedWeek = toDate <| Task.Meta.assignmentGetExtra "marvinPlannedWeek" instance
                , plannedMonth = Nothing -- TODO Maybe (Year, Month)
                , rewardPoints = 0 -- TODO Float
                , rewardId = Task.Meta.assignmentGetExtra "marvinRewardID" instance
                , backburner = Maybe.withDefault False <| Maybe.map toBool <| Task.Meta.assignmentGetExtra "marvinBackburner" instance
                , reviewDate = toDate <| Task.Meta.assignmentGetExtra "marvinReviewDate" instance
                , itemSnoozeTime = Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Task.Meta.assignmentGetExtra "marvinItemSnoozeTime" instance
                , permaSnoozeTime = Maybe.andThen (SmartTime.Human.Clock.fromStandardString >> Result.toMaybe) <| Task.Meta.assignmentGetExtra "marvinPermaSnoozeTime" instance
                , timeZoneOffset = Maybe.andThen String.toInt <| Task.Meta.assignmentGetExtra "marvinTimeZoneOffset" instance
                , startDate = toDate <| Task.Meta.assignmentGetExtra "marvinStartDate" instance
                , endDate = toDate <| Task.Meta.assignmentGetExtra "marvinEndDate" instance
                , db = Maybe.withDefault "tasks" <| Task.Meta.assignmentGetExtra "marvinDb" instance
                , times = parseTimesList <| Maybe.withDefault "[]" <| Task.Meta.assignmentGetExtra "marvinTimes" instance
                , taskTime = Maybe.andThen (SmartTime.Human.Clock.fromStandardString >> Result.toMaybe) <| Task.Meta.assignmentGetExtra "marvinTaskTime" instance
                , pinId = Task.Meta.assignmentGetExtra "marvinPinID" instance
                , recurringTaskId = Task.Meta.assignmentGetExtra "recurringTaskID" instance
                , masterRank = Maybe.withDefault 0 <| Maybe.andThen String.toFloat <| Task.Meta.assignmentGetExtra "marvinMasterRank" instance
                , createdAt = Maybe.withDefault Moment.zero <| Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Task.Meta.assignmentGetExtra "marvinCreatedAt" instance
                , doneAt = Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Task.Meta.assignmentGetExtra "marvinDoneAt" instance
                , updatedAt = Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Task.Meta.assignmentGetExtra "marvinUpdatedAt" instance
                , fieldUpdates = Maybe.withDefault Dict.empty <| Maybe.andThen (useDecoder (Decode.dict decodeUnixTimestamp)) <| Task.Meta.assignmentGetExtra "marvinFieldUpdates" instance
                }

        _ ->
            Nothing


parseTimesList timesList =
    let
        decodeResult =
            decodeString (Decode.list decodeUnixTimestamp) timesList
    in
    Maybe.withDefault [] <| Result.toMaybe <| strict <| decodeResult


{-| Determine which activity to assign to a newly imported class
-}
determineClassActivity : MarvinItem -> Activity.Store -> Maybe ActivityID
determineClassActivity marvinItem activities =
    case ( marvinItem.parentId, marvinItem.labelIds ) of
        ( Just someParent, [] ) ->
            let
                activitiesWithMarvinCategories =
                    List.map pairActivityIDWithMaybeMarvinID (Activity.allUnhidden activities)

                pairActivityIDWithMaybeMarvinID activity =
                    ( Activity.getID activity, Activity.getExternalID "marvinCategory" activity )

                matchingActivities : List ActivityID
                matchingActivities =
                    List.filterMap
                        (\( id, actCat ) ->
                            if Maybe.withDefault "nope" actCat == someParent then
                                Just id

                            else
                                Nothing
                        )
                        activitiesWithMarvinCategories
            in
            List.head matchingActivities

        ( _, labels ) ->
            let
                activitiesWithMarvinLabels =
                    List.map pairActivityIDWithMaybeMarvinID (Activity.allUnhidden activities)

                pairActivityIDWithMaybeMarvinID activity =
                    ( Activity.getID activity, Activity.getExternalID "marvinLabel" activity )

                matchingActivities : List ActivityID
                matchingActivities =
                    List.filterMap
                        (\( id, associatedLabelMaybe ) ->
                            case associatedLabelMaybe of
                                Just associatedLabel ->
                                    if List.member associatedLabel labels then
                                        Just id

                                    else
                                        Nothing

                                Nothing ->
                                    Nothing
                        )
                        activitiesWithMarvinLabels
            in
            List.head matchingActivities


type alias MarvinLabel =
    { id : String
    , title : String
    , color : String
    }


decodeMarvinLabel : Decoder MarvinLabel
decodeMarvinLabel =
    succeed MarvinLabel
        |> required "_id" string
        |> required "title" string
        |> optional "color" string ""
        |> optionalIgnored "_rev"


labelToDocketActivity : Activity.Store -> MarvinLabel -> List Change
labelToDocketActivity activities label =
    let
        nameMatch activity =
            List.member label.title (Activity.getNames activity) || List.member (String.toLower label.title) (List.map (String.toLower << String.trim) (Activity.getNames activity))

        matchingActivities =
            -- Debug.log ("matching activity names for " ++ label.title) <|
            List.filter nameMatch (Activity.allUnhidden activities)

        firstActivityMatch =
            List.head matchingActivities

        toChanges : List Change
        toChanges =
            case firstActivityMatch of
                Just activity ->
                    [ Activity.setExternalID "marvinLabel" label.id activity ]

                Nothing ->
                    []
    in
    toChanges


type alias MarvinTimeBlock =
    { title : String
    , date : CalendarDate
    , time : TimeOfDay
    , duration : Duration
    , isSection : Bool
    , cancelDates : List CalendarDate

    --, exceptions : List RecurrenceException
    , recurrence : List RecurrencePattern
    }


decodeMarvinTimeBlock : Decoder MarvinTimeBlock
decodeMarvinTimeBlock =
    succeed MarvinTimeBlock
        |> required "title" string
        |> required "date" calendarDateDecoder
        |> required "time" timeOfDayDecoder
        |> required "duration" decodeDuration
        |> optional "isSection" bool True
        |> optionalIgnored "exceptions"
        |> optional "cancelDates" decodeCancelDates []
        --|> optional "exceptions" (nullable decodeExceptions) Nothing
        |> optional "recurrence" (list decodeRecurrencePattern) []
        |> optionalIgnored "_rev"


decodeCancelDates : Decoder (List CalendarDate)
decodeCancelDates =
    let
        convertDictionary dict =
            List.filterMap kvPairToDate (Dict.toList dict)

        kvPairToDate ( datestring, canceled ) =
            -- always true, right?
            case ( SmartTime.Human.Calendar.fromNumberString datestring, canceled ) of
                ( Ok date, True ) ->
                    Just date

                _ ->
                    Nothing
    in
    Decode.map convertDictionary (Decode.dict Decode.bool)


type RecurrencePattern
    = Daily
    | Weekly (List DayOfWeek)
    | Other


decodeRecurrencePattern : Decoder RecurrencePattern
decodeRecurrencePattern =
    let
        interpreted string =
            -- Result.map interpretRecurrenceRule (getRawRecurrencePattern string)
            Err "NYI"
    in
    Helpers.customDecoder string interpreted


marvinTimeBlockToDocketTimeBlock : Profile -> Dict String String -> MarvinTimeBlock -> List Change
marvinTimeBlockToDocketTimeBlock profile assignments marvinBlock =
    let
        normalizeRegex =
            Maybe.withDefault Regex.never (Regex.fromString "[\\s-_]|[^\\x20\\x2D0-9A-Z\\x5Fa-z\\xC0-\\xD6\\xD8-\\xF6\\xF8-\\xFF]")

        normalizeTitle title =
            -- TODO use the regex /[^-_\p{L}0-9]/gu
            -- \p is unicode, not supported by elm library
            Regex.replace normalizeRegex (\_ -> "") title

        labelMaybe =
            Dict.get (normalizeTitle marvinBlock.title) assignments

        activityLookup =
            Dict.fromList <| List.filterMap createActivityLookupEntry (Activity.allUnhidden profile.activities)

        createActivityLookupEntry : Activity -> Maybe ( LabelID, ActivityID )
        createActivityLookupEntry activity =
            case Activity.getExternalID "marvinLabel" activity of
                Nothing ->
                    Nothing

                Just marvinLabelID ->
                    Just ( marvinLabelID, Activity.getID activity )

        buildWithActivity activityFound context =
            Codec.seededNew TimeBlock.codec context <|
                TimeBlock.TimeBlockSeed (TimeBlock.Activity activityFound) marvinBlock.date marvinBlock.time marvinBlock.duration

        buildWithTag tag context =
            Codec.seededNew TimeBlock.codec context <|
                TimeBlock.TimeBlockSeed (TimeBlock.Tag tag) marvinBlock.date marvinBlock.time marvinBlock.duration

        logBad =
            String.concat [ "Could not find a label for ", marvinBlock.title, ", normalized as ", normalizeTitle marvinBlock.title ]

        logGood =
            String.concat [ "Found label for time block ", marvinBlock.title, "! normalized as ", normalizeTitle marvinBlock.title ]
    in
    case labelMaybe of
        Nothing ->
            []

        Just foundAssignment ->
            case Dict.get foundAssignment activityLookup of
                Nothing ->
                    [ RepList.insertNew RepList.Last [ buildWithTag foundAssignment ] profile.timeBlocks ]

                Just foundActivity ->
                    [ RepList.insertNew RepList.Last [ buildWithActivity foundActivity ] profile.timeBlocks ]
