module Update exposing (Msg(..), completed, update)

import Browser
import Browser.Dom as Dom
import Model exposing (..)
import Model.Progress exposing (..)
import Model.Task exposing (..)
import Model.TaskMoment exposing (..)
import Browser.Navigation as Nav exposing (..)
import Task as Job
import Time
import Url


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



-- HELPERS
-- Works on an entire task, not a Progress


completed : Task -> Bool
completed task =
    isMax (.completion task)
