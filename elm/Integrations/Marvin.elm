module Integrations.Marvin exposing (..)

{-| A library for interacting with the Amazing Marvin API.
-}

import Activity.Activity as Activity exposing (StoredActivities)
import Base64
import Bytes.Encode
import Dict exposing (Dict)
import Http
import IntDict exposing (IntDict)
import Integrations.Marvin.MarvinItem as MarvinItem exposing (ItemType(..), LabelID, MarvinItem, MarvinLabel, MarvinTimeBlock, OutputType(..), labelToDocketActivity, marvinTimeBlockToDocketTimeBlock, toDocketItem, toDocketTask)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import Maybe.Extra
import Porting exposing (..)
import Profile exposing (Profile)
import SmartTime.Moment exposing (Moment)
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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


handle : Int -> Profile -> Msg -> ( Profile, String, Cmd Msg )
handle classCounter profile response =
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
                    , Debug.toString itemList
                    , getTimeBlockAssignments
                    )

                Err err ->
                    ( profile
                    , describeError err
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
                    , Debug.toString labelList
                    , getTasks partialAccessToken
                    )

                Err err ->
                    ( profile
                    , describeError err
                    , Cmd.none
                    )

        GotTimeBlocks assignments result ->
            case result of
                Ok timeBlockList ->
                    ( { profile | timeBlocks = importTimeBlocks profile assignments timeBlockList }
                    , Debug.toString timeBlockList
                    , Cmd.none
                    )

                Err err ->
                    ( profile
                    , describeError err
                    , Cmd.none
                    )

        GotTimeBlockAssignments assignmentsResult ->
            case assignmentsResult of
                Ok assignmentDict ->
                    ( profile
                    , Debug.toString assignmentDict
                    , getTimeBlocks assignmentDict
                    )

                Err err ->
                    ( profile
                    , describeError err
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
                    Maybe.Extra.toList (tasksOnly output)

                activities =
                    Maybe.Extra.toList (activitiesOnly output)
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
                            , ( "timeEstimate", Encode.object [ ( "$gt", Encode.int 0 ) ] )
                            , ( "done", Encode.object [ ( "$exists", Encode.bool False ) ] )

                            --, ( "day", Encode.object [ ( "$regex", Encode.string "^\\d" ) ] )
                            , ( "labelIds", Encode.object [ ( "$not", Encode.object [ ( "$size", Encode.int 0 ) ] ) ] )
                            ]
                      )
                    , ( "fields"
                      , Encode.list Encode.string
                            [ "_id"
                            , "_rev"
                            , "done"
                            , "day"
                            , "title"
                            , "parentId"
                            , "labelIds"
                            , "dueDate"
                            , "timeEstimate"
                            , "startDate"
                            , "endDate"
                            , "times"
                            , "taskTime"
                            , "pinId"
                            , "recurringTaskId"
                            , "note"
                            ]
                      )
                    ]
                )
        , expect = Http.expectJson GotItems (toClassicLoose <| Decode.at [ "docs" ] <| Decode.list MarvinItem.decodeMarvinItem)
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Update a marvin doc
-}
updateDoc : Task.Instance.Instance -> Cmd Msg
updateDoc taskInstance =
    let
        asMarvinItem =
            MarvinItem.fromDocket taskInstance
    in
    case asMarvinItem of
        Just marvinItem ->
            Http.request
                { method = "PUT"
                , headers = [ Http.header "Accept" "application/json", buildAuthorizationHeader syncUser syncPassword, Http.header "If-Match" marvinItem.rev ]
                , url = marvinCloudantDatabaseUrl [ syncDatabase, marvinItem.id ] []
                , body =
                    Http.jsonBody
                        (MarvinItem.encodeMarvinItem marvinItem)
                , expect = Http.expectJson GotItems (toClassicLoose <| Decode.at [ "docs" ] <| Decode.list MarvinItem.decodeMarvinItem)
                , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
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
        , timeout = Nothing
        , tracker = Nothing
        }


{-| start or stop time tracking a task by its ID
-}
timeTrack : SecretToken -> String -> Cmd Msg
timeTrack secret taskID =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-API-Token" secret ]
        , url = marvinEndpointURL "time"
        , body =
            Http.jsonBody <|
                Encode.object
                    [ ( "taskId", Encode.string taskID ), ( "action", Encode.string "START" ) ]
        , expect = Http.expectString TestResult --TODO
        , timeout = Nothing
        , tracker = Nothing
        }


{-| A message for you to add to your app's `Msg` type. Comes back when the sync request succeeded or failed.
-}
type Msg
    = TestResult (Result Http.Error String)
    | AuthResult (Result Http.Error String)
    | GotItems (Result Http.Error (List MarvinItem))
    | GotLabels (Result Http.Error (List MarvinLabel))
    | GotTimeBlockAssignments (Result Http.Error TimeBlockAssignments)
    | GotTimeBlocks TimeBlockAssignments (Result Http.Error (List MarvinTimeBlock))



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
