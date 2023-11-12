module Layouts.AppFrame exposing (Model, Msg, Props, layout)

import Activity.Activity as Activity
import Activity.HistorySession as HistorySession exposing (HistorySession)
import Auth
import Browser
import Browser.Dom exposing (Viewport, getViewport, setViewport)
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Dict
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font
import Element.Input as Input
import Html as H exposing (Html)
import Html.Attributes as HA exposing (class)
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
import Layout exposing (Layout)
import List.Nonempty exposing (Nonempty(..))
import Log
import ML.OnlineChat
import NativeScript.Notification as Notif
import Popup.Popups as Popups
import Profile exposing (..)
import Replicated.Change as Change exposing (Frame)
import Replicated.Codec
import Replicated.Node.Node
import Replicated.Op.OpID
import Replicated.Reducer.RepDb as RepDb
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Route exposing (Route)
import Route.Path
import Shared
import Shared.Msg exposing (..)
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
import TaskPort
import Url
import Url.Parser as P exposing ((</>), Parser)
import Url.Parser.Query as PQ
import View exposing (View)


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view shared route
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = JustRunEffects (List (Effect Shared.Msg))
    | EffectsAndLogError (List (Effect Shared.Msg)) String
    | SendSharedMsg Shared.Msg
    | AskAModel
    | HandlePredictionResponse (Result String ML.OnlineChat.Prediction -> Msg) ML.OnlineChat.Prediction


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        JustRunEffects effects ->
            ( model
            , Effect.batch effects
                |> Effect.map SendSharedMsg
            )

        EffectsAndLogError effects errorMessage ->
            -- TODO. shared update?
            ( model
            , Effect.batch effects
                |> Effect.map SendSharedMsg
            )

        SendSharedMsg sharedMsg ->
            ( model
            , Effect.sendMsg sharedMsg
                |> Effect.map SendSharedMsg
            )

        AskAModel ->
            let
                handleDialogResult : Result TaskPort.Error String -> Msg
                handleDialogResult result =
                    case result of
                        Err error ->
                            EffectsAndLogError [ Effect.toast <| TaskPort.errorToString error ] (TaskPort.errorToString error)

                        Ok userInput ->
                            HandlePredictionResponse handlePredictionResponse (ML.OnlineChat.newPrediction userInput)

                handlePredictionResponse : Result String ML.OnlineChat.Prediction -> Msg
                handlePredictionResponse result =
                    case result of
                        Ok predictionSoFar ->
                            if predictionSoFar.done then
                                EffectsAndLogError [ Effect.toast (ML.OnlineChat.resultToString result) ] (ML.OnlineChat.resultToString result)

                            else
                                HandlePredictionResponse handlePredictionResponse predictionSoFar

                        Err problem ->
                            EffectsAndLogError [ Effect.toast problem ] problem
            in
            ( model
            , Effect.dialogPrompt handleDialogResult { title = Just "Ask a model", message = "What would you like to ask a model about?", okButtonTitle = Just "Send", cancelButtonTitle = Nothing, inputPlaceholder = Just "What is the meaning of life?", inputText = Nothing }
            )

        HandlePredictionResponse handler prediction ->
            --TODO just do in shared update?
            ( model
            , Effect.mlPredict handler prediction
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


view : Shared.Model -> Route () -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view sharedModel route { toContentMsg, model, content } =
    let
        htmlListMap htmlList =
            List.map (H.map toContentMsg) htmlList
    in
    { title = content.title
    , body =
        [ globalLayout model sharedModel route content.body toContentMsg
        ]
    }


globalLayout : Model -> Shared.Model -> Route () -> List (H.Html contentMsg) -> (Msg -> contentMsg) -> H.Html contentMsg
globalLayout model shared route bodyContentList toContentMsg =
    let
        formattedTime =
            let
                ( calendarDate, timeOfDay ) =
                    HumanMoment.humanize shared.timeZone shared.time
            in
            String.concat
                [ SmartTime.Human.Calendar.toStandardString calendarDate
                , " @ "
                , SmartTime.Human.Clock.toStandardString timeOfDay
                ]

        activitySelectOption givenActivity =
            H.node "ion-select-option"
                [ HA.value (Activity.idToString (Activity.getID givenActivity)) ]
                [ H.text <| Activity.getName givenActivity ]
    in
    Ion.Content.appWithAttributes [ HA.classList [ ( "dark", shared.darkThemeOn ) ], HA.id "ion-app" ]
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
            , Ion.Content.content [ HA.classList [ ( "ion-padding", not (route.path == Route.Path.Timeflow) ) ], HA.attribute "fullscreen" "true", HA.attribute "scrollY" "true" ] [ H.node "page" [] bodyContentList ]
            , Ion.Toolbar.footer [ Ion.Toolbar.translucentOnIos ]
                [ --Ion.Toolbar.title [] [ H.text "Footer" ]
                  bottomNavTabBar route
                , trackingDisplay shared.replica shared.time shared.launchTime shared.timeZone
                ]
            ]
        , H.map toContentMsg (mainMenu shared)

        --TODO , Popups.popupWrapper model.viewState.popup shared.replica shared |> H.map PopupMsg
        ]


