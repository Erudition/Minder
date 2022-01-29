port module Main exposing (JsonAppDatabase, Model, Msg(..), Screen(..), ViewState, buildModel, emptyViewState, infoFooter, init, main, profileFromJson, profileToJson, setStorage, subscriptions, update, updateWithStorage, updateWithTime, view, viewUrl)

import Activity.Activity as Activity
import Activity.Switch as Switch exposing (Switch(..))
import Activity.Timeline as Timeline exposing (Timeline)
import Browser
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font
import Element.Input as Input
import Environment exposing (..)
import External.Commands exposing (..)
import Html as PlainHtml
import Html.Attributes as HA
import Html.Styled as H exposing (Html, a, div, li, ol, p, toUnstyled)
import Html.Styled.Attributes as Attr exposing (class, href)
import Html.Styled.Events as HtmlEvents
import Incubator.Todoist as Todoist
import IntDict
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Json.Decode as ClassicDecode
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
import Log
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Profile exposing (..)
import Replicated.Node.Node as Node exposing (Node)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration exposing (HumanDuration(..), dur)
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import Task as Job
import Task.Instance as Instance
import TaskList
import TimeTracker
import Timeflow
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
subscriptions ({ viewState, profile, environment } as model) =
    Sub.batch <|
        [ -- TODO unsubscribe when not visible
          -- TODO sync subscription with current activity
          HumanMoment.everyMinuteOnTheMinute environment.time
            environment.timeZone
            (Tock NoOp)

        -- Debug.log "starting interval" (Moment.every Duration.aMinute (Tock NoOp))
        , Browser.Events.onVisibilityChange (\_ -> Tick NoOp)
        , storageChangedElsewhere NewAppData

        -- , Browser.Events.onMouseMove <| ClassicDecode.map2 MouseMoved decodeButtons decodeFraction
        , Moment.every (Duration.fromSeconds (1 / 5)) (Tock NoOp)
        ]
            ++ (case viewState.primaryView of
                    Timeflow subState ->
                        [ Sub.map TimeflowMsg (Timeflow.subscriptions profile environment subState) ]

                    _ ->
                        []
               )



{- The goal here is to get (mouse x / window width) on each mouse event. So if
   the mouse is at 500px and the screen is 1000px wide, we should get 0.5 from this.
   Getting the mouse x is not too hard, but getting window width is a bit tricky.
   We want the window.innerWidth value, which happens to be available at:
       event.currentTarget.defaultView.innerWidth
   The value at event.currentTarget is the document in these cases, but this will
   not work if you have a <section> or a <div> with a normal elm/html event handler.
   So if currentTarget is NOT the document, you should instead get the value at:
       event.currentTarget.ownerDocument.defaultView.innerWidth
                           ^^^^^^^^^^^^^
-}


decodeFraction : ClassicDecode.Decoder Float
decodeFraction =
    ClassicDecode.map2 (/)
        (ClassicDecode.field "pageX" ClassicDecode.float)
        (ClassicDecode.at [ "currentTarget", "defaultView", "innerWidth" ] ClassicDecode.float)



{- What happens when the user is dragging, but the "mouse up" occurs outside
   the browser window? We need to stop listening for mouse movement and end the
   drag. We use MouseEvent.buttons to detect this:
       https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/buttons
   The "buttons" value is 1 when "left-click" is pressed, so we use that to
   detect zombie drags.
-}


