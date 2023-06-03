port module Main exposing (FrameworkModel, MainModel, Msg(..), StoredRON, ViewState, emptyViewState, incomingFramesFromElsewhere, infoFooter, init, main, nativeView, navigate, setStorage, subscriptions, update, view)

import Activity.Activity as Activity
import Activity.Session as Session exposing (Session(..))
import Activity.Timeline as Timeline
import Browser
import Browser.Dom exposing (Viewport, getViewport, setViewport)
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import DevTools
import Dict
import Effect
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font
import Element.Input as Input
import External.Commands exposing (..)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as HK
import Html.Styled as SH exposing (Html, li, toUnstyled)
import Html.Styled.Attributes as SHA exposing (class, href)
import Html.Styled.Events as SHE
import Html.Styled.Keyed as SHK
import Incubator.Todoist as Todoist
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Ion.Button
import Ion.Content
import Ion.Icon
import Ion.Item
import Ion.List
import Ion.Menu
import Ion.Tab
import Ion.Toolbar
import Json.Decode as JD
import Json.Decode.Exploration exposing (..)
import Json.Encode as JE
import List.Nonempty exposing (Nonempty(..))
import Log
import Native exposing (Native)
import Native.Attributes as NA
import Native.Event
import Native.Frame
import Native.Layout as Layout
import Native.Page as Page
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import Popups exposing (Popup)
import Profile exposing (..)
import Replicated.Change as Change exposing (Frame)
import Replicated.Codec
import Replicated.Framework as Framework
import Replicated.Node.Node
import Replicated.Op.OpID
import Replicated.Reducer.RepDb as RepDb
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.Model exposing (..)
import Shared.Msg
import SmartTime.Duration as Duration
import SmartTime.Human.Calendar
import SmartTime.Human.Clock
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment
import SmartTime.Moment as Moment
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.AssignedAction as AssignedAction exposing (AssignedAction)
import TaskList
import TaskPort
import TimeTracker
import Timeflow
import Url
import Url.Parser as P exposing ((</>), Parser)
import Url.Parser.Query as PQ


main : Framework.Program Flags Profile MainModel Msg
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


subscriptions : FrameworkModel -> Sub Msg
subscriptions { replica, temp } =
    Sub.batch <|
        [ -- TODO unsubscribe when not visible
          -- TODO sync subscription with current activity
          --   SmartTime.Human.Moment.everyMinuteOnTheMinute temp.time
          --     temp.timeZone
          --     (\_ -> NoOp)
          -- Debug.log
          -- "starting interval"
          -- (Moment.every Duration.aMinute (\_ -> NoOp))
          Browser.Events.onVisibilityChange VisibilityChanged
        , Browser.Events.onResize (\width height -> ResizeViewport width height)

        -- , storageChangedElsewhere NewAppData
        --, Browser.Events.onMouseMove <| JD.map2 MouseMoved decodeButtons decodeFraction
        --, SmartTime.Human.Moment.everySecondOnTheSecond temp.shared.time (\_ -> NoOp)
        ]
            ++ (case temp.viewState.timeflow of
                    OpenPanel _ (Just subState) ->
                        [ Sub.map TimeflowMsg (Timeflow.subscriptions replica temp.shared subState) ]

                    _ ->
                        []
               )


port incomingFramesFromElsewhere : (String -> msg) -> Sub msg


clearPreferences : TaskPort.Task ()
clearPreferences =
    TaskPort.callNoArgs
        { function = "changePassphrase"
        , valueDecoder = TaskPort.ignoreValue
        }



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


decodeFraction : JD.Decoder Float
decodeFraction =
    JD.map2 (/)
        (JD.field "pageX" JD.float)
        (JD.at [ "currentTarget", "defaultView", "innerWidth" ] JD.float)



{- What happens when the user is dragging, but the "mouse up" occurs outside
   the browser window? We need to stop listening for mouse movement and end the
   drag. We use MouseEvent.buttons to detect this:
       https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/buttons
   The "buttons" value is 1 when "left-click" is pressed, so we use that to
   detect zombie drags.
-}


decodeButtons : JD.Decoder Bool
decodeButtons =
    JD.field "buttons" (JD.map (\buttons -> buttons == 1) JD.int)


port setStorage : String -> Cmd msg


type alias StoredRON =
    String