mainMenu shared =
    let
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
    in
    Ion.Menu.menu [ Ion.Menu.contentID "main-content", Ion.Menu.overlay ]
        [ Ion.Toolbar.header []
            [ Ion.Toolbar.toolbar []
                [ Ion.Toolbar.title [] [ H.text "Minder (Alpha)" ]
                , Ion.Toolbar.buttons [ Ion.Toolbar.placeEnd ]
                    [ Ion.Button.button [ HE.onClick (JustRunEffects [ Effect.sendMsg (ToggledDarkTheme (not shared.darkThemeOn)) ]) ] [ Ion.Icon.basic "contrast-outline" ]
                    ]
                ]
            ]
        , Ion.Content.content []
            [ Ion.List.list []
                [ menuItemOnClick "Toggle Dark Theme" "contrast-outline" (SendSharedMsg <| ToggledDarkTheme (not shared.darkThemeOn))
                , Ion.Item.item [ Ion.Item.button, HE.onClick (JustRunEffects [ Effect.syncMarvin ]), Ion.Item.detail False ]
                    [ Ion.Item.label [] [ H.text "Test Marvin Sync" ]
                    , Ion.Icon.withAttr "sync-outline" [ Ion.Toolbar.placeEnd ]
                    ]

                --, menuItemHref "Test Marvin Sync" "sync-outline" "?sync=marvin"
                , menuItemHref "Reload App" "sync-outline" "index.html"
                , menuItemHref "Service worker js file" "sync-outline" "https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/sw.js"
                , menuItemHref "Installed branch" "sync-outline" "https://minder-localhost/fallback.html"
                , menuItemHref "Redirect" "sync-outline" "https://minder-localhost/go-online.html"
                , menuItemHref "Master branch" "sync-outline" "https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/"
                , Ion.Item.item [ Ion.Item.button, HE.onClick (JustRunEffects [ Effect.clearPreferences ]), Ion.Item.detail False ]
                    [ Ion.Item.label [] [ H.text "Switch Account" ]
                    , Ion.Icon.withAttr "trash-outline" [ Ion.Toolbar.placeEnd ]
                    ]
                , Ion.Item.item [ Ion.Item.button, HE.onClick AskAModel, Ion.Item.detail False ]
                    [ Ion.Item.label [] [ H.text "Ask a model" ]
                    , Ion.Icon.withAttr "chatbox-ellipses-outline" [ Ion.Toolbar.placeEnd ]
                    ]
                , Ion.Item.item [ Ion.Item.button, HE.onClick (JustRunEffects [ Effect.requestNotificationPermission ]), Ion.Item.detail False ]
                    [ Ion.Item.label []
                        [ if shared.notifPermission /= Notif.Granted then
                            H.text "Enable Notifications"

                          else
                            H.text "Notifications Enabled"
                        ]
                    , Ion.Icon.withAttr "notifications-outline" [ Ion.Toolbar.placeEnd ]
                    ]
                ]
            ]
        ]


