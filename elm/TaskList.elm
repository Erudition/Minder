module TaskList exposing (ExpandedTask, Filter(..), Msg(..), NewTaskField, ViewState(..), attemptDateChange, defaultView, dynamicSliderThumbCss, extractSliderInput, filterName, onEnter, progressSlider, routeView, timingInfo, update, urlTriggers, view, viewControlsClear, viewControlsCount, viewControlsFilters, viewInput, visibilitySwap)

import Activity.Activity as Activity exposing (ActivityID)
import Activity.HistorySession
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Effect exposing (Effect(..))
import External.Commands as Commands
import Helpers exposing (..)
import Html.Styled as SH exposing (..)
import Html.Styled.Attributes as SHA exposing (..)
import Html.Styled.Events exposing (..)
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
import Popup.Editor.Assignable
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (Change, Parent)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.Model exposing (..)
import Shared.PopupType as PopupType exposing (PopupType)
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
import VirtualDom
import ZoneHistory



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type Filter
    = AllTasks
    | AllIncompleteTasks
    | AllRelevantTasks
    | CompleteTasksOnly



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type ViewState
    = Normal (List Filter) (Maybe ExpandedTask) NewTaskField (Maybe CurrentlyEditing)


routeView : Parser (ViewState -> a) a
routeView =
    P.map (Normal [ AllRelevantTasks ] Nothing "" Nothing) (P.s "projects")


defaultView : ViewState
defaultView =
    Normal [ AllRelevantTasks ] Nothing "" Nothing


type alias ExpandedTask =
    AssignableID


type alias NewTaskField =
    String


type CurrentlyEditing
    = EditingAssignableTitle AssignableID String
    | EditingProjectDate
    | EditingProjectModal (Maybe Assignment)


view : ViewState -> Profile -> Shared -> Html Msg
view state profile env =
    let
        renderView lazyState lazyProfile launchTime zone =
            case state of
                Normal filters expanded field editing ->
                    let
                        activeFilter =
                            Maybe.withDefault AllTasks (List.head filters)

                        -- modalIfOpen =
                        --     case editing of
                        --         Just (EditingProjectModal assignment) ->
                        --             [ viewTaskEditModal profile env assignment ]
                        --         _ ->
                        --             []
                    in
                    div
                        []
                        [ section
                            []
                            [ lazy viewInput field
                            , Html.Styled.Lazy.lazy4 viewProjects env.time env.timeZone activeFilter profile

                            -- , Html.Styled.Lazy.lazy5 viewTasks env.launchTime env.timeZone activeFilter editing profile
                            -- , Html.Styled.Lazy.lazy4 viewControls filters env.launchTime env.timeZone profile
                            ]
                        ]
    in
    Html.Styled.Lazy.lazy4 renderView state profile env.launchTime env.timeZone


viewInput : String -> Html Msg
viewInput newEntryFieldContents =
    node "ion-input"
        [ class "new-task"
        , placeholder "Type new project name here..."
        , autofocus True
        , value newEntryFieldContents
        , name "newTask"
        , onInput UpdateNewEntryField
        , onEnter AddProject
        , attribute "data-flip-key" ("task-named-" ++ String.Normalize.slug newEntryFieldContents)
        ]
        []


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg

            else
                JD.fail "not ENTER"
    in
    on "keydown" (JD.andThen isEnter keyCode)



-- VIEW ALL TODOS
-- viewTasks : String -> List Assignment -> Html Msg


viewProjects : Moment -> HumanMoment.Zone -> Filter -> Profile -> Html Msg
viewProjects time timeZone filter profile =
    let
        trackedTaskMaybe =
            Profile.currentAssignmentID profile

        taskLayers =
            Task.Layers.buildLayerDatabase profile.projects

        projectList =
            AnyDict.values taskLayers.projects
    in
    Keyed.node "ion-list" [ SHA.attribute "lines" "full" ] <|
        List.map (viewKeyedProject profile ( time, timeZone ) trackedTaskMaybe) projectList


viewKeyedProject : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Project -> ( String, Html Msg )
viewKeyedProject profile ( time, timeZone ) trackedTaskMaybe rootEntryItem =
    ( Project.idString rootEntryItem, lazy4 viewProject profile ( time, timeZone ) trackedTaskMaybe rootEntryItem )


