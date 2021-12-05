module Integrations.Marvin.MarvinItem exposing (..)

import Activity.Activity as Activity exposing (Activity, ActivityID, StoredActivities)
import Dict exposing (Dict)
import ID
import IntDict
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode exposing (..)
import List.Extra as List
import Maybe.Extra
import Porting exposing (..)
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
import Task.Class
import Task.Entry
import Task.Instance
import Task.Progress
import Task.SessionSkel exposing (UserPlannedSession)
import TimeBlock.TimeBlock exposing (TimeBlock)


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
    , type_ : ItemType
    , times : List Moment
    , taskTime : Maybe TimeOfDay
    , pinId : Maybe String
    , recurringTaskId : Maybe String
    }


encodeMarvinItem : MarvinItem -> Encode.Value
encodeMarvinItem task =
    Encode.object <|
        [ ( "_id", Encode.string task.id )
        , ( "_rev", Encode.string task.rev )
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
        , ( "type", encodeItemType task.type_ )
        , ( "times", Encode.list encodeMoment task.times )
        , ( "taskTime", Encode.maybe encodeTimeOfDay task.taskTime )
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
        |> optional "firstScheduled" (nullable calendarDateDecoder) Nothing
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
        |> optional "type" decodeItemType Task
        |> optional "times" (list decodeUnixTimestamp) []
        |> optional "taskTime" (nullable timeOfDayDecoder) Nothing
        |> optional "pinID" (nullable string) Nothing
        |> optional "recurringTaskId" (nullable string) Nothing
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


toDocketItem : MarvinItem -> Profile -> OutputType
toDocketItem marvinItem profile =
    case marvinItem.type_ of
        Task ->
            ConvertedToTaskTriplet <| toDocketTask profile marvinItem

        Project ->
            ConvertedToTaskTriplet <| toDocketTask profile marvinItem

        Category ->
            ConvertedToActivity <| projectToDocketActivity profile.activities marvinItem


type OutputType
    = ConvertedToTaskTriplet { entries : List Task.Entry.Entry, classes : List Task.Class.ClassSkel, instances : List Task.Instance.InstanceSkel }
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


toDocketTask : Profile -> MarvinItem -> { entries : List Task.Entry.Entry, classes : List Task.Class.ClassSkel, instances : List Task.Instance.InstanceSkel }
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


toDocketClassAndEntry : Int -> Profile -> MarvinItem -> ( Task.Class.ClassSkel, Maybe Task.Entry.Entry )
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
            Maybe.withDefault (Task.Class.newClassSkel marvinItem.title newClassID) existingClassMaybe

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


toDocketInstance : Int -> Task.Class.ClassSkel -> Profile -> MarvinItem -> Task.Instance.InstanceSkel
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
            Maybe.withDefault (Task.Instance.newInstanceSkel classCounter class) existingInstanceMaybe

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

        addExtras =
            Dict.fromList <|
                List.filterMap identity
                    [ Just ( "marvinCouchdbRev", marvinItem.rev )
                    , Just ( "marvinID", marvinItem.id )
                    , Maybe.map (\n -> ( "marvinNote", n )) marvinItem.note
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


fromDocket : Task.Instance.Instance -> MarvinItem
fromDocket instance =
    Debug.todo "from instance"


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
            Debug.log ("matching activity names for " ++ label.title) <| IntDict.filter nameMatch (Activity.allActivities activities)

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
    Decode.list calendarDateDecoder


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
    Porting.customDecoder string interpreted


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
