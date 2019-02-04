port module Docket exposing (init, main, setStorage, subscriptions, updateWithStorage, updateWithTime)

--import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
--import Time.TimeZones as TimeZones
--import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav exposing (..)
import Html.Styled exposing (..)
import Model exposing (..)
import Model.Progress exposing (..)
import Model.Task exposing (..)
import Model.TaskMoment exposing (..)
import Task as Job
import Time
import Update exposing (..)
import Url
import View exposing (..)


main : Program (Maybe ModelAsJson) Model Msg
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


port setStorage : ModelAsJson -> Cmd msg


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
    , Cmd.batch [ setStorage (modelToJson newModel), cmds ]
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
init : Maybe ModelAsJson -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeModelAsJson url key =
    let
        startingModel =
            case maybeModelAsJson of
                Just modelAsJson ->
                    case modelFromJson modelAsJson navkey of
                        Ok restoredModel ->
                            { restoredModel | navkey = key }

                        Err errormsg ->
                            { emptyModel | errors = [ Debug.log "Errors" errormsg ], navkey = key }

                -- no json stored at all
                Nothing ->
                    emptyModel

        effects =
            [ Job.perform MinutePassed Time.now ]
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
Intentionally minimal - we originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is completed", all stored in App "Database").
-}
type alias Model =
    { appData : AppData
    , viewState : ViewState
    , updateTime : Time.Posix
    , navkey : Nav.Key
    }


type alias ModelAsJson =
    String


modelFromJson : ModelAsJson -> Nav.Key -> DecodeResult Model
modelFromJson incomingJson navkey =
    Decode.decodeString (decodeModel navkey) incomingJson


modelToJson : Model -> ModelAsJson
modelToJson model =
    Encode.encode 0 (encodeModel model)



-- buildModel : Nav.Key -> Model
-- buildModel key =
--     { tasks = []
--     , field = ""
--     , uid = 0
--     , errors = []
--     , updateTime = millisToPosix 0
--     , viewState = emptyViewState
--     , navkey = key
--     }


{-| TODO will be UUIDs. Was going to have a user ID (for multi-user one day) and a device ID, but instead we can just have one UUID for every instance out there and determine who owns it when needed.
-}
type alias Instance =
    Int


type alias AppData =
    { tasks : List Task
    , uid : Instance
    , errors : List String
    }


decodeAppData =
    Decode.map7 AppData
        (field "tasks" (Decode.list decodeTask))
        (field "field" Decode.string)
        (field "uid" Decode.int)
        (field "errors" (Decode.list Decode.string))
        (field "updateTime" decodeMoment)


encodeAppData : Model -> Encode.Value
encodeAppData record =
    Encode.object
        [ ( "tasks", Encode.list encodeTask record.tasks )
        , ( "field", Encode.string record.field )
        , ( "uid", Encode.int record.uid )
        , ( "errors", Encode.list Encode.string record.errors )
        , ( "updateTime", encodeMoment record.updateTime )
        ]



{--Due to the disappointingly un-automated nature of uncustomized Decoders and Encoders in Elm (and the current auto-generators out there being broken for many types), they must be written out by hand for every data type of our app (since all of our app's data will be ported out, and Elm doesn't support porting out even it's own Union types). To make sure we don't forget to update the coders (hard) whenever we change our model (easy), we shall always put them directly below the corresponding type definition. For example:

type Widget = ...
encodeWidget = ...
decodeWidget = ...

Using that nomenclature. Don't change Widget without updating the decoder!
--}


emptyAppData : AppData
emptyAppData =
    { tasks = [], uid = 0, errors = [] }


type alias ViewState =
    { pane : Pane
    , uid : Int
    }


emptyViewState =
    { pane = TaskList "" Nothing AllTasks }


type Pane
    = TaskList TextboxContents (Maybe ExpandedTask) TaskListFilter


type alias ExpandedTask =
    TaskId


type alias TextboxContents =
    String



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
    , body = viewTaskList model
    }



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
      -- | Tick Msg
      -- | Tock Msg Moment
    | UpdateField String
    | EditingTask TaskId Bool
    | UpdateTask TaskId String
    | Add
    | Delete TaskId
    | DeleteComplete
    | UpdateProgressPortion TaskId Portion
    | CheckAll Progress
    | ChangeVisibility String
    | FocusSlider TaskId Bool
    | MinutePassed Moment
    | UpdateTaskDate TaskId String TaskMoment
    | Link Browser.UrlRequest
    | NewUrl Url.Url



-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        -- Tick msg ->
        --     ( model
        --     , Cmd.none
        --     )
        --
        -- Tock msg time ->
        --     ( model
        --     , Cmd.none
        --     )
        Add ->
            ( { model
                | uid = model.uid + 1
                , field = ""
                , tasks =
                    if String.isEmpty model.field then
                        model.tasks

                    else
                        model.tasks ++ [ newTask model.field model.uid ]
              }
            , Cmd.none
            )

        UpdateField str ->
            ( { model | field = str }
            , Cmd.none
            )

        EditingTask id isEditing ->
            let
                updateTask t =
                    if t.id == id then
                        { t | editing = isEditing }

                    else
                        t

                focus =
                    Dom.focus ("task-" ++ String.fromInt id)
            in
            ( { model | tasks = List.map updateTask model.tasks }
            , Job.attempt (\_ -> NoOp) focus
            )

        UpdateTask id task ->
            let
                updateTask t =
                    if t.id == id then
                        { t | title = task }

                    else
                        t
            in
            ( { model | tasks = List.map updateTask model.tasks }
            , Cmd.none
            )

        UpdateTaskDate id field date ->
            let
                updateTask t =
                    if t.id == id then
                        { t | deadline = date }

                    else
                        t
            in
            ( { model | tasks = List.map updateTask model.tasks }
            , Cmd.none
            )

        Delete id ->
            ( { model | tasks = List.filter (\t -> t.id /= id) model.tasks }
            , Cmd.none
            )

        DeleteComplete ->
            ( { model | tasks = List.filter (not << completed) model.tasks }
            , Cmd.none
            )

        UpdateProgressPortion id new_completion ->
            let
                updateTask t =
                    if t.id == id then
                        { t | completion = ( new_completion, getUnits t.completion ) }

                    else
                        t
            in
            ( { model | tasks = List.map updateTask model.tasks }
            , Cmd.none
            )

        CheckAll newCompletion ->
            let
                updateTask t =
                    { t | completion = newCompletion }
            in
            ( { model | tasks = List.map updateTask model.tasks }
            , Cmd.none
            )

        ChangeVisibility visibility ->
            ( { model | visibility = visibility }
            , Cmd.none
            )

        FocusSlider task focused ->
            ( model
            , Cmd.none
            )

        MinutePassed time ->
            ( { model | updateTime = time }
            , Cmd.none
            )

        Link urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navkey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        -- TODO Change model state based on url
        NewUrl url ->
            ( { model | viewState = TaskList Nothing }
            , Cmd.none
            )
