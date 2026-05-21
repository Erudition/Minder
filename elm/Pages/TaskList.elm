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
    { title = "Task List"
    , body =
        [ node "style" [] [ text """
            :root, ion-app {
              --glass-bg: rgba(0, 0, 0, 0.03) !important;
              --glass-border: rgba(0, 0, 0, 0.08) !important;
              --glass-text-primary: rgba(0, 0, 0, 0.85) !important;
              --glass-text-secondary: rgba(0, 0, 0, 0.55) !important;
              --glass-text-muted: rgba(0, 0, 0, 0.38) !important;
              --glass-card-bg: rgba(0, 0, 0, 0.015) !important;
              --glass-card-backing: #ffffff !important;
              --glass-card-border: #f0f0f0 !important;
              --glass-card-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.06) !important;
              --glass-input-bg: rgba(0, 0, 0, 0.02) !important;
              --glass-input-border: rgba(0, 0, 0, 0.08) !important;
              --glass-input-focus-bg: rgba(0, 0, 0, 0.04) !important;
              --glass-input-color: #000 !important;
              --glass-scroll-thumb: rgba(0, 0, 0, 0.15) !important;
              --glass-scroll-thumb-hover: rgba(0, 0, 0, 0.25) !important;
            }
            
            ion-app.dark {
              --glass-bg: rgba(255, 255, 255, 0.03) !important;
              --glass-border: rgba(255, 255, 255, 0.08) !important;
              --glass-text-primary: rgba(255, 255, 255, 0.95) !important;
              --glass-text-secondary: rgba(255, 255, 255, 0.65) !important;
              --glass-text-muted: rgba(255, 255, 255, 0.45) !important;
              --glass-card-bg: rgba(255, 255, 255, 0.02) !important;
              --glass-card-backing: #121212 !important;
              --glass-card-border: #222222 !important;
              --glass-card-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3) !important;
              --glass-input-bg: rgba(255, 255, 255, 0.03) !important;
              --glass-input-border: rgba(255, 255, 255, 0.08) !important;
              --glass-input-focus-bg: rgba(255, 255, 255, 0.06) !important;
              --glass-input-color: #fff !important;
              --glass-scroll-thumb: rgba(255, 255, 255, 0.15) !important;
              --glass-scroll-thumb-hover: rgba(255, 255, 255, 0.25) !important;
            }

            @keyframes pulseGlow {
              from {
                box-shadow: 0 0 5px rgba(66, 140, 255, 0.4), inset 0 0 5px rgba(66, 140, 255, 0.2);
                border-color: rgba(66, 140, 255, 0.6);
              }
              50% {
                box-shadow: 0 0 20px rgba(66, 140, 255, 0.8), inset 0 0 10px rgba(66, 140, 255, 0.4);
                border-color: rgba(66, 140, 255, 1);
              }
              to {
                box-shadow: 0 0 5px rgba(66, 140, 255, 0.4), inset 0 0 5px rgba(66, 140, 255, 0.2);
                border-color: rgba(66, 140, 255, 0.6);
              }
            }
            .tracking-pulse {
              animation: pulseGlow 2.5s infinite ease-in-out !important;
              border: 1px solid rgba(66, 140, 255, 0.8) !important;
            }
            .glass-input::part(native) {
              background: var(--glass-input-bg) !important;
              border: 1px solid var(--glass-input-border) !important;
              border-radius: 12px !important;
              padding: 12px 20px !important;
              color: var(--glass-input-color) !important;
              font-family: inherit !important;
              transition: all 0.3s ease !important;
            }
            .glass-input::part(native):focus-within {
              border-color: rgba(66, 140, 255, 0.5) !important;
              box-shadow: 0 0 15px rgba(66, 140, 255, 0.3) !important;
              background: var(--glass-input-focus-bg) !important;
            }
            .horizontal-scroll-container::-webkit-scrollbar {
              height: 6px;
            }
            .horizontal-scroll-container::-webkit-scrollbar-track {
              background: rgba(255, 255, 255, 0.02);
              border-radius: 3px;
            }
            .horizontal-scroll-container::-webkit-scrollbar-thumb {
              background: var(--glass-scroll-thumb);
              border-radius: 3px;
            }
            .horizontal-scroll-container::-webkit-scrollbar-thumb:hover {
              background: var(--glass-scroll-thumb-hover);
            }
            .custom-glass-card {
              background: linear-gradient(var(--glass-card-bg), var(--glass-card-bg)), var(--glass-card-backing) !important;
              backdrop-filter: blur(12px) !important;
              -webkit-backdrop-filter: blur(12px) !important;
              border: 1px solid var(--glass-card-border) !important;
              border-radius: 16px !important;
              box-shadow: var(--glass-card-shadow) !important;
              transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            }
             .custom-glass-card:hover {
               background: var(--glass-input-focus-bg) !important;
               border-color: var(--glass-input-border) !important;
             }
             
             .stepped-deck-card {
               position: sticky !important;
               left: calc(var(--card-start) + (var(--index) - var(--total-count)) * var(--stack-step)) !important;
               width: var(--card-width) !important;
               margin: 0.4rem !important;
               flex-shrink: 0 !important;
               height: 180px !important;
               background: transparent !important;
               border: 1px solid var(--glass-card-border) !important;
               border-radius: 16px !important;
               overflow: hidden !important;
               pointer-events: none !important;
               z-index: calc(10 + var(--index)) !important;
             }
             
             .stepped-deck-card:first-of-type {
               margin-left: var(--card-start) !important;
             }
            
            .stepped-deck-glass {
              background: linear-gradient(var(--glass-card-bg), var(--glass-card-bg)), var(--glass-card-backing) !important;
              transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
              pointer-events: auto !important;
            }
            
            .stepped-deck-card-tag {
              position: absolute !important;
              right: 0 !important;
              top: 0 !important;
              width: 5.5rem !important;
              height: 3.5rem !important;
              z-index: 0 !important;
            }
            
            .stepped-deck-card-body {
              position: absolute !important;
              left: 0 !important;
              right: 0 !important;
              bottom: 0 !important;
              top: 3.5rem !important;
              z-index: 0 !important;
            }
            
            .stepped-deck-card-disabled-hover-1 {
              background: var(--glass-input-focus-bg) !important;
            }
            
            .stepped-deck-card-disabled-hover-2 {
              border-color: var(--glass-input-border) !important;
            }
            
            .stepped-deck-card-new {
               background: transparent !important;
               border: 2px dashed var(--glass-card-border) !important;
               border-radius: 16px !important;
               box-shadow: none !important;
               width: var(--peek) !important;
               height: auto !important;
               align-self: stretch !important;
               display: flex !important;
               align-items: center !important;
               justify-content: center !important;
               cursor: pointer !important;
               color: var(--glass-text-muted) !important;
               transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
               pointer-events: auto !important;
             }
             
             .stepped-deck-card-new:hover {
               color: var(--glass-text-primary) !important;
               border-color: var(--glass-input-border) !important;
             }
            
            .horizontal-scroll-container > :only-child {
              margin-left: auto !important;
            }
            
            .stepped-deck-card-disabled-hover-3 {
              color: var(--glass-text-primary) !important;
              border-color: var(--glass-input-border) !important;
            }
             
             :root, ion-app {
               --card-width: 14rem !important;
               --card-gap: 0.8rem !important;
               --card-start: 0.4rem !important;
               --stack-step: 0.8rem !important;
               --peek: 4rem !important;
             }
             
             .horizontal-scroll-container {
               --stack-step: calc(0.8rem / var(--total-count, 1)) !important;
               --card-start: 1.2rem !important;
               --card-width: calc(100% - var(--card-start) - var(--card-gap) - var(--peek)) !important;
               padding-left: 0 !important;
               padding-right: 0 !important;
               scroll-padding: var(--card-start) !important;
               scroll-snap-type: x mandatory !important;
               margin-left: calc(0px - var(--card-start)) !important;
               width: calc(100% + var(--card-start)) !important;
               min-height: calc(3.5rem + 0.8rem) !important;
             }
             
             @media (max-width: 600px) {
               :root, ion-app {
                 --card-width: calc(100% - var(--card-start) - var(--card-gap) - var(--peek)) !important;
                 --card-gap: 0.8rem !important;
               }
             }
             
             snap-placeholder, .absolute-snap-target {
               position: absolute !important;
               display: block !important;
               left: calc(var(--card-start) + var(--index) * (var(--card-width) + var(--card-gap))) !important;
               width: var(--card-width) !important;
               height: 100% !important;
               pointer-events: none !important;
               visibility: hidden !important;
               scroll-snap-align: start !important;
             }
           """ ]
        , div
            [ css
                [ padding (rem 1.5)
                , maxWidth (px 800)
                , margin2 (px 0) auto
                , displayFlex
                , flexDirection column
                , Css.property "gap" "1.5rem"
                ]
            ]
            [ lazy viewInput model.newTaskField
            , Html.Styled.Lazy.lazy4 viewProjects shared.time shared.timeZone model.filters shared.replica
            ]
        ]
    }


