port module Todo exposing (..)

import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Json.Decode as Json
import String
import Task as Job

type alias ModelAsJson = String

main : Program (Maybe ModelAsJson) Model Msg
main =
    Html.programWithFlags
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
type alias Model =
    { tasks : List Task
    , field : String
    , uid : Int
    , visibility : String
    }

type alias PortableModel =
    { tasks : List Task
    , field : String
    , uid : Int
    , visibility : String
    }

{-- Definition of a single task.
    Working rules:
    * there should be no fields for storing data that can be fully derived from other fields [consistency]
    * combine related fields into a single one with a tuple value [minimalism]
--}
type alias Task =
    { title : String
    , completion : Progress
    , editing : Bool
    , id : TaskId
    , predictedEffort : Duration -- make Fuzzy Duration in seconds
    , history : List (TaskChange, Moment)
    , parent : Maybe TaskId
    , tags : List String
    , created : (Moment, User)
    , assigned : (Moment, User)
    , project : Maybe ProjectId
    , deadline : Maybe MomentOrDay
    , plannedStart : Maybe MomentOrDay
    , plannedFinish : Maybe MomentOrDay
    , relevanceStarts : Maybe MomentOrDay
    , relevanceEnds : Maybe MomentOrDay
    }
{-- Additional meta-fields (realized via functions):
    + completed : Bool
--}


-- possible ways to filter the list of tasks (legacy)
type TaskListFilter
    = AllTasks
    | ActiveTasksOnly
    | CompletedTasksOnly



{-- possible activities that can be logged about a task.
    Working rules:
    * names should just be '(exact name of field being changed)+Change' [consistency]
    * value always includes the full value it was changed to at the time, never the delta [consistency]
--}
type TaskChange
    = CompletionChange Progress
    | TitleChange String
    | PredictedEffortChange Duration
    | ParentChange TaskId
    | TagsChange

type MomentOrDay = AtExactly Moment | OnDayOf Moment

type alias TaskId = Int

type alias ProjectId = Int

type alias Progress = Float

type alias Duration = Int                 --seconds

type alias Moment = Int                     --seconds since epoch or something

type alias User = Int                   -- to be determined

emptyModel : Model
emptyModel =
    { tasks = []
    , visibility = "All"
    , field = ""
    , uid = 0
    }


newTask : String -> Int -> Task
newTask desc id =
    { title = desc
    , editing = False
    , id = id
    , completion = 0
    , parent = Nothing
    , predictedEffort = 0
    , history = []
    , tags = []
    , created = (0, 0)              --TODO put in actual creation time
    , assigned = (0, 0)             --TODO put in actual users
    , project = Just 0
    , deadline = Nothing
    , plannedStart = Nothing
    , plannedFinish = Nothing
    , relevanceStarts = Nothing
    , relevanceEnds = Nothing
    }


-- initialize model
init : Maybe ModelAsJson -> ( Model, Cmd Msg )
init maybeModelAsJson =
  let finalModel =
      case maybeModelAsJson of
          Just modelAsJson ->
              case modelFromJson modelAsJson of
                  Ok restoredModel ->
                      restoredModel

                  Err msg ->
                      emptyModel

          -- no json stored at all
          Nothing ->
              emptyModel
  in
      finalModel ! []


modelFromJson : ModelAsJson -> Result String Model
modelFromJson incomingJson =
    Err "Always Fails for now"

modelToJson : Model -> ModelAsJson
modelToJson model =
    "hiya there"


-- adroit's helper functions
completed : Task -> Bool
completed task =
    .completion task == 1




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
    | UpdateProgress TaskId Progress
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

        UpdateProgress id completion ->
            let
                updateTask t =
                    if t.id == id then
                        { t | completion = completion }
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
        [ class "todomvc-wrapper"
        , style [ ( "visibility", "hidden" ) ]
        ]
        [ section
            [ class "todoapp" ]
            [ lazy viewInput model.field
            , lazy2 viewTasks model.visibility model.tasks
            , lazy2 viewControls model.visibility model.tasks
            ]
        , infoFooter
        ]


viewInput : String -> Html Msg
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


viewTasks : String -> List Task -> Html Msg
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
            , checked allCompleted
            , onClick
                (CheckAll
                    (if not allCompleted then
                        1
                     else
                        0
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



-- VIEW INDIVIDUAL ENTRIES


viewKeyedTask : Task -> ( String, Html Msg )
viewKeyedTask task =
    ( toString task.id, lazy viewTask task )


viewTask : Task -> Html Msg
viewTask task =
    li
        [ classList [ ( "completed", completed task ), ( "editing", task.editing ) ] ]
        [ div
            [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , checked (completed task)
                , onClick
                    (UpdateProgress task.id
                        (if not (completed task) then
                            1
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



-- VIEW CONTROLS AND FOOTER


viewControls : String -> List Task -> Html Msg
viewControls visibility tasks =
    let
        tasksCompleted =
            List.length (List.filter completed tasks)

        tasksLeft =
            List.length tasks - tasksCompleted
    in
    footer
        [ class "footer"
        , hidden (List.isEmpty tasks)
        ]
        [ lazy viewControlsCount tasksLeft
        , lazy viewControlsFilters visibility
        , lazy viewControlsClear tasksCompleted
        ]


viewControlsCount : Int -> Html Msg
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
viewControlsClear tasksCompleted =
    button
        [ class "clear-completed"
        , hidden (tasksCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ toString tasksCompleted ++ ")")
        ]


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
