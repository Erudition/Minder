module Integrations.Marvin exposing (..)

{-| A library for interacting with the Amazing Marvin API.
-}

import Activity.Activity as Activity exposing (StoredActivities)
import Activity.Timeline as Timeline
import Base64
import Bytes.Encode
import Dict exposing (Dict)
import Environment exposing (Environment)
import Helpers exposing (..)
import Http
import IntDict exposing (IntDict)
import Integrations.Marvin.MarvinItem as MarvinItem exposing (ItemType(..), LabelID, MarvinItem, MarvinLabel, MarvinTimeBlock, OutputType(..), labelToDocketActivity, marvinTimeBlockToDocketTimeBlock, toDocketItem, toDocketTask)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import List.Extra as List
import Log
import Maybe.Extra as Maybe
import Profile exposing (Profile)
import Set
import SmartTime.Duration as Duration
import SmartTime.Human.Duration as HumanDuration
import SmartTime.Human.Moment as HumanMoment
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task.Class
import Task.Entry
import Task.Instance
import TimeBlock.TimeBlock exposing (TimeBlock)
import Url.Builder


type alias SecretToken =
    String


type alias SecretFullToken =
    String


marvinEndpointURL : String -> String
marvinEndpointURL endpoint =
    Url.Builder.crossOrigin "https://serv.amazingmarvin.com"
        [ "api", endpoint ]
        []


marvinDocURL : String -> String
marvinDocURL docID =
    Url.Builder.crossOrigin "https://serv.amazingmarvin.com"
        [ "api", "doc" ]
        [ Url.Builder.string "id" docID ]


marvinCloudantDatabaseUrl directories params =
    Url.Builder.crossOrigin
        "https://512940bf-6e0c-4d7b-884b-9fc66185836b-bluemix.cloudant.com"
        directories
        params


{-| Builds an authorization header based on provided username and password.
This can be put directly into the Http.request headers array.
-}
buildAuthorizationHeader : String -> String -> Http.Header
buildAuthorizationHeader username password =
    Http.header "Authorization" ("Basic " ++ buildAuthorizationToken username password)


{-| Builds just the authorization token based on provided username and password.
Use this if you need just the token for some reason.
Use buildAuthorizationHeader if you need the header anyway.
-}
buildAuthorizationToken : String -> String -> String
buildAuthorizationToken username password =
    Bytes.Encode.string (username ++ ":" ++ password)
        |> Bytes.Encode.encode
        |> Base64.fromBytes
        |> Maybe.withDefault ""


syncDatabase =
    "u32410002"


syncUser =
    "tuddereartheirceirleacco"


syncPassword =
    "3c749548fd996396c2bfefdb44bd140fc9d25de8"


couchLogin =
    Http.request
        { method = "POST"
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            , buildAuthorizationHeader syncUser syncPassword
            ]
        , url = marvinCloudantDatabaseUrl [ "_session" ] []
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "name", Encode.string syncUser )
                    , ( "password", Encode.string syncPassword )
                    ]
                )
        , expect = Http.expectString AuthResult
        , timeout = Just 3000
        , tracker = Nothing
        }


couchSessionInfo : Cmd Msg
couchSessionInfo =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = marvinCloudantDatabaseUrl [ "_session" ] []
        , body = Http.emptyBody
        , expect = Http.expectString TestResult
        , timeout = Just 1000
        , tracker = Nothing
        }


testCouch : Cmd Msg
testCouch =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword ]
        , url = marvinCloudantDatabaseUrl [ syncDatabase ] []
        , body = Http.emptyBody
        , expect = Http.expectString TestResult
        , timeout = Just 5000
        , tracker = Nothing
        }


couchEverything : Cmd Msg
couchEverything =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword ]
        , url = marvinCloudantDatabaseUrl [ syncDatabase, "_all_docs" ] [ Url.Builder.string "include_docs" "true" ]
        , body = Http.emptyBody
        , expect = Http.expectString TestResult
        , timeout = Just 10000
        , tracker = Nothing
        }


