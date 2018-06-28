port module Todo exposing (..)

{-| TodoMVC implemented in Elm, using plain HTML and CSS for rendering.
This application is broken up into three key parts:

1.  Model - a full definition of the application's state
2.  Update - a way to step the application state forward
3.  View - a way to visualize our application state with HTML
    This clean division of concerns is a core part of Elm. You can read more about
    this in <http://guide.elm-lang.org/architecture/index.html>

-}

import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Json.Decode as Json
import String
import Task


main : Program (Maybe Model) Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = \_ -> Sub.none
        }


port setStorage : Model -> Cmd msg


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
    , Cmd.batch [ setStorage newModel, cmds ]
    )



-- MODEL
-- The full application state of our todo app.


type alias Model =
    { todos : List Todo
    , field : String
    , uid : Int
    , visibility : String
    }


type alias Todo =
    { title : String
    , completion : Float
    , editing : Bool
    , id : Int -- make UUID-type?
    , effort : Duration -- make Fuzzy Duration in seconds
    , effortHistory : List ( Date, Duration )
    , subtasks : List Int
    , created : Date
    }


completed : Todo -> Bool
completed todo =
    .completion todo == 1


type TaskListFilter
    = AllTasks
    | ActiveTasksOnly
    | CompletedTasksOnly



type alias UUID= Int

type alias Progress = Float


type alias Duration =
    Int



--seconds


type alias Date =
    Int



--seconds since epoch or something


emptyModel : Model
emptyModel =
    { todos = []
    , visibility = "All"
    , field = ""
    , uid = 0
    }


newTodo : String -> Int -> Todo
newTodo desc id =
    { title = desc
    , editing = False
    , id = id
    , completion = 0
    , created = 0
    , effort = 0
    , effortHistory = []
    , subtasks = []
    }


init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
    Maybe.withDefault emptyModel savedModel ! []



-- UPDATE


{-| Users of our app can trigger messages by clicking and typing. These
messages are fed into the `update` function as they occur, letting us react
to them.
-}
type Msg
    = NoOp
    | UpdateField String
    | EditingTodo Int Bool
    | UpdateTodo Int String
    | Add
    | Delete Int
    | DeleteComplete
    | UpdateProgress UUID Progress
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
                , todos =
                    if String.isEmpty model.field then
                        model.todos
                    else
                        model.todos ++ [ newTodo model.field model.uid ]
            }
                ! []

        UpdateField str ->
            { model | field = str }
                ! []

        EditingTodo id isEditing ->
            let
                updateTodo t =
                    if t.id == id then
                        { t | editing = isEditing }
                    else
                        t

                focus =
                    Dom.focus ("todo-" ++ toString id)
            in
            { model | todos = List.map updateTodo model.todos }
                ! [ Task.attempt (\_ -> NoOp) focus ]

        UpdateTodo id task ->
            let
                updateTodo t =
                    if t.id == id then
                        { t | title = task }
                    else
                        t
            in
            { model | todos = List.map updateTodo model.todos }
                ! []

        Delete id ->
            { model | todos = List.filter (\t -> t.id /= id) model.todos }
                ! []

        DeleteComplete ->
            { model | todos = List.filter (not << completed) model.todos }
                ! []

        UpdateProgress id completion ->
            let
                updateTodo t =
                    if t.id == id then
                        { t | completion = completion }
                    else
                        t
            in
            { model | todos = List.map updateTodo model.todos }
                ! []

        CheckAll completion ->
            let
                updateTodo t =
                    { t | completion = completion }
            in
            { model | todos = List.map updateTodo model.todos }
                ! []

        ChangeVisibility visibility ->
            { model | visibility = visibility }
                ! []



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "todomvc-wrapper"
        , style [ ( "visibility", "hidden" ) ]
        ]
        [ section
            [ class "todoapp" ]
            [ lazy viewInput model.field
            , lazy2 viewTodos model.visibility model.todos
            , lazy2 viewControls model.visibility model.todos
            ]
        , infoFooter
        ]


