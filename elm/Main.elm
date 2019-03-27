port module Main exposing (AppData, ExpandedTask, Instance, JsonAppDatabase, Model, Msg(..), Pane(..), TextboxContents, ViewState, appDataFromJson, appDataToJson, decodeAppData, emptyAppData, emptyViewState, encodeAppData, infoFooter, init, main, setStorage, subscriptions, update, updateWithStorage, updateWithTime, view)

--import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
--import Time.TimeZones as TimeZones
--import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)

import AppData exposing (..)
import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav exposing (..)
import Environment exposing (..)
import Html.Styled exposing (..)
import Task as Job
import Task.Progress exposing (..)
import Task.TaskMoment exposing (..)
import TaskList
import Time
import Url


main : Program (Maybe JsonAppDatabase) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.minute MinutePassed


port setStorage : JsonAppDatabase -> Cmd msg


{-| We want to `setStorage` on every update. This function adds the setStorage
command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            updateWithTime msg model
    in
    ( newModel
    , Cmd.batch [ setStorage (appDataToJson newModel), cmds ]
    )


{-| Slips in before the real `update` function to pass in the current time.

For bookkeeping purposes, we want the current time for pretty much every update. This function intercepts the `update` process by first updating our model's `time` field before passing our Msg along to the real `update` function, which can then assume `model.time` is an up-to-date value.

(Since Elm is pure and Time is side-effect-y, there's no better way to do this.)
<https://stackoverflow.com/a/41025989/8645412>

-}
updateWithTime : Msg -> Model -> ( Model, Cmd Msg )
updateWithTime msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        Tick msg ->
            ( model
            , Job.perform (Tock msg) Time.now
            )

        Tock msg time ->
            update msg { model | updateTime = time }

        otherMsg ->
            updateWithTime (Tick msg) model


{-| TODO: The "ModelAsJson" could be a whole slew of flags instead.
Key and URL also need to be fed into the model.
-}
init : Maybe JsonAppDatabase -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeJson url key =
    let
        startingModel =
            case maybeJson of
                Just jsonAppDatabase ->
                    case appDataFromJson jsonAppDatabase of
                        Success savedAppData ->
                            buildModelFromSaved savedAppData environment

                        WithWarnings warnings savedAppData ->
                            buildModelFromSaved savedAppData url key

                        Errors errors ->
                            buildModelFromScratch url key

                        BadJson errormsg ->
                            Model { uid = 0, errors = [ errormsg ], tasks = [] } (viewUrl url) (Time.millisToPosix 0) key

                -- no json stored at all
                Nothing ->
                    emptyModel

        environment =
            Client

        effects =
            [ Job.perform MinutePassed Time.now
            , Job.perform SetZone Time.here
            ]
    in
    ( startingModel
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
    { appData : AppData
    , viewState : ViewState
    , client : Client
    }


buildModelFromSaved : AppData -> Maybe Decode.Warnings -> Url.Url -> Nav.Key -> Model
buildModelFromSaved savedAppData warnings url key =
    Model { savedAppData | errors = warnings } (viewUrl url) (Time.millisToPosix 0) key


buildModelFromScratch : Maybe Decode.Errors -> Url.Url -> Nav.Key -> Model
buildModelFromScratch errors url key =
    Model { uid = 0, errors = [ errors ], tasks = [] } (viewUrl url) (Time.millisToPosix 0) key


type alias JsonAppDatabase =
    String


appDataFromJson : JsonAppDatabase -> DecodeResult AppData
appDataFromJson incomingJson =
    Decode.decodeString decodeAppData incomingJson


appDataToJson : Model -> JsonAppDatabase
appDataToJson model =
    Encode.encode 0 (encodeModel model)


type alias ViewState =
    { primaryView : Screen
    , uid : Int
    }


emptyViewState =
    { primaryView = TaskList "" Nothing AllTasks }


type Screen
    = TaskList TaskList.ViewState
    | TimeTracker
    | Calendar
    | Preferences



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


view : Model -> Browser.Document Msg
view model =
    { title = "Docket"
    , body = showPane model
    }


showPane model =
    case model.viewState.pane of
        TaskList _ _ _ ->
            TaskList.view model



-- myStyle = (style, "color:red")
--
-- div [(att1, "hi"), (att2, "yo"), (myStyle completion)] [nodes]
--
-- <div att1="hi" att2="yo">nodes</div>


infoFooter : Html msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text "Double-click to edit a task" ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/Erudition" ] [ text "Connor" ]
            ]
        , p []
            [ text "Fork of Evan's elm "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]



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
    | MinutePassed Moment
    | SetZone Time.Zone
    | Link Browser.UrlRequest
    | NewUrl Url.Url
    | TaskListMsg TaskList.Msg



-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        client =
            model.client

        setClient new =
            { model | client = new }

        setAppData new =
            { model | appData = new }

        updateScreen model ( appData, commands ) =
            ( setAppData model appData, commands )
    in
    case ( msg, model.viewState.primaryView ) of
        ( NoOp, _ ) ->
            ( model
            , Cmd.none
            )

        ( MinutePassed time, _ ) ->
            ( setClient { client | updateTime = time }
            , Cmd.none
            )

        ( SetZone zone, _ ) ->
            ( setClient { client | timeZone = zone }
            , Cmd.none
            )

        ( Link urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navkey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        -- TODO Change model state based on url
        ( NewUrl url, _ ) ->
            ( { model | viewState = TaskList Nothing }
            , Cmd.none
            )

        ( TaskListMsg tasklistmsg, TaskList viewState ) ->
            TaskList.update tasklistmsg client model.appData viewState