getTimeBlocks : TimeBlockAssignments -> Cmd Msg
getTimeBlocks assignments =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword ]
        , url = marvinCloudantDatabaseUrl [ syncDatabase, "_find" ] []
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "selector", Encode.object [ ( "db", Encode.string "PlannerItems" ) ] )
                    , ( "fields", Encode.list Encode.string [ "title", "date", "time", "duration", "cancelDates", "exceptions" ] )
                    ]
                )
        , expect = Http.expectJson (GotTimeBlocks assignments) (toClassicLoose <| Decode.at [ "docs" ] <| Decode.list MarvinItem.decodeMarvinTimeBlock)
        , timeout = Just 5000
        , tracker = Nothing
        }


type alias TimeBlockAssignments =
    Dict String LabelID


{-| Get Marvin Config information

{
"docs": [
{
"val": {
"parentId": {
"op": "in",
"val": "2021-01-10\_62f0a9be-3c47-4c89-9fce-a296de4f2ada"
}
},
"\_id": "strategySettings.plannerSmartLists.AMBookend"
},

        {
        "val": {
        "parentId": {
        "op": "in",
        "val": "b1609499-aa72-49b8-ad11-885aed57db94"
        }
        },
        "_id": "strategySettings.plannerSmartLists.BusinessBlock"
        },

-}
getTimeBlockAssignments : Cmd Msg
getTimeBlockAssignments =
    let
        decodeAssignment =
            Decode.map2 Tuple.pair decodeAssignmentName decodeAssignmentValue

        decodeAssignmentValue =
            Decode.oneOf
                [ Decode.at [ "val", "parentId", "val" ] Decode.string
                , Decode.at [ "val", "goalId", "val" ] Decode.string
                , Decode.at [ "val", "labelIds", "val" ] Decode.string
                ]

        decodeAssignmentName =
            Decode.field "_id" (Decode.map stripPrefix Decode.string)

        stripPrefix settingIDString =
            String.dropLeft 35 settingIDString
    in
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword ]
        , url = marvinCloudantDatabaseUrl [ syncDatabase, "_find" ] []
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "selector"
                      , Encode.object
                            [ ( "db", Encode.string "ProfileItems" )
                            , ( "_id", Encode.object [ ( "$regex", Encode.string "^strategySettings.plannerSmartLists" ) ] )
                            ]
                      )
                    , ( "fields", Encode.list Encode.string [ "val", "_id" ] )
                    ]
                )
        , expect =
            Http.expectJson GotTimeBlockAssignments
                (toClassicLoose <|
                    Decode.at [ "docs" ] <|
                        Decode.map Dict.fromList <|
                            Decode.list
                                decodeAssignment
                )
        , timeout = Just 1000
        , tracker = Nothing
        }


test : SecretToken -> Cmd Msg
test secret =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "test"
        , body = Http.emptyBody
        , expect = Http.expectString TestResult
        , timeout = Just 1000
        , tracker = Nothing
        }


test2 : Cmd Msg
test2 =
    getTodayItems partialAccessToken


fullAccessToken =
    "7o0b6/c0i+zXgWx5eheuM7Eob7w="


partialAccessToken =
    "m47dqHEwdJy56/j8tyAcXARlADg="


getLabelsCmd : Cmd Msg
getLabelsCmd =
    Cmd.batch [ getLabels partialAccessToken ]


