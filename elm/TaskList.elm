module TaskList exposing (ExpandedTask, Msg(..), TaskListFilter(..), TextboxContents, ViewState(..), dynamicSliderThumbCss, extractDate, extractSliderInput, onEnter, progressSlider, timingInfo, update, view, viewControls, viewControlsClear, viewControlsCount, viewControlsFilters, viewInput, viewKeyedTask, viewTask, viewTasks, visibilitySwap)

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
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
import Task as Job
import Task.Progress exposing (..)
import Task.Task exposing (..)
import Task.TaskMoment exposing (..)
import Time
import VirtualDom



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type TaskListFilter
    = AllTasks
    | ActiveTasksOnly
    | CompletedTasksOnly



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type ViewState
    = TextboxContents (Maybe ExpandedTask) TaskListFilter


type alias ExpandedTask =
    TaskId


type alias TextboxContents =
    String


view model =
    div
        [ class "todomvc-wrapper", style [ ( "visibility", "hidden" ) ] ]
        [ section
            [ class "todoapp" ]
            [ lazy viewInput model.field
            , Html.Styled.Lazy.lazy3 viewTasks model.updateTime model.visibility model.tasks
            , lazy2 viewControls model.visibility model.tasks
            ]
        , section [ css [ opacity (num 0.1) ] ]
            [ text "Everything working well?"
            ]
        ]



-- viewInput : String -> Html Msg


viewInput : String -> VirtualDom.Node Msg
viewInput task =
    header
        [ class "header" ]
        [ h1 [] [ text "docket" ]
        , input
            [ class "new-task"
            , placeholder "What needs to be done?"
            , autofocus True
            , value task
            , name "newTask"
            , onInput UpdateNewEntryField
            , onEnter Add
            ]
            []
        ]
        |> toUnstyled


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Decode.succeed msg

            else
                Decode.fail "not ENTER"
    in
    on "keydown" (Decode.andThen isEnter keyCode)



-- VIEW ALL TODOS
-- viewTasks : String -> List Task -> Html Msg


viewTasks : Moment -> String -> List Task -> VirtualDom.Node Msg
viewTasks now visibility tasks =
    let
        isVisible task =
            case visibility of
                "Completed" ->
                    completed task

                "Active" ->
                    not (completed task)

                _ ->
                    True

        allCompleted =
            List.all completed tasks

        cssVisibility =
            if List.isEmpty tasks then
                "hidden"

            else
                "visible"
    in
    section
        [ class "main"
        , style [ ( "visibility", cssVisibility ) ]
        ]
        [ input
            [ class "toggle-all"
            , type_ "checkbox"
            , name "toggle"
            , Html.Styled.Attributes.checked allCompleted
            , onClick
                (CheckAll
                    (if not allCompleted then
                        progressFromFloat 1

                     else
                        progressFromFloat 0
                    )
                )
            ]
            []
        , label
            [ for "toggle-all" ]
            [ text "Mark all as complete" ]
        , Keyed.ul [ class "task-list" ] <|
            List.map (viewKeyedTask now) (List.filter isVisible tasks)
        ]
        |> toUnstyled



-- VIEW INDIVIDUAL ENTRIES


viewKeyedTask : Moment -> Task -> ( String, Html Msg )
viewKeyedTask now task =
    ( String.fromInt task.id, lazy2 viewTask now task )



-- viewTask : Task -> Html Msg


viewTask : Moment -> Task -> VirtualDom.Node Msg
viewTask now task =
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
                            0
                        )
                    )
                ]
                []
            , label
                [ onDoubleClick (EditingTask task.id True), onClick (FocusSlider task.id True) ]
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
            , onBlur (EditingTask task.id False)
            , onEnter (EditingTask task.id False)
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
        |> toUnstyled


