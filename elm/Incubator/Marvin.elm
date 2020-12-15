module Incubator.Marvin exposing (..)

{-| A library for interacting with the Amazing Marvin API.
-}

import Dict exposing (Dict)
import Http
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Maybe.Extra as Maybe
import Porting exposing (..)
import Set exposing (Set)
import SmartTime.Human.Moment as HumanMoment
import Url
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


getDoc : SecretFullToken -> Cmd Msg
getDoc fullSecret =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-Full-Access-Token" fullSecret ]
        , url = marvinEndpointURL "doc"
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


{-| Sync with Marvin

This is a `Platform.Cmd`, you'll need to run it from your `update`.

-}
sync : Cache -> SecretToken -> List Resources -> List CommandInstance -> Cmd Msg
sync cache secret resourceList commandList =
    Http.request
        { method = "POST"
        , headers = [ header "X-API-Token" secret ]
        , url = serverUrl resourceList commandList cache.nextSync
        , body = r.body
        , expect = r.expect
        , timeout = Nothing
        , tracker = Nothing
        }


{-| A message for you to add to your app's `Msg` type. Comes back when the sync request succeeded or failed.
-}
type Msg
    = TestResult (Result Http.Error String)
    | SyncResponded (Result Http.Error Response)


{-| A place to store your local copy of the user's Todoist data.

By keeping this in your model, you can quickly and easily perform efficient incremental synchronization with Todoist's servers by passing it to the `sync` function! Only the (desired) resources changed since the last sync will be updated, and the commands that didn't go through will be kept around so you can retry them.

That said, this is optional. You can handle the fetched resources individually if you want, or even discard

-}
type alias Cache =
    { nextSync : IncrementalSyncToken
    , items : IntDict Item
    , projects : IntDict Project
    , pendingCommands : List String
    }


emptyCache : Cache
emptyCache =
    { nextSync = IncrementalSyncToken "*"
    , items = IntDict.empty
    , projects = IntDict.empty
    , pendingCommands = []
    }


decodeCache : Decoder Cache
decodeCache =
    decode Cache
        |> optional "nextSync" decodeIncrementalSyncToken emptyCache.nextSync
        |> required "items" (decodeIntDict Item.decodeItem)
        |> required "projects" (decodeIntDict Project.decodeProject)
        |> required "pendingCommands" (Decode.list Decode.string)


encodeCache : Cache -> Encode.Value
encodeCache record =
    Encode.object
        [ ( "nextSync", encodeIncrementalSyncToken record.nextSync )
        , ( "items", encodeIntDict Item.encodeItem record.items )
        , ( "projects", encodeIntDict Project.encodeProject record.projects )
        , ( "pendingCommands", Encode.list Encode.string record.pendingCommands )
        ]


serverUrl : SecretToken -> List Resources -> List CommandInstance -> IncrementalSyncToken -> String
serverUrl secret resourceList commandList (IncrementalSyncToken syncToken) =
    let
        chosenResources =
            """[%22items%22,%22projects%22]"""

        resources =
            Encode.list encodeResources resourceList

        commands =
            Encode.list encodeCommandInstance commandList

        withRead =
            if List.length resourceList > 0 then
                [ Url.Builder.string "sync_token" syncToken
                , Url.Builder.string "resource_types" (Encode.encode 0 resources)
                ]

            else
                []

        withWrite =
            if List.length commandList > 0 then
                [ Url.Builder.string "commands" (Encode.encode 0 commands) ]

            else
                []
    in
    marvinEndpoint
        ([ Url.Builder.string "token" secret ] ++ withRead ++ withWrite)



--------------------------------- RESPONSE ---------------------------------NOTE


handleResponse : Msg -> Cache -> Result Http.Error ( Cache, LatestChanges )
handleResponse (SyncResponded response) oldCache =
    case response of
        Ok newStuff ->
            let
                -- creates a dictionary out of the returned stuff, for merging
                ( itemsDict, projectsDict ) =
                    ( IntDict.fromList (List.map (\i -> ( i.id, i )) newStuff.items)
                    , IntDict.fromList (List.map (\p -> ( p.id, p )) newStuff.projects)
                    )

                -- Only remove deleted if it's a partial sync. We won't get deleted items on a full sync anyway, and that would take the longest to map over.
                prune inputDict =
                    if not newStuff.full_sync then
                        pruneDeleted inputDict

                    else
                        inputDict
            in
            Ok
                ( { nextSync = Maybe.withDefault oldCache.nextSync newStuff.sync_token
                  , items = prune <| IntDict.union itemsDict oldCache.items
                  , projects = prune <| IntDict.union projectsDict oldCache.projects
                  , pendingCommands = []
                  }
                , summarizeChanges oldCache newStuff
                )

        Err err ->
            Result.Err err


{-| A summary of the latest changes!
-}
type alias LatestChanges =
    { itemsAdded : Set Item.ItemID
    , itemsDeleted : Set Item.ItemID
    , itemsChanged : Set Item.ItemID
    , projectsAdded : Set Project.ProjectID
    , projectsDeleted : Set Project.ProjectID
    , projectsChanged : Set Project.ProjectID
    }


