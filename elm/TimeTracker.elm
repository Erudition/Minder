module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, update, view, viewActivities, viewActivity, viewKeyedActivity)

import Activity exposing (..)
import AppData exposing (..)
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Environment exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
import Task as Job
import Time
import Url.Parser as P exposing ((</>), Parser, fragment, int, map, oneOf, s, string)
import VirtualDom



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type ViewState
    = Normal



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


routeView : Parser (ViewState -> a) a
routeView =
    P.map (Normal (s "timetracker"))


defaultView : ViewState
defaultView =
    Normal


view : ViewState -> AppData -> Environment -> Html Msg
view state app env =
    case state of
        Normal ->
            div
                [ class "todomvc-wrapper", css [ visibility Css.hidden ] ]
                [ section
                    [ class "todoapp" ]
                    [ lazy3 viewActivities env app
                    ]
                , section [ css [ opacity (num 0.1) ] ]
                    [ text "Quite Ambitious."
                    ]
                ]


viewActivities : Environment -> AppData -> Html Msg
viewActivities env app =
    let
        isVisible task =
            case filter of
                CompleteTasksOnly ->
                    completed task

                IncompleteTasksOnly ->
                    not (completed task)

                _ ->
                    True

        allCompleted =
            List.all completed tasks
    in
    section
        [ class "main" ]
        [ input
            [ class "toggle-all"
            , type_ "checkbox"
            , name "toggle"
            , Html.Styled.Attributes.checked allCompleted
            ]
            []
        , label
            [ for "toggle-all" ]
            [ text "Mark all as complete" ]
        , Keyed.ul [ class "task-list" ] <|
            List.map (viewKeyedTask now) (List.filter isVisible tasks)
        ]



-- VIEW INDIVIDUAL ENTRIES


viewKeyedActivity : Environment -> Activity -> ( String, Html Msg )
viewKeyedActivity env activity =
    ( String.fromInt activity.id, lazy2 viewActivity env activity )



-- viewTask : Task -> Html Msg


viewActivity : Environment -> Activity -> Html Msg
viewActivity env activity =
    li
        [ class "task-entry", classList [ ( "completed", completed task ), ( "editing", task.editing ) ] ]
        [ progressSlider task
        , div
            [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , Html.Styled.Attributes.checked (completed task)
                , onClick
                    (UpdateProgress task.id
                        (if not (completed task) then
                            maximize task.completion

                         else
                            setPortion task.completion 0
                        )
                    )
                ]
                []
            , label
                [ onDoubleClick (EditingTitle task.id True), onClick (FocusSlider task.id True) ]
                [ text task.title ]
            , div
                [ class "timing-info" ]
                [ timingInfo now task ]
            , button
                [ class "destroy"
                , onClick (Delete task.id)
                ]
                [ text "×" ]
            ]
        , input
            [ class "edit"
            , value task.title
            , name "title"
            , id ("task-" ++ String.fromInt task.id)
            , onInput (UpdateTask task.id)
            , onBlur (EditingTitle task.id False)
            , onEnter (EditingTitle task.id False)
            ]
            []
        , div [ class "task-drawer", Html.Styled.Attributes.hidden False ]
            [ label [ for "readyDate" ] [ text "Ready" ]
            , input [ type_ "date", name "readyDate", onInput (extractDate task.id "Ready"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
            , label [ for "startDate" ] [ text "Start" ]
            , input [ type_ "date", name "startDate", onInput (extractDate task.id "Start"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
            , label [ for "finishDate" ] [ text "Finish" ]
            , input [ type_ "date", name "finishDate", onInput (extractDate task.id "Finish"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
            , label [ for "deadlineDate" ] [ text "Deadline" ]
            , input [ type_ "date", name "deadlineDate", onInput (extractDate task.id "Deadline"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
            , label [ for "expiresDate" ] [ text "Expires" ]
            , input [ type_ "date", name "expiresDate", onInput (extractDate task.id "Expires"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
            ]
        ]



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = EditingTitle ActivityId Bool
    | UpdateTask ActivityId String
    | Add
    | Delete ActivityId
    | DeleteComplete
    | UpdateProgress ActivityId Progress
    | FocusSlider ActivityId Bool
    | UpdateTaskDate ActivityId String TaskMoment
    | UpdateNewEntryField String
    | NoOp


update : Msg -> ViewState -> AppData -> Environment -> ( ViewState, AppData, Cmd Msg )
update msg state app env =
    case msg of
        Add ->
            case state of
                Normal filters _ "" ->
                    ( Normal filters Nothing ""
                      -- resets new-entry-textbox to empty, collapses tasks
                    , app
                    , Cmd.none
                    )

                Normal filters _ newTaskTitle ->
                    ( Normal filters Nothing ""
                      -- resets new-entry-textbox to empty, collapses tasks
                    , { app
                        | tasks = app.tasks ++ [ newTask newTaskTitle (Time.posixToMillis env.time) ]
                      }
                      -- now using the creation time as the task ID, for sync
                    , Cmd.none
                    )

        UpdateNewEntryField typedSoFar ->
            ( let
                (Normal filters expanded _) =
                    state
              in
              Normal filters expanded typedSoFar
              -- TODO will collapse expanded tasks. Should it?
            , app
            , Cmd.none
            )

        EditingTitle id isEditing ->
            let
                updateTask t =
                    if t.id == id then
                        { t | editing = isEditing }
                        -- TODO editing should be a viewState thing, not a task prop

                    else
                        t

                focus =
                    Browser.Dom.focus ("task-" ++ String.fromInt id)
            in
            ( state
            , { app | tasks = List.map updateTask app.tasks }
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
            ( state
            , { app | tasks = List.map updateTask app.tasks }
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
            ( state
            , { app | tasks = List.map updateTask app.tasks }
            , Cmd.none
            )

        Delete id ->
            ( state
            , { app | tasks = List.filter (\t -> t.id /= id) app.tasks }
            , Cmd.none
            )

        DeleteComplete ->
            ( state
            , { app | tasks = List.filter (not << completed) app.tasks }
            , Cmd.none
            )

        UpdateProgress id new_completion ->
            let
                updateTask t =
                    if t.id == id then
                        { t | completion = new_completion }

                    else
                        t
            in
            ( state
            , { app | tasks = List.map updateTask app.tasks }
            , Cmd.none
            )

        FocusSlider task focused ->
            ( state
            , app
            , Cmd.none
            )

        NoOp ->
            ( state
            , app
            , Cmd.none
            )