viewInput : String -> Html Msg
viewInput newEntryFieldContents =
    node "ion-input"
        [ class "glass-input"
        , placeholder "Type new project name here..."
        , autofocus True
        , value newEntryFieldContents
        , name "newTask"
        , onInput UpdateNewEntryField
        , SHE.onEnter AddProject
        , attribute "data-flip-key" ("task-named-" ++ String.Normalize.slug newEntryFieldContents)
        , css
            [ fontSize (rem 1.1)
            , fontFamily inherit
            , Css.property "--padding-start" "0"
            , Css.property "--padding-end" "0"
            , Css.property "--background" "transparent"
            , Css.property "--color" "#fff"
            ]
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
    in
    Keyed.node "div"
        [ css
            [ displayFlex
            , flexDirection column
            , Css.property "gap" "1.5rem"
            ]
        ]
        items


viewKeyedProject : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Project -> ( String, Html Msg )
viewKeyedProject profile ( time, timeZone ) trackedTaskMaybe rootEntryItem =
    ( Project.idString rootEntryItem, lazy4 viewProject profile ( time, timeZone ) trackedTaskMaybe rootEntryItem )


viewProject : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Project -> Html Msg
viewProject profile ( time, timeZone ) trackedTaskMaybe project =
    let
        entryContents =
            case Project.children project |> RepList.listValues of
                [] ->
                    node "ion-button"
                        [ attribute "fill" "clear"
                        , onClick (AddAssignable project)
                        , css [ Css.property "--color" "var(--glass-text-secondary)" ]
                        ]
                        [ node "ion-icon" [ name "add-circle-outline", attribute "slot" "start" ] [], text "Add first assignable" ]

                someChildren ->
                    div [ css [ displayFlex, flexDirection column, Css.property "gap" "0.8rem" ] ] <| List.map viewProjectChild someChildren

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
    div
        [ attribute "data-flip-key" ("project-" ++ Project.idString project)
        , css
            [ Css.property "background" "var(--glass-card-bg)"
            , Css.property "border" "1px solid var(--glass-card-border)"
            , borderRadius (px 14)
            , paddingTop (rem 1.0)
            , paddingBottom (rem 1.0)
            , paddingLeft (rem 1.2)
            , paddingRight (rem 1.2)
            , overflow Css.hidden
            , position relative
            , marginBottom (rem 1.5)
            ]
        ]
        [ div [ css [ Css.width (pct 100), displayFlex, flexDirection column, Css.property "gap" "1rem" ] ]
            [ div
                [ css
                    [ displayFlex
                    , alignItems center
                    , justifyContent spaceBetween
                    , Css.property "border-bottom" "1px solid var(--glass-card-border)"
                    , paddingBottom (rem 0.8)
                    , marginBottom (rem 0.5)
                    ]
                ]
                [ div
                    [ id sheetButtonID
                    , css
                        [ cursor Css.pointer
                        , displayFlex
                        , alignItems center
                        , Css.property "gap" "0.5rem"
                        , hover [ opacity (num 0.8) ]
                        ]
                    ]
                    [ div
                        [ css
                            [ Css.width (rem 0.4)
                            , Css.height (rem 1.2)
                            , borderRadius (px 2)
                            , backgroundColor (Css.hsl 215 1 0.6)
                            , boxShadow4 (px 0) (px 0) (px 8) (rgba 42 140 255 0.5)
                            ]
                        ]
                        []
                    , span
                        [ css
                            [ fontSize (rem 1.1)
                            , fontWeight (Css.int 700)
                            , Css.property "color" "var(--glass-text-primary)"
                            , letterSpacing (px -0.2)
                            ]
                        ]
                        [ text projectDisplayTitle ]
                    , span
                        [ css
                            [ fontSize (rem 0.8)
                            , Css.property "color" "var(--glass-text-muted)"
                            ]
                        ]
                        [ text "➤" ]
                    ]
                , div
                    [ id sheetButtonID
                    , css
                        [ cursor Css.pointer
                        , Css.property "color" "var(--glass-text-muted)"
                        , hover [ Css.property "color" "var(--glass-text-primary)" ]
                        ]
                    ]
                    [ Ion.Icon.basic "ellipsis-horizontal-outline" |> SH.fromUnstyled ]
                ]
            , entryContents
            ]
        , presentActionSheet
        ]


viewAssignable : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Assignable -> Html Msg
viewAssignable profile ( time, timeZone ) trackedTaskMaybe assignable =
    let
        assignableDisplayTitle =
            case String.trim (Assignable.title assignable) of
                "" ->
                    "Untitled Assignable"

                other ->
                    other

        assignments =
            Assignment.fromAssignable Assignment.AllSaved assignable

        totalCount =
            List.length assignments + 1

        viewAssignments =
            List.indexedMap
                (\i assignment ->
                    [ node "snap-placeholder"
                        [ class "absolute-snap-target"
                        , attribute "style" ("--index: " ++ String.fromInt i)
                        ]
                        []
                    , viewAssignment ( time, timeZone ) trackedTaskMaybe i assignment
                    ]
                )
                assignments
                |> List.concat
                |> (\list -> list ++ [ addAssignmentCard ])

        addAssignmentCard =
            div
                [ onClick (AddAssignment assignable)
                , class "stepped-deck-card stepped-deck-card-new"
                , attribute "style" ("--index: " ++ String.fromInt (List.length assignments))
                ]
                [ node "ion-icon"
                    [ name "add-outline"
                    , css [ fontSize (rem 2.0) ]
                    ]
                    []
                ]

        presentActionSheet =
            ActionSheet.actionSheet
                [ ActionSheet.header ("Assignable: " ++ assignableDisplayTitle)
                , ActionSheet.trigger sheetButtonID
                ]
                [ ActionSheet.buttonWithIcon "Rename" "create-outline" (PromptRename assignableDisplayTitle (\t -> Assignable.setTitle t assignable))
                , ActionSheet.buttonWithIcon "New Assignment" "add-circle-outline" (AddAssignment assignable)
                ]
                |> SH.fromUnstyled

        sheetButtonID =
            "actionsheet-trigger-for-assignable-" ++ Assignable.idString assignable
    in
    div
        [ attribute "data-flip-key" ("assignable-" ++ Assignable.idString assignable)
        , css
            [ displayFlex
            , flexDirection column
            , position relative
            ]
        ]
        [ div
            [ id sheetButtonID
            , css
                [ cursor Css.pointer
                , displayFlex
                , alignItems center
                , Css.property "gap" "0.5rem"
                , hover [ opacity (num 0.8) ]
                , paddingLeft (rem 1.2)
                , paddingTop (rem 0.8)
                , Css.height (rem 3.5)
                , marginBottom (rem -3.5)
                , position relative
                , zIndex (Css.int 1)
                , Css.property "pointer-events" "auto"
                ]
            ]
            [ SH.fromUnstyled <| identicon "1.2em" (Assignable.idString assignable)
            , span [ css [ fontWeight (Css.int 600), fontSize (rem 0.95), Css.property "color" "var(--glass-text-primary)" ] ] [ text assignableDisplayTitle ]
            , span
                [ css
                    [ fontSize (rem 0.7)
                    , padding2 (px 2) (px 6)
                    , borderRadius (px 10)
                    , Css.property "background-color" "var(--glass-bg)"
                    , Css.property "color" "var(--glass-text-secondary)"
                    , fontWeight (Css.int 500)
                    ]
                ]
                [ text <| String.fromInt (List.length assignments) ]
            ]
        , div
            [ class "horizontal-scroll-container"
            , css
                [ displayFlex
                , flexDirection row
                , overflowX scroll
                , paddingBottom (rem 0.5)
                , position relative
                , zIndex (Css.int 2)
                , Css.property "pointer-events" "none"
                ]
            , attribute "style" ("--total-count: " ++ String.fromInt totalCount)
            ]
            viewAssignments
        , presentActionSheet
        ]


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
                    HumanMoment.describeGapVsNowSimple timeZone time assignedAt

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

        isCurrentlyTracked =
            Maybe.map ((==) (Assignment.id assignment)) trackedTaskMaybe == Just True

        trackingIndicator =
            if isCurrentlyTracked then
                span
                    [ css
                        [ fontSize (rem 0.7)
                        , color (Css.hsl 140 0.8 0.6)
                        , fontWeight (Css.int 700)
                        , displayFlex
                        , alignItems center
                        , Css.property "gap" "4px"
                        ]
                    ]
                    [ div
                        [ css
                            [ Css.width (px 6)
                            , Css.height (px 6)
                            , borderRadius (pct 50)
                            , backgroundColor (Css.hsl 140 0.8 0.5)
                            , boxShadow4 (px 0) (px 0) (px 6) (rgba 47 223 117 0.8)
                            ]
                        ]
                        []
                    , text "TRACKING"
                    ]

            else
                SH.text ""
    in
    div
        [ classList [ ( "stepped-deck-card", True ), ( "tracking-pulse", isCurrentlyTracked ) ]
        , attribute "style" ("--index: " ++ String.fromInt index)
        ]
        [ div [ class "stepped-deck-glass stepped-deck-card-tag" ] []
        , div [ class "stepped-deck-glass stepped-deck-card-body" ] []
        , div
            [ css
                [ position relative
                , zIndex (Css.int 1)
                , Css.height (pct 100)
                , displayFlex
                , flexDirection column
                , Css.property "pointer-events" "none"
                ]
            ]
            [ div
                [ css
                    [ displayFlex
                    , alignItems center
                    , justifyContent flexEnd
                    , Css.height (rem 3.5)
                    , paddingRight (rem 0.8)
                    , Css.property "pointer-events" "none"
                    ]
                ]
                [ div
                    [ title assignmentTooltip
                    , css
                        [ displayFlex
                        , alignItems center
                        , Css.property "gap" "0.4rem"
                        , Css.property "pointer-events" "auto"
                        ]
                    ]
                    [ span [ css [ fontWeight (Css.int 700), fontSize (rem 0.9), Css.property "color" "var(--glass-text-primary)" ] ]
                        [ text <| "#" ++ String.fromInt (index + 1) ]
                    , SH.fromUnstyled <| identicon "1.1em" (Assignment.idString assignment)
                    ]
                ]
            , div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , Css.property "gap" "0.6rem"
                    , padding (rem 0.8)
                    , paddingTop (rem 0.2)
                    , flexGrow (Css.int 1)
                    , Css.property "pointer-events" "auto"
                    ]
                ]
                [ div [ css [ displayFlex, alignItems center, minHeight (rem 1.0) ] ]
                    [ trackingIndicator ]
                , div [ css [ displayFlex, flexDirection column, Css.property "gap" "2px" ] ]
                    [ span [ css [ fontSize (rem 0.75), Css.property "color" "var(--glass-text-muted)" ] ] [ text "Assigned" ]
                    , span [ css [ fontSize (rem 0.85), Css.property "color" "var(--glass-text-secondary)", fontWeight (Css.int 500) ] ]
                        [ text
                            (if assignedTimeText == "" then
                                "just now"

                             else
                                assignedTimeText
                            )
                        ]
                    ]
                , div
                    [ css
                        [ displayFlex
                        , alignItems center
                        , justifyContent spaceBetween
                        , Css.property "border-top" "1px solid var(--glass-card-border)"
                        , paddingTop (rem 0.6)
                        , marginTop auto
                        ]
                    ]
                    [ div [ css [ displayFlex, alignItems center, Css.property "gap" "6px" ] ]
                        [ div
                            [ css
                                [ Css.width (rem 1.2)
                                , Css.height (rem 1.2)
                                , borderRadius (pct 50)
                                , Css.property "background-color" "var(--glass-bg)"
                                , displayFlex
                                , alignItems center
                                , justifyContent center
                                , fontSize (rem 0.7)
                                , Css.property "color" "var(--glass-text-secondary)"
                                ]
                            ]
                            [ text "✓" ]
                        , span [ css [ fontSize (rem 0.8), Css.property "color" "var(--glass-text-secondary)", fontWeight (Css.int 500) ] ]
                            [ text <| String.fromInt (Assignment.completion assignment) ++ "% Done" ]
                        ]
                    , div [ id sheetButtonID, css [ cursor Css.pointer, Css.property "color" "var(--glass-text-muted)", hover [ Css.property "color" "var(--glass-text-primary)" ] ] ]
                        [ Ion.Icon.basic "ellipsis-horizontal-outline" |> SH.fromUnstyled ]
                    ]
                ]
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