viewProject : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Project -> Html Msg
viewProject profile ( time, timeZone ) trackedTaskMaybe project =
    let
        entryContents =
            case Project.children project |> RepList.listValues of
                [ ProjectSkel.AssignableIsHere assignableSkelReg ] ->
                    viewAssignable profile ( time, timeZone ) trackedTaskMaybe (Assignable.fromSkel project assignableSkelReg)

                _ ->
                    text "viewing multiple assignables in project NYI"
    in
    node "ion-item-sliding"
        []
        [ node "ion-item"
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
                    []
                    [ text "" -- Project title if assignable is deeper
                    ]
                , entryContents
                ]
            ]
        , node "ion-item-options"
            []
            [ node "ion-item-option" [ attribute "color" "danger" ] [ text "delete" ]
            ]
        ]


viewAssignable : Profile -> ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Assignable -> Html Msg
viewAssignable profile ( time, timeZone ) trackedTaskMaybe assignable =
    let
        viewAssignableTitle =
            [ text <| Assignable.title assignable ]

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
                ++ [ addAssignment ]

        addAssignment =
            node "ion-card"
                [ css [ minWidth (pct 60), maxWidth (pct 90) ] ]
                [ node "ion-card-header"
                    []
                    [ node "ion-card-subtitle" [] [ text "Add the first assignment" ]
                    ]
                , node "ion-card-content"
                    []
                    []
                , node "ion-button" [ attribute "fill" "clear", onClick (AddAssignment assignable) ] [ node "ion-icon" [ name "add-circle-outline" ] [], text "assign" ]
                ]
    in
    div
        [ class "assignments" ]
        [ node "ion-card-title" [] (viewAssignableTitle ++ viewSubAssignables)
        , div [ css [ displayFlex, overflowX scroll ] ] viewAssignments
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
                    ", " ++ HumanMoment.describeGapVsNowSimple timeZone time assignedAt

        sheetButtonID =
            "actionsheet-trigger-for-assignment-" ++ Assignment.idString assignment

        presentActionSheet =
            ActionSheet.actionSheet
                [ ActionSheet.header "Action Sheet!"
                , ActionSheet.isOpen True
                , ActionSheet.trigger sheetButtonID
                ]
                [ ActionSheet.deleteButton (DeleteAssignment assignment)
                , startTrackingButton assignment trackedTaskMaybe
                , ActionSheet.button "Continue" (Toast "clicked Continue!")
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
        [ css [ Css.width (pct 90), minWidth (rem 10), maxWidth (rem 300) ] ]
        [ node "ion-card-content"
            []
            [ node "ion-note"
                [ title assignmentTooltip ]
                [ SH.fromUnstyled <| identicon "1em" (Assignment.idString assignment)
                , text <| "#" ++ String.fromInt (index + 1) ++ assignedTimeText
                ]
            , node "ion-list" [] [ node "ion-item" [] [ text <| "action 1" ] ]
            , node "ion-button" [ attribute "fill" "clear", attribute "color" "danger", onClick (DeleteAssignment assignment) ] [ node "ion-icon" [ name "trash-outline" ] [] ]
            , node "ion-button" [ attribute "fill" "clear", attribute "color" "primary", SHA.id sheetButtonID ] [ node "ion-icon" [ name "menu-outline" ] [] ]
            ]
        , presentActionSheet
        ]


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



--- old view
-- viewTasks : Moment -> HumanMoment.Zone -> Filter -> Maybe CurrentlyEditing -> Profile -> Html Msg
-- viewTasks time timeZone filter editingMaybe profile =
--     let
--         trackedTaskMaybe =
--             Activity.HistorySession.currentAssignmentID profile.timeline
--         sortedTasks =
--             allFullTaskInstances profile ( time, timeZone )
--         isVisible task =
--             case filter of
--                 CompleteTasksOnly ->
--                     Assignment.isCompleted task
--                 AllIncompleteTasks ->
--                     not (Assignment.isCompleted task)
--                 AllRelevantTasks ->
--                     not (Assignment.isCompleted task) && Assignment.isRelevantNow task time timeZone
--                 _ ->
--                     True
--         allCompleted =
--             List.all Assignment.isCompleted sortedTasks
--     in
--     Keyed.node "ion-list"
--         []
--     <|
--         List.map (viewKeyedTask ( time, timeZone ) trackedTaskMaybe editingMaybe) (List.filter isVisible sortedTasks)
-- VIEW INDIVIDUAL ENTRIES
-- viewKeyedTask : ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Maybe CurrentlyEditing -> Assignment -> ( String, Html Msg )
-- viewKeyedTask ( time, timeZone ) trackedTaskMaybe editingMaybe task =
--     ( Assignment.idString task, lazy4 viewTask ( time, timeZone ) trackedTaskMaybe editingMaybe task )
-- -- viewTask : Assignment -> Html Msg
-- viewTask : ( Moment, HumanMoment.Zone ) -> Maybe AssignmentID -> Maybe CurrentlyEditing -> Assignment -> Html Msg
-- viewTask ( time, timeZone ) trackedTaskMaybe editingMaybe task =
--     node "ion-item-sliding"
--         []
--         [ node "ion-item"
--             [ classList [ ( "completed", Assignment.isCompleted task ), ( "editing", False ) ]
--             , attribute "data-flip-key" ("task-" ++ Assignment.assignableIDString task)
--             ]
--             [ div
--                 [ class "task-bubble"
--                 , attribute "slot" "start"
--                 , title (taskTooltip ( time, timeZone ) task)
--                 , onClick (OpenEditor <| Just task)
--                 , css
--                     [ Css.height (rem 2)
--                     , Css.width (rem 2)
--                     , backgroundColor (activityColor task).lighter
--                     , Css.color (activityColor task).medium
--                     , border3 (px 2) solid (activityColor task).darker
--                     , displayFlex
--                     , borderRadius (pct 100)
--                     -- , margin (rem 0.5)
--                     , fontSize (rem 1)
--                     , alignItems center
--                     , justifyContent center
--                     -- , padding (rem 0.2)
--                     , fontFamily monospace
--                     , fontWeight Css.normal
--                     , textAlign center
--                     ]
--                 ]
--                 [ if SmartTime.Duration.isZero (Assignment.estimatedEffort task) then
--                     text "?"
--                   else
--                     text (String.fromInt (Basics.round (SmartTime.Duration.inMinutes (Assignment.estimatedEffort task))))
--                 ]
--             --, node "ion-icon" [ name "star", attribute "slot" "start", onClick (OpenEditor <| Just task) ] []
--             , viewTaskTitle task editingMaybe
--             , timingInfo ( time, timeZone ) task
--             , div
--                 [ class "view" ]
--                 [ div
--                     [ class "task-times"
--                     , css
--                         [ Css.width (rem 3)
--                         , displayFlex
--                         , flex3 (num 0) (num 0) (rem 3)
--                         , flexDirection column
--                         , fontSize (rem 0.7)
--                         , justifyContent center
--                         , alignItems center
--                         , textAlign center
--                         , letterSpacing (rem -0.1)
--                         ]
--                     ]
--                     [ div
--                         [ class "minimum-duration"
--                         , css
--                             [ justifyContent Css.end
--                             ]
--                         ]
--                         [ if SmartTime.Duration.isZero (Assignment.minEffort task) then
--                             text ""
--                           else
--                             text (String.fromInt (Basics.round (SmartTime.Duration.inMinutes (Assignment.estimatedEffort task))))
--                         ]
--                     , div
--                         [ class "maximum-duration"
--                         , css
--                             [ justifyContent Css.end
--                             ]
--                         ]
--                         [ if SmartTime.Duration.isZero (Assignment.maxEffort task) then
--                             text ""
--                           else
--                             text (String.fromInt (Basics.round (SmartTime.Duration.inMinutes (Assignment.estimatedEffort task))))
--                         ]
--                     ]
--                 -- , div
--                 --     [ class "sessions"
--                 --     , css
--                 --         [ fontSize (Css.em 0.5)
--                 --         , Css.width (pct 50)
--                 --         , displayFlex
--                 --         , flexDirection column
--                 --         , alignItems end
--                 --         , textAlign center
--                 --         ]
--                 --     ]
--                 --     (plannedSessions ( time, timeZone ) task)
--                 ]
--             ]
--         , node "ion-item-options"
--             []
--             [ node "ion-item-option" [ attribute "color" "danger", onClick (Delete task) ] [ text "delete" ]
--             , startTrackingButton task trackedTaskMaybe
--             ]
--         ]
-- viewTaskTitle : Assignment -> Maybe CurrentlyEditing -> Html Msg
-- viewTaskTitle assignment editingMaybe =
--     let
--         titleNotEditing =
--             node "ion-label"
--                 [ css
--                     [ fontWeight (Css.int <| Basics.round (Assignable.importance (Assignment.assignable assignment) * 200 + 200)) ]
--                 , onDoubleClick (EditingClassTitle assignment <| Assignment.title assignment)
--                 , attribute "data-flip-key" ("title-for-task-named-" ++ String.Normalize.slug (Assignment.title assignment))
--                 ]
--                 [ text <| Assignment.title assignment
--                 , span [ css [ opacity (num 0.4), fontSize (Css.em 0.5), fontWeight (Css.int 200) ] ] [ text <| "#" ++ String.fromInt assignment.index ]
--                 ]
--         titleEditing newTitleSoFar =
--             node "ion-input"
--                 [ value newTitleSoFar
--                 , placeholder <| "Enter a new name for: " ++ Assignment.title assignment
--                 , name "title"
--                 , id ("task-title-" ++ Assignment.idString assignment)
--                 , onInput (EditingClassTitle assignment)
--                 , on "ionBlur" (JD.succeed StopEditing)
--                 , onEnter (UpdateTitle assignment newTitleSoFar)
--                 , SHA.property "clearInput" (JE.bool True)
--                 , autofocus True
--                 , attribute "enterkeyhint" "done"
--                 , attribute "helper-text" <| "Enter a new title for the project. "
--                 , spellcheck True
--                 , minlength 2
--                 , SHA.required True
--                 , attribute "error-text" <| "Minimum 2 characters."
--                 , attribute "autocorrect" "on"
--                 , attribute "data-flip-key" ("title-for-task-named-" ++ String.Normalize.slug (Assignment.title assignment))
--                 ]
--                 []
--     in
--     case editingMaybe of
--         Just (EditingAssignableTitle classID newTitleSoFar) ->
--             if classID == assignment.assignableID then
--                 titleEditing newTitleSoFar
--             else
--                 titleNotEditing
--         _ ->
--             titleNotEditing
-- viewTaskEditModal : Profile -> Shared -> (Maybe Assignment) -> Html Msg
-- viewTaskEditModal profile env assignmentMaybe =
--     let
--         activitySelectOption givenActivity =
--             node "ion-select-option"
--                 [ value (Activity.idToString (Activity.getID givenActivity)) ]
--                 [ text <| Activity.getName givenActivity ]
--     in
--     node "ion-popover"
--         [ SHA.property "isOpen" (JE.bool True), on "didDismiss" <| JD.succeed CloseEditor ]
--         [ node "ion-header"
--             []
--             [ node "ion-toolbar"
--                 []
--                 [ node "ion-buttons"
--                     [ attribute "slot" "start" ]
--                     [ node "ion-button" [ attribute "color" "medium", onClick CloseEditor ] [ text "Close" ]
--                     ]
--                 , node "ion-title" [] [ text <| Assignment.getTitle assignment ]
--                 , node "ion-buttons"
--                     [ attribute "slot" "end" ]
--                     [ node "ion-button" [ attribute "strong" "true" ] [ text "Confirm" ]
--                     ]
--                 ]
--             ]
--         , node "ion-content"
--             [ class "ion-padding" ]
--             [ node "ion-item" [] [ node "ion-input" [ type_ "text", attribute "label-placement" "stacked", attribute "label" "Task Title", placeholder "New Task Title Here" ] [] ]
--             , node "ion-item"
--                 []
--                 [ node "ion-select"
--                     [ type_ "text", attribute "label-placement" "stacked", attribute "label" "Activity", placeholder "What's the most fitting activity?" ]
--                     (List.map activitySelectOption (Activity.allUnhidden profile.activities))
--                 ]
--             ]
--         ]
--, div [ class "task-drawer", class "slider-overlay" , SHA.hidden False ]
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
-- plannedSessions env task =
--     let
--         durationToWidgetWidthPct duration =
--             (clamp 20 120 (SmartTime.Duration.inMinutes duration) / 120) * 100
--         sessionWidget fullSession =
--             div
--                 [ css
--                     [ borderStyle solid
--                     , borderWidth (px 1)
--                     , borderColor (Css.hsl 0 1 0)
--                     , borderRadius (Css.em 1)
--                     , padding (Css.em 0.2)
--                     , backgroundColor (Css.hsl 202 0.83 0.86)
--                     , Css.width (pct (durationToWidgetWidthPct (Task.Session.duration fullSession)))
--                     , overflow Css.hidden
--                     , Css.height (Css.em 2)
--                     ]
--                 ]
--                 [ text <| describeTaskPlan env fullSession ]
--     in
--     List.map sessionWidget (Task.Session.getFullSessions task)


activityColor task =
    let
        activityDerivation n =
            modBy 360 ((n + 1) * 333)
    in
    case Maybe.map String.length (Assignment.activityIDString task) of
        Just activityNumber ->
            let
                hue =
                    toFloat (activityDerivation activityNumber)
            in
            { lighter = Css.hsl hue 0.5 0.8
            , medium = Css.hsl hue 0.5 0.5
            , darker = Css.hsl hue 0.5 0.3
            }

        Nothing ->
            { lighter = Css.hsl 0 0 0.8
            , medium = Css.hsl 0 0 0.5
            , darker = Css.hsl 0 0 0.3
            }



-- taskTooltip : ( Moment, HumanMoment.Zone ) -> Assignment.Assignment -> String
-- taskTooltip ( time, timeZone ) task =
--     -- hover tooltip
--     String.concat <|
--         List.intersperse "\n" <|
--             List.filterMap identity
--                 ([ Just ("Class ID: " ++ Assignment.assignableIDString task)
--                  , Just ("Instance ID: " ++ Assignment.idString task)
--                  , Maybe.map (String.append "activity ID: ") (Assignment.activityIDString task)
--                  , Just ("importance: " ++ String.fromFloat (Assignable.importance Assignment.assignable task))
--                  , Just ("progress: " ++ Task.Progress.toString (Assignment.progress task))
--                  , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance starts: ") (Assignment.relevanceStarts task)
--                  , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance ends: ") (Assignment.relevanceEnds task)
--                  ]
--                     ++ List.map (\( k, v ) -> Just ("instance " ++ k ++ ": " ++ v)) (RepDict.list (Reg.latest task.assignment).extra)
--                 )


{-| This slider is an html input type=range so it does most of the work for us. (It's accessible, works with arrow keys, etc.) No need to make our own ad-hoc solution! We theme it to look less like a form control, and become the background of our Assignment entry.
-}
progressSlider : Assignment -> Html Msg
progressSlider task =
    let
        completion =
            Assignment.progress task
    in
    input
        [ class "task-progress"
        , type_ "range"
        , value <| String.fromInt <| getPortion completion
        , SHA.min "0"
        , SHA.max <| String.fromInt <| getWhole completion
        , step
            (if isDiscrete <| getUnits completion then
                "1"

             else
                "any"
            )
        , onInput (extractSliderInput task)

        -- , onDoubleClick (EditingClassTitle task True)
        , onFocus (FocusSlider task True)
        , onBlur (FocusSlider task False)
        , dynamicSliderThumbCss (getNormalizedPortion (Assignment.progress task))
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

        thumbAttributes =
            [ transforms [ translateY (px (-50 + offset)), rotate (deg angle) ] ]
    in
    css
        [ focus
            [ pseudoElement "-moz-range-thumb" thumbAttributes
            , pseudoElement "-webkit-slider-thumb" thumbAttributes
            , pseudoElement "-ms-thumb" thumbAttributes
            ]
        ]


extractSliderInput : Assignment -> String -> Msg
extractSliderInput task input =
    UpdateProgress task <|
        Basics.round <|
            -- TODO not ideal. keep decimals?
            Maybe.withDefault 0
            <|
                String.toFloat input


{-| Human-friendly text in a task summarizing the various TaskMoments (e.g. the due date)
TODO currently only captures deadline
TODO doesn't specify "ago", "in", etc.
-}
timingInfo : ( Moment, HumanMoment.Zone ) -> Assignment -> Html Msg
timingInfo ( time, timeZone ) task =
    let
        effortDescription =
            describeEffort task

        uniquePrefix =
            "task-" ++ Assignment.idString task ++ "-"

        dateLabelNameAndID : String
        dateLabelNameAndID =
            uniquePrefix ++ "due-date-field"

        dueDate_editable =
            editableDateLabel ( time, timeZone )
                dateLabelNameAndID
                (Maybe.map (HumanMoment.dateFromFuzzy timeZone) (Assignment.externalDeadline task))
                (attemptDateChange ( time, timeZone ) task (Assignment.externalDeadline task) "Due")

        timeLabelNameAndID =
            uniquePrefix ++ "due-time-field"

        dueTime_editable =
            editableTimeLabel ( time, timeZone )
                timeLabelNameAndID
                deadlineTime
                (attemptTimeChange ( time, timeZone ) task (Assignment.externalDeadline task) "Due")

        deadlineTime =
            case Maybe.map (HumanMoment.timeFromFuzzy timeZone) (Assignment.externalDeadline task) of
                Just (Just timeOfDay) ->
                    Just timeOfDay

                _ ->
                    Nothing
    in
    node "ion-note"
        [ class "timing-info" ]
        [ text <| "Effort: " ++ effortDescription ]


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


describeEffort : Assignment -> String
describeEffort task =
    let
        sayEffort amount =
            HumanDuration.breakdownNonzero amount
    in
    case ( sayEffort (Assignment.minEffort task), sayEffort (Assignment.estimatedEffort task), sayEffort (Assignment.maxEffort task) ) of
        ( [], [], [] ) ->
            ""

        ( [], [], givenMax ) ->
            "up to " ++ HumanDuration.abbreviatedSpaced givenMax ++ " by "

        ( givenMin, [], [] ) ->
            "at least " ++ HumanDuration.abbreviatedSpaced givenMin ++ " by "

        ( givenMin, [], givenMax ) ->
            HumanDuration.abbreviatedSpaced givenMin ++ " - " ++ HumanDuration.abbreviatedSpaced givenMax ++ " by "

        ( [], predicted, [] ) ->
            "~" ++ HumanDuration.abbreviatedSpaced predicted ++ " by "

        ( givenMin, predicted, givenMax ) ->
            "~" ++ HumanDuration.abbreviatedSpaced predicted ++ " (" ++ HumanDuration.abbreviatedSpaced givenMin ++ "-" ++ HumanDuration.abbreviatedSpaced givenMax ++ ") by "


describeTaskMoment : Moment -> Zone -> FuzzyMoment -> String
describeTaskMoment now zone dueMoment =
    HumanMoment.fuzzyDescription now zone dueMoment



-- describeTaskPlan : ( Moment, HumanMoment.Zone ) -> Task.Session.PlannedSession -> String
-- describeTaskPlan ( time, timeZone ) fullSession =
--     HumanMoment.fuzzyDescription time timeZone (Task.Session.start fullSession)


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



-- viewControls : List Filter -> Moment -> HumanMoment.Zone -> Profile -> Html Msg
-- viewControls visibilityFilters time zone profile =
--     let
--         sortedTasks =
--             allFullTaskInstances profile ( time, zone )
--         tasksCompleted =
--             List.length (List.filter Assignment.isCompleted sortedTasks)
--         tasksLeft =
--             List.length sortedTasks - tasksCompleted
--     in
--     footer
--         [ class "footer"
--         , SHA.hidden (List.isEmpty sortedTasks)
--         ]
--         [ Html.Styled.Lazy.lazy viewControlsCount tasksLeft
--         , Html.Styled.Lazy.lazy viewControlsFilters visibilityFilters
--         , Html.Styled.Lazy.lazy viewControlsClear tasksCompleted
--         ]


viewControlsCount : Int -> Html msg
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


viewControlsFilters : List Filter -> Html Msg
viewControlsFilters visibilityFilters =
    ul
        [ class "filters" ]
        [ visibilitySwap "all" AllTasks visibilityFilters
        , text " "
        , visibilitySwap "active" AllIncompleteTasks visibilityFilters
        , text " "
        , visibilitySwap "completed" CompleteTasksOnly visibilityFilters
        , text " "
        , visibilitySwap "relevant" AllRelevantTasks visibilityFilters
        ]


visibilitySwap : String -> Filter -> List Filter -> Html Msg
visibilitySwap name visibilityToDisplay actualVisibility =
    let
        isCurrent =
            List.member visibilityToDisplay actualVisibility

        changeList =
            if isCurrent then
                List.remove visibilityToDisplay actualVisibility

            else
                visibilityToDisplay :: actualVisibility
    in
    li
        []
        [ input
            [ type_ "checkbox"
            , SHA.checked isCurrent
            , onClick (Refilter changeList)
            , classList [ ( "selected", isCurrent ) ]
            , SHA.name name
            ]
            []
        , label [ for name ] [ text (filterName visibilityToDisplay) ]
        ]


filterName : Filter -> String
filterName filter =
    case filter of
        AllTasks ->
            "All"

        CompleteTasksOnly ->
            "Complete"

        AllIncompleteTasks ->
            "Remaining"

        AllRelevantTasks ->
            "Doable Now"



-- viewControlsClear : Int -> VirtualDom.Node Msg


viewControlsClear : Int -> Html Msg
viewControlsClear tasksCompleted =
    button
        [ class "clear-completed"
        , SHA.hidden (tasksCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ String.fromInt tasksCompleted ++ ")")
        ]



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = Refilter (List Filter)
    | StopEditing
    | UpdateTitle Assignable String
    | OpenEditor (Maybe Assignment)
    | CloseEditor
    | AddProject
    | AddAssignment Assignable
    | DeleteAssignment Assignment
    | DeleteComplete
    | UpdateProgress Assignment Portion
    | FocusSlider Assignment Bool
    | UpdateTaskDate Assignment String (Maybe FuzzyMoment)
    | UpdateNewEntryField String
    | NoOp
    | TodoistServerResponse Todoist.Msg
    | MarvinServerResponse Marvin.Msg
    | StartTrackingAssignment Assignment ActivityID
    | StopTrackingAssignment Assignment
    | SimpleChange Change
    | LogError String
    | Toast String


update : Msg -> ViewState -> Profile -> Shared -> ( ViewState, Change.Frame, List (Effect msg) )
update msg state profile env =
    case msg of
        AddProject ->
            case state of
                Normal filters _ "" _ ->
                    ( Normal filters Nothing "" Nothing
                      -- resets new-entry-textbox to empty, collapses tasks
                    , Change.none
                    , []
                    )

                Normal filters _ newProjectTitle _ ->
                    let
                        newProjectSkel =
                            Project.createTopLevelSkel projectChanger

                        projectChanger project =
                            [ Project.setTitle (Just newProjectTitle) project ]

                        -- newAssignable : Change.Creator (Reg AssignableSkel)
                        -- newAssignable c =
                        --     let
                        --         assignableChanger : Reg AssignableSkel -> List Change
                        --         assignableChanger parentAssignable =
                        --             [ RepDb.addNew (Assignment.new (ID.fromPointer (Reg.getPointer parentAssignable))) profile.assignments
                        --             , RepList.insert RepList.Last (Action.ActionIsHere actionToAdd) (Reg.latest parentAssignable).children
                        --             ]
                        --         actionToAdd =
                        --             Action.newActionSkel (Change.reuseContext "in-action" c) "first action" (\_ -> [])
                        --     in
                        --     Assignable.newWithoutAction c (Assignable.normalizeTitle newProjectTitle) assignableChanger
                        frameDescription =
                            "Added project: " ++ newProjectTitle

                        finalChanges =
                            [ RepList.insert RepList.Last frameDescription profile.errors
                            , RepDb.addNew newProjectSkel profile.projects

                            -- , RepList.insertNew RepList.Last
                            --     [ \c -> Project.AssignableIsHere (newAssignable (Change.reuseContext "Assignable in Project" c)) ]
                            --     profile.projects
                            ]
                    in
                    ( Normal filters Nothing "" Nothing
                      -- ^resets new-entry-textbox to empty, collapses tasks
                    , Change.saveChanges frameDescription finalChanges
                    , []
                    )

        AddAssignment assignable ->
            let
                frameDescription =
                    "Added a new assignment."

                finalChanges =
                    [ RepList.insert RepList.Last frameDescription profile.errors
                    , Assignment.create (\_ -> []) assignable
                    ]
            in
            ( state
            , Change.saveChanges frameDescription finalChanges
            , []
            )

        DeleteAssignment assignment ->
            let
                frameDescription =
                    "Deleted assignment"

                finalChanges =
                    [ RepList.insert RepList.Last frameDescription profile.errors
                    , Assignment.delete assignment
                    ]
            in
            ( state
            , Change.saveChanges frameDescription finalChanges
            , []
            )

        UpdateNewEntryField typedSoFar ->
            ( let
                (Normal filters expanded _ editingMaybe) =
                    state
              in
              Normal filters expanded typedSoFar editingMaybe
              -- TODO will collapse expanded tasks. Should it?
            , Change.none
            , []
            )

        OpenEditor actionMaybe ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar (Just <| EditingProjectModal actionMaybe)
            , Change.none
            , [ Effect.OpenPopup (PopupType.AssignmentEditor actionMaybe) ]
            )

        CloseEditor ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar Nothing
            , Change.none
            , [ Effect.ClosePopup ]
            )

        StopEditing ->
            let
                (Normal filters expanded typedSoFar _) =
                    state
            in
            ( Normal filters expanded typedSoFar Nothing
            , Change.none
            , []
            )

        UpdateTitle assignable newTitle ->
            let
                (Normal filters expanded typedSoFar _) =
                    state

                normalizedNewTitle =
                    String.trim newTitle

                changeTitleIfValid =
                    if (String.length normalizedNewTitle < 2) || normalizedNewTitle == Assignable.title assignable then
                        Change.none

                    else
                        Change.saveChanges "Updating project title" [ Assignable.setTitle newTitle assignable ]
            in
            ( Normal filters expanded typedSoFar Nothing
            , changeTitleIfValid
            , []
            )

        UpdateTaskDate id field date ->
            let
                updateTask t =
                    { t | externalDeadline = date }
            in
            -- ( state
            -- , { profile | taskInstances = IntDict.update id (Maybe.map updateTask) profile.taskInstances }
            -- , []
            -- )
            Debug.todo "Not yet implemented: UpdateTaskTitle"

        DeleteComplete ->
            ( state
            , Change.none
              -- TODO { profile | taskInstances = IntDict.filter (\_ t -> not (Assignment.completed t)) profile.taskInstances }
            , []
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
            --             -- , Cmd.map TodoistServerResponse <|item
            --
            --     _ ->
            --         -- nothing changed, completion-wise
            --         ( state, profile1WithUpdatedInstance, [] )
            Debug.todo "completion update"

        FocusSlider task focused ->
            ( state
            , Change.none
            , []
            )

        NoOp ->
            ( state
            , Change.none
            , []
            )

        TodoistServerResponse response ->
            let
                ( todoistChanges, whatHappened ) =
                    Integrations.Todoist.handle response profile
            in
            ( state
            , todoistChanges
            , [ Effect.Toast whatHappened ]
            )

        MarvinServerResponse response ->
            -- gets intercepted up top!
            ( state, Change.none, [] )

        Refilter newList ->
            ( case state of
                Normal filterList expandedTaskMaybe newTaskField editing ->
                    Normal newList expandedTaskMaybe newTaskField editing
            , Change.none
            , []
            )

        StartTrackingAssignment assignment activityID ->
            let
                projectLayers =
                    Debug.todo "projectlayers for switching tracking"

                ( addSessionChanges, sessionCommands ) =
                    Refocus.switchTracking (TimeTrackable.TrackedAssignmentID (Assignment.id assignment) activityID) profile projectLayers ( env.time, env.timeZone )

                -- ( newProfile2WithMarvinTimes, marvinCmds ) =
                --     Marvin.marvinUpdateCurrentlyTracking newProfile1WithSession env (Just instanceID) True
            in
            ( state
            , Change.saveChanges "Start tracking" addSessionChanges
            , []
              -- , Cmd.batch
              --     [ sessionCommands
              --     -- , Cmd.map MarvinServerResponse <| marvinCmds
              --     ]
            )

        StopTrackingAssignment instanceID ->
            let
                activityToContinue =
                    Activity.HistorySession.currentActivityID (RepList.listValues profile.timeline)

                instanceToStop =
                    Activity.HistorySession.currentAssignmentID (RepList.listValues profile.timeline)

                projectLayers =
                    Debug.todo "projectlayers for switching tracking"

                ( sessionChanges, sessionCommands ) =
                    Refocus.switchTracking TimeTrackable.stub profile projectLayers ( env.time, env.timeZone )

                -- ( newProfile2WithMarvinTimes, marvinCmds ) =
                --     Marvin.marvinUpdateCurrentlyTracking newProfile1WithSession env instanceToStop False
            in
            ( state
            , Change.saveChanges "Stop tracking" sessionChanges
            , []
              -- , Cmd.batch
              --     [ sessionCommands
              --     -- , Cmd.map MarvinServerResponse <| marvinCmds
              --     ]
            )

        SimpleChange change ->
            ( state, Change.saveChanges "Simple change" [ change ], [] )

        LogError errorMsg ->
            ( state, Change.saveChanges "Log Error" [ RepList.insert RepList.Last errorMsg profile.errors ], [] )

        Toast toastMsg ->
            ( state, Change.none, [ Effect.Toast toastMsg ] )


urlTriggers : Profile -> ( Moment, HumanMoment.Zone ) -> List ( String, Dict.Dict String Msg )
urlTriggers profile ( time, timeZone ) =
    let
        fullTaskInstances =
            -- TODO include unsaved assignments
            Task.Layers.getAllSavedAssignments (Task.Layers.buildLayerDatabase profile.projects)

        tasksIDsWithDoneMsg =
            List.map doneTriggerEntry fullTaskInstances

        doneTriggerEntry fullInstance =
            ( Assignment.idString fullInstance, UpdateProgress fullInstance (getWhole (Assignment.progress fullInstance)) )

        taskIDsWithStartMsg =
            List.filterMap startTriggerEntry fullTaskInstances
                |> List.map (\( entryID, entryStart, _ ) -> ( entryID, entryStart ))

        taskIDsWithStopMsg =
            List.filterMap startTriggerEntry fullTaskInstances
                |> List.map (\( entryID, _, entryStop ) -> ( entryID, entryStop ))

        startTriggerEntry fullInstance =
            case Assignment.activityID fullInstance of
                Nothing ->
                    Nothing

                Just hasActivityID ->
                    Just
                        ( Assignment.idString fullInstance
                        , StartTrackingAssignment fullInstance hasActivityID
                        , StopTrackingAssignment fullInstance
                        )
    in
    [ ( "complete", Dict.fromList tasksIDsWithDoneMsg )
    , ( "startTask", Dict.fromList taskIDsWithStartMsg )
    , ( "stopTask", Dict.fromList taskIDsWithStopMsg )
    ]