summarizeChanges : Cache -> Response -> LatestChanges
summarizeChanges oldCache new =
    let
        toIDSet list =
            Set.fromList (List.map .id list)

        -- keeps track of all the changed IDs, before the changes are merged
        ( allChangedItemIDs, allChangedProjectIDs ) =
            ( toIDSet new.items, toIDSet new.projects )

        ( newlyAddedItemIDs, newlyAddedProjectIDs ) =
            ( Set.filter (\id -> not (IntDict.member id oldCache.items)) allChangedItemIDs
            , Set.filter (\id -> not (IntDict.member id oldCache.projects)) allChangedProjectIDs
            )

        ( deletedItemIDs, deletedProjectIDs ) =
            ( toIDSet (List.filter .is_deleted new.items)
            , toIDSet (List.filter .is_deleted new.projects)
            )

        -- not new nor deleted, but changed some other way
        ( remainingItemIDs, remainingProjectIDs ) =
            ( Set.diff allChangedItemIDs (Set.union newlyAddedItemIDs deletedItemIDs)
            , Set.diff allChangedProjectIDs (Set.union newlyAddedProjectIDs deletedProjectIDs)
            )
    in
    { itemsAdded = newlyAddedItemIDs
    , itemsDeleted = deletedItemIDs
    , itemsChanged = remainingItemIDs
    , projectsAdded = newlyAddedProjectIDs
    , projectsDeleted = deletedProjectIDs
    , projectsChanged = remainingProjectIDs
    }


{-| An example of how you can handle the output of `handleResponse`. Wraps it.
-}
easyHandle : Msg -> Cache -> ( Cache, String )
easyHandle inputMsg oldCache =
    let
        runHandler =
            handleResponse inputMsg oldCache
    in
    case runHandler of
        Ok ( newCache, _ ) ->
            -- TODO describe success
            ( newCache, "Success" )

        Err error ->
            ( oldCache, describeError error )


describeError : Http.Error -> String
describeError error =
    case error of
        Http.BadUrl msg ->
            "For some reason we were told the URL is bad. This should never happen, it's a perfectly tested working URL! The error: " ++ msg

        Http.Timeout ->
            "Timed out. Try again later?"

        Http.NetworkError ->
            "Couldn't get on the network. Are you offline?"

        Http.BadStatus status ->
            case status of
                400 ->
                    "400 Bad Request: The request was incorrect."

                401 ->
                    "401 Unauthorized: Authentication is required, and has failed, or has not yet been provided. Maybe your API credentials are messed up?"

                403 ->
                    "403 Forbidden: The request was valid, but for something that is forbidden."

                404 ->
                    "404 Not Found! That should never happen, because I definitely used the right URL. Is your system or proxy blocking or messing with internet requests? Is it many years in future, where Todoist API v8 has been deprecated, obseleted, and then discontinued? Or maybe it's far enough in the future that Todoist doesn't exist anymore but for some reason you're still using this library?"

                429 ->
                    "429 Too Many Requests: Slow down, cowboy! Check out the Todoist API Docs for Usage Limits. Maybe try batching more requests into one?"

                500 ->
                    "500 Internal Server Error: Not my fault! Todoist must be having a bad day."

                502 ->
                    "502 Bad Gateway: I was trying to reach the Todoist server but I got stopped along the way. If you're definitely connected, it's probably a temporary hiccup on their side -- but if you see this a lot, check that your DNS is resolving (try todoist.com) and any proxy setup you have is working."

                503 ->
                    "503 Service Unavailable: Not my fault! Todoist must be bogged down today, or perhaps experiencing a DDoS attack. :O"

                other ->
                    "Got HTTP Error code " ++ String.fromInt other ++ ", not sure what that means in this case. Sorry!"

        Http.BadBody string ->
            "I successfully talked with Todoist servers, but the response had some weird parts I was never trained for. Either Todoist changed something recently, or you've found a weird edge case the developer didn't know about. Either way, please report this! \n" ++ string


pruneDeleted : IntDict { a | is_deleted : Bool } -> IntDict { a | is_deleted : Bool }
pruneDeleted items =
    IntDict.filterValues (not << .is_deleted) items


type alias Response =
    { sync_token : Maybe IncrementalSyncToken
    , sync_status : Dict CommandUUID CommandResult
    , full_sync : Bool
    , items : List Item
    , projects : List Project
    }


decodeResponse : Decoder Response
decodeResponse =
    decode Response
        |> optional "sync_token" (Decode.map Just decodeIncrementalSyncToken) Nothing
        |> optional "sync_status" (Decode.dict decodeCommandResult) Dict.empty
        |> required "full_sync" bool
        |> optional "items" (list Item.decodeItem) []
        |> optional "projects" (list Project.decodeProject) []
        |> optionalIgnored "collaborators"
        |> optionalIgnored "collaborator_states"
        |> optionalIgnored "day_orders"
        |> optionalIgnored "filters"
        |> optionalIgnored "labels"
        |> optionalIgnored "live_notifications"
        |> optionalIgnored "live_notifications_last_read_id"
        |> optionalIgnored "notes"
        |> optionalIgnored "project_notes"
        |> optionalIgnored "reminders"
        |> optionalIgnored "settings_notifications"
        |> optionalIgnored "temp_id_mapping"
        |> optionalIgnored "user"
        |> optionalIgnored "user_settings"
        |> optionalIgnored "sections"
        -- each item below not in spec!
        |> optionalIgnored "due_exceptions"
        |> optionalIgnored "day_orders_timestamp"
        |> optionalIgnored "incomplete_project_ids"
        |> optionalIgnored "incomplete_item_ids"
        |> optionalIgnored "stats"
        |> optionalIgnored "locations"
        |> optionalIgnored "tooltips"