{-| This slider is an html input type=range so it does most of the work for us. (It's accessible, works with arrow keys, etc.) No need to make our own ad-hoc solution! We theme it to look less like a form control, and become the background of our Task entry.
-}
progressSlider : Task -> Html Msg
progressSlider task =
    input
        [ class "task-progress"
        , type_ "range"
        , value <| String.fromInt <| getPortion task.completion
        , Html.Styled.Attributes.min "0"
        , Html.Styled.Attributes.max <| String.fromInt <| getWhole task.completion
        , step
            (if isDiscrete <| getUnits task.completion then
                "1"

             else
                "any"
            )
        , onInput (extractSliderInput task)
        , onDoubleClick (EditingTask task.id True)
        , onFocus (FocusSlider task.id True)
        , onBlur (FocusSlider task.id False)
        , dynamicSliderThumbCss (getNormalizedPortion task.completion)
        ]
        []


{-| The Slider has a thumb control that we push outside of the box, and shape it kinda like a pin, like the text selector on Android. Unfortunately, it expects the track to have side margins, so it only bumps up against the edges and doesn't line up with the actual progress since the track has been stretched to not have these standard margins.

Rather than force the thumb to push past the walls, I came up with this cool-looking way to warp the tip of the pin to always line up correctly. The pin is rotated more or less than the original 45deg (center) based on the progress being more or less than 50%.

Also, since this caused the thumb to appear to float a few pixels higher when at extreme rotations, I added a small linear offset to make it line up better. This is technically still wrong, TODO it should be a trigonometric offset (sin/cos) since rotation is causing the need for it.

-}
dynamicSliderThumbCss : Float -> Attribute msg
dynamicSliderThumbCss portion =
    let
        ( angle, offset ) =
            ( portion * -90, abs ((portion - 0.5) * 5) )
    in
    css [ focus [ pseudoElement "-moz-range-thumb" [ transforms [ translateY (px (-50 + offset)), rotate (deg angle) ] ] ] ]


extractSliderInput : Task -> String -> Msg
extractSliderInput task input =
    UpdateProgress task.id <| Result.withDefault 0 <| String.toFloat input


{-| Human-friendly text in a task summarizing the various TaskMoments (e.g. the due date)
TODO currently only captures deadline
TODO doesn't specify "ago", "in", etc.
-}
timingInfo : Time.Posix -> Task -> Html Msg
timingInfo time task =
    text <| describeTaskMoment time task.deadline


{-| Get the date out of a date input.
TODO handle LocalMoments and UniversalMoments
TODO handle times
-}
extractDate : TaskId -> String -> String -> Msg
extractDate task field input =
    case Date.fromIsoString input of
        Ok date ->
            UpdateTaskDate task field (LocalDate date)

        Err msg ->
            NoOp


{-| VIEW CONTROLS AND FOOTER
-- viewControls : String -> List Task -> Html Msg
-}
viewControls : String -> List Task -> VirtualDom.Node Msg
viewControls visibility tasks =
    let
        tasksCompleted =
            List.length (List.filter completed tasks)

        tasksLeft =
            List.length tasks - tasksCompleted
    in
    footer
        [ class "footer"
        , Html.Styled.Attributes.hidden (List.isEmpty tasks)
        ]
        [ Html.Styled.Lazy.lazy viewControlsCount tasksLeft
        , Html.Styled.Lazy.lazy viewControlsFilters visibility
        , Html.Styled.Lazy.lazy viewControlsClear tasksCompleted
        ]
        |> toUnstyled


viewControlsCount : number -> VirtualDom.Node msg



-- viewControlsCount : Int -> VirtualDom.Node msg


viewControlsCount tasksLeft =
    let
        item_ =
            if tasksLeft == 1 then
                " item"

            else
                " items"
    in
    span
        [ class "task-count" ]
        [ strong [] [ text (String.fromInt tasksLeft) ]
        , text (item_ ++ " left")
        ]
        |> toUnstyled


viewControlsFilters : String -> VirtualDom.Node Msg



-- viewControlsFilters : String -> VirtualDom.Node Msg


viewControlsFilters visibility =
    ul
        [ class "filters" ]
        [ visibilitySwap "#/" "All" visibility
        , text " "
        , visibilitySwap "#/active" "Active" visibility
        , text " "
        , visibilitySwap "#/completed" "Completed" visibility
        ]
        |> toUnstyled


visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
    li
        [ onClick (ChangeVisibility visibility) ]
        [ a [ href uri, classList [ ( "selected", visibility == actualVisibility ) ] ]
            [ text visibility ]
        ]



-- viewControlsClear : Int -> VirtualDom.Node Msg


viewControlsClear : number -> VirtualDom.Node Msg
viewControlsClear tasksCompleted =
    button
        [ class "clear-completed"
        , Html.Styled.Attributes.hidden (tasksCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ String.fromInt tasksCompleted ++ ")")
        ]
        |> toUnstyled



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = EditingTask TaskId Bool
    | UpdateTask TaskId String
    | Add
    | Delete TaskId
    | DeleteComplete
    | UpdateProgress TaskId Progress
    | CheckAll Progress
    | ChangeVisibility String
    | FocusSlider TaskId Bool
    | UpdateTaskDate TaskId String TaskMoment
    | UpdateNewEntryField String
    | NoOp


update : Msg -> AppData -> ViewState -> Environment -> ( AppData, Cmd Msg )
update msg model viewState env =
    case msg of
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

        UpdateNewEntryField str ->
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
                    Browser.Dom.focus ("task-" ++ String.fromInt id)
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

        UpdateProgress id new_completion ->
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

        NoOp ->
            ( model
            , Cmd.none
            )