decodeButtons : ClassicDecode.Decoder Bool
decodeButtons =
    ClassicDecode.field "buttons" (ClassicDecode.map (\buttons -> buttons == 1) ClassicDecode.int)


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

        paneInits =
            [ Cmd.map TimeflowMsg <| Tuple.second (Timeflow.init modelWithFirstUpdate.profile modelWithFirstUpdate.environment) ]
    in
    ( modelWithFirstUpdate
    , Cmd.batch (effects ++ paneInits)
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
    { primaryView = TaskList TaskList.defaultView
    , uid = 0
    }


type Screen
    = TaskList TaskList.ViewState
    | TimeTracker TimeTracker.ViewState
    | Timeflow (Maybe Timeflow.ViewState)
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


view : Model -> Browser.Document Msg
view { viewState, profile, environment } =
    let
        activePage =
            case viewState.primaryView of
                TaskList subState ->
                    { title = "Docket - Task List"
                    , body = H.map TaskListMsg (TaskList.view subState profile environment)
                    }

                Timeflow subState ->
                    { title = "Docket - Timeflow"
                    , body =
                        H.map TimeflowMsg (Timeflow.view subState profile environment)
                    }

                TimeTracker subState ->
                    { title = "Docket Time Tracker"
                    , body =
                        H.map TimeTrackerMsg (TimeTracker.view subState profile environment)
                    }

                _ ->
                    { title = "TODO Some other page"
                    , body = infoFooter
                    }

        withinPage =
            toUnstyled <|
                H.node "page"
                    []
                    [ activePage.body

                    --, errorList profile.errors
                    ]
    in
    { title = activePage.title
    , body =
        [ globalLayout viewState profile environment withinPage ]
    }


{-|

    selectedTab takes an element and wraps it in a stylied container
    to indicate which page is currently active.

    Todo: Consider adding costumisable styling for this.

-}
selectedTab : List (Element msg) -> Element msg -> List (Element msg) -> Element msg
selectedTab startingList selected endingList =
    row [ centerX, Element.spacing 20, height fill, Element.paddingXY 0 5 ]
        (startingList
            ++ [ el
                    [ Element.centerY
                    , Element.centerX
                    , Background.color (rgba255 255 255 255 0.3)
                    , height fill
                    , Element.Font.semiBold
                    , Border.rounded 7
                    , Element.paddingXY 10 5
                    ]
                    selected
               ]
            ++ endingList
        )


globalLayout : ViewState -> Profile -> Environment -> PlainHtml.Html Msg -> PlainHtml.Html Msg
globalLayout viewState profile env innerStuff =
    let
        elmUIOptions =
            { options = [] }

        timetrackerLink =
            link [ centerX, centerY ] { url = "#/timetracker", label = text "Timetracker" }

        classesLink =
            link [ centerX, centerY ] { url = "#", label = text "Classes" }

        tasksLink =
            link [ centerX, centerY ] { url = "#/tasks", label = text "Tasks" }

        timeflowLink =
            link [ centerX, centerY ] { url = "#/timeflow", label = text "Timeflow" }

        footerLinks =
            case viewState.primaryView of
                TimeTracker _ ->
                    selectedTab [] timetrackerLink [ classesLink, tasksLink, timeflowLink ]

                TaskList _ ->
                    selectedTab [ timetrackerLink, classesLink ] tasksLink [ timeflowLink ]

                Timeflow _ ->
                    selectedTab [ timetrackerLink, classesLink, tasksLink ] timeflowLink []

                _ ->
                    Debug.todo "branch not implemented"
    in
    layoutWith elmUIOptions [ width fill, htmlAttribute (HA.style "max-height" "100vh") ] <|
        column [ width fill, height fill ]
            [ row [ width fill, height (fillPortion 1), Background.color (rgb 0.5 0.5 0.5) ]
                [ el [ centerX ] <| text "Minder - pre-alpha prototype"
                , link [ alignRight ] { url = "?sync=marvin", label = text "SM" }
                ]
            , row [ width fill, height (fillPortion 20), clip, scrollbarY ]
                [ html innerStuff ]
            , row [ width fill, spacing 30, height (fillPortion 1), Background.color (rgb 0.5 0.5 0.5) ]
                [ footerLinks
                ]
            , trackingDisplay profile env
            ]


trackingDisplay profile env =
    let
        currentActivity =
            Timeline.currentActivity profile.activities profile.timeline

        latestSwitch =
            Log.logMessage ("latest switch at " ++ HumanMoment.toStandardString (Switch.getMoment (Timeline.latestSwitch profile.timeline))) (Timeline.latestSwitch profile.timeline)

        currentInstanceIDMaybe =
            Switch.getInstanceID latestSwitch

        allInstances =
            Profile.instanceListNow profile env

        currentInstanceMaybe currentInstanceID =
            List.head (List.filter (\t -> Instance.getID t == currentInstanceID) allInstances)

        timeSinceSwitch =
            Moment.difference (Switch.getMoment latestSwitch) env.time

        tracking_for_string thing time =
            "Tracking "
                ++ thing
                ++ " for "
                ++ SmartTime.Human.Duration.singleLetterSpaced [ SmartTime.Human.Duration.inLargestWholeUnits time ]
    in
    case Maybe.andThen currentInstanceMaybe currentInstanceIDMaybe of
        Nothing ->
            row [ width fill, height (fillPortion 1), Background.color (rgb 1 1 1) ]
                [ el [] <| text "O"
                , el [ centerX ] <|
                    text
                        (tracking_for_string (Activity.getName currentActivity) timeSinceSwitch)
                ]

        Just currentInstance ->
            row
                [ width fill
                , height (fillPortion 1)
                , Background.color (rgb 1 1 1)
                , behindContent
                    (row [ width fill, height fill ]
                        [ el [] <| text "O"
                        , el [ centerX ] (text (tracking_for_string (Instance.getTitle currentInstance) timeSinceSwitch))
                        ]
                    )
                ]
                [ trackingTaskCompletionSlider currentInstance ]


trackingTaskCompletionSlider instance =
    let
        blue =
            Element.rgb255 238 238 238
    in
    Input.slider
        [ Element.height (Element.px 30)

        -- Here is where we're creating/styling the "track"
        , Element.behindContent
            (row [ width fill, height fill ]
                [ Element.el
                    [ Element.width (fillPortion (Instance.getCompletionInt instance))
                    , Element.height fill
                    , Element.centerY
                    , Background.color (Element.rgba 0 1 0 0.5)
                    , Border.rounded 2
                    ]
                    Element.none
                , Element.el
                    [ Element.width (fillPortion (Instance.getProgressMaxInt instance - Instance.getCompletionInt instance))
                    , Element.height fill
                    , Element.centerY
                    , Background.color (Element.rgba 0 0 0 0)
                    , Border.rounded 2
                    ]
                    Element.none
                ]
            )
        ]
        { onChange = \input -> TaskListMsg <| TaskList.UpdateProgress instance (round input)
        , label =
            Input.labelHidden "Task Progress"
        , min = 0
        , max = toFloat <| Instance.getProgressMaxInt instance
        , step = Just 1
        , value = toFloat (Instance.getCompletionInt instance)
        , thumb =
            Input.thumb []
        }



-- myStyle = (style, "color:red")
--
-- div [(att1, "hi"), (att2, "yo"), (myStyle completion)] [nodes]
--
-- <div att1="hi" att2="yo">nodes</div>


infoFooter : Html Msg
infoFooter =
    H.footer [ class "info" ]
        [ H.p []
            [ H.text "Switch to: "
            , H.a [ href "/tasks" ] [ H.text "Task List" ]
            , H.text " ➖ "
            , H.a [ href "/timetracker" ] [ H.text "Time Tracker" ]
            , H.text " ➖ "
            , H.a [ href "/timeflow" ] [ H.text "Timeflow" ]
            , H.text " ➖ "
            , H.a [ href "?sync=marvin" ] [ H.text "Sync Marvin" ]
            ]
        , H.p []
            [ H.text "Written by "
            , H.a [ href "https://github.com/Erudition" ] [ H.text "Erudition" ]
            ]
        , H.p []
            [ H.text "(Increasingly more distant) fork of Evan's elm "
            , H.a [ href "http://todomvc.com" ] [ H.text "TodoMVC" ]
            ]
        ]


errorList : List String -> Html Msg
errorList stringList =
    let
        descWithBreaks desc =
            String.split "\n" desc

        asLi desc =
            li [ HtmlEvents.onDoubleClick ClearErrors ] (List.map asP (descWithBreaks desc))

        asP sub =
            H.div [ class "error-line" ] [ H.text sub ]
    in
    H.ol [] (List.map asLi stringList)



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
    | TimeflowMsg Timeflow.Msg
    | NewAppData String
    | MouseMoved Bool Float


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
                        Cmd.batch
                            [ Cmd.map ThirdPartyServerResponded <|
                                Cmd.map MarvinServer <|
                                    Marvin.getLabelsCmd
                            , External.Commands.toast "Reached out to Marvin server..."
                            ]

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
                        |> Notif.setBigTextStyle True
            in
            ( Model viewState newAppData environment
            , notify [ notification ]
            )

        ThirdPartyServerResponded (MarvinServer response) ->
            let
                ( newProfile1WithItems, whatHappened, nextStep ) =
                    Marvin.handle (IntDict.size profile.taskClasses + 1000) profile environment response

                newProfile2WithErrors =
                    Profile.saveError newProfile1WithItems ("Synced with Marvin: \n" ++ whatHappened)

                syncStatusChannel =
                    Notif.basicChannel "Sync Status"
                        |> Notif.setChannelDescription "Lets you know what happened the last time we tried to sync with online servers."
                        |> Notif.setChannelImportance Notif.Min
                        |> Notif.setChannelGroup "Status"

                notification =
                    Notif.build syncStatusChannel
                        |> Notif.setExpiresAfter (Duration.fromMinutes 1)
                        |> Notif.setTitle "Marvin Response"
                        |> Notif.setSubtitle "Sync Status"
                        |> Notif.setBody whatHappened
                        |> Notif.setBigTextStyle True
                        |> Notif.setAccentColor "green"
                        |> Notif.setGroup (Notif.GroupKey "marvin")
            in
            ( Model viewState newProfile2WithErrors environment
            , Cmd.batch
                [ Cmd.map ThirdPartyServerResponded <| Cmd.map MarvinServer <| nextStep
                , notify [ notification ]
                ]
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
            case subMsg of
                TaskList.MarvinServerResponse subSubMsg ->
                    update (ThirdPartyServerResponded (MarvinServer subSubMsg)) model

                _ ->
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

        TimeflowMsg subMsg ->
            let
                subViewState =
                    case viewState.primaryView of
                        Timeflow (Just subView) ->
                            subView

                        _ ->
                            Tuple.first (Timeflow.init profile environment)

                ( newState, newApp, newCommand ) =
                    Timeflow.update subMsg subViewState profile environment
            in
            ( Model (ViewState (Timeflow (Just newState)) 0) newApp environment, Cmd.map TimeflowMsg newCommand )

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
    Maybe.withDefault emptyViewState (P.parse routeParser finalUrl)


routeParser : Parser (ViewState -> a) a
routeParser =
    let
        wrapScreen parser =
            P.map screenToViewState parser
    in
    P.oneOf
        [ wrapScreen (P.map TaskList TaskList.routeView)
        , wrapScreen (P.map TimeTracker TimeTracker.routeView)
        , wrapScreen (P.map Timeflow Timeflow.routeView)
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