bottomNavTabBar route =
    let
        buttonProps path =
            [ HA.href (Route.Path.toString path), HA.selected (route.path == Route.Path.TaskList) ]
    in
    HK.node "ion-tab-bar"
        [ HA.style "width" "100%" ]
        [ ( "home-tab-button", Ion.Tab.labeledIconButton (buttonProps Route.Path.Home_) "Home" "albums-outline" )
        , ( "cares-tab-button", Ion.Tab.labeledIconButton [ HA.disabled True ] "Cares" "heart-circle-outline" )
        , ( "projects-tab-button", Ion.Tab.labeledIconButton (buttonProps Route.Path.TaskList) "Projects" "list-outline" )
        , ( "timeflow-tab-button", Ion.Tab.labeledIconButton (buttonProps Route.Path.Timeflow) "Timeflow" "hourglass-outline" )
        , ( "timetracker-tab-button", Ion.Tab.labeledIconButton (buttonProps Route.Path.TimeTracker) "Activities" "stopwatch-outline" )
        , ( "dev-tab-button", Ion.Tab.labeledIconButton [ HA.href "#/devtools" ] "Dev" "code-working-outline" )
        ]


trackingDisplay : Profile -> Moment -> Moment -> Zone -> H.Html msg
trackingDisplay replica time launchTime timeZone =
    let
        timeline =
            RepList.listValues replica.timeline

        currentSessionMaybe =
            HistorySession.current timeline

        currentActivityID =
            HistorySession.currentActivityID timeline

        currentActivity =
            Activity.getByID currentActivityID replica.activities

        currentAssignmentIDMaybe =
            HistorySession.currentAssignmentID timeline

        projectLayers =
            -- TODO use from above
            Task.Layers.buildLayerDatabase replica.projects

        currentAssignmentMaybe =
            Maybe.andThen (Task.Layers.getAssignmentByID projectLayers) currentAssignmentIDMaybe

        timeSinceSession =
            Maybe.map (\s -> Period.length (HistorySession.getPeriodWithDefaultEnd time s)) currentSessionMaybe
                |> Maybe.withDefault Duration.zero

        tracking_for_string thing givenTime =
            "Tracking "
                ++ thing
                ++ " for "
                ++ SmartTime.Human.Duration.singleLetterSpaced [ SmartTime.Human.Duration.inLargestWholeUnits givenTime ]

        trackingTitle =
            case currentAssignmentMaybe of
                Just trackedAssignment ->
                    Assignment.title trackedAssignment

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
    --         , el [ centerX ] (text (tracking_for_string (Assignment.getTitle currentInstance) timeSinceSession))
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
                    [ Element.width (fillPortion (Assignment.completion instance))
                    , Element.height fill
                    , Element.centerY
                    , Background.color (Element.rgba 0 1 0 0.5)
                    , Border.rounded 2
                    ]
                    Element.none
                , Element.el
                    [ Element.width (fillPortion (Assignment.progressMaxInt instance - Assignment.completion instance))
                    , Element.height fill
                    , Element.centerY
                    , Background.color (Element.rgba 0 0 0 0)
                    , Border.rounded 2
                    ]
                    Element.none
                ]
            )
        ]
        { onChange = \input -> JustRunEffects [ Effect.saveChanges "Updating Progress" [ Assignment.setCompletion (round input) instance ] ]
        , label =
            Input.labelHidden "Task Progress"
        , min = 0
        , max = toFloat <| Assignment.progressMaxInt instance
        , step = Just 1
        , value = toFloat (Assignment.completion instance)
        , thumb =
            Input.thumb []
        }



-- myStyle = (style, "color:red")
--
-- div [(att1, "hi"), (att2, "yo"), (myStyle completion)] [nodes]
--
-- <div att1="hi" att2="yo">nodes</div>
