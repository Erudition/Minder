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


{-| A message for you to add to your app's `Msg` type. Comes back when the sync request succeeded or failed.
-}
type Msg
    = TestResult (Result Http.Error String)
    | SyncResponded (Result Http.Error Response)



--------------------------------- RESPONSE ---------------------------------NOTE


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
