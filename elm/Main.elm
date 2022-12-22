port module Main exposing (Msg(..), StoredRON, Temp, ViewState, emptyViewState, infoFooter, init, main, navigate, setStorage, subscriptions, update, view)

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
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Parser
import Profile exposing (..)
import Replicated.Change as Change exposing (Change, Frame)
import Replicated.Codec as Codec exposing (Codec, decodeFromNode)
import Replicated.Framework as Framework
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.OpID as OpID exposing (OpID)
import Replicated.Reducer.RepDb as RepDb
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration exposing (HumanDuration(..), dur)
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import Task as Job
import Task.AssignedAction as Instance
import TaskList
import TimeTracker
import Timeflow
import Url
import Url.Parser as P exposing ((</>), Parser)
import Url.Parser.Query as PQ


main : Framework.Program () Profile Temp Msg
main =
    Framework.browserApplication
        { init = initGraphical
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = NewUrl
        , onUrlRequest = Link
        , replicaCodec = Profile.codec
        , portSetStorage = setStorage
        }


subscriptions : Model -> Sub Msg
subscriptions { replica, temp } =
    Sub.batch <|
        [ -- TODO unsubscribe when not visible
          -- TODO sync subscription with current activity
          --   HumanMoment.everyMinuteOnTheMinute temp.environment.time
          --     temp.environment.timeZone
          --     (\_ -> NoOp)
          -- Debug.log "starting interval" (Moment.every Duration.aMinute (Tock NoOp))
          Browser.Events.onVisibilityChange (\_ -> NoOp)

        -- , storageChangedElsewhere NewAppData
        -- , Browser.Events.onMouseMove <| ClassicDecode.map2 MouseMoved decodeButtons decodeFraction
        --, Moment.every (Duration.fromSeconds (1 / 5)) (Tock NoOp)
        ]
            ++ (case temp.viewState.timeflow of
                    OpenPanel _ subState ->
                        [ Sub.map TimeflowMsg (Timeflow.subscriptions replica temp.environment subState) ]

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


port setStorage : String -> Cmd msg


port storageChangedElsewhere : (String -> msg) -> Sub msg


log : String -> a -> a
log label valueToLog =
    -- Debug.log label valueToLog
    valueToLog


type alias StoredRON =
    String


initGraphical : () -> Url.Url -> Nav.Key -> Profile -> ( List Frame, Temp, Cmd Msg )
initGraphical maybeJson url key =
    init url (Just key)


init : Url.Url -> Maybe Nav.Key -> Profile -> ( List Frame, Temp, Cmd Msg )
init url maybeKey replica =
    let
        cmdsFromUrl =
            handleUrlTriggers url replica initialTemp

        initialTemp : Temp
        initialTemp =
            { viewState = navigate url
            , environment = Environment.preInit maybeKey
            }

        paneInits =
            [ Cmd.map TimeflowMsg <| Tuple.second (Timeflow.init replica initialTemp.environment)
            ]
    in
    ( []
    , initialTemp
    , Cmd.batch (cmdsFromUrl :: paneInits)
    )



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


{-| Our whole app's Model.
Intentionally minimal - we originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is due thursday", all stored in App "Database").
-}
type alias Temp =
    { viewState : ViewState
    , environment : Environment
    }


type alias Model =
    Framework.Replicator Profile Temp


type Panel panelState
    = OpenPanel PanelPosition panelState
    | ClosedPanel PanelPosition panelState
    | UnopenedPanel


type PanelPosition
    = FullScreen


type alias ViewState =
    { taskList : Panel TaskList.ViewState
    , timeTracker : Panel TimeTracker.ViewState
    , timeflow : Panel (Maybe Timeflow.ViewState)
    }


emptyViewState : ViewState
emptyViewState =
    { taskList = UnopenedPanel -- OpenPanel FullScreen <| TaskList.defaultView
    , timeTracker = UnopenedPanel
    , timeflow = UnopenedPanel
    }



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


view : Model -> Browser.Document Msg
view { replica, temp } =
    let
        activePage =
            case ( temp.viewState.taskList, temp.viewState.timeflow, temp.viewState.timeTracker ) of
                ( OpenPanel _ subState, _, _ ) ->
                    { title = "Docket - Task List"
                    , body = H.map TaskListMsg (TaskList.view subState replica temp.environment)
                    }

                ( _, OpenPanel _ subState, _ ) ->
                    { title = "Docket - Timeflow"
                    , body =
                        H.map TimeflowMsg (Timeflow.view subState replica temp.environment)
                    }

                ( _, _, OpenPanel _ subState ) ->
                    { title = "Docket Time Tracker"
                    , body =
                        H.map TimeTrackerMsg (TimeTracker.view subState replica temp.environment)
                    }

                _ ->
                    { title = "Multiple Panels Open"
                    , body =
                        H.map TimeflowMsg (Timeflow.view Nothing replica temp.environment)
                    }

        withinPage =
            toUnstyled <|
                H.node "page"
                    []
                    [ activePage.body

                    --, errorList replica.errors
                    ]
    in
    { title = activePage.title
    , body =
        [ globalLayout temp.viewState replica temp.environment withinPage ]
    }


{-|

    selectedTab takes an element and wraps it in a styled container
    to indicate which page is currently active.

    Todo: Consider adding customizable styling for this.

-}
selectedTabs : List ( Bool, Element msg ) -> Element msg
selectedTabs panelStatusAndLinks =
    let
        panelsList =
            List.map applyOpenPanelStyle panelStatusAndLinks

        applyOpenPanelStyle ( isOpen, givenLink ) =
            if isOpen then
                el
                    [ Element.centerY
                    , Element.centerX
                    , Background.color (rgba255 255 255 255 0.3)
                    , height fill
                    , Element.Font.semiBold
                    , Border.rounded 7
                    , Element.paddingXY 10 5
                    ]
                    givenLink

            else
                givenLink
    in
    row [ centerX, Element.spacing 20, height fill, Element.paddingXY 0 5 ]
        panelsList


getPanelViewState : Panel panelState -> panelState -> ( panelState, PanelPosition )
getPanelViewState panel default =
    case panel of
        OpenPanel position state ->
            ( state, position )

        ClosedPanel position state ->
            ( state, position )

        UnopenedPanel ->
            ( default, FullScreen )


globalLayout : ViewState -> Profile -> Environment -> PlainHtml.Html Msg -> PlainHtml.Html Msg
globalLayout viewState replica env innerStuff =
    let
        elmUIOptions =
            { options = [] }

        projectsLink =
            link [ centerX, centerY ] { url = "#/projects", label = text "Projects" }

        readyLink =
            link [ centerX, centerY ] { url = "#/ready", label = text "Ready" }

        timeflowLink =
            link [ centerX, centerY ] { url = "#/timeflow", label = text "Timeflow" }

        timetrackerLink =
            link [ centerX, centerY ] { url = "#/timetracker", label = text "Timetracker" }

        dashLink =
            link [ centerX, centerY ] { url = "#/dash", label = text "Dashboard" }

        isPanelOpen panelStatus =
            case panelStatus of
                OpenPanel _ _ ->
                    True

                _ ->
                    False

        footerLinks =
            selectedTabs
                [ ( isPanelOpen viewState.taskList, projectsLink )
                , ( False, readyLink )
                , ( isPanelOpen viewState.timeflow, timeflowLink )
                , ( isPanelOpen viewState.timeTracker, timetrackerLink )
                , ( False, dashLink )
                ]
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
            , trackingDisplay replica env
            ]