initGraphical : Url.Url -> Nav.Key -> Flags -> Profile -> ( List Frame, MainModel, Cmd Msg )
initGraphical url key flags =
    init url (Just key) flags


init : Url.Url -> Maybe Nav.Key -> Flags -> Profile -> ( List Frame, MainModel, Cmd Msg )
init url maybeKey flags replica =
    let
        cmdsFromUrl =
            handleUrlTriggers url replica initialMainModel

        ( state, panelOpenCmds ) =
            navigate url

        initialMainModel : MainModel
        initialMainModel =
            { viewState = state
            , shared = initialShared maybeKey flags
            }

        initNotif =
            Job.attempt NotificationScheduled <|
                Notif.dispatch
                    [ Notif.test "We have taken over Android, woo!" ]

        getViewport =
            Job.perform setViewport Browser.Dom.getViewport

        setViewport : Viewport -> Msg
        setViewport newViewport =
            ResizeViewport (truncate newViewport.viewport.width) (truncate newViewport.viewport.height)

        getTimeZone =
            Job.perform NewTimeZone SmartTime.Human.Moment.localZone
    in
    ( []
    , initialMainModel
    , Cmd.batch [ cmdsFromUrl, panelOpenCmds, initNotif, getViewport, getTimeZone ]
    )



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type alias FrameworkModel =
    Framework.Replicator Profile MainModel


type alias MainModel =
    { viewState : ViewState
    , shared : Shared
    }


type NativePage
    = HomePage


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
    , rootFrame : Native.Frame.Model NativePage
    }


emptyViewState : ViewState
emptyViewState =
    { taskList = UnopenedPanel
    , timeTracker = UnopenedPanel
    , timeflow = UnopenedPanel
    , devTools = UnopenedPanel
    , rootFrame = Native.Frame.init HomePage
    }



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


view : FrameworkModel -> Browser.Document Msg
view { replica, temp } =
    let
        openPanels =
            List.filterMap identity
                [ case temp.viewState.taskList of
                    OpenPanel _ state ->
                        Just
                            { title = "Projects"
                            , body = SH.map TaskListMsg (TaskList.view state replica temp.shared)
                            }

                    _ ->
                        Nothing
                , case temp.viewState.timeTracker of
                    OpenPanel _ state ->
                        Just
                            { title = "Time Tracker"
                            , body = SH.map TimeTrackerMsg (TimeTracker.view state replica temp.shared)
                            }

                    _ ->
                        Nothing
                , case temp.viewState.timeflow of
                    OpenPanel _ (Just state) ->
                        Just
                            { title = "Timeflow"
                            , body = SH.map TimeflowMsg (Timeflow.view state replica temp.shared)
                            }

                    _ ->
                        Nothing
                , case temp.viewState.devTools of
                    OpenPanel _ state ->
                        Just
                            { title = "Dev Tools"
                            , body = SH.map DevToolsMsg (DevTools.view state replica temp.shared)
                            }

                    _ ->
                        Nothing
                ]

        finalTitle =
            String.join "/" (List.map .title openPanels)

        withinPage =
            toUnstyled <|
                SH.node "page"
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


