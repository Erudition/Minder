module Integrations.Marvin.MarvinItem exposing (..)

import Activity.Activity as Activity exposing (Activity, ActivityID, StoredActivities)
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
import SmartTime.Duration as Duration exposing (Duration(..))
import SmartTime.Human.Calendar exposing (CalendarDate(..))
import SmartTime.Human.Calendar.Month exposing (Month(..))
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Human.Calendar.Year exposing (Year(..))
import SmartTime.Human.Clock exposing (TimeOfDay)
import SmartTime.Human.Moment
import SmartTime.Moment as Moment exposing (Moment(..))
import SmartTime.Period as Period exposing (Period(..))
import Task.ActionClass
import Task.AssignedAction
import Task.Entry
import Task.Progress
import Task.SessionSkel exposing (UserPlannedSession)
import TimeBlock.TimeBlock exposing (TimeBlock)


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
    , masterRank : Int
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
        , omittableNum ( "masterRank", Encode.int, task.masterRank )
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
        |> optional "masterRank" int 0
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


toDocketItem : MarvinItem -> Profile -> OutputType
toDocketItem marvinItem profile =
    case marvinItem.db of
        "Tasks" ->
            ConvertedToTaskTriplet <| toDocketTask profile marvinItem

        _ ->
            ConvertedToActivity <| projectToDocketActivity profile.activities marvinItem


type OutputType
    = ConvertedToTaskTriplet { entries : List Task.Entry.Entry, classes : List Task.ActionClass.ActionClassSkel, instances : List Task.AssignedAction.AssignedActionSkel }
    | ConvertedToActivity StoredActivities


projectToDocketActivity : StoredActivities -> MarvinItem -> StoredActivities
projectToDocketActivity activities marvinCategory =
    let
        nameMatch key value =
            List.member marvinCategory.title value.names

        matchingActivities =
            IntDict.filter nameMatch (Activity.allActivities activities)

        firstActivityMatch =
            List.head (IntDict.toList matchingActivities)

        toCustomizations : Maybe Activity.Customizations
        toCustomizations =
            case firstActivityMatch of
                Just ( key, activity ) ->
                    Just
                        { names = Nothing
                        , icon = Nothing
                        , excusable = Nothing
                        , taskOptional = Nothing
                        , evidence = []
                        , category = Nothing
                        , backgroundable = Nothing
                        , maxTime = Nothing
                        , hidden = Nothing
                        , template = activity.template
                        , id = ID.tag key
                        , externalIDs = Dict.insert "marvinCategory" marvinCategory.id activity.externalIDs
                        }

                Nothing ->
                    Nothing
    in
    case toCustomizations of
        Just customizedActivity ->
            IntDict.insert (ID.read customizedActivity.id) customizedActivity activities

        Nothing ->
            activities


toDocketTask : Profile -> MarvinItem -> { entries : List Task.Entry.Entry, classes : List Task.ActionClass.ActionClassSkel, instances : List Task.AssignedAction.AssignedActionSkel }
toDocketTask profile marvinItem =
    let
        classCounter =
            Maybe.withDefault 0 (Maybe.map Tuple.first <| List.last <| IntDict.toList profile.taskClasses)

        ( finalClass, newEntryMaybe ) =
            toDocketClassAndEntry classCounter profile marvinItem

        finalInstance =
            toDocketInstance classCounter finalClass profile marvinItem
    in
    { entries = Maybe.Extra.toList newEntryMaybe, classes = [ finalClass ], instances = [ finalInstance ] }


