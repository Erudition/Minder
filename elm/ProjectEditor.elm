module TaskList exposing (ExpandedTask, Filter(..), Msg(..), NewTaskField, ViewState(..), attemptDateChange, defaultView, dynamicSliderThumbCss, extractSliderInput, filterName, onEnter, progressSlider, routeView, timingInfo, update, urlTriggers, view, viewControls, viewControlsClear, viewControlsCount, viewControlsFilters, viewInput, viewKeyedTask, viewTask, viewTasks, visibilitySwap)

import Activity.Activity as Activity exposing (ActivityID)
import Activity.Session
import Activity.Timeline
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import External.Commands as Commands
import Helpers exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2, lazy3, lazy4)
import ID
import Incubator.IntDict.Extra as IntDict
import Incubator.Todoist as Todoist
import Incubator.Todoist.Command as TodoistCommand
import IntDict
import Integrations.Marvin as Marvin
import Integrations.Todoist
import Ion.Icon
import Ion.Item
import Ion.List
import Json.Decode as JD
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as JE exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import Log
import Maybe.Extra as Maybe
import Process
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (Change, Parent)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.Model exposing (..)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period
import String.Normalize
import Task as Job
import Task.Assignable as ActionClass exposing (ActionClass, ActionClassID)
import Task.Assignment as Assignment exposing (Assignment, AssignmentID, AssignmentSkel, completed, getProgress, isRelevantNow)
import Task.Entry as Entry
import Task.Progress exposing (..)
import Task.Session
import TaskPort
import Url.Parser as P exposing ((</>), Parser, fragment, int, map, oneOf, s, string)
import VirtualDom
import ZoneHistory



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL
--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type ViewState
    = Normal


view : ViewState -> Profile -> Environment -> Html Msg
view state profile env =
    let
        renderView lazyState lazyProfile launchTime zone =
            case state of
                Normal filters expanded field editing ->
                    let
                        activeFilter =
                            Maybe.withDefault AllTasks (List.head filters)

                        modalIfOpen =
                            case editing of
                                Just (EditingProjectModal assignment) ->
                                    [ viewTaskEditModal profile env assignment ]

                                _ ->
                                    []
                    in
                    div
                        []
                        [ section
                            []
                            ([ lazy viewInput field
                             , Html.Styled.Lazy.lazy5 viewTasks env.launchTime env.timeZone activeFilter editing profile

                             -- , Html.Styled.Lazy.lazy4 viewControls filters env.launchTime env.timeZone profile
                             ]
                                ++ modalIfOpen
                            )
                        ]
    in
    Html.Styled.Lazy.lazy4 renderView state profile env.launchTime env.timeZone


viewTaskEditModal : Profile -> Environment -> Assignment -> Html Msg
viewTaskEditModal profile env assignment =
    let
        activitySelectOption givenActivity =
            node "ion-select-option"
                [ value (Activity.idToString (Activity.getID givenActivity)) ]
                [ text <| Activity.getName givenActivity ]
    in
    node "ion-modal"
        [ Attr.property "isOpen" (JE.bool True), on "didDismiss" <| JD.succeed CloseEditor ]
        [ node "ion-header"
            []
            [ node "ion-toolbar"
                []
                [ node "ion-buttons"
                    [ attribute "slot" "start" ]
                    [ node "ion-button" [ attribute "color" "medium", onClick CloseEditor ] [ text "Close" ]
                    ]
                , node "ion-title" [] [ text <| Assignment.getTitle assignment ]
                , node "ion-buttons"
                    [ attribute "slot" "end" ]
                    [ node "ion-button" [ attribute "strong" "true" ] [ text "Confirm" ]
                    ]
                ]
            ]
        , node "ion-content"
            [ class "ion-padding" ]
            [ node "ion-item" [] [ node "ion-input" [ type_ "text", attribute "label-placement" "stacked", attribute "label" "Task Title", placeholder "New Task Title Here" ] [] ]
            , node "ion-item"
                []
                [ node "ion-select"
                    [ type_ "text", attribute "label-placement" "stacked", attribute "label" "Activity", placeholder "What's the most fitting activity?" ]
                    (List.map activitySelectOption (Activity.allUnhidden profile.activities))
                ]
            ]
        ]