trackingDisplay replica env =
    let
        currentActivity =
            Timeline.currentActivity replica.activities replica.timeline

        latestSwitch =
            -- Log.logMessageOnly ("latest switch at " ++ HumanMoment.toStandardString (Switch.getMoment (Timeline.latestSwitch replica.timeline)))
            Timeline.latestSwitch replica.timeline

        currentInstanceIDMaybe =
            Switch.getInstanceID latestSwitch

        allInstances =
            Profile.instanceListNow replica env

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
    | ClearErrors
    | ThirdPartySync ThirdPartyService
    | ThirdPartyServerResponded ThirdPartyResponse
    | Link Browser.UrlRequest
    | NewUrl Url.Url
    | TaskListMsg TaskList.Msg
    | TimeTrackerMsg TimeTracker.Msg
    | TimeflowMsg Timeflow.Msg



-- | MouseMoved Bool Float


type ThirdPartyService
    = Todoist
    | Marvin


type ThirdPartyResponse
    = TodoistServer Todoist.Msg
    | MarvinServer Marvin.Msg


update : Msg -> Model -> ( List Change.Frame, Temp, Cmd Msg )
update msg { temp, replica, now } =
    let
        viewState =
            temp.viewState

        environment =
            temp.environment

        justRunCommand command =
            ( [], temp, command )

        noOp =
            ( [], temp, Cmd.none )

        justSetEnv newEnv =
            ( [], { temp | environment = newEnv }, Cmd.none )
    in
    case msg of
        NoOp ->
            ( []
            , temp
            , Cmd.none
            )

        ClearErrors ->
            ( []
            , temp
              -- TODO Model viewState { replica | errors = [] } environment
            , Cmd.none
            )

        ThirdPartySync service ->
            case service of
                Todoist ->
                    justRunCommand <|
                        Cmd.map ThirdPartyServerResponded <|
                            Cmd.map TodoistServer <|
                                Integrations.Todoist.fetchUpdates replica.todoist

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
                    Integrations.Todoist.handle response replica

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
            -- TODO Model viewState newAppData environment
            justRunCommand (notify [ notification ])

        ThirdPartyServerResponded (MarvinServer response) ->
            let
                ( newProfile1WithItems, whatHappened, nextStep ) =
                    Marvin.handle (RepDb.size replica.taskClasses + 1000) replica environment response

                newProfile2WithErrors =
                    Profile.saveError replica ("Synced with Marvin: \n" ++ whatHappened)

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
            -- TODO update appdata
            justRunCommand <|
                Cmd.batch
                    [ Cmd.map ThirdPartyServerResponded <| Cmd.map MarvinServer <| nextStep
                    , notify [ notification ]
                    ]

        Link urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    case environment.navkey of
                        Just navkey ->
                            -- in browser
                            justRunCommand <| Nav.pushUrl navkey (Url.toString url)

                        Nothing ->
                            -- running headless
                            noOp

                Browser.External href ->
                    justRunCommand <| Nav.load href

        NewUrl url ->
            let
                effectsAfter =
                    handleUrlTriggers url replica temp

                -- effectsAfterDebug =External.Commands.toast ("got NewUrl: " ++ Url.toString url)
                    
            in
            ( [], {temp | viewState = navigate url }, effectsAfter )

        TaskListMsg subMsg ->
            case subMsg of
                TaskList.MarvinServerResponse subSubMsg ->
                    justRunCommand <| Job.perform (\_ -> ThirdPartyServerResponded (MarvinServer subSubMsg)) (Job.succeed ())

                _ ->
                    let
                        ( oldPanelState, position ) =
                            getPanelViewState viewState.taskList TaskList.defaultView

                        ( newPanelState, newFrame, newCommand ) =
                            TaskList.update subMsg oldPanelState replica environment

                        newViewState =
                            { viewState | taskList = OpenPanel position newPanelState }
                    in
                    ( [ newFrame ]
                    , { temp | viewState = newViewState }
                    , Cmd.map TaskListMsg newCommand
                    )

        TimeTrackerMsg subMsg ->
            let
                ( oldPanelState, position ) =
                    getPanelViewState viewState.timeTracker TimeTracker.defaultView

                ( newFrame, newPanelState, newCommand ) =
                    TimeTracker.update subMsg oldPanelState replica environment

                newViewState =
                    { viewState | timeTracker = OpenPanel position newPanelState }
            in
            ( [ newFrame ]
            , { temp | viewState = newViewState }
            , Cmd.map TimeTrackerMsg newCommand
            )

        TimeflowMsg subMsg ->
            let
                ( panelState, position, initCmdsIfNeeded ) =
                    case viewState.timeflow of
                        OpenPanel oldPosition (Just oldState) ->
                            ( oldState, oldPosition, Cmd.none )

                        ClosedPanel oldPosition (Just oldState) ->
                            ( oldState, oldPosition, Cmd.none )

                        _ ->
                            let
                                ( freshState, initCmds ) =
                                    Timeflow.init replica environment
                            in
                            ( freshState, FullScreen, initCmds )

                ( newFrame, newPanelState, newCommand ) =
                    Timeflow.update subMsg panelState replica environment

                newViewState =
                    { viewState | timeflow = OpenPanel position (Just newPanelState) }
            in
            ( [ newFrame ]
            , { temp | viewState = newViewState }
            , Cmd.map TimeflowMsg (Cmd.batch [ initCmdsIfNeeded, newCommand ])
            )



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