handle : Int -> Profile -> Environment -> Msg -> ( Profile, String, Cmd Msg )
handle classCounter profile env response =
    case response of
        TestResult result ->
            case result of
                Ok serversays ->
                    ( profile
                    , serversays
                    , Cmd.none
                    )

                Err err ->
                    ( profile
                    , describeError err
                    , Cmd.none
                    )

        AuthResult result ->
            case result of
                Ok serversays ->
                    ( profile
                    , serversays
                    , Cmd.none
                    )

                Err err ->
                    ( profile
                    , describeError err
                    , Cmd.none
                    )

        GotItems result ->
            case result of
                Ok itemList ->
                    let
                        newProfile =
                            importItems profile itemList
                    in
                    ( newProfile
                    , "Fetched items: " ++ Debug.toString itemList
                    , getTimeBlockAssignments
                    )

                Err err ->
                    ( profile
                    , "when getting items: " ++ describeError err
                    , Cmd.none
                    )

        GotLabels result ->
            case result of
                Ok labelList ->
                    let
                        newActivities =
                            importLabels profile labelList
                    in
                    ( { profile | activities = IntDict.union profile.activities newActivities }
                    , "Fetched labels: " ++ Debug.toString labelList
                    , getTasks partialAccessToken
                    )

                Err err ->
                    ( profile
                    , "when getting labels: " ++ describeError err
                    , Cmd.none
                    )

        GotTimeBlocks assignments result ->
            case result of
                Ok timeBlockList ->
                    ( { profile | timeBlocks = importTimeBlocks profile assignments timeBlockList }
                    , "Fetched timeblocks: " ++ Debug.toString timeBlockList
                    , Cmd.none
                    )

                Err err ->
                    ( profile
                    , "when getting time blocks: " ++ describeError err
                    , Cmd.none
                    )

        GotTimeBlockAssignments assignmentsResult ->
            case assignmentsResult of
                Ok assignmentDict ->
                    ( profile
                    , "Fetched timeblock assignments: " ++ Debug.toString assignmentDict
                    , getTimeBlocks assignmentDict
                    )

                Err err ->
                    ( profile
                    , "when getting time block assignments: " ++ describeError err
                    , Cmd.none
                    )

        GotTrackTruth trackTruthResult ->
            case trackTruthResult of
                Ok timesList ->
                    let
                        updatedTimeline =
                            Timeline.backfill profile.timeline (List.concatMap (trackTruthToTimelineSessions profile env) timesList)
                    in
                    ( { profile | timeline = updatedTimeline }
                    , "Fetched canonical timetrack timing tables: " ++ Debug.toString timesList
                    , Cmd.none
                    )

                Err err ->
                    ( profile
                    , "when getting canonical timetrack timing tables: " ++ describeError err
                    , Cmd.none
                    )

        GotTrackAck ackResult ->
            case ackResult of
                Ok ack ->
                    let
                        timesList =
                            if List.length ack.startTimes >= List.length ack.stopTimes then
                                ack.startTimes

                            else
                                ack.stopTimes

                        itemIDMaybe =
                            Maybe.or ack.startID ack.stopID

                        asSessions =
                            case itemIDMaybe of
                                Just itemID ->
                                    trackTruthToTimelineSessions profile env (TrackTruthItem itemID timesList)

                                Nothing ->
                                    Debug.log "wha??? no task?? " []

                        updatedTimeline =
                            Timeline.backfill profile.timeline asSessions

                        newestReport time =
                            HumanDuration.say (Moment.difference env.time time)

                        logMsg =
                            "got timetrack acknowledgement at " ++ HumanMoment.toStandardString env.time ++ " my time, newest marvin time was off by " ++ (Maybe.withDefault "none" <| Maybe.map newestReport (List.last timesList))
                    in
                    ( { profile | timeline = updatedTimeline }
                    , logMsg
                    , Cmd.none
                    )

                Err err ->
                    ( profile
                    , "when sending start/stop timetracking signal: " ++ describeError err
                    , Cmd.none
                    )


importItems : Profile -> List MarvinItem -> Profile
importItems profile itemList =
    let
        updateProfileWithOutput item beforeProfile =
            let
                output =
                    toDocketItem item beforeProfile

                tasks =
                    Maybe.toList (tasksOnly output)

                activities =
                    Maybe.toList (activitiesOnly output)
            in
            { beforeProfile
                | taskEntries = beforeProfile.taskEntries ++ List.concatMap .entries tasks
                , taskClasses = IntDict.union (IntDict.fromList <| List.map (\i -> ( i.id, i )) <| List.concatMap .classes tasks) beforeProfile.taskClasses
                , taskInstances = IntDict.union (IntDict.fromList <| List.map (\i -> ( i.id, i )) <| List.concatMap .instances tasks) beforeProfile.taskInstances
                , activities = List.foldl (\d1 d2 -> IntDict.union d2 d1) beforeProfile.activities activities
            }

        profileFedToAll =
            List.foldl updateProfileWithOutput profile itemList

        tasksOnly outputItem =
            case outputItem of
                ConvertedToTaskTriplet taskitem ->
                    Just taskitem

                _ ->
                    Nothing

        activitiesOnly outputItem =
            case outputItem of
                ConvertedToActivity activitystore ->
                    Just activitystore

                _ ->
                    Nothing
    in
    profileFedToAll