viewInput : String -> Html Msg
viewInput task =
    header
        [ class "header" ]
        [ h1 [] [ text "docket" ]
        , input
            [ class "new-todo"
            , placeholder "What needs to be done?"
            , autofocus True
            , value task
            , name "newTodo"
            , onInput UpdateField
            , onEnter Add
            ]
            []
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)



-- VIEW ALL TODOS


viewTodos : String -> List Todo -> Html Msg
viewTodos visibility todos =
    let
        isVisible todo =
            case visibility of
                "Completed" ->
                    completed todo

                "Active" ->
                    not (completed todo)

                _ ->
                    True

        allCompleted =
            List.all completed todos

        cssVisibility =
            if List.isEmpty todos then
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
            , checked allCompleted
            , onClick (CheckAll (if (not allCompleted) then 1 else 0 ) )
            ]
            []
        , label
            [ for "toggle-all" ]
            [ text "Mark all as complete" ]
        , Keyed.ul [ class "todo-list" ] <|
            List.map viewKeyedTodo (List.filter isVisible todos)
        ]



-- VIEW INDIVIDUAL ENTRIES


viewKeyedTodo : Todo -> ( String, Html Msg )
viewKeyedTodo todo =
    ( toString todo.id, lazy viewTodo todo )


viewTodo : Todo -> Html Msg
viewTodo todo =
    li
        [ classList [ ( "completed", completed todo ), ( "editing", todo.editing ) ] ]
        [ div
            [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , checked (completed todo)
                , onClick (UpdateProgress todo.id (if not (completed todo) then 1 else 0 ))
                ]
                []
            , label
                [ onDoubleClick (EditingTodo todo.id True) ]
                [ text todo.title ]
            , button
                [ class "destroy"
                , onClick (Delete todo.id)
                ]
                []
            ]
        , input
            [ class "edit"
            , value todo.title
            , name "title"
            , id ("todo-" ++ toString todo.id)
            , onInput (UpdateTodo todo.id)
            , onBlur (EditingTodo todo.id False)
            , onEnter (EditingTodo todo.id False)
            ]
            []
        ]



-- VIEW CONTROLS AND FOOTER


viewControls : String -> List Todo -> Html Msg
viewControls visibility todos =
    let
        todosCompleted =
            List.length (List.filter completed todos)

        todosLeft =
            List.length todos - todosCompleted
    in
    footer
        [ class "footer"
        , hidden (List.isEmpty todos)
        ]
        [ lazy viewControlsCount todosLeft
        , lazy viewControlsFilters visibility
        , lazy viewControlsClear todosCompleted
        ]


viewControlsCount : Int -> Html Msg
viewControlsCount todosLeft =
    let
        item_ =
            if todosLeft == 1 then
                " item"
            else
                " items"
    in
    span
        [ class "todo-count" ]
        [ strong [] [ text (toString todosLeft) ]
        , text (item_ ++ " left")
        ]


viewControlsFilters : String -> Html Msg
viewControlsFilters visibility =
    ul
        [ class "filters" ]
        [ visibilitySwap "#/" "All" visibility
        , text " "
        , visibilitySwap "#/active" "Active" visibility
        , text " "
        , visibilitySwap "#/completed" "Completed" visibility
        ]


visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
    li
        [ onClick (ChangeVisibility visibility) ]
        [ a [ href uri, classList [ ( "selected", visibility == actualVisibility ) ] ]
            [ text visibility ]
        ]


viewControlsClear : Int -> Html Msg
viewControlsClear todosCompleted =
    button
        [ class "clear-completed"
        , hidden (todosCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ toString todosCompleted ++ ")")
        ]


infoFooter : Html msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text "Double-click to edit a todo" ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/Erudition" ] [ text "Connor" ]
            ]
        , p []
            [ text "Fork of Evan's elm "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]