toDocketClassAndEntry : Int -> Profile -> MarvinItem -> ( Task.ActionClass.ActionClassSkel, Maybe Task.Entry.Entry )
toDocketClassAndEntry classCounter profile marvinItem =
    let
        newClassID =
            classCounter + 1

        ( existingClasses, _ ) =
            Task.Entry.getClassesFromEntries ( profile.taskEntries, profile.taskClasses )

        existingClassesWithMarvinLink =
            Dict.fromList <| List.filterMap pairClassWithMarvinIDMaybe existingClasses

        pairClassWithMarvinIDMaybe class =
            case Dict.get "marvinGeneratorID" class.class.extra of
                Just marvinID ->
                    Just ( marvinID, class.class.id )

                Nothing ->
                    Nothing

        marvinGeneratorIDMaybe =
            Maybe.Extra.or marvinItem.recurringTaskId marvinItem.pinId

        existingClassIDMaybe =
            -- look for an existing class that's linked to a marvin generator.
            Dict.get marvinGeneratorID existingClassesWithMarvinLink

        existingClassMaybe =
            Maybe.andThen (\classID -> IntDict.get classID profile.taskClasses) existingClassIDMaybe

        newEntry =
            Task.Entry.newRootEntry newClassID

        classBase =
            Maybe.withDefault (Task.ActionClass.newActionClassSkel marvinItem.title newClassID) existingClassMaybe

        derivedMarvinGeneratorID =
            -- instance ID like 2021-11-11_b5946420-afe1-488e-adb0-3633b1905095
            -- becomes just b5946420-afe1-488e-adb0-3633b1905095
            List.last (String.split "_" marvinItem.id)

        marvinGeneratorID =
            Maybe.withDefault marvinItem.id (Maybe.Extra.or marvinGeneratorIDMaybe derivedMarvinGeneratorID)

        updateExtraData oldDict =
            Dict.insert "marvinID" marvinItem.id <|
                Dict.insert "marvinGeneratorID" marvinGeneratorID oldDict

        finalClass =
            { classBase
                | predictedEffort = Maybe.withDefault Duration.zero marvinItem.timeEstimate
                , importance = toFloat marvinItem.isStarred
                , activity = determineClassActivity marvinItem profile.activities
                , extra = updateExtraData classBase.extra
            }
    in
    case existingClassMaybe of
        Just existingClass ->
            ( finalClass, Nothing )

        Nothing ->
            ( finalClass, Just newEntry )


toDocketInstance : Int -> Task.ActionClass.ActionClassSkel -> Profile -> MarvinItem -> Task.AssignedAction.AssignedActionSkel
toDocketInstance classCounter class profile marvinItem =
    let
        existingInstancesWithMarvinLink =
            Dict.fromList <| List.filterMap pairInstanceWithMarvinIDMaybe (IntDict.values profile.taskInstances)

        pairInstanceWithMarvinIDMaybe instance =
            case Dict.get "marvinID" instance.extra of
                Just marvinID ->
                    Just ( marvinID, instance.id )

                Nothing ->
                    Nothing

        existingInstanceIDMaybe =
            -- look for an existing class that's linked to a marvin generator.
            Dict.get marvinItem.id existingInstancesWithMarvinLink

        existingInstanceMaybe =
            Maybe.andThen (\instanceID -> IntDict.get instanceID profile.taskInstances) existingInstanceIDMaybe

        instanceBase =
            Maybe.withDefault (Task.AssignedAction.newAssignedActionSkel classCounter class) existingInstanceMaybe

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

        addExtras =
            Dict.fromList <|
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
                    , Just ( "marvinMasterRank", String.fromInt marvinItem.masterRank )
                    , Just ( "marvinCreatedAt", SmartTime.Human.Moment.toStandardString marvinItem.createdAt )
                    , Maybe.map (\d -> ( "marvinDoneAt", SmartTime.Human.Moment.toStandardString d )) marvinItem.doneAt
                    , Just ( "marvinFieldUpdates", Encode.encode 0 (Encode.dict identity encodeUnixTimestamp marvinItem.fieldUpdates) )
                    , Just ( "marvinTimes", Encode.encode 0 (Encode.list encodeUnixTimestamp marvinItem.times) )
                    ]

        finalInstance =
            { instanceBase
                | completion =
                    if marvinItem.done then
                        100

                    else
                        0
                , externalDeadline = Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.dueDate
                , startBy = Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.startDate
                , finishBy =
                    Maybe.Extra.or
                        (Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.endDate)
                        (Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.day)
                , plannedSessions = plannedSessionList
                , relevanceStarts =
                    if Maybe.Extra.isJust marvinItem.recurringTaskId then
                        Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.day

                    else
                        Nothing
                , relevanceEnds =
                    if Maybe.Extra.isJust marvinItem.recurringTaskId then
                        Maybe.map SmartTime.Human.Moment.DateOnly marvinItem.day

                    else
                        Nothing
                , extra = Dict.union addExtras instanceBase.extra
            }
    in
    finalInstance