importLabels : Profile -> List MarvinLabel -> Activity.StoredActivities
importLabels profile labels =
    let
        activities =
            List.map (labelToDocketActivity profile.activities) labels

        finalActivities =
            List.foldl IntDict.union IntDict.empty activities
    in
    finalActivities


importTimeBlocks : Profile -> TimeBlockAssignments -> List MarvinTimeBlock -> List TimeBlock
importTimeBlocks profile assignments marvinBlocks =
    List.filterMap (marvinTimeBlockToDocketTimeBlock profile assignments) marvinBlocks


addTask : SecretToken -> Cmd Msg
addTask secret =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "addTask"
        , body = Http.emptyBody -- TODO task
        , expect = Http.expectString TestResult
        , timeout = Just 5000
        , tracker = Nothing
        }


addProject : SecretToken -> Cmd Msg
addProject secret =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "addProject"
        , body = Http.emptyBody -- TODO project
        , expect = Http.expectString TestResult
        , timeout = Just 5000
        , tracker = Nothing
        }


type alias Document =
    String


getDoc : SecretFullToken -> Document -> Cmd Msg
getDoc fullSecret doc =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-Full-Access-Token" fullSecret ]
        , url = marvinDocURL doc
        , body = Http.emptyBody -- TODO project
        , expect = Http.expectString TestResult
        , timeout = Just 10000
        , tracker = Nothing
        }


getTrackedItem : SecretToken -> Cmd Msg
getTrackedItem secret =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "trackedItem"
        , body = Http.emptyBody
        , expect = Http.expectString TestResult
        , timeout = Just 5000
        , tracker = Nothing
        }


{-| Get tasks and projects scheduled today (including rollover/auto-schedule due items if enabled)
-}
getTodayItems : SecretToken -> Cmd Msg
getTodayItems secret =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "todayItems"
        , body = Http.emptyBody
        , expect = Http.expectJson GotItems (toClassicLoose <| Decode.list MarvinItem.decodeMarvinItem)
        , timeout = Just 10000
        , tracker = Nothing
        }


{-| Get tasks and projects that are due today
-}
getDueItems : SecretToken -> Cmd Msg
getDueItems secret =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "dueItems"
        , body = Http.emptyBody
        , expect = Http.expectString TestResult --TODO
        , timeout = Just 10000
        , tracker = Nothing
        }


{-| Get tasks and projects that are due today
-}
getTasks : SecretToken -> Cmd Msg
getTasks secret =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword ]
        , url = marvinCloudantDatabaseUrl [ syncDatabase, "_find" ] []
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "selector"
                      , Encode.object
                            [ ( "db", Encode.string "Tasks" )

                            --, ( "timeEstimate", Encode.object [ ( "$gt", Encode.int 0 ) ] )
                            --, ( "done", Encode.object [ ( "$exists", Encode.bool False ) ] )
                            --, ( "day", Encode.object [ ( "$regex", Encode.string "^\\d" ) ] )
                            , ( "labelIds", Encode.object [ ( "$not", Encode.object [ ( "$size", Encode.int 0 ) ] ) ] )
                            ]
                      )

                    -- , ( "fields"
                    --   , Encode.list Encode.string
                    --         [ "_id"
                    --         , "_rev"
                    --         , "done"
                    --         , "day"
                    --         , "title"
                    --         , "parentId"
                    --         , "labelIds"
                    --         , "dueDate"
                    --         , "timeEstimate"
                    --         , "startDate"
                    --         , "endDate"
                    --         , "times"
                    --         , "taskTime"
                    --         , "pinId"
                    --         , "recurringTaskId"
                    --         , "note"
                    --         ]
                    --   )
                    ]
                )
        , expect = Http.expectJson GotItems (toClassicLoose <| Decode.at [ "docs" ] <| Decode.list MarvinItem.decodeMarvinItem)
        , timeout = Just 10000
        , tracker = Nothing
        }