navigate : Url.Url -> ViewState
navigate url =
    let
        finalUrl =
            bypassFakeFragment url
    in
    Maybe.withDefault emptyViewState (P.parse routeParser finalUrl)


routeParser : Parser (ViewState -> a) a
routeParser =
    let
        openTimeTracker : TimeTracker.ViewState -> ViewState
        openTimeTracker subView =
            { emptyViewState | timeTracker = OpenPanel FullScreen subView }

        openTaskList subView =
            { emptyViewState | taskList = OpenPanel FullScreen subView }

        openTimeflow subView =
            { emptyViewState | timeflow = OpenPanel FullScreen subView }
    in
    P.oneOf
        [ P.map openTaskList TaskList.routeView
        , P.map openTimeTracker TimeTracker.routeView
        , P.map openTimeflow Timeflow.routeView
        ]


{-| Turns parts of the URL query into `Cmd`s. to allow us to send `Msg`s from the address bar! Thus our web app should be completely scriptable.
-}
handleUrlTriggers : Url.Url -> Profile -> Temp -> Cmd Msg
handleUrlTriggers rawUrl replica temp =
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
            List.map (wrapMsgs TaskListMsg) (TaskList.urlTriggers replica temp.environment)
                ++ List.map (wrapMsgs TimeTrackerMsg) (TimeTracker.urlTriggers replica)
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
            case temp.environment.navkey of
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
                    Cmd.batch [ Job.perform (\_ -> triggerMsg) (Job.succeed ()), removeTriggersFromUrl ]

                ( Nothing, Just query ) ->
                    let
                        problemText =
                            "Handle URL Triggers: none of  "
                                ++ String.fromInt (List.length parseList)
                                ++ " parsers matched key and value: "
                                ++ query
                    in
                    (-- TODO { model | replica = saveError replica problemText }
                     External.Commands.toast problemText
                    )

                ( Just triggerMsg, Nothing ) ->
                    let
                        problemText =
                            "Handle URL Triggers: impossible situation. No query (Nothing) but we still successfully parsed it!"
                    in
                    (--TODO { model | replica = saveError replica problemText }
                     External.Commands.toast problemText
                    )

                ( Nothing, Nothing ) ->
                    Cmd.none

        Nothing ->
            -- Failed to parse URL Query - was there one?
            case normalizedUrl.query of
                Nothing ->
                    -- Perfectly normal - failed to parse triggers because there were none.
                    Cmd.none

                Just queriesPresent ->
                    -- passed a query that we didn't understand! Fail gracefully
                    let
                        problemText =
                            "URL: not sure what to do with: " ++ queriesPresent ++ ", so I just left it there. Is the trigger misspelled?"
                    in
                    (-- TODO { model | replica = saveError replica problemText }
                     External.Commands.toast problemText
                    )


nerfUrl : Url.Url -> Url.Url
nerfUrl original =
    { original | path = "" }