fromDocket : Task.AssignedAction.AssignedAction -> Maybe MarvinItem
fromDocket instance =
    let
        idMaybe =
            Dict.get "marvinID" instance.instance.extra

        revMaybe =
            Dict.get "marvinCouchdbRev" instance.instance.extra

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
                , done = Debug.log "checking completion" Task.AssignedAction.completed instance
                , day = toDate <| Dict.get "marvinDay" instance.instance.extra
                , title = instance.class.title
                , parentId = Dict.get "marvinParentID" instance.instance.extra
                , labelIds = Maybe.withDefault [] <| Maybe.map String.words <| Dict.get "marvinLabels" instance.instance.extra
                , firstScheduled = toDate <| Dict.get "marvinFirstScheduled" instance.instance.extra
                , rank = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Dict.get "marvinRank" instance.instance.extra
                , dailySection = Dict.get "marvinDailySection" instance.instance.extra
                , bonusSection = Maybe.withDefault Essential <| Maybe.andThen (useDecoder essentialOrBonusDecoder) (Dict.get "marvinEssentialOrBonus" instance.instance.extra)
                , customSection = Dict.get "marvinCustomSection" instance.instance.extra
                , timeBlockSection = Dict.get "marvinTimeBlockSection" instance.instance.extra
                , note = Dict.get "marvinNote" instance.instance.extra
                , dueDate = toDate <| Dict.get "marvinDueDate" instance.instance.extra
                , timeEstimate = Just instance.class.predictedEffort
                , isReward = Maybe.withDefault False <| Maybe.map toBool <| Dict.get "marvinIsReward" instance.instance.extra
                , isStarred = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Dict.get "marvinIsStarred" instance.instance.extra
                , isFrogged = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Dict.get "marvinIsFrogged" instance.instance.extra
                , plannedWeek = toDate <| Dict.get "marvinPlannedWeek" instance.instance.extra
                , plannedMonth = Nothing -- TODO Maybe (Year, Month)
                , rewardPoints = 0 -- TODO Float
                , rewardId = Dict.get "marvinRewardID" instance.instance.extra
                , backburner = Maybe.withDefault False <| Maybe.map toBool <| Dict.get "marvinBackburner" instance.instance.extra
                , reviewDate = toDate <| Dict.get "marvinReviewDate" instance.instance.extra
                , itemSnoozeTime = Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Dict.get "marvinItemSnoozeTime" instance.instance.extra
                , permaSnoozeTime = Maybe.andThen (SmartTime.Human.Clock.fromStandardString >> Result.toMaybe) <| Dict.get "marvinPermaSnoozeTime" instance.instance.extra
                , timeZoneOffset = Maybe.andThen String.toInt <| Dict.get "marvinTimeZoneOffset" instance.instance.extra
                , startDate = toDate <| Dict.get "marvinStartDate" instance.instance.extra
                , endDate = toDate <| Dict.get "marvinEndDate" instance.instance.extra
                , db = Maybe.withDefault "tasks" <| Dict.get "marvinDb" instance.instance.extra
                , times = parseTimesList <| Maybe.withDefault "[]" <| Dict.get "marvinTimes" instance.instance.extra
                , taskTime = Maybe.andThen (SmartTime.Human.Clock.fromStandardString >> Result.toMaybe) <| Dict.get "marvinTaskTime" instance.instance.extra
                , pinId = Dict.get "marvinPinID" instance.instance.extra
                , recurringTaskId = Dict.get "recurringTaskID" instance.instance.extra
                , masterRank = Maybe.withDefault 0 <| Maybe.andThen String.toInt <| Dict.get "marvinMasterRank" instance.instance.extra
                , createdAt = Maybe.withDefault Moment.zero <| Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Dict.get "marvinCreatedAt" instance.instance.extra
                , doneAt = Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Dict.get "marvinDoneAt" instance.instance.extra
                , updatedAt = Maybe.andThen (SmartTime.Human.Moment.fromStandardStringLoose >> Result.toMaybe) <| Dict.get "marvinUpdatedAt" instance.instance.extra
                , fieldUpdates = Maybe.withDefault Dict.empty <| Maybe.andThen (useDecoder (Decode.dict decodeUnixTimestamp)) <| Dict.get "marvinFieldUpdates" instance.instance.extra
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
determineClassActivity : MarvinItem -> StoredActivities -> Maybe ActivityID
determineClassActivity marvinItem activities =
    case ( marvinItem.parentId, marvinItem.labelIds ) of
        ( Just someParent, [] ) ->
            let
                activitiesWithMarvinCategories =
                    List.map getMarvinID (IntDict.toList (Activity.allActivities activities))

                getMarvinID ( intID, activity ) =
                    ( ID.tag intID, Dict.get "marvinCategory" activity.externalIDs )

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
                    List.map getMarvinID (IntDict.toList (Activity.allActivities activities))

                getMarvinID ( intID, activity ) =
                    ( ID.tag intID, Dict.get "marvinLabel" activity.externalIDs )

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


