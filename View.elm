module View exposing (..)

-- import Html exposing (..)
--import Html.Attributes exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import Json.Decode as Decode
import Model exposing (..)
import Model.Moment exposing (..)
import Model.Progress exposing (..)
import Model.Task exposing (..)
import Time
import Update exposing (..)
import VirtualDom


-- import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
-- --import Time.TimeZones as TimeZones
-- import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)


view : Model -> Html Msg
view model =
    div
        [ class "todomvc-wrapper", style [ ( "visibility", "hidden" ) ] ]
        [ section
            [ class "todoapp" ]
            [ lazy viewInput model.field
            , Html.Styled.Lazy.lazy3 viewTasks model.updateTime model.visibility model.tasks
            , lazy2 viewControls model.visibility model.tasks
            ]
        , infoFooter
        , section [ css [ opacity (num 0.1) ] ]
            [ text (modelToJson model)
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
            , onInput UpdateField
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


viewTasks : Time.Time -> String -> List Task -> VirtualDom.Node Msg
viewTasks time visibility tasks =
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
            List.map (viewKeyedTask time) (List.filter isVisible tasks)
        ]
        |> toUnstyled



-- VIEW INDIVIDUAL ENTRIES


viewKeyedTask : Time.Time -> Task -> ( String, Html Msg )
viewKeyedTask time task =
    ( toString task.id, lazy2 viewTask time task )



-- viewTask : Task -> Html Msg


viewTask : Time.Time -> Task -> VirtualDom.Node Msg
viewTask time task =
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
                    (UpdateProgressPart task.id
                        (if not (completed task) then
                            toFloat <| whole task.completion
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
                [ timingInfo time task ]
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
            , id ("task-" ++ toString task.id)
            , onInput (UpdateTask task.id)
            , onBlur (EditingTask task.id False)
            , onEnter (EditingTask task.id False)
            ]
            []
        , div [ class "task-drawer", Html.Styled.Attributes.hidden False ]
            [ input [ type_ "date", onInput extractDate, pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
            , input [ type_ "date" ] []
            , input [ type_ "date" ] []
            , input [ type_ "date" ] []
            , input [ type_ "date" ] []
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
        , value <| toString <| part task.completion
        , Html.Styled.Attributes.min "0"
        , Html.Styled.Attributes.max <| toString <| whole task.completion
        , step
            (if discrete <| units task.completion then
                "1"
             else
                "any"
            )
        , onInput (extractSliderInput task)
        , onDoubleClick (EditingTask task.id True)
        , onFocus (FocusSlider task.id True)
        , onBlur (FocusSlider task.id False)

        --    , dynamicSliderThumbCss (normalizedPart task.completion)
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
    UpdateProgressPart task.id <| Result.withDefault 0 <| String.toFloat input


timingInfo : Time.Time -> Task -> Html Msg
timingInfo time task =
    case task.deadline of
        Just momentOrDay ->
            text <| describeMomentOrDay time momentOrDay

        Nothing ->
            text ""


extractDate : String -> Msg
extractDate input =
    NoOp



--Date.fromString input
-- VIEW CONTROLS AND FOOTER
-- viewControls : String -> List Task -> Html Msg


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
        [ lazy viewControlsCount tasksLeft
        , lazy viewControlsFilters visibility
        , lazy viewControlsClear tasksCompleted
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
        [ strong [] [ text (toString tasksLeft) ]
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
        [ text ("Clear completed (" ++ toString tasksCompleted ++ ")")
        ]
        |> toUnstyled



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
