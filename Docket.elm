port module Docket exposing (..)

-- core libraries
import Dom
import List
import Css exposing (..)
import VirtualDom

-- import Html exposing (..)
import Html.Styled exposing (..)
--import Html.Attributes exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import Json.Decode as Decode
import Json.Encode as Encode
import String
import Task as Job

--community libraries
--import Time.DateTime as Moment exposing (DateTime, dateTime, year, month, day, hour, minute, second, millisecond)
--import Time.TimeZones as TimeZones
--import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)

-- ours
import Porting exposing (..)
import Model exposing (..)
import Model.Progress exposing (..)


{-- IMPORT HANDLING
    Section where we massage imports to be the way we like
--}


type alias ModelAsJson = String

main : Program (Maybe ModelAsJson) Model Msg
main =
    Html.Styled.programWithFlags
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = \_ -> Sub.none
        }


-- main : Program Model Msg
-- main =
--     Html.program
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = \_ -> Sub.none
--         }


port setStorage : ModelAsJson -> Cmd msg


{-| We want to `setStorage` on every update. This function adds the setStorage
command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
    in
    ( newModel
    , Cmd.batch [ setStorage (modelToJson newModel), cmds ]
    )



-- MODEL
-- The full application state of our todo app.


-- Entire program



-- initialize model
init : Maybe ModelAsJson -> ( Model, Cmd Msg )
init maybeModelAsJson =
  let finalModel =
      case maybeModelAsJson of
          Just modelAsJson ->
              case modelFromJson modelAsJson of
                  Ok restoredModel ->
                      restoredModel

                  Err errormsg ->
                      { emptyModel | errors = [(Debug.log "Errors" errormsg)] }

          -- no json stored at all
          Nothing ->
              emptyModel
  in
      finalModel ! []


modelFromJson : ModelAsJson -> Result String Model
modelFromJson incomingJson =
  Decode.decodeString decodeModel incomingJson

modelToJson : Model -> ModelAsJson
modelToJson model =
    Encode.encode 0 (encodeModel model)


-- adroit's helper functions
completed : Task -> Bool
completed task =
    part (.completion task) == toFloat ( whole (.completion task))




-- UPDATE -------------------- UPDATE -------------------- UPDATE -------------------- UPDATE


{-| Users of our app can trigger messages by clicking and typing. These
messages are fed into the `update` function as they occur, letting us react
to them.
-}

type Msg
    = NoOp
    | UpdateField String
    | EditingTask TaskId Bool
    | UpdateTask TaskId String
    | Add
    | Delete TaskId
    | DeleteComplete
    | UpdateProgressPart TaskId Part
    | CheckAll Progress
    | ChangeVisibility String


-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
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
                        { t | completion = (new_completion, units t.completion)  }
                    else
                        t
            in
            { model | tasks = List.map updateTask model.tasks }
                ! []

        CheckAll completion ->
            let
                updateTask t =
                    { t | completion = completion }
            in
            { model | tasks = List.map updateTask model.tasks }
                ! []

        ChangeVisibility visibility ->
            { model | visibility = visibility }
                ! []



------------------- VIEW ------------------- VIEW ------------------- VIEW ------------------- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "todomvc-wrapper", style [ ( "visibility", "hidden" ) ]]
        [ section
            [ class "todoapp" ]

            [ lazy viewInput model.field
            , lazy2 viewTasks model.visibility model.tasks
            , lazy2 viewControls model.visibility model.tasks
            ]

        , infoFooter
        , section [css [opacity (num 0.1)]]
            [
              text (modelToJson model)
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
viewTasks : String -> List Task -> VirtualDom.Node Msg
viewTasks visibility tasks =
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
            List.map viewKeyedTask (List.filter isVisible tasks)
        ]
    |> toUnstyled



-- VIEW INDIVIDUAL ENTRIES


viewKeyedTask : Task -> ( String, Html Msg )
viewKeyedTask task =
    ( toString task.id, lazy viewTask task )


-- viewTask : Task -> Html Msg
viewTask : Task -> VirtualDom.Node Msg
viewTask task =
    li
        [ classList [ ( "completed", completed task ), ( "editing", task.editing ) ] ]
        [ input
            [ class "task-progress"
            , type_ "range"
            , value <| toString <| part task.completion
            , Html.Styled.Attributes.min "0"
            , Html.Styled.Attributes.max <| toString <| whole task.completion
            , step (if (discrete <| units task.completion) then "1" else "any")
            , onInput (extractSliderInput task)
            , onDoubleClick (EditingTask task.id True)
            , dynamicSliderThumbCss (normalizedPart task.completion)
            ] []
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
                [ onDoubleClick (EditingTask task.id True) ]
                [ text task.title ]
            , button
                [ class "destroy"
                , onClick (Delete task.id)
                ]
                []
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
        ]
    |> toUnstyled

dynamicSliderThumbCss : Float -> Attribute msg
dynamicSliderThumbCss portion =
  let (angle, offset) = (portion * -90, abs ( (portion - 0.5) * 10) )
  in  css [ focus [pseudoElement "-moz-range-thumb" [transforms [translateY (px (-50 + offset)), rotate (deg angle)]]]]

extractSliderInput : Task -> String -> Msg
extractSliderInput task input =
  UpdateProgressPart task.id <| Result.withDefault 0 <| String.toFloat input



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