labelToDocketActivity : StoredActivities -> MarvinLabel -> StoredActivities
labelToDocketActivity activities label =
    let
        nameMatch key value =
            List.member label.title value.names || List.member (String.toLower label.title) (List.map (String.toLower << String.trim) value.names)

        matchingActivities =
            -- Debug.log ("matching activity names for " ++ label.title) <|
            IntDict.filter nameMatch (Activity.allActivities activities)

        firstActivityMatch =
            List.head (IntDict.toList matchingActivities)

        toCustomizations : Maybe Activity.Customizations
        toCustomizations =
            case firstActivityMatch of
                Just ( key, activity ) ->
                    Just
                        { names = Nothing
                        , icon = Nothing
                        , excusable = Nothing
                        , taskOptional = Nothing
                        , evidence = []
                        , category = Nothing
                        , backgroundable = Nothing
                        , maxTime = Nothing
                        , hidden = Nothing
                        , template = activity.template
                        , id = ID.tag key
                        , externalIDs = Dict.insert "marvinLabel" label.id activity.externalIDs
                        }

                Nothing ->
                    Nothing
    in
    case toCustomizations of
        Just customizedActivity ->
            IntDict.insert (ID.read customizedActivity.id) customizedActivity activities

        Nothing ->
            activities


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


marvinTimeBlockToDocketTimeBlock : Profile -> Dict String String -> MarvinTimeBlock -> Maybe TimeBlock
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
            Dict.fromList <| List.filterMap createActivityLookupEntry (IntDict.toList (Activity.allActivities profile.activities))

        createActivityLookupEntry : ( Int, Activity ) -> Maybe ( LabelID, ActivityID )
        createActivityLookupEntry ( activityID, activity ) =
            case Dict.get "marvinLabel" activity.externalIDs of
                Nothing ->
                    Nothing

                Just marvinLabelID ->
                    Just ( marvinLabelID, ID.tag activityID )

        buildWithActivity activityFound =
            { focus = TimeBlock.TimeBlock.Activity activityFound
            , date = marvinBlock.date
            , startTime = marvinBlock.time
            , duration = marvinBlock.duration
            }

        buildWithTag tag =
            { focus = TimeBlock.TimeBlock.Tag tag
            , date = marvinBlock.date
            , startTime = marvinBlock.time
            , duration = marvinBlock.duration
            }

        logBad =
            String.concat [ "Could not find a label for ", marvinBlock.title, ", normalized as ", normalizeTitle marvinBlock.title ]

        logGood =
            String.concat [ "Found label for time block ", marvinBlock.title, "! normalized as ", normalizeTitle marvinBlock.title ]
    in
    case labelMaybe of
        Nothing ->
            Nothing

        Just foundAssignment ->
            case Dict.get foundAssignment activityLookup of
                Nothing ->
                    Just <| buildWithTag foundAssignment

                Just foundActivity ->
                    Just <| buildWithActivity foundActivity
