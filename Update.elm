module Update exposing (..)

import Dom
import Model exposing (..)
import Model.Progress exposing (..)
import Model.Task exposing (..)
import Task as Job
import Time


{-| Users of our app can trigger messages by clicking and typing. These
messages are fed into the `update` function as they occur, letting us react
to them.
-}
type Msg
    = NoOp
    | Tick Msg
    | Tock Msg Time.Time
    | UpdateField String
    | EditingTask TaskId Bool
    | UpdateTask TaskId String
    | Add
    | Delete TaskId
    | DeleteComplete
    | UpdateProgressPart TaskId Part
    | CheckAll Progress
    | ChangeVisibility String
    | FocusSlider TaskId Bool
    | MinutePassed Time.Time



-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Tick msg ->
            model ! []

        Tock msg time ->
            model ! []

        Add ->
            { model
                | uid = model.uid + 1
                , field = ""
                , tasks =
                    if String.isEmpty model.field then
                        model.tasks
                    else
                        model.tasks ++ [ newTask model.field model.uid ]
            }
                ! []

        UpdateField str ->
            { model | field = str }
                ! []

        EditingTask id isEditing ->
            let
                updateTask t =
                    if t.id == id then
                        { t | editing = isEditing }
                    else
                        t

                focus =
                    Dom.focus ("task-" ++ toString id)
            in
            { model | tasks = List.map updateTask model.tasks }
                ! [ Job.attempt (\_ -> NoOp) focus ]

        UpdateTask id task ->
            let
                updateTask t =
                    if t.id == id then
                        { t | title = task }
                    else
                        t
            in
            { model | tasks = List.map updateTask model.tasks }
                ! []

        Delete id ->
            { model | tasks = List.filter (\t -> t.id /= id) model.tasks }
                ! []

        DeleteComplete ->
            { model | tasks = List.filter (not << completed) model.tasks }
                ! []

        UpdateProgressPart id new_completion ->
            let
                updateTask t =
                    if t.id == id then
                        { t | completion = ( new_completion, units t.completion ) }
                    else
                        t
            in
            { model | tasks = List.map updateTask model.tasks }
                ! []

        CheckAll newCompletion ->
            let
                updateTask t =
                    { t | completion = newCompletion }
            in
            { model | tasks = List.map updateTask model.tasks }
                ! []

        ChangeVisibility visibility ->
            { model | visibility = visibility }
                ! []

        FocusSlider task focused ->
            model
                ! []

        MinutePassed time ->
            { model | updateTime = time }
                ! []



-- HELPERS
-- Works on an entire task, not a Progress


completed : Task -> Bool
completed task =
    part (.completion task) == toFloat (whole (.completion task))
