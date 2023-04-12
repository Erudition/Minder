port module Main exposing (Flags, Model, Msg(..), StoredRON, Temp, ViewState, emptyViewState, incomingFramesFromElsewhere, infoFooter, init, main, nativeView, navigate, setStorage, subscriptions, update, view)

import Activity.Activity as Activity
import Activity.Session as Session exposing (Session(..))
import Activity.Timeline as Timeline
import Browser
import Browser.Dom exposing (Viewport, getViewport, setViewport)
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import DevTools
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font
import Element.Input as Input
import Environment exposing (..)
import External.Commands exposing (..)
import Html as PlainHtml
import Html.Attributes as HA
import Html.Events
import Html.Keyed as HK
import Html.Styled as H exposing (Html, li, toUnstyled)
import Html.Styled.Attributes exposing (class, href)
import Html.Styled.Events as HtmlEvents
import Incubator.Todoist as Todoist
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Ion.Button
import Ion.Content
import Ion.Icon
import Ion.Menu
import Ion.Tab
import Ion.Toolbar
import Json.Decode as ClassicDecode
import Json.Decode.Exploration exposing (..)
import List.Nonempty exposing (Nonempty(..))
import Native exposing (Native)
import Native.Attributes as NA
import Native.Event
import Native.Frame
import Native.Layout as Layout
import Native.Page as Page
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import Profile exposing (..)
import Replicated.Change as Change exposing (Frame)
import Replicated.Codec
import Replicated.Framework as Framework
import Replicated.Node.Node
import Replicated.Op.OpID
import Replicated.Reducer.RepDb as RepDb
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration
import SmartTime.Human.Calendar
import SmartTime.Human.Clock
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment
import SmartTime.Moment as Moment
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.AssignedAction as Instance
import TaskList
import TimeTracker
import Timeflow
import Url
import Url.Parser as P exposing ((</>), Parser)
import Url.Parser.Query as PQ


main : Framework.Program Flags Profile Temp Msg
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
        , portIncomingChanges = incomingFramesFromElsewhere
        }


subscriptions : Model -> Sub Msg
subscriptions { replica, temp } =
    Sub.batch <|
        [ -- TODO unsubscribe when not visible
          -- TODO sync subscription with current activity
          --   SmartTime.Human.Moment.everyMinuteOnTheMinute temp.environment.time
          --     temp.environment.timeZone
          --     (\_ -> NoOp)
          -- Debug.log
          -- "starting interval"
          -- (Moment.every Duration.aMinute (\_ -> NoOp))
          Browser.Events.onVisibilityChange VisibilityChanged
        , Browser.Events.onResize (\width height -> ResizeViewport width height)

        -- , storageChangedElsewhere NewAppData
        , Browser.Events.onMouseMove <| ClassicDecode.map2 MouseMoved decodeButtons decodeFraction

        -- , Moment.every (Duration.fromSeconds (1/5)) (\_ -> NoOp)
        , SmartTime.Human.Moment.everySecondOnTheSecond temp.environment.time (\_ -> NoOp)
        ]
            ++ (case temp.viewState.timeflow of
                    OpenPanel _ (Just subState) ->
                        [ Sub.map TimeflowMsg (Timeflow.subscriptions replica temp.environment subState) ]

                    _ ->
                        []
               )


port incomingFramesFromElsewhere : (String -> msg) -> Sub msg



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


type alias StoredRON =
    String


type alias Flags =
    { darkTheme : Bool }


initGraphical : Url.Url -> Nav.Key -> Flags -> Profile -> ( List Frame, Temp, Cmd Msg )
initGraphical url key flags =
    init url (Just key) flags


init : Url.Url -> Maybe Nav.Key -> Flags -> Profile -> ( List Frame, Temp, Cmd Msg )
init url maybeKey flags replica =
    let
        cmdsFromUrl =
            handleUrlTriggers url replica initialTemp

        ( state, panelOpenCmds ) =
            navigate url

        initialTemp : Temp
        initialTemp =
            { viewState = state
            , environment = Environment.preInit maybeKey
            , rootFrame = Native.Frame.init HomePage
            , viewportSize = { width = 0, height = 0 }
            , viewportSizeClass = Element.Phone
            , windowVisibility = Browser.Events.Visible
            , darkTheme = flags.darkTheme
            }

        initNotif =
            [ Notif.test "We have taken over Android, woo!" ]
                |> NativeScript.Commands.notify

        getViewport =
            Job.perform setViewport Browser.Dom.getViewport

        setViewport : Viewport -> Msg
        setViewport newViewport =
            ResizeViewport (truncate newViewport.viewport.width) (truncate newViewport.viewport.height)

        getTimeZone =
            Job.perform NewTimeZone SmartTime.Human.Moment.localZone
    in
    ( []
    , initialTemp
    , Cmd.batch [ cmdsFromUrl, panelOpenCmds, initNotif, getViewport, getTimeZone ]
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
    , rootFrame : Native.Frame.Model NativePage
    , viewportSize : { width : Int, height : Int }
    , viewportSizeClass : Element.DeviceClass
    , windowVisibility : Browser.Events.Visibility
    , darkTheme : Bool
    }