{-| Update a marvin doc
-}
updateDoc : Moment -> List String -> Task.Instance.Instance -> Cmd Msg
updateDoc timestamp updatedFields taskInstance =
    let
        asMarvinItem =
            MarvinItem.fromDocket taskInstance
    in
    case asMarvinItem of
        Just marvinItem ->
            let
                stampedItem =
                    { marvinItem
                        | updatedAt = Just timestamp
                        , createdAt =
                            if List.member "createdAt" updatedFields then
                                timestamp

                            else
                                marvinItem.createdAt
                        , doneAt =
                            if List.member "done" updatedFields then
                                Just timestamp

                            else
                                marvinItem.doneAt
                        , fieldUpdates =
                            Dict.union (Dict.fromList (List.map (\f -> ( f, timestamp )) updatedFields)) marvinItem.fieldUpdates
                    }
            in
            Http.request
                { method = "PUT"
                , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword, Http.header "If-Match" marvinItem.rev ]
                , url = marvinCloudantDatabaseUrl [ syncDatabase, marvinItem.id ] []
                , body =
                    Http.jsonBody
                        (MarvinItem.encodeMarvinItem stampedItem)
                , expect = Http.expectJson GotItems (toClassicLoose <| Decode.at [ "docs" ] <| Decode.list MarvinItem.decodeMarvinItem)
                , timeout = Just 5000
                , tracker = Nothing
                }

        Nothing ->
            Cmd.none



--TODO
--updateDoc (Dict.get "marvinID" marvinExtraData)
--    (Dict.get "marvinCouchdbRev" marvinExtraData)
--    (Encode.object
--        [ ( "note", Encode.string "hello from docket!" )
--
--        --, ( "done", Encode.bool True )
--        --, ( "doneAt", encodeUnixTimestamp now )
--        --, ( "completedAt", encodeUnixTimestamp now )
--        --, ( "updatedAt", encodeUnixTimestamp now )
--        ]
--    )


{-| Get tasks and projects that are due today
-}
getRecurringTasks : SecretToken -> Cmd Msg
getRecurringTasks secret =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword ]
        , url = marvinCloudantDatabaseUrl [ syncDatabase, "_find" ] []
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "selector"
                      , Encode.object
                            [ ( "db", Encode.string "RecurringTasks" )
                            ]
                      )
                    ]
                )
        , expect = Http.expectJson GotItems (toClassicLoose <| Decode.at [ "docs" ] <| Decode.list MarvinItem.decodeMarvinItem)
        , timeout = Just 10000
        , tracker = Nothing
        }


{-| Get a list of all categories
-}
getCategories : SecretToken -> Cmd Msg
getCategories secret =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "categories"
        , body = Http.emptyBody
        , expect = Http.expectJson GotItems (toClassicLoose <| Decode.list MarvinItem.decodeMarvinItem)
        , timeout = Just 10000
        , tracker = Nothing
        }


{-| Get a list of all labels
-}
getLabels : SecretToken -> Cmd Msg
getLabels secret =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "labels"
        , body = Http.emptyBody
        , expect = Http.expectJson GotLabels (toClassicLoose <| Decode.list MarvinItem.decodeMarvinLabel)
        , timeout = Just 10000
        , tracker = Nothing
        }


{-| start or stop time tracking a task by its ID
-}
timeTrack : SecretToken -> String -> Bool -> Cmd Msg
timeTrack secret taskID starting =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "time"
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "taskId", Encode.string taskID )
                    , ( "action"
                      , Encode.string
                            (if starting then
                                "START"

                             else
                                "STOP"
                            )
                      )
                    ]
        , expect = Http.expectJson GotTrackAck (toClassicLoose <| decodeTrackAck) --TODO
        , timeout = Just 5000
        , tracker = Nothing
        }


