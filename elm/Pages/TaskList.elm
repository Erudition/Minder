module Pages.TaskList exposing (Model, Msg, page)

import Activity.Activity as Activity exposing (ActivityID)
import Activity.HistorySession
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Effect exposing (Effect)
import Helpers exposing (..)
import Html.Styled as SH exposing (..)
import Html.Styled.Attributes as SHA exposing (..)
import Html.Styled.Events as SHE exposing (..)
import Html.Styled.Events.Extra as SHE
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2, lazy3, lazy4)
import ID
import Identicon exposing (identicon)
import Incubator.IntDict.Extra as IntDict
import Incubator.Todoist as Todoist
import Incubator.Todoist.Command as TodoistCommand
import IntDict
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Ion.ActionSheet as ActionSheet
import Ion.Button
import Ion.Icon
import Ion.Item
import Ion.List
import Json.Decode as JD
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as JE exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Layouts
import List.Extra as List
import Log
import Maybe.Extra as Maybe
import Page exposing (Page)
import Popup.Editor.Assignable
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (Change, Parent)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Route exposing (Route)
import Shared
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period
import String.Normalize
import Task as Job
import Task.ActionSkel as Action
import Task.Assignable as Assignable exposing (Assignable, AssignableID)
import Task.Assignment as Assignment exposing (Assignment, AssignmentID)
import Task.Layers
import Task.Progress exposing (..)
import Task.Project as Project exposing (Project)
import Task.ProjectSkel as ProjectSkel
import Task.SubAssignableSkel as SubAssignableSkel exposing (SubAssignableSkel)
import TaskPort
import TimeTrackable exposing (TimeTrackable)
import Url.Parser as P exposing ((</>), Parser, fragment, int, map, oneOf, s, string)
import View exposing (View)
import VirtualDom
import ZoneHistory


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout toLayout


{-| Use the appframe layout on this page
-}
toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.AppFrame
        {}



-- MODEL


type alias Model =
    { filters : List Filter
    , expandedTask : Maybe AssignableID
    , newTaskField : String
    , currentlyEditing : Maybe CurrentlyEditing
    }


type
    Filter
    -- TODO redesign to allow multiple
    = AllTasks
    | AllIncompleteTasks
    | AllRelevantTasks
    | CompleteTasksOnly


type alias ExpandedTask =
    AssignableID


type alias NewTaskField =
    String


type CurrentlyEditing
    = EditingAssignableTitle AssignableID String
    | EditingProjectDate
    | EditingProjectModal (Maybe Assignment)