type NativePage
    = HomePage


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
    , devTools : Panel DevTools.ViewState
    }


emptyViewState : ViewState
emptyViewState =
    { taskList = UnopenedPanel
    , timeTracker = UnopenedPanel
    , timeflow = UnopenedPanel
    , devTools = UnopenedPanel
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
        openPanels =
            List.filterMap identity
                [ case temp.viewState.taskList of
                    OpenPanel _ state ->
                        Just
                            { title = "Projects"
                            , body = H.map TaskListMsg (TaskList.view state replica temp.environment)
                            }

                    _ ->
                        Nothing
                , case temp.viewState.timeTracker of
                    OpenPanel _ state ->
                        Just
                            { title = "Time Tracker"
                            , body = H.map TimeTrackerMsg (TimeTracker.view state replica temp.environment)
                            }

                    _ ->
                        Nothing
                , case temp.viewState.timeflow of
                    OpenPanel _ (Just state) ->
                        Just
                            { title = "Timeflow"
                            , body = H.map TimeflowMsg (Timeflow.view state replica temp.environment)
                            }

                    _ ->
                        Nothing
                , case temp.viewState.devTools of
                    OpenPanel _ state ->
                        Just
                            { title = "Dev Tools"
                            , body = H.map DevToolsMsg (DevTools.view state replica temp.environment)
                            }

                    _ ->
                        Nothing
                ]

        finalTitle =
            String.join "/" (List.map .title openPanels)

        withinPage =
            toUnstyled <|
                H.node "page"
                    []
                    (List.map .body openPanels)
    in
    { title = finalTitle
    , body =
        [ globalLayout temp replica withinPage ]
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


globalLayout : Temp -> Profile -> PlainHtml.Html Msg -> PlainHtml.Html Msg
globalLayout temp replica innerStuff =
    let
        env =
            temp.environment

        viewState =
            temp.viewState

        elmUIOptions =
            { options = [] }

        projectsLink =
            link [ centerX, centerY, Element.Events.onClick (TaskListMsg TaskList.NoOp) ] { url = "#/projects", label = text "Projects" }

        readyLink =
            link [ centerX, centerY ] { url = "#/ready", label = text "Ready" }

        timeflowLink =
            link [ centerX, centerY ] { url = "#/timeflow", label = text "Timeflow" }

        timetrackerLink =
            link [ centerX, centerY ] { url = "#/timetracker", label = text "Timetracker" }

        dashLink =
            link [ centerX, centerY ] { url = "#/dash", label = text "Dashboard" }

        devToolsLink =
            link [ centerX, centerY ] { url = "#/devtools", label = text "Dev" }

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
                , ( isPanelOpen viewState.devTools, devToolsLink )
                ]

        tabBar =
            HK.node "ion-tab-bar"
                [ HA.style "width" "100%" ]
                [ ( "home-tab-button", Ion.Tab.labeledIconButton [ HA.disabled True ] "Home" "albums-outline" )
                , ( "cares-tab-button", Ion.Tab.labeledIconButton [ HA.disabled True ] "Cares" "heart-circle-outline" )
                , ( "projects-tab-button", Ion.Tab.labeledIconButton [ HA.href "#/projects", HA.selected (isPanelOpen viewState.taskList) ] "Projects" "list-outline" )
                , ( "timeflow-tab-button", Ion.Tab.labeledIconButton [ HA.href "#/timeflow", HA.selected (isPanelOpen viewState.timeflow) ] "Timeflow" "hourglass-outline" )
                , ( "timetracker-tab-button", Ion.Tab.labeledIconButton [ HA.href "#/timetracker", HA.selected (isPanelOpen viewState.timeTracker) ] "Activities" "stopwatch-outline" )
                , ( "dev-tab-button", Ion.Tab.labeledIconButton [ HA.href "#/devtools", HA.selected (isPanelOpen viewState.devTools) ] "Dev" "code-working-outline" )
                ]

        formattedTime =
            let
                ( calendarDate, timeOfDay ) =
                    SmartTime.Human.Moment.humanize env.timeZone env.time
            in
            String.concat
                [ SmartTime.Human.Calendar.toStandardString calendarDate
                , " @ "
                , SmartTime.Human.Clock.toStandardString timeOfDay
                ]
    in
    Ion.Content.appWithAttributes [ HA.classList [ ( "dark", temp.darkTheme ) ], HA.id "ion-app" ]
        [ PlainHtml.div [ HA.class "ion-page", HA.id "main-content" ]
            [ Ion.Toolbar.header [ Ion.Toolbar.translucentOnIos ]
                [ Ion.Toolbar.toolbar []
                    [ Ion.Toolbar.buttons [ Ion.Toolbar.placeStart ]
                        [ Ion.Menu.button [] [] ]
                    , Ion.Toolbar.title [] [ PlainHtml.text "Minder" ]
                    , Ion.Toolbar.title [] [ PlainHtml.text formattedTime ]
                    , Ion.Toolbar.buttons [ Ion.Toolbar.placeEnd ]
                        [ Ion.Button.button [ HA.href "?sync=marvin" ] [ Ion.Icon.basic "sync-outline" ]
                        ]
                    ]
                ]
            , Ion.Content.content [ HA.class "ion-padding", HA.id "page-viewport", HA.attribute "fullscreen" "true", HA.attribute "scrollY" "true" ] [ innerStuff ]
            , Ion.Toolbar.footer [ Ion.Toolbar.translucentOnIos ]
                [ --Ion.Toolbar.title [] [ PlainHtml.text "Footer" ]
                  tabBar
                , trackingDisplay replica env.time env.launchTime env.timeZone
                ]
            ]
        , Ion.Menu.menu [ Ion.Menu.contentID "main-content", Ion.Menu.push ]
            [ Ion.Toolbar.header []
                [ Ion.Toolbar.toolbar []
                    [ Ion.Toolbar.title [] [ PlainHtml.text "Minder (Alpha)" ]
                    , Ion.Toolbar.buttons [ Ion.Toolbar.placeEnd ]
                        [ Ion.Button.button [ HA.href "?sync=marvin" ] [ Ion.Icon.basic "sync-outline" ]
                        , Ion.Button.button [ Html.Events.onClick (ToggleDarkTheme (not temp.darkTheme)) ] [ Ion.Icon.basic "contrast-outline" ]
                        ]
                    ]
                ]
            , Ion.Content.content [ HA.class "ion-padding" ] [ PlainHtml.text "menu " ]
            ]
        ]


trackingDisplay replica time launchTime timeZone =
    let
        currentActivity =
            Timeline.currentActivity replica.activities replica.timeline

        currentInstanceIDMaybe =
            Timeline.currentInstanceID replica.timeline

        allInstances =
            Profile.instanceListNow replica ( launchTime, timeZone )

        currentInstanceMaybe currentInstanceID =
            List.head (List.filter (\t -> Instance.getID t == currentInstanceID) allInstances)

        timeSinceSession =
            Period.length (Timeline.currentAsPeriod time replica.timeline)

        tracking_for_string thing givenTime =
            "Tracking "
                ++ thing
                ++ " for "
                ++ SmartTime.Human.Duration.singleLetterSpaced [ SmartTime.Human.Duration.inLargestWholeUnits givenTime ]
    in
    -- row
    -- [ width fill
    -- , height (px 30)
    -- , Background.color (rgb 1 1 1)
    -- , behindContent
    --     (row [ width fill, height fill ]
    --         [ el [] <| text "O"
    --         , el [ centerX ] (text (tracking_for_string (Instance.getTitle currentInstance) timeSinceSession))
    --         ]
    --     )
    -- ]
    -- [ trackingTaskCompletionSlider currentInstance ]
    Ion.Toolbar.toolbar []
        [ Ion.Toolbar.title [] [ PlainHtml.text <| tracking_for_string (Activity.getName currentActivity) timeSinceSession ]
        , Ion.Button.button [ Ion.Toolbar.placeEnd ] [ Ion.Icon.basic "stop-circle-outline" ]
        ]


trackingTaskCompletionSlider instance =
    let
        _ =
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


homePage : Model -> Native Msg
homePage { replica } =
    Page.pageWithActionBar SyncNSFrame
        []
        (Native.actionBar [ NA.title "Minder" ]
            [ Native.navigationButton [ NA.text "Back" ] []
            , Native.actionItem [ NA.text "Marvin", Native.Event.onTap (ThirdPartySync Marvin) ] []
            ]
        )
        (Layout.flexboxLayout
            [ NA.alignItems "center"
            , NA.justifyContent "center"
            , NA.height "100%"
            ]
            [ Native.label [ NA.text "Log", NA.textWrap "true" ] []
            , logList replica
            ]
        )


logList : Profile -> Native Msg
logList replica =
    Native.scrollView [ NA.orientation "vertical" ] <|
        Layout.stackLayout [] <|
            List.map logItem (RepList.listValues replica.errors)


logItem : String -> Native Msg
logItem logString =
    Native.label [ NA.text logString, NA.textWrap "true" ] []


getPage : Model -> NativePage -> Native Msg
getPage model page =
    case page of
        HomePage ->
            homePage model


nativeView : Model -> PlainHtml.Html Msg
nativeView model =
    model.temp.rootFrame
        |> Native.Frame.view [] (getPage model)



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
    | InternalLink String
    | SyncNSFrame Bool
    | TaskListMsg TaskList.Msg
    | TimeTrackerMsg TimeTracker.Msg
    | TimeflowMsg Timeflow.Msg
    | DevToolsMsg DevTools.Msg
    | MouseMoved Bool Float
    | ResizeViewport Int Int
    | VisibilityChanged Browser.Events.Visibility
    | NewTimeZone SmartTime.Human.Moment.Zone
    | ToggleDarkTheme Bool


type ThirdPartyService
    = Todoist
    | Marvin


type ThirdPartyResponse
    = TodoistServer Todoist.Msg
    | MarvinServer Marvin.Msg


update : Msg -> Model -> ( List Change.Frame, Temp, Cmd Msg )
update msg { temp, replica, now } =
    let
        newTemp =
            { temp | environment = environment }

        viewState =
            temp.viewState

        environment =
            let
                oldEnv =
                    temp.environment
            in
            { oldEnv | time = now }

        justRunCommand command =
            ( [], newTemp, command )

        noOp =
            ( [], temp, Cmd.none )

        justSetEnv newEnv =
            ( [], { temp | environment = newEnv }, Cmd.none )
    in
    case msg of
        NewTimeZone zone ->
            justSetEnv { environment | timeZone = zone }

        ResizeViewport newWidth newHeight ->
            ( []
            , { newTemp | viewportSize = { height = newHeight, width = newWidth }, viewportSizeClass = (Element.classifyDevice { height = newHeight, width = newWidth }).class }
            , Cmd.none
            )

        VisibilityChanged newVisibility ->
            ( []
            , { newTemp | windowVisibility = newVisibility }
            , Cmd.none
            )

        ToggleDarkTheme isDark ->
            ( []
            , { newTemp | darkTheme = isDark }
            , Cmd.none
            )

        MouseMoved _ _ ->
            ( []
            , newTemp
            , Cmd.none
            )

        NoOp ->
            ( []
            , newTemp
            , Cmd.none
            )

        ClearErrors ->
            ( []
            , newTemp
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
                ( marvinChangeFrame, whatHappened ) =
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
            ( [ marvinChangeFrame ]
            , newTemp
            , Cmd.batch [ notify [ notification ], External.Commands.toast whatHappened ]
            )

        ThirdPartyServerResponded (MarvinServer response) ->
            let
                ( marvinChanges, whatHappened, nextStep ) =
                    Marvin.handle (RepDb.size replica.taskClasses + 1000) replica ( environment.time, environment.timeZone ) response

                _ =
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
            ( [ marvinChanges, Change.saveChanges "Log it temporarily" [ Profile.saveError replica ("Synced with Marvin: \n" ++ whatHappened) ] ]
            , newTemp
            , Cmd.batch
                [ Cmd.map ThirdPartyServerResponded <| Cmd.map MarvinServer <| nextStep
                , notify [ notification ]
                , External.Commands.toast whatHappened
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
                            noOp

                Browser.External href ->
                    justRunCommand <| Nav.load href

        NewUrl url ->
            let
                effectsAfter =
                    handleUrlTriggers url replica temp

                ( newViewState, panelOpenCmds ) =
                    navigate url

                -- effectsAfterDebug =External.Commands.toast ("got NewUrl: " ++ Url.toString url)
            in
            ( [], { newTemp | viewState = newViewState }, Cmd.batch [ panelOpenCmds, effectsAfter ] )

        InternalLink path ->
            case environment.navkey of
                Just navkey ->
                    -- in browser
                    justRunCommand <| Nav.pushUrl navkey path

                Nothing ->
                    -- running headless
                    noOp

        SyncNSFrame bool ->
            ( [], { newTemp | rootFrame = Native.Frame.handleBack bool temp.rootFrame }, Cmd.none )

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
                    , { newTemp | viewState = newViewState }
                    , Cmd.map TaskListMsg newCommand
                    )

        TimeTrackerMsg subMsg ->
            let
                ( oldPanelState, position ) =
                    getPanelViewState viewState.timeTracker TimeTracker.defaultView

                ( newFrame, newPanelState, newCommand ) =
                    TimeTracker.update subMsg oldPanelState replica ( environment.time, environment.timeZone )

                newViewState =
                    { viewState | timeTracker = OpenPanel position newPanelState }
            in
            ( [ newFrame ]
            , { newTemp | viewState = newViewState }
            , Cmd.map TimeTrackerMsg newCommand
            )

        TimeflowMsg subMsg ->
            let
                ( panelState, position, initCmdIfNeeded ) =
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
                    Timeflow.update subMsg (Just panelState) replica environment

                newViewState =
                    { viewState | timeflow = OpenPanel position (Just newPanelState) }
            in
            ( [ newFrame ]
            , { newTemp | viewState = newViewState }
            , Cmd.map TimeflowMsg (Cmd.batch [ initCmdIfNeeded, newCommand ])
            )

        DevToolsMsg subMsg ->
            let
                ( panelState, position, initCmdsIfNeeded ) =
                    case viewState.devTools of
                        OpenPanel oldPosition oldState ->
                            ( oldState, oldPosition, Cmd.none )

                        ClosedPanel oldPosition oldState ->
                            ( oldState, oldPosition, Cmd.none )

                        _ ->
                            let
                                ( freshState, initCmds ) =
                                    DevTools.init replica environment "not wired yet"
                            in
                            ( freshState, FullScreen, initCmds )

                ( newPanelState, newFrame, newCommand ) =
                    DevTools.update subMsg panelState replica environment

                newViewState =
                    { viewState | devTools = OpenPanel position newPanelState }
            in
            ( [ newFrame ]
            , { newTemp | viewState = newViewState }
            , Cmd.map DevToolsMsg (Cmd.batch [ initCmdsIfNeeded, newCommand ])
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
    -- case Maybe.map String.uncons url.fragment of
    --     -- only if "#" is immediately followed by a "/" (path)
    --     Just (Just ( '/', fakeFragment )) ->
    --         -- take the url and drop the first "#", then re-parse it
    --         case String.split "#" (Url.toString url) of
    --             _ :: afterFragment ->
    --                 -- Url.fromString can fail, but it shouldn't here
    --                 Maybe.withDefault url <|
    --                     -- include all the rest
    --                     Url.fromString (String.concat afterFragment)
    --             _ ->
    --                 url
    --     _ ->
    --         url
    { protocol = url.protocol
    , host = url.host
    , port_ = url.port_
    , path = Maybe.withDefault "/" url.fragment
    , query = url.query
    , fragment = Nothing
    }


navigate : Url.Url -> ( ViewState, Cmd Msg )
navigate url =
    let
        finalUrl =
            bypassFakeFragment url

        finalViewState =
            Maybe.withDefault emptyViewState (P.parse routeParser finalUrl)

        panelOpenCmds =
            List.filterMap identity
                [ case finalViewState.timeflow of
                    OpenPanel _ _ ->
                        Just <| Job.perform (\_ -> TimeflowMsg Timeflow.Refresh) (Job.succeed ())

                    _ ->
                        Nothing
                ]
    in
    ( finalViewState, Cmd.batch panelOpenCmds )


routeParser : Parser (ViewState -> a) a
routeParser =
    let
        openTimeTracker : TimeTracker.ViewState -> ViewState
        openTimeTracker subView =
            { emptyViewState | timeTracker = OpenPanel FullScreen subView }

        openTaskList subView =
            { emptyViewState | taskList = OpenPanel FullScreen subView }

        openTimeflow subViewMaybe =
            { emptyViewState | timeflow = OpenPanel FullScreen subViewMaybe }

        openDevTools subView =
            { emptyViewState | devTools = OpenPanel FullScreen subView }
    in
    P.oneOf
        [ P.map openTaskList TaskList.routeView
        , P.map openTimeTracker TimeTracker.routeView
        , P.map openTimeflow Timeflow.routeView
        , P.map openDevTools DevTools.routeView
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
        _ =
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
            List.map (wrapMsgs TaskListMsg) (TaskList.urlTriggers replica ( temp.environment.time, temp.environment.timeZone ))
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

                ( Just _, Nothing ) ->
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
