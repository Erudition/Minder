port module Main exposing (JsonAppDatabase, Model, Msg(..), PreUpdate(..), Screen(..), ViewState, appDataFromJson, appDataToJson, buildModelFromSaved, buildModelFromScratch, emptyViewState, infoFooter, init, main, setStorage, showPane, subscriptions, update, updateWithStorage, updateWithTime, view)

--import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
--import Time.TimeZones as TimeZones
--import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)

import AppData exposing (..)
import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav exposing (..)
import Environment exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode
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
        , onUrlChange = NewUrl
        , onUrlRequest = Link
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (60 * 1000) MinutePassed


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
    , Cmd.batch [ setStorage (appDataToJson model.appData), cmds ]
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

        -- first get the current time
        Tick submsg ->
            ( model
            , Job.perform (Tock submsg) Time.now
            )

        -- actually do the update
        Tock submsg time ->
            update submsg { model | time = time }

        -- intercept normal update
        otherMsg ->
            updateWithTime (Tick msg) model


type PreUpdate
    = Tick Msg
    | Tock Msg Time.Posix


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

                        Errors errormsgs ->
                            Model { uid = 0, errors = [ errormsgs ], tasks = [] } (Debug.todo "viewUrl" url) (Time.millisToPosix 0) key

                        BadJson ->
                            buildModelFromScratch url key

                -- no json stored at all
                Nothing ->
                    buildModelFromScratch url key

        environment =
            Environment

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
    , environment : Environment
    }


buildModelFromSaved : AppData -> Maybe Decode.Warnings -> Url.Url -> Nav.Key -> Model
buildModelFromSaved savedAppData warnings url key =
    Model { savedAppData | errors = warnings } (Debug.todo "viewUrl" url) (Time.millisToPosix 0) key


buildModelFromScratch : Maybe Decode.Errors -> Url.Url -> Nav.Key -> Model
buildModelFromScratch errors url key =
    Model { uid = 0, errors = [ errors ], tasks = [] } (Debug.todo "viewUrl" url) (Time.millisToPosix 0) key


type alias JsonAppDatabase =
    String


appDataFromJson : JsonAppDatabase -> DecodeResult AppData
appDataFromJson incomingJson =
    Decode.decodeString decodeAppData incomingJson


appDataToJson : AppData -> JsonAppDatabase
appDataToJson appData =
    Encode.encode 0 (encodeAppData appData)


type alias ViewState =
    { primaryView : Screen
    , uid : Int
    }


emptyViewState =
    { primaryView = TaskList "" Nothing }


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
        TaskList _ ->
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
            [ text "(Increasingly more distant) fork of Evan's elm "
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
        env =
            model.env

        setEnv new =
            { model | environment = new }

        setAppData new =
            { model | appData = new }

        updateScreen model_here ( appData, commands ) =
            ( setAppData appData, commands )
    in
    case ( msg, model.viewState.primaryView ) of
        ( NoOp, _ ) ->
            ( model
            , Cmd.none
            )

        ( MinutePassed time, _ ) ->
            ( setEnv { env | time = time }
            , Cmd.none
            )

        ( SetZone zone, _ ) ->
            ( setEnv { env | timeZone = zone }
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
            ( { model | viewState = TaskList (TaskList.Normal "" Nothing) }
            , Cmd.none
            )

        ( TaskListMsg tasklistmsg, TaskList viewState ) ->
            TaskList.update tasklistmsg env model.appData viewState