marvinUpdateCurrentlyTracking : Profile -> Environment -> Maybe Task.Instance.InstanceID -> Bool -> ( Profile, Cmd Msg )
marvinUpdateCurrentlyTracking profile env instanceIDMaybe starting =
    case Maybe.andThen (Profile.getInstanceByID profile env) instanceIDMaybe of
        Just instance ->
            case Task.Instance.getExtra "marvinID" instance of
                Nothing ->
                    ( profile, Debug.log "No MarvinID found" Cmd.none )

                Just marvinID ->
                    let
                        trackCmd =
                            timeTrack partialAccessToken marvinID starting

                        instanceSkel =
                            instance.instance

                        updatedInstanceSkel =
                            { instanceSkel | extra = Dict.insert "marvinTimes" (timesUpdater profile (Task.Instance.getID instance)) instanceSkel.extra }

                        updatedInstanceDict =
                            IntDict.insert (Task.Instance.getID instance) updatedInstanceSkel profile.taskInstances

                        updatedProfile =
                            { profile | taskInstances = updatedInstanceDict }

                        updateTimesCmd =
                            updateDoc env.time [ "times" ] { instance | instance = updatedInstanceSkel }
                    in
                    ( updatedProfile, Cmd.batch [ trackCmd ] )

        Nothing ->
            ( profile, Log.logSeparate "No Instance found for ID" instanceIDMaybe Cmd.none )


timesUpdater : Profile -> Task.Instance.InstanceID -> String
timesUpdater profile instanceID =
    let
        timesList =
            Timeline.getInstanceTimes profile.timeline instanceID
    in
    Encode.encode 0 (Encode.list encodeUnixTimestamp timesList)


{-| get truth about tracked tasks
-}
trackTruth : SecretToken -> String -> Cmd Msg
trackTruth secret taskID =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "tracks"
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "taskIds", Encode.list Encode.string [ taskID ] ) ]
        , expect = Http.expectJson GotTrackTruth (toClassicLoose <| Decode.list decodeTrackTruthItem) --TODO
        , timeout = Just 5000
        , tracker = Nothing
        }


type alias TrackTruthItem =
    { task : MarvinItem.ItemID
    , times : List Moment
    }


decodeTrackTruthItem : Decode.Decoder TrackTruthItem
decodeTrackTruthItem =
    Decode.map2 TrackTruthItem
        (Decode.field "task" Decode.string)
        (Decode.field "times"
            (Decode.list
                decodeUnixTimestamp
            )
        )


trackTruthToTimelineSessions : Profile -> Environment -> TrackTruthItem -> List ( Activity.ActivityID, Maybe Task.Instance.InstanceID, Period )
trackTruthToTimelineSessions profile env truthItem =
    let
        isCorrectInstance instance =
            Just truthItem.task == Task.Instance.getExtra "marvinID" instance

        matchingInstance =
            List.find isCorrectInstance (Profile.instanceListNow profile env)

        indexedTimes =
            List.indexedMap Tuple.pair truthItem.times

        keepEvenOdd modNum ( i, v ) =
            if modBy 2 i == modNum then
                Just v

            else
                Nothing

        startsList =
            -- Marvin seems to start tracking 5 seconds in the past
            List.map (\m -> Moment.future m (Duration.fromSeconds 5)) (List.filterMap (keepEvenOdd 0) indexedTimes)

        stopsList =
            case modBy 2 (List.length truthItem.times) == 0 of
                True ->
                    -- even # of times, tracking has stopped
                    -- line up with stop times
                    List.filterMap (keepEvenOdd 1) indexedTimes

                False ->
                    -- odd means never stopped tracking, use current time
                    List.filterMap (keepEvenOdd 1) (List.indexedMap Tuple.pair truthItem.times)
    in
    case matchingInstance of
        Nothing ->
            Log.logMessage "no matching instance when constructing timeline sessions from marvin data!" []

        Just instance ->
            case Task.Instance.getActivityID instance of
                Nothing ->
                    []

                Just activity ->
                    let
                        toSession moment1 moment2 =
                            ( activity, Just <| Task.Instance.getID instance, Period.fromPair ( moment1, moment2 ) )
                    in
                    List.map2 toSession startsList stopsList


