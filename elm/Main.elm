port module Main exposing (JsonAppDatabase, Model, Msg(..), Screen(..), ViewState, buildModel, defaultView, emptyViewState, infoFooter, init, main, profileFromJson, profileToJson, setStorage, subscriptions, update, updateWithStorage, updateWithTime, view, viewUrl)

import Browser
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Dict
import Environment exposing (..)
import External.Commands exposing (..)
import Html.Styled as H exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Incubator.Todoist as Todoist
import IntDict
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Profile exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration exposing (HumanDuration(..), dur)
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import Task as Job
import TaskList
import TimeTracker exposing (..)
import Timeline
import Url
import Url.Parser as P exposing ((</>), Parser)
import Url.Parser.Query as PQ


main : Program (Maybe JsonAppDatabase) Model Msg
main =
    Browser.application
        { init = initGraphical
        , view = view
        , update = updateWithTime
        , subscriptions = subscriptions
        , onUrlChange = NewUrl
        , onUrlRequest = Link
        }


subscriptions : Model -> Sub Msg
subscriptions ({ profile, environment } as model) =
    Sub.batch
        [ -- TODO unsubscribe when not visible
          -- TODO sync subscription with current activity
          HumanMoment.everyMinuteOnTheMinute environment.time
            environment.timeZone
            (Tock NoOp)

        -- Debug.log "starting interval" (Moment.every Duration.aMinute (Tock NoOp))
        , Browser.Events.onVisibilityChange (\_ -> Tick NoOp)
        , storageChangedElsewhere NewAppData
        ]


port setStorage : JsonAppDatabase -> Cmd msg


port storageChangedElsewhere : (String -> msg) -> Sub msg


log : String -> a -> a
log label valueToLog =
    -- Debug.log label valueToLog
    valueToLog


{-| We want to `setStorage` on every update. This function adds the setStorage
command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ setStorage (profileToJson newModel.profile), cmds ]
    )