-- INIT


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { filters = []
      , expandedTask = Nothing
      , newTaskField = ""
      , currentlyEditing = Nothing
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Refilter (List Filter)
    | StopEditing
    | UpdateTitle Assignable String
    | OpenEditor (Maybe Assignment)
    | CloseEditor
    | AddProject
    | AddAssignable Project
    | AddAssignment Assignable
    | DeleteAssignment Assignment
    | DeleteComplete
    | UpdateProgress Assignment Portion
    | FocusSlider Assignment Bool
    | UpdateTaskDate Assignment String (Maybe FuzzyMoment)
    | UpdateNewEntryField String
    | NoOp
    | StartTrackingAssignment Assignment ActivityID
    | StopTrackingAssignment Assignment
    | SimpleChange Change
    | LogError String
    | Toast String
    | RunEffect (Effect Msg)
    | PromptRename String (String -> Change)


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        AddProject ->
            case model.newTaskField of
                "" ->
                    ( model, Effect.none )

                newProjectTitle ->
                    ( { model | newTaskField = "", expandedTask = Nothing }
                    , Effect.userChangeNow (Profile.AddProject newProjectTitle)
                    )

        AddAssignable project ->
            let
                handleResult result =
                    case result of
                        Ok newName ->
                            RunEffect <| Effect.saveUserChanges (frameDescription newName) (finalChanges newName)

                        Err _ ->
                            RunEffect <| Effect.none

                promptOptions =
                    { title = Just ("New Assignable in project: " ++ Maybe.withDefault "Untitled Project" (Project.title project))
                    , message = "Enter a name for the assignable."
                    , okButtonTitle = Just "Rename"
                    , cancelButtonTitle = Nothing
                    , inputPlaceholder = Just "Assignable title here"
                    , inputText = Nothing
                    }

                frameDescription newName =
                    "Added a new assignable to project: " ++ newName

                assignableChanger : Assignable -> List Change
                assignableChanger parentAssignable =
                    [-- RepDb.addNew (Assignment.new (ID.fromPointer (Reg.getPointer parentAssignable))) shared.replica.assignments
                     --RepList.insertNew RepList.Last (SubAssignableSkel.ActionIsHere actionToAdd) (Assignable.children parentAssignable)
                    ]

                -- actionToAdd =
                --     Action.newActionSkel (Change.reuseContext "in-action" c) "first action" (\_ -> [])
                finalChanges newName =
                    [ RepList.insert RepList.Last (frameDescription newName) shared.replica.errors
                    , Assignable.createWithinProject newName [ assignableChanger ] project
                    ]
            in
            ( model, Effect.dialogPrompt handleResult promptOptions )

        AddAssignment assignable ->
            let
                frameDescription =
                    "Added a new assignment."

                finalChanges =
                    [ RepList.insert RepList.Last frameDescription shared.replica.errors
                    , Assignment.create (\_ -> []) assignable
                    ]
            in
            ( model, Effect.saveUserChanges frameDescription finalChanges )

        DeleteAssignment assignment ->
            let
                frameDescription =
                    "Deleted assignment"

                finalChanges =
                    [ RepList.insert RepList.Last frameDescription shared.replica.errors
                    , Assignment.delete assignment
                    ]
            in
            ( model, Effect.saveUserChanges frameDescription finalChanges )

        UpdateNewEntryField typedSoFar ->
            ( { model | newTaskField = typedSoFar }
            , Effect.none
            )

        OpenEditor actionMaybe ->
            ( { model | currentlyEditing = Just <| EditingProjectModal actionMaybe }
              --, Effect.OpenPopup (PopupType.AssignmentEditor actionMaybe)
            , Effect.none
            )

        CloseEditor ->
            ( { model | currentlyEditing = Nothing }
              --, Effect.ClosePopup
            , Effect.none
            )

        StopEditing ->
            ( { model | currentlyEditing = Nothing }
            , Effect.none
            )

        UpdateTitle assignable newTitle ->
            let
                normalizedNewTitle =
                    String.trim newTitle

                changeTitleIfValid =
                    if (String.length normalizedNewTitle < 2) || normalizedNewTitle == Assignable.title assignable then
                        Effect.none

                    else
                        Effect.saveUserChanges "Updating project title" [ Assignable.setTitle newTitle assignable ]
            in
            ( { model | currentlyEditing = Nothing }
            , changeTitleIfValid
            )

        UpdateTaskDate id field date ->
            let
                updateTask t =
                    { t | externalDeadline = date }
            in
            -- ( model
            -- , { profile | taskInstances = IntDict.update id (Maybe.map updateTask) shared.replica.taskInstances }
            -- , []
            -- )
            Debug.todo "Not yet implemented: UpdateTaskTitle"

        DeleteComplete ->
            ( model
              -- TODO { profile | taskInstances = IntDict.filter (\_ t -> not (Assignment.completed t)) shared.replica.taskInstances }
            , Effect.none
            )

        UpdateProgress givenTask newCompletion ->
            -- let
            --     updateTaskInstance t =
            --         Assignment.setCompletion newCompletion
            --
            --     oldProgress =
            --         Assignment.instanceProgress givenTask
            --
            --     profile1WithUpdatedInstance =
            --         { profile | taskInstances = IntDict.update givenTask.Assignment.id (Maybe.map updateTaskInstance) shared.replica.taskInstances }
            -- in
            -- -- how does the new completion status compare to the previous?
            -- case ( isMax oldProgress, isMax ( newCompletion, getUnits oldProgress ) ) of
            --     ( False, True ) ->
            --         let
            --             ( viewState2, profile2WithTrackingStopped, trackingStoppedCmds ) =
            --                 update (StopTracking (Assignment.getID givenTask)) model profile1WithUpdatedInstance env
            --         in
            --         ( viewState2
            --         , profile2WithTrackingStopped
            --         , -- It was incomplete before, completed now
            --           Cmd.batch
            --             [ Commands.toast ("Marked as complete: " ++ givenTask.class.title)
            --
            --             --, Cmd.map TodoistServerResponse <|
            --             --    Integrations.Todoist.sendChanges shared.replica.todoist
            --             --        [ ( HumanMoment.toStandardString env.time, TodoistCommand.ItemClose (TodoistCommand.RealItem givenTask.instance.id) ) ]
            --             , Cmd.map MarvinServerResponse <|
            --                 Marvin.updateDocOfItem env.time
            --                     [ "done", "doneAt" ]
            --                     { givenTask | instance = updateTaskInstance givenTask.instance }
            --             , trackingStoppedCmds
            --             ]
            --         )
            --
            --     ( True, False ) ->
            --         -- It was complete before, but now marked incomplete
            --         ( model
            --         , profile1WithUpdatedInstance
            --         , Cmd.batch
            --             [ Commands.toast ("No longer marked as complete: " ++ givenTask.class.title)
            --
            --             -- , Cmd.map TodoistServerResponse <|item
            --
            --     _ ->
            --         -- nothing changed, completion-wise
            --         ( model, profile1WithUpdatedInstance, [] )
            Debug.todo "completion update"

        FocusSlider task focused ->
            ( model
            , Effect.none
            )

        NoOp ->
            ( model
            , Effect.none
            )

        Refilter newList ->
            ( { model | filters = newList }
            , Effect.none
            )

        StartTrackingAssignment assignment activityID ->
            let
                projectLayers =
                    Debug.todo "projectlayers for switching tracking"

                addSessionEffects =
                    Refocus.switchTracking (TimeTrackable.TrackedAssignmentID (Assignment.id assignment) activityID) shared.replica projectLayers ( shared.time, shared.timeZone )

                -- ( newProfile2WithMarvinTimes, marvinCmds ) =
                --     Marvin.marvinUpdateCurrentlyTracking newProfile1WithSession env (Just instanceID) True
            in
            ( model
            , addSessionEffects
            )

        StopTrackingAssignment instanceID ->
            let
                activityToContinue =
                    Activity.HistorySession.currentActivityID (RepList.listValues shared.replica.timeline)

                instanceToStop =
                    Activity.HistorySession.currentAssignmentID (RepList.listValues shared.replica.timeline)

                projectLayers =
                    Debug.todo "projectlayers for switching tracking"

                sessionEffect =
                    Refocus.switchTracking TimeTrackable.stub shared.replica projectLayers ( shared.time, shared.timeZone )

                -- ( newProfile2WithMarvinTimes, marvinCmds ) =
                --     Marvin.marvinUpdateCurrentlyTracking newProfile1WithSession env instanceToStop False
            in
            ( model
            , sessionEffect
              -- , Cmd.batch
              --     [ sessionCommands
              --     -- , Cmd.map MarvinServerResponse <| marvinCmds
              --     ]
            )

        SimpleChange change ->
            ( model, Effect.saveUserChanges "Simple change" [ change ] )

        LogError errorMsg ->
            ( model, Effect.saveUserChanges "Log Error" [ RepList.insert RepList.Last errorMsg shared.replica.errors ] )

        Toast toastMsg ->
            ( model, Effect.toast toastMsg )

        RunEffect effect ->
            ( model, effect )

        PromptRename oldName newNameToChange ->
            let
                handleResult result =
                    case result of
                        Ok newName ->
                            RunEffect <| Effect.saveUserChanges "renaming" [ newNameToChange newName ]

                        Err _ ->
                            RunEffect <| Effect.none

                promptOptions =
                    { title = Just ("Renaming " ++ oldName)
                    , message = "Enter a new name for \"" ++ oldName ++ "\"."
                    , okButtonTitle = Just "Rename"
                    , cancelButtonTitle = Nothing
                    , inputPlaceholder = Just oldName
                    , inputText = Just oldName
                    }
            in
            ( model, Effect.dialogPrompt handleResult promptOptions )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    -- let
    --     -- modalIfOpen =
    --                     --     case editing of
    --                     --         Just (EditingProjectModal assignment) ->
    --                     --             [ viewTaskEditModal profile env assignment ]
    --                     --         _ ->
    --                     --             []
    -- in
    { title = "Task List"
    , body =
        [ section []
            [ lazy viewInput model.newTaskField
            , Html.Styled.Lazy.lazy4 viewProjects shared.time shared.timeZone model.filters shared.replica

            -- , Html.Styled.Lazy.lazy5 viewTasks env.launchTime env.timeZone activeFilter editing profile
            -- , Html.Styled.Lazy.lazy4 viewControls filters env.launchTime env.timeZone profile
            ]
        ]
    }


viewInput : String -> Html Msg
viewInput newEntryFieldContents =
    node "ion-input"
        [ class "new-task"
        , placeholder "Type new project name here..."
        , autofocus True
        , value newEntryFieldContents
        , name "newTask"
        , onInput UpdateNewEntryField
        , SHE.onEnter AddProject
        , attribute "data-flip-key" ("task-named-" ++ String.Normalize.slug newEntryFieldContents)
        ]
        []


viewProjects : Moment -> HumanMoment.Zone -> List Filter -> Profile -> Html Msg
viewProjects time timeZone filters replica =
    let
        trackedTaskMaybe =
            Profile.currentAssignmentID replica

        taskLayers =
            Task.Layers.buildLayerDatabase replica.projects

        projectList =
            AnyDict.values taskLayers.projects

        items =
            List.map (viewKeyedProject replica ( time, timeZone ) trackedTaskMaybe) projectList

        header =
            node "ion-list-header" [] [ node "ion-label" [] [ text "Tasks" ] ]
    in
    Keyed.node "ion-list" [ SHA.attribute "lines" "full" ] (( "tasks-header", header ) :: items)


viewKeyedProject : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Project -> ( String, Html Msg )
viewKeyedProject profile ( time, timeZone ) trackedTaskMaybe rootEntryItem =
    ( Project.idString rootEntryItem, lazy4 viewProject profile ( time, timeZone ) trackedTaskMaybe rootEntryItem )


viewProject : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Project -> Html Msg
viewProject profile ( time, timeZone ) trackedTaskMaybe project =
    let
        entryContents =
            case Project.children project |> RepList.listValues of
                [] ->
                    node "ion-button" [ attribute "fill" "clear", onClick (AddAssignable project) ] [ node "ion-icon" [ name "add-circle-outline" ] [], text "Add first assignable" ]

                someChildren ->
                    div [] <| List.map viewProjectChild someChildren

        viewProjectChild projectChild =
            case projectChild of
                ProjectSkel.AssignableIsHere assignableSkelReg ->
                    viewAssignable profile ( time, timeZone ) trackedTaskMaybe (Assignable.fromSkel project assignableSkelReg)

                ProjectSkel.AssignableIsDeeper nestedProjectSkelReg ->
                    viewProject profile ( time, timeZone ) trackedTaskMaybe (Project.fromSkel (Just project) nestedProjectSkelReg)

        sheetButtonID =
            "actionsheet-trigger-for-project-" ++ Project.idString project

        presentActionSheet =
            ActionSheet.actionSheet
                [ ActionSheet.header <| "Project: " ++ projectDisplayTitle
                , ActionSheet.trigger sheetButtonID
                ]
                [ ActionSheet.deleteButton (Toast "NYI: Delete Project")
                , ActionSheet.buttonWithIcon "Rename" "create-outline" (PromptRename projectDisplayTitle (\t -> Project.setTitle (Just t) project))
                , ActionSheet.buttonWithIcon "Add Assignable" "add-circle-outline" (AddAssignable project)
                ]
                |> SH.fromUnstyled

        projectDisplayTitle =
            case Project.title project of
                Nothing ->
                    "No project"

                Just "" ->
                    "Untitled project"

                Just other ->
                    other
    in
    node "ion-item"
        [ classList []
        , attribute "data-flip-key" ("project-" ++ Project.idString project)
        ]
        [ -- node "ion-thumbnail"
          -- [ class "project-image"
          -- , attribute "slot" "start"
          -- , css
          --     [ backgroundColor <| Css.hsl 0 0 0.5
          --     , Css.height (pct 100)
          --     ]
          -- ]
          -- [ --img [ src "https://ionicframework.com/docs/img/demos/thumbnail.svg" ] []
          --   SH.fromUnstyled <| identicon "100%" (RepList.handleString rootEntryItem)
          -- ]
          div [ css [ Css.width (pct 100) ] ]
            [ node "ion-label"
                [ id sheetButtonID, css [ cursor Css.pointer ] ]
                [ text (projectDisplayTitle ++ " ➤ ") -- Project title if assignable is deeper
                ]
            , entryContents

            --, viewMenuButton sheetButtonID
            ]
        , presentActionSheet
        ]



-- , node "ion-item-options"
--     []
--     [ node "ion-item-option" [ attribute "color" "danger" ] [ text "delete" ]
--     , node "ion-item-option" [ attribute "color" "primary", onClick (AddAssignable project) ] [ text "add assignable" ]
--     ]


viewAssignable : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Assignable -> Html Msg
viewAssignable profile ( time, timeZone ) trackedTaskMaybe assignable =
    let
        assignableDisplayTitle =
            case String.trim (Assignable.title assignable) of
                "" ->
                    "Untitled Assignable"

                other ->
                    other

        project =
            Assignable.parent assignable

        viewSubAssignables =
            List.map viewSubAssignable (RepList.listValues (Assignable.children assignable))

        viewSubAssignable subAssignableNested =
            case subAssignableNested of
                SubAssignableSkel.ActionIsHere actionClassReg ->
                    text (Reg.latest actionClassReg).title.get

                SubAssignableSkel.ActionIsDeeper containerOfActions ->
                    text (Debug.toString containerOfActions)

        assignments =
            Assignment.fromAssignable Assignment.AllSaved assignable

        viewAssignments =
            List.indexedMap (viewAssignment ( time, timeZone ) trackedTaskMaybe) assignments

        -- ++ [ addAssignment ]
        addAssignment =
            node "ion-card"
                [ css [ minWidth (pct 60), maxWidth (pct 90) ] ]
                [ node "ion-card-header"
                    []
                    [ node "ion-card-subtitle" [] [ text "Add another assignment" ]
                    ]
                , node "ion-card-content"
                    []
                    []
                , node "ion-button" [ attribute "fill" "clear", onClick (AddAssignment assignable) ] [ node "ion-icon" [ name "add-circle-outline" ] [], text "assign" ]
                ]

        presentActionSheet =
            ActionSheet.actionSheet
                [ ActionSheet.header ("Assignable:" ++ assignableDisplayTitle)
                , ActionSheet.trigger sheetButtonID
                ]
                [ ActionSheet.buttonWithIcon "Rename" "create-outline" (PromptRename assignableDisplayTitle (\t -> Assignable.setTitle t assignable))
                , ActionSheet.buttonWithIcon "New Assignment" "add-circle-outline" (AddAssignment assignable)
                ]
                |> SH.fromUnstyled

        sheetButtonID =
            "actionsheet-trigger-for-assignable-" ++ Assignable.idString assignable
    in
    node "ion-item"
        [ classList []
        , attribute "data-flip-key" ("assignable-" ++ Assignable.idString assignable)
        ]
        [ div [ css [ Css.width (pct 100) ] ]
            [ node "ion-label"
                [ id sheetButtonID, css [ cursor Css.pointer ] ]
                [ SH.fromUnstyled <| identicon "1em" (Assignable.idString assignable)
                , span [ css [ fontWeight bold ] ] [ text (Assignable.title assignable) ]
                , SH.small [ css [ color <| Css.rgb 100 100 100 ] ] [ text <| " (×" ++ String.fromInt (List.length assignments) ++ ")" ]
                ]
            , div [ css [ displayFlex, flexDirection row, overflowX scroll, padding (rem 0.5) ], style "scroll-snap-type" "x mandatory", style "scroll-padding" "1rem" ] viewAssignments
            ]
        , presentActionSheet
        ]



-- div
--     [ class "assignments" ]
--     [ node "ion-card-title" [ onDoubleClick (PromptRename (Assignable.title assignable) (\t -> Assignable.setTitle t assignable)) ] (viewAssignableTitle ++ viewSubAssignables)
--     , div [ css [ displayFlex, overflowX scroll ] ] viewAssignments
--     ]


viewAssignment : ( Moment, Zone ) -> Maybe AssignmentID -> Int -> Assignment -> Html Msg
viewAssignment ( time, timeZone ) trackedTaskMaybe index assignment =
    let
        assignmentCreated =
            Assignment.created assignment

        assignedTimeText =
            case assignmentCreated of
                Nothing ->
                    ""

                Just assignedAt ->
                    ", " ++ HumanMoment.describeGapVsNowSimple timeZone time assignedAt

        sheetButtonID =
            "actionsheet-trigger-for-assignment-" ++ Assignment.idString assignment

        presentActionSheet =
            ActionSheet.actionSheet
                [ ActionSheet.header ("Assignment of: " ++ Assignment.title assignment)
                , ActionSheet.trigger sheetButtonID
                ]
                [ ActionSheet.deleteButton (DeleteAssignment assignment)
                , startTrackingButton assignment trackedTaskMaybe
                ]
                |> SH.fromUnstyled

        assignmentTooltip =
            String.concat <|
                List.intersperse "\n" <|
                    List.filterMap identity
                        ([ Just ("Assignment #" ++ String.fromInt (index + 1))
                         , Just ("ID: " ++ Assignment.idString assignment)
                         , Just ("completion: " ++ String.fromInt (Assignment.completion assignment))
                         , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance starts: ") (Assignment.relevanceStarts assignment)
                         , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance ends: ") (Assignment.relevanceEnds assignment)
                         ]
                            ++ List.map (\( k, v ) -> Just ("instance " ++ k ++ ": " ++ v)) (RepDict.list (Assignment.extras assignment))
                        )
    in
    node "ion-card"
        [ css [ Css.width (vw 90), minWidth (rem 10), maxWidth (vw 90), position sticky, left (px 0) ], style "scroll-snap-align" "start" ]
        [ node "ion-card-content"
            []
            [ node "ion-note"
                [ title assignmentTooltip, id sheetButtonID, css [ cursor Css.pointer ] ]
                [ SH.fromUnstyled <| identicon "1em" (Assignment.idString assignment)
                , text <| "#" ++ String.fromInt (index + 1) ++ assignedTimeText
                ]
            , node "ion-list" [] [ node "ion-item" [] [ text <| "action 1" ] ]
            ]
        , presentActionSheet
        ]


viewMenuButton triggerID =
    SH.node "ion-button" [ SHA.attribute "slot" "end", SHA.id triggerID ] [ Ion.Icon.basic "ellipsis-vertical-outline" |> SH.fromUnstyled ]


startTrackingButton : Assignment -> Maybe AssignmentID -> ActionSheet.Button Msg
startTrackingButton assignment trackedTaskMaybe =
    case Assignment.activityID assignment of
        Nothing ->
            -- assignment has no activity
            ActionSheet.button "Track" (Toast "No activity set!")

        Just assignmentActivityID ->
            -- assignment has an activity, it's trackable
            if Maybe.map ((==) (Assignment.id assignment)) trackedTaskMaybe == Just True then
                -- this is the assignment we're currently tracking
                ActionSheet.buttonWithIcon "Pause tracking" "pause-outline" (StopTrackingAssignment assignment)

            else
                ActionSheet.buttonWithIcon "Start tracking" "play-outline" (StartTrackingAssignment assignment assignmentActivityID)