type alias TrackAck =
    { startID : Maybe MarvinItem.ItemID
    , startTimes : List Moment
    , stopID : Maybe MarvinItem.ItemID
    , stopTimes : List Moment
    }


decodeTrackAck : Decode.Decoder TrackAck
decodeTrackAck =
    let
        decodeID =
            Decode.oneOf [ Decode.check Decode.string "" <| Decode.succeed Nothing, Decode.nullable Decode.string, Decode.null Nothing ]

        decodeTimes =
            Decode.oneOf
                [ Decode.list
                    decodeUnixTimestamp
                , Decode.succeed []
                ]
    in
    Decode.map4 TrackAck
        (Decode.field "startId" decodeID)
        (Decode.field "startTimes" decodeTimes)
        (Decode.field "stopId" decodeID)
        (Decode.field "stopTimes" decodeTimes)


{-| A message for you to add to your app's `Msg` type. Comes back when the sync request succeeded or failed.
-}
type Msg
    = TestResult (Result Http.Error String)
    | AuthResult (Result Http.Error String)
    | GotItems (Result Http.Error (List MarvinItem))
    | GotLabels (Result Http.Error (List MarvinLabel))
    | GotTimeBlockAssignments (Result Http.Error TimeBlockAssignments)
    | GotTimeBlocks TimeBlockAssignments (Result Http.Error (List MarvinTimeBlock))
    | GotTrackTruth (Result Http.Error (List TrackTruthItem))
    | GotTrackAck (Result Http.Error TrackAck)



--| SyncResponded (Result Http.Error Response)
--------------------------------- RESPONSE ---------------------------------NOTE


describeError : Http.Error -> String
describeError error =
    case error of
        Http.BadUrl msg ->
            "For some reason we were told the URL is bad. This should never happen, it's a perfectly tested working URL! The error: " ++ msg

        Http.Timeout ->
            "Timed out. Try again later?"

        Http.NetworkError ->
            "Are you offline? I couldn't get on the network, but it could also be your system blocking me."

        Http.BadStatus status ->
            case status of
                400 ->
                    "400 Bad Request: The request was incorrect."

                401 ->
                    "401 Unauthorized: Authentication is required, and has failed, or has not yet been provided. Maybe your API credentials are messed up?"

                403 ->
                    "403 Forbidden: The request was valid, but for something that is forbidden."

                404 ->
                    "404 Not Found! That should never happen, because I definitely used the right URL. Is your system or proxy blocking or messing with internet requests? Is it many years in future, where the API has been deprecated, obsoleted, and then discontinued? Or maybe it's far enough in the future that the service doesn't exist anymore but for some reason you're still using this version of the software?"

                429 ->
                    "429 Too Many Requests: Slow down, cowboy! Check out the API Docs for Usage Limits."

                500 ->
                    "500 Internal Server Error: They got the message, and it got confused"

                502 ->
                    "502 Bad Gateway: I was trying to reach the server but I got stopped along the way. If you're definitely connected, it's probably a temporary hiccup on their side -- but if you see this a lot, check that your DNS is resolving (try amazingmarvin.com) and any proxy setup you have is working."

                503 ->
                    "503 Service Unavailable: Not my fault! The service must be bogged down today, or perhaps experiencing a DDoS attack. :O"

                other ->
                    "Got HTTP Error code " ++ String.fromInt other ++ ", not sure what that means in this case. Sorry!"

        Http.BadBody string ->
            "I successfully talked with the servers, but the response had some weird parts I was never trained for. Either Marvin changed something recently, or you've found a weird edge case the developer didn't know about. Either way, please report this! \n" ++ string