{-| Slips in before the real `update` function to pass in the current time.

For bookkeeping purposes, we want the current time for pretty much every update. This function intercepts the `update` process by first updating our model's `time` field before passing our Msg along to the real `update` function, which can then assume `model.time` is an up-to-date value.

(Since Elm is pure and Time is side-effect-y, there's no better way to do this.)
<https://stackoverflow.com/a/41025989/8645412>

-}
updateWithTime : Msg -> Model -> ( Model, Cmd Msg )
updateWithTime msg ({ environment } as model) =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        -- first get the current time
        Tick submsg ->
            ( model
            , Job.perform (Tock submsg) Moment.now
            )

        -- no storage change, just view
        Tock NoOp time ->
            let
                newEnv =
                    { environment | time = time }
            in
            update NoOp { model | environment = newEnv }

        -- actually do the update
        Tock submsg time ->
            let
                newEnv =
                    { environment | time = time }
            in
            updateWithStorage submsg { model | environment = newEnv }

        SetZoneAndTime zone time ->
            -- The only time we ever need to fetch the zone is at the start, and that's also when we need the time, so we combine them to reduce initial updates - this saves us one
            let
                newEnv =
                    { environment | time = time, timeZone = zone, launchTime = time }
            in
            -- no need to run updateWithStorage yet - on first run we do the first update anyway, with the passed in Msg, so skipping it here saves us another update with a storage write
            ( { model | environment = newEnv }, Cmd.none )

        -- intercept normal update
        otherMsg ->
            updateWithTime (Tick msg) model


initGraphical : Maybe JsonAppDatabase -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
initGraphical maybeJson url key =
    init maybeJson url (Just key)


init : Maybe JsonAppDatabase -> Url.Url -> Maybe Nav.Key -> ( Model, Cmd Msg )
init maybeJson url maybeKey =
    let
        startingModel =
            case maybeJson of
                Just jsonAppDatabase ->
                    case profileFromJson jsonAppDatabase of
                        Success savedAppData ->
                            buildModel savedAppData url maybeKey

                        WithWarnings warnings savedAppData ->
                            buildModel (Profile.saveWarnings savedAppData warnings) url maybeKey

                        Errors errors ->
                            buildModel (Profile.saveDecodeErrors Profile.fromScratch errors) url maybeKey

                        BadJson ->
                            buildModel Profile.fromScratch url maybeKey

                -- no json stored at all
                Nothing ->
                    buildModel Profile.fromScratch url maybeKey

        ( modelWithFirstUpdate, firstEffects ) =
            updateWithTime (NewUrl url) startingModel

        effects =
            [ Job.perform identity (Job.map2 SetZoneAndTime HumanMoment.localZone Moment.now) -- reduces initial calls to update
            , firstEffects
            ]
    in
    ( modelWithFirstUpdate
    , Cmd.batch effects
    )



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


{-| Our whole app's Model.
Intentionally minimal - we originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is due thursday", all stored in App "Database").
-}
type alias Model =
    { viewState : ViewState
    , profile : Profile
    , environment : Environment
    }


buildModel : Profile -> Url.Url -> Maybe Nav.Key -> Model
buildModel profile url maybeKey =
    { viewState = viewUrl url
    , profile = profile
    , environment = Environment.preInit maybeKey
    }


type alias JsonAppDatabase =
    String


profileFromJson : JsonAppDatabase -> DecodeResult Profile
profileFromJson incomingJson =
    Decode.decodeString decodeProfile incomingJson


profileToJson : Profile -> JsonAppDatabase
profileToJson appData =
    Encode.encode 0 (encodeProfile appData)


type alias ViewState =
    { primaryView : Screen
    , uid : Int
    }


emptyViewState : ViewState
emptyViewState =
    { primaryView = TimeTracker TimeTracker.defaultView
    , uid = 0
    }


type Screen
    = TaskList TaskList.ViewState
    | TimeTracker TimeTracker.ViewState
    | Timeline (Maybe Timeline.ViewState)
    | Calendar
    | Features
    | Preferences


screenToViewState : Screen -> ViewState
screenToViewState screen =
    { primaryView = screen, uid = 0 }



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


defaultView : ViewState
defaultView =
    ViewState (Timeline Nothing) 0


view : Model -> Browser.Document Msg
view { viewState, profile, environment } =
    if environment.time == Moment.zero then
        { title = "Loading..."
        , body = [ toUnstyled (H.map (\_ -> NoOp) (text "Loading")) ]
        }

    else
        case viewState.primaryView of
            TaskList subState ->
                { title = "Docket - Task List"
                , body =
                    List.map toUnstyled
                        [ H.map TaskListMsg (TaskList.view subState profile environment)
                        , infoFooter
                        , errorList profile.errors
                        ]
                }

            Timeline subState ->
                { title = "Docket - Timeline"
                , body =
                    List.map toUnstyled
                        [ H.map TimelineMsg (Timeline.view subState profile environment)
                        , infoFooter
                        , errorList profile.errors
                        ]
                }

            TimeTracker subState ->
                { title = "Docket Time Tracker"
                , body =
                    List.map toUnstyled
                        [ H.map TimeTrackerMsg (TimeTracker.view subState profile environment)
                        , infoFooter
                        , errorList profile.errors
                        ]
                }

            _ ->
                { title = "TODO Some other page"
                , body = List.map toUnstyled [ infoFooter ]
                }



-- myStyle = (style, "color:red")
--
-- div [(att1, "hi"), (att2, "yo"), (myStyle completion)] [nodes]
--
-- <div att1="hi" att2="yo">nodes</div>


infoFooter : Html Msg
infoFooter =
    footer [ class "info" ]
        [ p []
            [ text "Switch to: "
            , a [ href "/tasks" ] [ text "Task List" ]
            , text " ➖ "
            , a [ href "/timetracker" ] [ text "Time Tracker" ]
            , text " ➖ "
            , a [ href "/timeline" ] [ text "Timeline" ]
            , text " ➖ "
            , a [ href "?sync=marvin" ] [ text "Sync Marvin" ]
            ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/Erudition" ] [ text "Erudition" ]
            ]
        , p []
            [ text "(Increasingly more distant) fork of Evan's elm "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]


errorList : List String -> Html Msg
errorList stringList =
    let
        descWithBreaks desc =
            String.split "\n" desc

        asLi desc =
            li [ onDoubleClick ClearErrors ] (List.map asP (descWithBreaks desc))

        asP sub =
            div [ class "error-line" ] [ text sub ]
    in
    ol [] (List.map asLi stringList)



-- type Phrase = Written_by
--             | Double_click_to_edit_a_task
-- say : Phrase -> Language -> String
-- say phrase language =
--     ""
--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


{-| Users of our app can trigger messages by clicking and typing. These
messages are fed into the `update` function as they occur, letting us react
to them.
-}
type Msg
    = NoOp
    | Tick Msg
    | Tock Msg Moment
    | SetZoneAndTime Zone Moment
    | ClearErrors
    | ThirdPartySync ThirdPartyService
    | ThirdPartyServerResponded ThirdPartyResponse
    | Link Browser.UrlRequest
    | NewUrl Url.Url
    | TaskListMsg TaskList.Msg
    | TimeTrackerMsg TimeTracker.Msg
    | TimelineMsg Timeline.Msg
    | NewAppData String


type ThirdPartyService
    = Todoist
    | Marvin


type ThirdPartyResponse
    = TodoistServer Todoist.Msg
    | MarvinServer Marvin.Msg



-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ viewState, profile, environment } as model) =
    let
        justRunCommand command =
            ( model, command )

        justSetEnv newEnv =
            ( Model viewState profile newEnv, Cmd.none )
    in
    case msg of
        ClearErrors ->
            ( Model viewState { profile | errors = [] } environment, Cmd.none )

        ThirdPartySync service ->
            case service of
                Todoist ->
                    justRunCommand <|
                        Cmd.map ThirdPartyServerResponded <|
                            Cmd.map TodoistServer <|
                                Integrations.Todoist.fetchUpdates profile.todoist

                Marvin ->
                    justRunCommand <|
                        Cmd.map ThirdPartyServerResponded <|
                            Cmd.map MarvinServer <|
                                Marvin.test2

        ThirdPartyServerResponded (TodoistServer response) ->
            let
                ( newAppData, whatHappened ) =
                    Integrations.Todoist.handle response profile

                syncStatusChannel =
                    Notif.basicChannel "Sync Status"
                        |> Notif.setChannelDescription "Lets you know what happened the last time we tried to sync with online servers."
                        |> Notif.setChannelImportance Notif.High

                notification =
                    Notif.build syncStatusChannel
                        |> Notif.setID 23
                        |> Notif.setExpiresAfter (Duration.fromMinutes 1)
                        |> Notif.setTitle "Todoist Response"
                        |> Notif.setSubtitle "Sync Status"
                        |> Notif.setBody whatHappened
            in
            ( Model viewState newAppData environment
            , notify [ notification ]
            )

        ThirdPartyServerResponded (MarvinServer response) ->
            let
                ( newItems, whatHappened ) =
                    Marvin.handle (Moment.toSmartInt environment.time) response

                newProfile1WithItems =
                    { profile
                        | taskEntries = profile.taskEntries ++ newItems.taskEntries
                        , taskClasses = IntDict.union profile.taskClasses newItems.taskClasses
                        , taskInstances = IntDict.union profile.taskInstances newItems.taskInstances
                    }

                newProfile2WithErrors =
                    Profile.saveError newProfile1WithItems ("Here's what happened: \n" ++ whatHappened)
            in
            ( Model viewState newProfile2WithErrors environment
            , Cmd.none
            )

        Link urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    case environment.navkey of
                        Just navkey ->
                            -- in browser
                            justRunCommand <| Nav.pushUrl navkey (Url.toString url)

                        Nothing ->
                            -- running headless
                            ( model, Cmd.none )

                Browser.External href ->
                    justRunCommand <| Nav.load href

        NewUrl url ->
            let
                ( modelAfter, effectsAfter ) =
                    handleUrlTriggers url model

                -- effectsAfterDebug =External.Commands.toast ("got NewUrl: " ++ Url.toString url)
            in
            ( { modelAfter | viewState = viewUrl url }, effectsAfter )

        TaskListMsg subMsg ->
            let
                subViewState =
                    case viewState.primaryView of
                        -- Currently viewing the task list
                        TaskList subView ->
                            subView

                        -- viewing something else at the time (or headless)
                        _ ->
                            TaskList.defaultView

                ( newState, newApp, newCommand ) =
                    TaskList.update subMsg subViewState profile environment
            in
            ( Model (ViewState (TaskList newState) 0) newApp environment, Cmd.map TaskListMsg newCommand )

        TimeTrackerMsg subMsg ->
            let
                subViewState =
                    case viewState.primaryView of
                        TimeTracker subView ->
                            subView

                        _ ->
                            TimeTracker.defaultView

                ( newState, newApp, newCommand ) =
                    TimeTracker.update subMsg subViewState profile environment
            in
            ( Model (ViewState (TimeTracker newState) 0) newApp environment, Cmd.map TimeTrackerMsg newCommand )

        NewAppData newJSON ->
            let
                maybeNewApp =
                    profileFromJson newJSON
            in
            case maybeNewApp of
                Success savedAppData ->
                    ( Model viewState savedAppData environment, toast "Synced with another browser tab!" )

                WithWarnings warnings savedAppData ->
                    ( Model viewState (Profile.saveWarnings savedAppData warnings) environment, Cmd.none )

                Errors errors ->
                    ( Model viewState (Profile.saveDecodeErrors profile errors) environment, Cmd.none )

                BadJson ->
                    ( Model viewState (Profile.saveError profile "Got bad JSON from cross-sync") environment, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- PARSER


{-| This dense function lets us pretend we have a server redirecting sub-urls (like app/task/57) to our app, even when we don't (like when running as a simple local file). Simply insert a "#" in the address bar, right before the path that gets passed into our app (inc. query&fragment) and this function will make it disappear before our app parses its url.

Example: `http://localhost:8000/www/index.html#/sub/path?hey=there#yo`

is normally parsed as
`url: { fragment = Just "/sub/path?hey=there#yo", host = "localhost", path = "/www/index.html", port_ = Just 8000, protocol = Http, query = Nothing }`

but with this function we can pretend it was:
`url: { fragment = Just "yo", host = "localhost", path = "/www/index.html/sub/path", port_ = Just 8000, protocol = Http, query = Just "hey=there" }`

even though that path may have resulted in a 404 on any host without fancy redirection set up (such as the development environment). Sweet!

-}
bypassFakeFragment : Url.Url -> Url.Url
bypassFakeFragment url =
    case Maybe.map String.uncons url.fragment of
        -- only if "#" is immediately followed by a "/" (path)
        Just (Just ( '/', fakeFragment )) ->
            -- take the url and drop the first "#", then re-parse it
            case String.split "#" (Url.toString url) of
                front :: _ ->
                    -- Url.fromString can fail, but it shouldn't here
                    Maybe.withDefault url <|
                        -- include all the rest (even later "#"s)
                        Url.fromString (front ++ fakeFragment)

                _ ->
                    url

        _ ->
            url


viewUrl : Url.Url -> ViewState
viewUrl url =
    let
        finalUrl =
            bypassFakeFragment url
    in
    Maybe.withDefault defaultView (P.parse routeParser finalUrl)


routeParser : Parser (ViewState -> a) a
routeParser =
    let
        wrapScreen parser =
            P.map screenToViewState parser
    in
    P.oneOf
        [ wrapScreen (P.map TaskList TaskList.routeView)
        , wrapScreen (P.map TimeTracker TimeTracker.routeView)
        ]


{-| Like an `update` function, but instead of accepting `Msg`s it works on the URL query -- to allow us to send `Msg`s from the address bar! (to the real update function). Thus our web app should be completely scriptable.
-}
handleUrlTriggers : Url.Url -> Model -> ( Model, Cmd Msg )
handleUrlTriggers rawUrl ({ profile, environment } as model) =
    let
        url =
            bypassFakeFragment rawUrl

        -- so that parsers run regardless of path:
        normalizedUrl =
            { url | path = "" }

        fancyRecursiveParse checkList =
            case checkList of
                -- Pull off the first of the list and work on that alone
                ( triggerName, triggerValues ) :: rest ->
                    case P.parse (P.query (PQ.enum triggerName triggerValues)) normalizedUrl of
                        Nothing ->
                            fancyRecursiveParse rest

                        Just Nothing ->
                            -- no match, start over with shorter parser list
                            fancyRecursiveParse rest

                        Just match ->
                            -- Found a match? Stop here!
                            Just match

                -- No more of the list left
                [] ->
                    Nothing

        -- Top level: run parser on parseList
        parsed =
            P.parse (P.oneOf parseList) normalizedUrl

        -- Create list of Normal parsers from our query-only parsers
        parseList =
            List.map P.query (List.map createQueryParsers allTriggers)

        -- Turns all our "trigger" dicts into query-only (PQ) parsers
        createQueryParsers ( key, values ) =
            PQ.enum key values

        -- Dig deep into all of our "urlTriggers" functions to wrap their Page-specific `Msg` with our Main `Msg`
        wrapMsgs tagger ( key, dict ) =
            ( key, Dict.map (\_ msg -> tagger msg) dict )

        -- Triggers (passed to PQ.enum) for each page. Add new page here
        allTriggers =
            List.map (wrapMsgs TaskListMsg) (TaskList.urlTriggers profile environment)
                ++ List.map (wrapMsgs TimeTrackerMsg) (TimeTracker.urlTriggers profile)
                ++ [ ( "sync"
                     , Dict.fromList
                        [ ( "todoist", ThirdPartySync Todoist )
                        , ( "marvin", ThirdPartySync Marvin )
                        ]
                     )
                   , ( "clearerrors", Dict.fromList [ ( "clearerrors", ClearErrors ) ] )
                   ]

        --TODO only remove handled triggers
        removeTriggersFromUrl =
            case environment.navkey of
                Just navkey ->
                    -- TODO maintain Fake Fragment. currently destroys it
                    Nav.replaceUrl navkey (Url.toString { url | query = Nothing })

                Nothing ->
                    Cmd.none
    in
    case fancyRecursiveParse allTriggers of
        Just parsedUrlSuccessfully ->
            case ( parsedUrlSuccessfully, normalizedUrl.query ) of
                ( Just triggerMsg, Just _ ) ->
                    let
                        ( newModel, newCmd ) =
                            update triggerMsg model

                        newCmdWithUrlCleaner =
                            Cmd.batch [ newCmd, removeTriggersFromUrl ]
                    in
                    ( newModel
                    , newCmdWithUrlCleaner
                    )

                ( Nothing, Just query ) ->
                    let
                        problemText =
                            "Handle URL Triggers: none of  "
                                ++ String.fromInt (List.length parseList)
                                ++ " parsers matched key and value: "
                                ++ query
                    in
                    ( { model | profile = saveError profile problemText }, External.Commands.toast problemText )

                ( Just triggerMsg, Nothing ) ->
                    let
                        problemText =
                            "Handle URL Triggers: impossible situation. No query (Nothing) but we still successfully parsed it!"
                    in
                    ( { model | profile = saveError profile problemText }, External.Commands.toast problemText )

                ( Nothing, Nothing ) ->
                    ( model, Cmd.none )

        Nothing ->
            -- Failed to parse URL Query - was there one?
            case normalizedUrl.query of
                Nothing ->
                    -- Perfectly normal - failed to parse triggers because there were none.
                    ( model, Cmd.none )

                Just queriesPresent ->
                    -- passed a query that we didn't understand! Fail gracefully
                    let
                        problemText =
                            "URL: not sure what to do with: " ++ queriesPresent ++ ", so I just left it there. Is the trigger misspelled?"
                    in
                    ( { model | profile = saveError profile problemText }, External.Commands.toast problemText )


nerfUrl : Url.Url -> Url.Url
nerfUrl original =
    { original | path = "" }