globalLayout : MainModel -> Profile -> H.Html Msg -> H.Html Msg
globalLayout model replica innerStuff =
    let
        temp =
            model.shared

        env =
            temp

        viewState =
            model.viewState

        isPanelOpen panelStatus =
            case panelStatus of
                OpenPanel _ _ ->
                    True

                _ ->
                    False

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

        menuItemHref label icon href =
            Ion.Item.item [ Ion.Item.button, HA.href href, Ion.Item.detail False ]
                [ Ion.Item.label [] [ H.text label ]
                , Ion.Icon.withAttr icon [ Ion.Toolbar.placeEnd ]
                ]

        menuItemOnClick label icon clickHandler =
            Ion.Item.item [ Ion.Item.button, HE.onClick clickHandler, Ion.Item.detail False ]
                [ Ion.Item.label [] [ H.text label ]
                , Ion.Icon.withAttr icon [ Ion.Toolbar.placeEnd ]
                ]

        activitySelectOption givenActivity =
            H.node "ion-select-option"
                [ HA.value (Activity.idToString (Activity.getID givenActivity)) ]
                [ H.text <| Activity.getName givenActivity ]
    in
    Ion.Content.appWithAttributes [ HA.classList [ ( "dark", temp.darkThemeActive ) ], HA.id "ion-app" ]
        [ H.div [ HA.class "ion-page", HA.id "main-content" ]
            [ Ion.Toolbar.header [ Ion.Toolbar.translucentOnIos ]
                [ Ion.Toolbar.toolbar []
                    [ Ion.Toolbar.buttons [ Ion.Toolbar.placeStart ]
                        [ Ion.Menu.button [] [] ]
                    , Ion.Toolbar.title [] [ H.text "Minder" ]
                    , Ion.Toolbar.title [ HA.attribute "size" "small" ] [ H.text formattedTime ]
                    , Ion.Toolbar.buttons [ Ion.Toolbar.placeEnd ]
                        [ Ion.Button.button [ HA.disabled True ] [ Ion.Icon.basic "arrow-undo-circle-outline" ]
                        ]
                    ]
                ]
            , Ion.Content.content [ HA.classList [ ( "ion-padding", not (isPanelOpen viewState.timeflow) ) ], HA.attribute "fullscreen" "true", HA.attribute "scrollY" "true" ] [ innerStuff ]
            , Ion.Toolbar.footer [ Ion.Toolbar.translucentOnIos ]
                [ --Ion.Toolbar.title [] [ H.text "Footer" ]
                  tabBar
                , trackingDisplay replica env.time env.launchTime env.timeZone
                ]
            ]
        , Ion.Menu.menu [ Ion.Menu.contentID "main-content", Ion.Menu.overlay ]
            [ Ion.Toolbar.header []
                [ Ion.Toolbar.toolbar []
                    [ Ion.Toolbar.title [] [ H.text "Minder (Alpha)" ]
                    , Ion.Toolbar.buttons [ Ion.Toolbar.placeEnd ]
                        [ Ion.Button.button [ HE.onClick (ToggleDarkTheme (not temp.darkThemeActive)) ] [ Ion.Icon.basic "contrast-outline" ]
                        ]
                    ]
                ]
            , Ion.Content.content []
                [ Ion.List.list []
                    [ menuItemOnClick "Toggle Dark Theme" "contrast-outline" (ToggleDarkTheme (not temp.darkThemeActive))
                    , menuItemHref "Test Marvin Sync" "sync-outline" "?sync=marvin"
                    , menuItemHref "Reload App" "sync-outline" "index.html"
                    , menuItemHref "Installed branch" "sync-outline" "https://localhost/"
                    , menuItemHref "Master branch" "sync-outline" "https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/"
                    , Ion.Item.item [ Ion.Item.button, HE.onClick ClearPreferences, Ion.Item.detail False ]
                        [ Ion.Item.label [] [ H.text "Switch Account" ]
                        , Ion.Icon.withAttr "trash-outline" [ Ion.Toolbar.placeEnd ]
                        ]
                    , Ion.Item.item [ Ion.Item.button, HE.onClick RequestNotificationPermission, Ion.Item.detail False ]
                        [ Ion.Item.label []
                            [ if temp.notifPermission /= Notif.Granted then
                                H.text "Enable Notifications"

                              else
                                H.text "Notifications Enabled"
                            ]
                        , Ion.Icon.withAttr "notifications-outline" [ Ion.Toolbar.placeEnd ]
                        ]
                    ]
                ]
            ]
        , SH.toUnstyled <| viewPopup model replica
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
            List.head (List.filter (\t -> AssignedAction.getID t == currentInstanceID) allInstances)

        timeSinceSession =
            Period.length (Timeline.currentAsPeriod time replica.timeline)

        tracking_for_string thing givenTime =
            "Tracking "
                ++ thing
                ++ " for "
                ++ SmartTime.Human.Duration.singleLetterSpaced [ SmartTime.Human.Duration.inLargestWholeUnits givenTime ]

        trackingTitle =
            case Maybe.andThen currentInstanceMaybe currentInstanceIDMaybe of
                Just trackedAssignment ->
                    AssignedAction.getTitle trackedAssignment

                Nothing ->
                    Activity.getName currentActivity
    in
    -- row
    -- [ width fill
    -- , height (px 30)
    -- , Background.color (rgb 1 1 1)
    -- , behindContent
    --     (row [ width fill, height fill ]
    --         [ el [] <| text "O"
    --         , el [ centerX ] (text (tracking_for_string (AssignedAction.getTitle currentInstance) timeSinceSession))
    --         ]
    --     )
    -- ]
    -- [ trackingTaskCompletionSlider currentInstance ]
    Ion.Toolbar.toolbar []
        [ H.node "ion-progress-bar" [] []
        , Ion.Toolbar.title [] [ H.text <| tracking_for_string trackingTitle timeSinceSession ]
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
                    [ Element.width (fillPortion (AssignedAction.getCompletionInt instance))
                    , Element.height fill
                    , Element.centerY
                    , Background.color (Element.rgba 0 1 0 0.5)
                    , Border.rounded 2
                    ]
                    Element.none
                , Element.el
                    [ Element.width (fillPortion (AssignedAction.getProgressMaxInt instance - AssignedAction.getCompletionInt instance))
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
        , max = toFloat <| AssignedAction.getProgressMaxInt instance
        , step = Just 1
        , value = toFloat (AssignedAction.getCompletionInt instance)
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
    SH.footer [ class "info" ]
        [ SH.p []
            [ SH.text "Switch to: "
            , SH.a [ href "/tasks" ] [ SH.text "Task List" ]
            , SH.text " ➖ "
            , SH.a [ href "/timetracker" ] [ SH.text "Time Tracker" ]
            , SH.text " ➖ "
            , SH.a [ href "/timeflow" ] [ SH.text "Timeflow" ]
            , SH.text " ➖ "
            , SH.a [ href "?sync=marvin" ] [ SH.text "Sync Marvin" ]
            ]
        , SH.p []
            [ SH.text "Written by "
            , SH.a [ href "https://github.com/Erudition" ] [ SH.text "Erudition" ]
            ]
        , SH.p []
            [ SH.text "(Increasingly more distant) fork of Evan's elm "
            , SH.a [ href "http://todomvc.com" ] [ SH.text "TodoMVC" ]
            ]
        ]


viewPopup : MainModel -> Profile -> SH.Html Msg
viewPopup temp profile =
    let
        outerShell innerStuff =
            [ SH.node "ion-header"
                [ SHA.id "ion-modal-header" ]
                [ SH.node "ion-toolbar"
                    []
                    [ SH.node "ion-buttons"
                        [ SHA.attribute "slot" "start" ]
                        [ SH.node "ion-button"
                            [ SHA.attribute "color" "medium"
                            , SHE.onClick (RunEffects [ Effect.ClosePopup ])
                            ]
                            [ SH.text "Close" ]
                        ]
                    , SH.node "ion-title" [] [ SH.text "Modal test" ]
                    , SH.node "ion-buttons"
                        [ SHA.attribute "slot" "end" ]
                        [ SH.node "ion-button" [ SHA.attribute "strong" "true", SHE.onClick (RunEffects [ Effect.ClosePopup, Effect.Toast "Pretended to Save Changes!" ]) ] [ SH.text "Confirm" ]
                        ]
                    ]
                ]
            , SH.node "ion-content"
                [ class "ion-padding" ]
                innerStuff

            -- [ SH.node "ion-item" [] [ SH.node "ion-input" [ SHA.type_ "text", SHA.attribute "label-placement" "stacked", SHA.attribute "label" "Task Title", SHA.placeholder "New Task Title Here" ] [] ]
            -- ]
            ]

        isOpen =
            case temp.shared.modal of
                Just popup ->
                    True

                Nothing ->
                    False

        contents =
            case temp.shared.modal of
                Just popup ->
                    outerShell
                        [ Popups.viewPopup popup
                            |> SH.fromUnstyled
                            |> SH.map PopupMsg
                        ]

                Nothing ->
                    outerShell []
    in
    SH.node "ion-modal"
        [ SHA.property "isOpen" (JE.bool isOpen)
        , SHE.on "didDismiss" <| JD.succeed (RunEffects [ Effect.ClosePopup ])
        ]
        [ SH.div [ SHA.class "ion-delegate-host", SHA.class "ion-page" ] contents ]



-- NATIVESCRIPT VIEWS


homePage : FrameworkModel -> Native Msg
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


getPage : FrameworkModel -> NativePage -> Native Msg
getPage model page =
    case page of
        HomePage ->
            homePage model


nativeView : FrameworkModel -> H.Html Msg
nativeView model =
    model.temp.viewState.rootFrame
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
    | RunEffects (List (Effect.Effect Msg))
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
    | NotificationScheduled (TaskPort.Result String)
    | ClearPreferences
    | RequestNotificationPermission
    | GotNotificationPermissionStatus (TaskPort.Result Notif.PermissionStatus)
    | OpenPopup Popup
    | ClosePopup
    | PopupMsg Popups.Msg


type ThirdPartyService
    = Todoist
    | Marvin


type ThirdPartyResponse
    = TodoistServer Todoist.Msg
    | MarvinServer Marvin.Msg


update : Msg -> FrameworkModel -> ( List Change.Frame, MainModel, Cmd Msg )
update msg ({ replica } as frameworkModel) =
    let
        shared =
            let
                oldShared =
                    frameworkModel.temp.shared
            in
            { oldShared | time = frameworkModel.now }

        viewState =
            frameworkModel.temp.viewState

        unchangedMainModel =
            { viewState = viewState, shared = shared }

        justRunCommand command =
            ( [], unchangedMainModel, command )

        justSetShared newShared =
            ( [], { viewState = viewState, shared = newShared }, Cmd.none )

        setSharedAndCmd newShared cmd =
            ( [], { viewState = viewState, shared = newShared }, cmd )

        justSetViewState newViewState =
            ( [], { viewState = newViewState, shared = shared }, Cmd.none )

        setViewStateAndCmd newViewState cmd =
            ( [], { viewState = newViewState, shared = shared }, cmd )

        noOp =
            ( [], { viewState = viewState, shared = shared }, Cmd.none )
    in
    case msg of
        RunEffects effects ->
            let
                ( effectFrames, newShared, effectCmds ) =
                    Effect.perform (\_ -> NoOp) shared replica effects
            in
            ( effectFrames
            , { unchangedMainModel | shared = newShared }
            , effectCmds
            )

        OpenPopup popup ->
            justSetShared { shared | modal = Just popup }

        ClosePopup ->
            justSetShared { shared | modal = Nothing }

        PopupMsg popupMsg ->
            case shared.modal of
                Just (Popups.Form popupModel) ->
                    let
                        outModel =
                            Popups.update popupMsg popupModel
                    in
                    justSetShared { shared | modal = Just (Popups.Form outModel) }

                _ ->
                    noOp

        NotificationScheduled response ->
            noOp

        NewTimeZone zone ->
            justSetShared { shared | timeZone = zone }

        ResizeViewport newWidth newHeight ->
            setSharedAndCmd { shared | viewportSize = { height = newHeight, width = newWidth }, viewportSizeClass = (Element.classifyDevice { height = newHeight, width = newWidth }).class }
                (Cmd.map TimeflowMsg Timeflow.resizeCmd)

        VisibilityChanged newVisibility ->
            setSharedAndCmd { shared | windowVisibility = newVisibility }
                (Cmd.map TimeflowMsg Timeflow.resizeCmd)

        ToggleDarkTheme isDark ->
            justSetShared { shared | darkThemeActive = isDark }

        MouseMoved _ _ ->
            noOp

        NoOp ->
            noOp

        ClearErrors ->
            -- TODO Model viewState { replica | errors = [] } environment
            noOp

        ClearPreferences ->
            justRunCommand <|
                Job.attempt (\_ -> NoOp) <|
                    clearPreferences

        RequestNotificationPermission ->
            justRunCommand <|
                Job.attempt GotNotificationPermissionStatus Notif.requestPermisson

        GotNotificationPermissionStatus result ->
            case result of
                Ok status ->
                    justSetShared { shared | notifPermission = status }

                Err taskPortErr ->
                    Log.logSeparate "taskport error" taskPortErr noOp

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
            , unchangedMainModel
            , Cmd.batch [ notify [ notification ], External.Commands.toast whatHappened ]
            )

        ThirdPartyServerResponded (MarvinServer response) ->
            let
                ( marvinChanges, whatHappened, nextStep ) =
                    Marvin.handle (RepDb.size replica.taskClasses + 1000) replica ( shared.time, shared.timeZone ) response

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
            , unchangedMainModel
            , Cmd.batch
                [ Cmd.map ThirdPartyServerResponded <| Cmd.map MarvinServer <| nextStep
                , notify [ notification ]
                , External.Commands.toast whatHappened
                ]
            )

        Link urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    case shared.navkey of
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
                    handleUrlTriggers url replica unchangedMainModel

                ( newViewState, panelOpenCmds ) =
                    navigate url

                -- effectsAfterDebug =External.Commands.toast ("got NewUrl: " ++ Url.toString url)
            in
            setViewStateAndCmd newViewState (Cmd.batch [ panelOpenCmds, effectsAfter ])

        InternalLink path ->
            case shared.navkey of
                Just navkey ->
                    -- in browser
                    justRunCommand <| Nav.pushUrl navkey path

                Nothing ->
                    -- running headless
                    noOp

        SyncNSFrame bool ->
            justSetViewState { viewState | rootFrame = Native.Frame.handleBack bool viewState.rootFrame }

        TaskListMsg subMsg ->
            case subMsg of
                TaskList.MarvinServerResponse subSubMsg ->
                    justRunCommand <| Job.perform (\_ -> ThirdPartyServerResponded (MarvinServer subSubMsg)) (Job.succeed ())

                _ ->
                    let
                        ( oldPanelState, position ) =
                            getPanelViewState viewState.taskList TaskList.defaultView

                        ( newPanelState, newFrame, outEffects ) =
                            TaskList.update subMsg oldPanelState replica shared

                        newViewState =
                            { viewState | taskList = OpenPanel position newPanelState }

                        ( effectFrames, newShared, effectCmds ) =
                            Effect.perform (\_ -> NoOp) shared replica outEffects
                    in
                    ( newFrame :: effectFrames
                    , { shared = newShared, viewState = newViewState }
                    , effectCmds
                    )

        TimeTrackerMsg subMsg ->
            let
                ( oldPanelState, position ) =
                    getPanelViewState viewState.timeTracker TimeTracker.defaultView

                ( newFrame, newPanelState, newCommand ) =
                    TimeTracker.update subMsg oldPanelState replica ( shared.time, shared.timeZone )

                newViewState =
                    { viewState | timeTracker = OpenPanel position newPanelState }
            in
            ( [ newFrame ]
            , { unchangedMainModel | viewState = newViewState }
            , Cmd.map TimeTrackerMsg newCommand
            )

        TimeflowMsg subMsg ->
            case viewState.timeflow of
                OpenPanel oldPosition (Just oldState) ->
                    let
                        ( newFrame, newPanelState, newCommand ) =
                            Timeflow.update subMsg (Just oldState) replica shared

                        newViewState =
                            { viewState | timeflow = OpenPanel oldPosition (Just newPanelState) }
                    in
                    ( [ newFrame ]
                    , { unchangedMainModel | viewState = newViewState }
                    , Cmd.map TimeflowMsg newCommand
                    )

                OpenPanel oldPosition Nothing ->
                    let
                        ( freshState, initCmds ) =
                            Timeflow.init replica shared

                        newViewState =
                            { viewState | timeflow = OpenPanel oldPosition (Just freshState) }
                    in
                    ( []
                    , { unchangedMainModel | viewState = newViewState }
                    , Cmd.map TimeflowMsg initCmds
                    )

                _ ->
                    noOp

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
                                    DevTools.init replica shared "not wired yet"
                            in
                            ( freshState, FullScreen, initCmds )

                ( newPanelState, newFrame, newCommand ) =
                    DevTools.update subMsg panelState replica shared

                newViewState =
                    { viewState | devTools = OpenPanel position newPanelState }
            in
            ( [ newFrame ]
            , { unchangedMainModel | viewState = newViewState }
            , Cmd.map DevToolsMsg (Cmd.batch [ initCmdsIfNeeded, newCommand ])
            )



-- SharedMsg sharedMsg ->
--     let
--         ( frames, newShared, cmds ) =
--             Effect.update shared replica sharedMsg
--     in
--     ( frames
--     , { unchangedMainModel | shared = newShared }
--     , Cmd.map SharedMsg cmds
--     )
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
                        Just <| Cmd.map TimeflowMsg Timeflow.resizeCmd

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
handleUrlTriggers : Url.Url -> Profile -> MainModel -> Cmd Msg
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
            List.map (wrapMsgs TaskListMsg) (TaskList.urlTriggers replica ( temp.shared.time, temp.shared.timeZone ))
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
            case temp.shared.navkey of
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
