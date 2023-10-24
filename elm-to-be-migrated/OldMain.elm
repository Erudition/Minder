port module OldMain exposing (FrameworkModel, MainModel, Msg(..), StoredRON, ViewState, emptyViewState, incomingFramesFromElsewhere, infoFooter, init, main, nativeView, navigate, setStorage, subscriptions, update, view)

import Activity.Activity as Activity
import Activity.HistorySession as HistorySession exposing (HistorySession)
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
import External.Commands exposing (..)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as HK
import Html.Styled as SH exposing (Html, li, toUnstyled)
import Html.Styled.Attributes as SHA exposing (class, href)
import Html.Styled.Events as SHE
import Html.Styled.Keyed as SHK
import Http
import Incubator.Todoist as Todoist
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Ion.ActionSheet as ActionSheet
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
import ML.OnlineChat
import Native exposing (Native)
import Native.Attributes as NA
import Native.Event
import Native.Frame
import Native.Layout as Layout
import Native.Page as Page
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import OldEffect exposing (Effect)
import OldShared.Model exposing (..)
import OldShared.Msg
import Popup.Popups as Popups
import Profile exposing (..)
import Replicated.Change as Change exposing (Frame)
import Replicated.Codec
import Replicated.Framework as Framework
import Replicated.Node.Node
import Replicated.Op.OpID
import Replicated.Reducer.RepDb as RepDb
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.PopupType as PopupType
import SmartTime.Duration as Duration
import SmartTime.Human.Calendar
import SmartTime.Human.Clock
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.Assignment as Assignment exposing (Assignment)
import Task.Layers
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


port incomingFramesFromElsewhere : (String -> msg) -> Sub msg


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
                    [ Notif.test "Minder has launched!" ]

        getViewport =
            Job.perform setViewport Browser.Dom.getViewport

        setViewport : Viewport -> Msg
        setViewport newViewport =
            ResizeViewport (truncate newViewport.viewport.width) (truncate newViewport.viewport.height)

        getTimeZone =
            Job.perform NewTimeZone HumanMoment.localZone
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


type alias ViewState =
    { taskList : Panel TaskList.ViewState
    , timeTracker : Panel TimeTracker.ViewState
    , timeflow : Panel (Maybe Timeflow.ViewState)
    , devTools : Panel DevTools.ViewState
    , rootFrame : Native.Frame.Model NativePage
    , popup : Popups.Model
    }


emptyViewState : ViewState
emptyViewState =
    { taskList = UnopenedPanel
    , timeTracker = UnopenedPanel
    , timeflow = UnopenedPanel
    , devTools = UnopenedPanel
    , rootFrame = Native.Frame.init HomePage
    , popup = Popups.initEmpty
    }



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
    | NewTimeZone Zone
    | ToggleDarkTheme Bool
    | NotificationScheduled (TaskPort.Result String)
    | ClearPreferences
    | RequestNotificationPermission
    | GotNotificationPermissionStatus (TaskPort.Result Notif.PermissionStatus)
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

        justSaveFrames frames =
            ( frames, unchangedMainModel, Cmd.none )

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
                    OldEffect.perform (\_ -> NoOp) shared replica effects
            in
            ( effectFrames
            , { unchangedMainModel | shared = newShared }
            , effectCmds
            )

        PopupMsg popupMsg ->
            let
                ( outModel, outEffects ) =
                    Popups.update popupMsg viewState.popup replica shared

                ( effectFrames, newShared, effectCmds ) =
                    OldEffect.perform (\_ -> NoOp) shared replica (List.map (OldEffect.map PopupMsg) outEffects)

                newViewState =
                    { viewState | popup = outModel }
            in
            ( effectFrames
            , { unchangedMainModel | viewState = newViewState, shared = newShared }
            , effectCmds
            )

        NotificationScheduled response ->
            noOp

        NewTimeZone zone ->
            justSetShared { shared | timeZone = zone, launchTime = frameworkModel.now }

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
                    Marvin.handle replica ( shared.time, shared.timeZone ) response

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

                        ( newPanelState, newFrame, outEffect ) =
                            TaskList.update subMsg oldPanelState replica shared

                        newViewState =
                            { viewState | taskList = OpenPanel position newPanelState }

                        ( effectFrames, newShared, effectCmds ) =
                            OldEffect.perform (\_ -> NoOp) shared replica [ OldEffect.map TaskListMsg outEffect ]
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