--, div [ class "task-drawer", class "slider-overlay" , Attr.hidden False ]
--    [ label [ for "readyDate" ] [ text "Ready" ]
--    , input [ type_ "date", name "readyDate", onInput (extractDate task.instance.id "Ready"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
--    , label [ for "startDate" ] [ text "Start" ]
--    , input [ type_ "date", name "startDate", onInput (extractDate task.instance.id "Start"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
--    , label [ for "finishDate" ] [ text "Finish" ]
--    , input [ type_ "date", name "finishDate", onInput (extractDate task.instance.id "Finish"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
--    , label [ for "deadlineDate" ] [ text "Deadline" ]
--    , input [ type_ "date", name "deadlineDate", onInput (extractDate task.instance.id "Deadline"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
--    , label [ for "expiresDate" ] [ text "Expires" ]
--    , input [ type_ "date", name "expiresDate", onInput (extractDate task.instance.id "Expires"), pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}" ] []
--    ]


taskTooltip : ( Moment, HumanMoment.Zone ) -> Assignment.Assignment -> String
taskTooltip ( time, timeZone ) task =
    -- hover tooltip
    String.concat <|
        List.intersperse "\n" <|
            List.filterMap identity
                ([ Just ("Class ID: " ++ Assignment.getClassIDString task)
                 , Just ("Instance ID: " ++ Assignment.getIDString task)
                 , Maybe.map (String.append "activity ID: ") (Assignment.getActivityIDString task)
                 , Just ("importance: " ++ String.fromFloat (Assignment.getImportance task))
                 , Just ("progress: " ++ Task.Progress.toString (Assignment.getProgress task))
                 , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance starts: ") (Assignment.getRelevanceStarts task)
                 , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance ends: ") (Assignment.getRelevanceEnds task)
                 ]
                    ++ List.map (\( k, v ) -> Just ("instance " ++ k ++ ": " ++ v)) (RepDict.list (Reg.latest task.instance).extra)
                )


editableDateLabel : ( Moment, HumanMoment.Zone ) -> String -> Maybe CalendarDate -> (String -> msg) -> List (Html msg)
editableDateLabel ( time, timeZone ) uniqueName givenDateMaybe changeEvent =
    let
        dateRelativeDescription =
            Maybe.withDefault "whenever" <|
                Maybe.map (Calendar.describeVsToday (HumanMoment.extractDate timeZone time)) givenDateMaybe

        dateFormValue =
            Maybe.withDefault "" <|
                Maybe.map Calendar.toStandardString givenDateMaybe
    in
    [ label [ for uniqueName, css [ hover [ textDecoration underline ] ] ]
        [ input
            [ type_ "date"
            , name uniqueName
            , id uniqueName
            , css
                [ Css.zIndex (Css.int -1)
                , Css.height (Css.em 1)
                , Css.width (Css.em 2)
                , Css.marginRight (Css.em -2)
                , visibility Css.hidden
                ]
            , onInput changeEvent -- TODO use onchange instead
            , pattern "[0-9]{4}-[0-9]{2}-[0-9]{2}"
            , value dateFormValue
            ]
            []
        , text dateRelativeDescription
        ]
    ]


editableTimeLabel : ( Moment, HumanMoment.Zone ) -> String -> Maybe TimeOfDay -> (String -> msg) -> List (Html msg)
editableTimeLabel env uniqueName givenTimeMaybe changeEvent =
    let
        timeDescription =
            Maybe.withDefault "(+ add time)" <|
                Maybe.map Clock.toShortString givenTimeMaybe

        timeFormValue =
            Maybe.withDefault "" <|
                Maybe.map Clock.toShortString givenTimeMaybe
    in
    [ label
        [ for uniqueName
        , class "editable-time-label"
        ]
        [ text " at "
        , span [ class "time-placeholder" ] [ text timeDescription ]
        ]
    , input
        [ type_ "time"
        , name uniqueName
        , id uniqueName
        , class "editable-time"
        , onInput changeEvent -- TODO use onchange instead
        , pattern "[0-9]{2}:[0-9]{2}" -- for unsupported browsers
        , value timeFormValue
        ]
        []
    ]


describeTaskMoment : Moment -> Zone -> FuzzyMoment -> String
describeTaskMoment now zone dueMoment =
    HumanMoment.fuzzyDescription now zone dueMoment


describeTaskPlan : ( Moment, HumanMoment.Zone ) -> Task.Session.FullSession -> String
describeTaskPlan ( time, timeZone ) fullSession =
    HumanMoment.fuzzyDescription time timeZone (Task.Session.start fullSession)


{-| Get the date out of a date input.
-}
attemptDateChange : ( Moment, HumanMoment.Zone ) -> Assignment -> Maybe FuzzyMoment -> String -> String -> Msg
attemptDateChange ( time, timeZone ) task oldFuzzyMaybe field input =
    case Calendar.fromNumberString input of
        Ok newDate ->
            case oldFuzzyMaybe of
                Nothing ->
                    UpdateTaskDate task field (Just (DateOnly newDate))

                Just (DateOnly _) ->
                    UpdateTaskDate task field (Just (DateOnly newDate))

                Just (Floating ( _, oldTime )) ->
                    UpdateTaskDate task field (Just (Floating ( newDate, oldTime )))

                Just (Global oldMoment) ->
                    UpdateTaskDate task field (Just (Global (HumanMoment.setDate newDate timeZone oldMoment)))

        Err msg ->
            NoOp


{-| Get the time out of a time input.
TODO Time Zones
-}
attemptTimeChange : ( Moment, HumanMoment.Zone ) -> Assignment -> Maybe FuzzyMoment -> String -> String -> Msg
attemptTimeChange ( time, timeZone ) task oldFuzzyMaybe whichTimeField input =
    case Clock.fromStandardString input of
        Ok newTime ->
            case oldFuzzyMaybe of
                Nothing ->
                    NoOp

                -- can't add a time when there's no date.
                Just (DateOnly oldDate) ->
                    -- we're adding a time!
                    UpdateTaskDate task whichTimeField (Just (Floating ( oldDate, newTime )))

                Just (Floating ( oldDate, _ )) ->
                    UpdateTaskDate task whichTimeField (Just (Floating ( oldDate, newTime )))

                Just (Global oldMoment) ->
                    UpdateTaskDate task whichTimeField (Just (Global (HumanMoment.setTime newTime timeZone oldMoment)))

        Err _ ->
            NoOp



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = Refilter (List Filter)
    | EditingClassTitle Assignment String
    | StopEditing
    | UpdateTitle Assignment String
    | OpenEditor Assignment
    | CloseEditor
    | Add
    | Delete AssignmentID
    | DeleteComplete
    | UpdateProgress Assignment Portion
    | FocusSlider Assignment Bool
    | UpdateTaskDate Assignment String (Maybe FuzzyMoment)
    | UpdateNewEntryField String
    | NoOp
    | TodoistServerResponse Todoist.Msg
    | MarvinServerResponse Marvin.Msg
    | StartTracking AssignmentID ActivityID
    | StopTracking AssignmentID
    | SimpleChange Change
    | LogError String


update : Msg -> ViewState -> Profile -> Environment -> ( ViewState, Change.Frame, Cmd Msg )
update msg state profile env =
    case msg of
        Add ->
            case state of
                Normal filters _ "" _ ->
                    ( Normal filters Nothing "" Nothing
                      -- resets new-entry-textbox to empty, collapses tasks
                    , Change.none
                    , Cmd.none
                    )

                Normal filters _ newTaskTitle _ ->
                    let
                        newAction : Change.Creator (Reg ActionClass.AssignmentSkel)
                        newAction c =
                            let
                                newClassChanger : Reg ActionClass.AssignmentSkel -> List Change
                                newClassChanger newClass =
                                    [ RepDb.addNew (Assignment.new (ID.fromPointer (Reg.getPointer newClass))) profile.taskInstances
                                    ]
                            in
                            ActionClass.newAssignableSkel c (ActionClass.normalizeTitle newTaskTitle) newClassChanger

                        frameDescription =
                            "Added new task class: " ++ newTaskTitle

                        finalChanges =
                            [ RepList.insert RepList.Last ("Added item: " ++ newTaskTitle) profile.errors
                            , RepList.insertNew RepList.Last
                                [ \c -> Entry.initWithClass (newAction (Change.reuseContext "action" c)) c ]
                                profile.taskEntries
                            ]
                    in
                    ( Normal filters Nothing "" Nothing
                      -- ^resets new-entry-textbox to empty, collapses tasks
                    , Change.saveChanges frameDescription finalChanges
                    , Cmd.none
                    )

        UpdateNewEntryField typedSoFar ->
            ( let
                (Normal filters expanded _ editingMaybe) =
                    state
              in
              Normal filters expanded typedSoFar editingMaybe
              -- TODO will collapse expanded tasks. Should it?
            , Change.none
            , Cmd.none
            )

        EditingClassTitle action newTitleSoFar ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar (Just <| EditingProjectTitle action.classID newTitleSoFar)
            , Change.none
            , Process.sleep 100
                |> Job.andThen (\_ -> ionInputSetFocus ("task-title-" ++ Assignment.getIDString action))
                |> Job.attempt (\_ -> NoOp)
            )

        OpenEditor action ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar (Just <| EditingProjectModal action)
            , Change.none
            , Cmd.none
            )

        CloseEditor ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar Nothing
            , Change.none
            , Cmd.none
            )

        StopEditing ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar Nothing
            , Change.none
            , Cmd.none
            )

        UpdateTitle action newTitle ->
            let
                (Normal filters expanded typedSoFar _) =
                    state

                normalizedNewTitle =
                    ActionClass.normalizeTitle newTitle

                changeTitleIfValid =
                    case (String.length normalizedNewTitle < 2) || normalizedNewTitle == Assignment.getTitle action of
                        True ->
                            Change.none

                        False ->
                            Change.saveChanges "Updating project title" [ Assignment.setProjectTitle newTitle action ]
            in
            ( Normal filters expanded typedSoFar Nothing
            , changeTitleIfValid
            , Cmd.none
            )

        UpdateTaskDate id field date ->
            let
                updateTask t =
                    { t | externalDeadline = date }
            in
            -- ( state
            -- , { profile | taskInstances = IntDict.update id (Maybe.map updateTask) profile.taskInstances }
            -- , Cmd.none
            -- )
            Debug.todo "UpdateTaskDate"

        Delete id ->
            -- ( state
            -- , { profile | taskInstances = IntDict.remove id profile.taskInstances }
            -- , Cmd.none
            -- )
            Debug.todo "Delete"

        DeleteComplete ->
            ( state
            , Change.none
              -- TODO { profile | taskInstances = IntDict.filter (\_ t -> not (Assignment.completed t)) profile.taskInstances }
            , Cmd.none
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
            --         { profile | taskInstances = IntDict.update givenTask.Assignment.id (Maybe.map updateTaskInstance) profile.taskInstances }
            -- in
            -- -- how does the new completion status compare to the previous?
            -- case ( isMax oldProgress, isMax ( newCompletion, getUnits oldProgress ) ) of
            --     ( False, True ) ->
            --         let
            --             ( viewState2, profile2WithTrackingStopped, trackingStoppedCmds ) =
            --                 update (StopTracking (Assignment.getID givenTask)) state profile1WithUpdatedInstance env
            --         in
            --         ( viewState2
            --         , profile2WithTrackingStopped
            --         , -- It was incomplete before, completed now
            --           Cmd.batch
            --             [ Commands.toast ("Marked as complete: " ++ givenTask.class.title)
            --
            --             --, Cmd.map TodoistServerResponse <|
            --             --    Integrations.Todoist.sendChanges profile.todoist
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
            --         ( state
            --         , profile1WithUpdatedInstance
            --         , Cmd.batch
            --             [ Commands.toast ("No longer marked as complete: " ++ givenTask.class.title)
            --
            --             -- , Cmd.map TodoistServerResponse <|
            --             --     Integrations.Todoist.sendChanges profile.todoist
            --             --         [ ( HumanMoment.toStandardString env.time, TodoistCommand.ItemUncomplete (TodoistCommand.RealItem givenTask.instance.id) ) ]
            --             ]
            --         )
            --
            --     _ ->
            --         -- nothing changed, completion-wise
            --         ( state, profile1WithUpdatedInstance, Cmd.none )
            Debug.todo "completion update"

        FocusSlider task focused ->
            ( state
            , Change.none
            , Cmd.none
            )

        NoOp ->
            ( state
            , Change.none
            , Cmd.none
            )

        TodoistServerResponse response ->
            let
                ( todoistChanges, whatHappened ) =
                    Integrations.Todoist.handle response profile
            in
            ( state
            , todoistChanges
            , Commands.toast whatHappened
            )

        MarvinServerResponse response ->
            -- gets intercepted up top!
            ( state, Change.none, Cmd.none )

        Refilter newList ->
            ( case state of
                Normal filterList expandedTaskMaybe newTaskField editing ->
                    Normal newList expandedTaskMaybe newTaskField editing
            , Change.none
            , Cmd.none
            )

        StartTracking instanceID activityID ->
            -- let
            --     ( addSession, sessionCommands ) =
            --         Refocus.switchTracking activityID (Just instanceID) profile env
            --
            --     ( newProfile2WithMarvinTimes, marvinCmds ) =
            --         Marvin.marvinUpdateCurrentlyTracking newProfile1WithSession env (Just instanceID) True
            -- in
            -- ( state
            -- , newProfile2WithMarvinTimes
            -- , Cmd.batch
            --     [ Cmd.map MarvinServerResponse <| marvinCmds
            --     , sessionCommands
            --     ]
            -- )
            Debug.todo "start tracking"

        StopTracking instanceID ->
            -- let
            --     activityToContinue =
            --         Activity.Timeline.currentActivityID profile.timeline
            --
            --     instanceToStop =
            --         Activity.Timeline.currentInstanceID profile.timeline
            --
            --     ( newProfile1WithSession, sessionCommands ) =
            --         Refocus.switchTracking activityToContinue Nothing profile env
            --
            --     ( newProfile2WithMarvinTimes, marvinCmds ) =
            --         Marvin.marvinUpdateCurrentlyTracking newProfile1WithSession env instanceToStop False
            -- in
            -- ( state
            -- , newProfile2WithMarvinTimes
            -- , Cmd.batch [ Cmd.map MarvinServerResponse <| marvinCmds, sessionCommands ]
            -- )
            Debug.todo "stop tracking"

        SimpleChange change ->
            ( state, Change.saveChanges "Simple change" [ change ], Cmd.none )

        LogError errorMsg ->
            ( state, Change.saveChanges "Log Error" [ RepList.insert RepList.Last errorMsg profile.errors ], Cmd.none )
