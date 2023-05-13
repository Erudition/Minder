module TaskList exposing (ExpandedTask, Filter(..), Msg(..), NewTaskField, ViewState(..), attemptDateChange, defaultView, dynamicSliderThumbCss, extractSliderInput, filterName, onEnter, progressSlider, routeView, timingInfo, update, urlTriggers, view, viewControls, viewControlsClear, viewControlsCount, viewControlsFilters, viewInput, viewKeyedTask, viewTask, viewTasks, visibilitySwap)

import Activity.Activity exposing (ActivityID)
import Activity.Session
import Activity.Timeline
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Environment exposing (..)
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
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period
import String.Normalize
import Task as Job
import Task.ActionClass as Class exposing (ActionClass, ActionClassID)
import Task.AssignedAction as Instance exposing (AssignedAction, AssignedActionID, AssignedActionSkel, completed, getProgress, isRelevantNow)
import Task.Entry as Entry
import Task.Progress exposing (..)
import Task.Session
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
    ActionClassID


type alias NewTaskField =
    String


type CurrentlyEditing
    = EditingProjectTitle Class.ActionClassID String
    | EditingProjectDate


allFullTaskInstances profile ( launchTime, zone ) =
    Profile.instanceListNow profile ( launchTime, zone )
        |> Instance.prioritize launchTime zone


view : ViewState -> Profile -> Environment -> Html Msg
view state profile env =
    let
        renderView lazyState lazyProfile launchTime zone =
            case state of
                Normal filters expanded field editing ->
                    let
                        activeFilter =
                            Maybe.withDefault AllTasks (List.head filters)
                    in
                    div
                        []
                        [ section
                            []
                            [ lazy viewInput field
                            , Html.Styled.Lazy.lazy5 viewTasks env.launchTime env.timeZone activeFilter editing profile

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
        , onEnter Add
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
-- viewTasks : String -> List AssignedAction -> Html Msg


viewTasks : Moment -> HumanMoment.Zone -> Filter -> Maybe CurrentlyEditing -> Profile -> Html Msg
viewTasks time timeZone filter editingMaybe profile =
    let
        trackedTaskMaybe =
            Activity.Timeline.currentInstanceID profile.timeline

        sortedTasks =
            allFullTaskInstances profile ( time, timeZone )
                |> Log.logMessageOnly "recalculating task list!"

        isVisible task =
            case filter of
                CompleteTasksOnly ->
                    completed task

                AllIncompleteTasks ->
                    not (completed task)

                AllRelevantTasks ->
                    not (completed task) && isRelevantNow task time timeZone

                _ ->
                    True

        allCompleted =
            List.all completed sortedTasks
    in
    Keyed.node "ion-list"
        []
    <|
        List.map (viewKeyedTask ( time, timeZone ) trackedTaskMaybe editingMaybe) (List.filter isVisible sortedTasks)



-- VIEW INDIVIDUAL ENTRIES


viewKeyedTask : ( Moment, HumanMoment.Zone ) -> Maybe AssignedActionID -> Maybe CurrentlyEditing -> AssignedAction -> ( String, Html Msg )
viewKeyedTask ( time, timeZone ) trackedTaskMaybe editingMaybe task =
    ( Instance.getIDString task, lazy4 viewTask ( time, timeZone ) trackedTaskMaybe editingMaybe task )



-- viewTask : AssignedAction -> Html Msg


viewTask : ( Moment, HumanMoment.Zone ) -> Maybe AssignedActionID -> Maybe CurrentlyEditing -> AssignedAction -> Html Msg
viewTask ( time, timeZone ) trackedTaskMaybe editingMaybe task =
    node "ion-item-sliding"
        []
        [ node "ion-item"
            [ classList [ ( "completed", completed task ), ( "editing", False ) ]
            , title (taskTooltip ( time, timeZone ) task)
            ]
            [ viewTaskTitle task editingMaybe
            , timingInfo ( time, timeZone ) task

            -- , div
            --     [ class "view" ]
            --     [ div
            --         [ class "task-times"
            --         , css
            --             [ Css.width (rem 3)
            --             , displayFlex
            --             , flex3 (num 0) (num 0) (rem 3)
            --             , flexDirection column
            --             , fontSize (rem 0.7)
            --             , justifyContent center
            --             , alignItems center
            --             , textAlign center
            --             , letterSpacing (rem -0.1)
            --             ]
            --         ]
            --         [ div
            --             [ class "minimum-duration"
            --             , css
            --                 [ justifyContent Css.end
            --                 ]
            --             ]
            --             [ if SmartTime.Duration.isZero (Instance.getMinEffort task) then
            --                 text ""
            --               else
            --                 text (String.fromInt (Basics.round (SmartTime.Duration.inMinutes (Instance.getPredictedEffort task))))
            --             ]
            --         , div
            --             [ class "task-bubble"
            --             , title (taskTooltip ( time, timeZone ) task)
            --             , css
            --                 [ Css.height (rem 2)
            --                 , Css.width (rem 2)
            --                 , backgroundColor (activityColor task).lighter
            --                 , Css.color (activityColor task).medium
            --                 , border3 (px 2) solid (activityColor task).darker
            --                 , displayFlex
            --                 , borderRadius (pct 100)
            --                 -- , margin (rem 0.5)
            --                 , fontSize (rem 1)
            --                 , alignItems center
            --                 , justifyContent center
            --                 -- , padding (rem 0.2)
            --                 , fontFamily monospace
            --                 , fontWeight Css.normal
            --                 , textAlign center
            --                 ]
            --             ]
            --             [ if SmartTime.Duration.isZero (Instance.getPredictedEffort task) then
            --                 text ""
            --               else
            --                 text (String.fromInt (Basics.round (SmartTime.Duration.inMinutes (Instance.getPredictedEffort task))))
            --             ]
            --         , div
            --             [ class "maximum-duration"
            --             , css
            --                 [ justifyContent Css.end
            --                 ]
            --             ]
            --             [ if SmartTime.Duration.isZero (Instance.getMaxEffort task) then
            --                 text ""
            --               else
            --                 text (String.fromInt (Basics.round (SmartTime.Duration.inMinutes (Instance.getPredictedEffort task))))
            --             ]
            --         ]
            --     , div [ class "title-and-details" ]
            --         [ label
            --             [ onDoubleClick (EditingTitle task True)
            --             , onClick (FocusSlider task True)
            --             , css [ fontWeight (Css.int <| Basics.round (Instance.getImportance task * 200 + 200)), pointerEvents none ]
            --             , class "task-title"
            --             ]
            --             [ span [ class "task-title-text" ] [ text <| Instance.getTitle task ]
            --             , span [ css [ opacity (num 0.4), fontSize (Css.em 0.5), fontWeight (Css.int 200) ] ] [ text <| "#" ++ String.fromInt task.index ]
            --             ]
            --         ]
            --     , div
            --         [ class "sessions"
            --         , css
            --             [ fontSize (Css.em 0.5)
            --             , Css.width (pct 50)
            --             , displayFlex
            --             , flexDirection column
            --             , alignItems end
            --             , textAlign center
            --             ]
            --         ]
            --         (plannedSessions ( time, timeZone ) task)
            --     , div [ class "task-controls" ]
            --         (List.filterMap
            --             identity
            --             [ startTrackingButton task trackedTaskMaybe
            --             , Just <|
            --                 button
            --                     [ class "destroy"
            --                     , onClick (Delete (Instance.getID task))
            --                     ]
            --                     [ text "×" ]
            --             ]
            --         )
            --     ]
            -- , input
            --     [ class "edit"
            --     , value <| Instance.getTitle task
            --     , name "title"
            --     , id ("task-" ++ Instance.getIDString task)
            --     , onInput (UpdateTitle task)
            --     , onBlur (EditingTitle task False)
            --     , onEnter (EditingTitle task False)
            --     ]
            --     []
            ]
        , node "ion-item-options"
            []
            [ node "ion-item-option" [ attribute "color" "danger", onClick (SimpleChange task.remove) ] [ text "delete" ] ]
        ]


viewTaskTitle : AssignedAction -> Maybe CurrentlyEditing -> Html Msg
viewTaskTitle task editingMaybe =
    let
        titleNotEditing =
            node "ion-label"
                [ css
                    [ fontWeight (Css.int <| Basics.round (Instance.getImportance task * 200 + 200)) ]
                , onDoubleClick (EditingClassTitle task <| Instance.getTitle task)
                ]
                [ text <| Instance.getTitle task
                , span [ css [ opacity (num 0.4), fontSize (Css.em 0.5), fontWeight (Css.int 200) ] ] [ text <| "#" ++ String.fromInt task.index ]
                ]

        titleEditing newTitleSoFar =
            node "ion-input"
                [ value newTitleSoFar
                , placeholder <| "Enter a new name for: " ++ Instance.getTitle task
                , name "title"
                , id ("task-title-" ++ Instance.getIDString task)
                , onInput (EditingClassTitle task)
                , on "ionBlur" (JD.succeed StopEditing)
                , onEnter (UpdateTitle task newTitleSoFar)
                , Attr.property "clearInput" (JE.bool True)
                , autofocus True
                , attribute "enterkeyhint" "done"
                , attribute "helper-text" <| "Enter a new title for the project. "
                , spellcheck True
                ]
                []
    in
    case editingMaybe of
        Just (EditingProjectTitle classID newTitleSoFar) ->
            if classID == task.classID then
                titleEditing newTitleSoFar

            else
                titleNotEditing

        _ ->
            titleNotEditing


startTrackingButton : AssignedAction -> Maybe AssignedActionID -> Maybe (Html Msg)
startTrackingButton task trackedTaskMaybe =
    case ( Instance.getActivityID task, Maybe.map ((==) (Instance.getID task)) trackedTaskMaybe ) of
        ( Just activityID, Just True ) ->
            Just <|
                button
                    [ class "stop-tracking-now"
                    , onClick (StopTracking (Instance.getID task))
                    ]
                    [ text "⏸︎" ]

        ( Just activityID, _ ) ->
            Just <|
                button
                    [ class "start-tracking-now"
                    , onClick (StartTracking (Instance.getID task) activityID)
                    ]
                    [ text "▶️" ]

        ( Nothing, _ ) ->
            Nothing



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


plannedSessions env task =
    let
        durationToWidgetWidthPct duration =
            (clamp 20 120 (SmartTime.Duration.inMinutes duration) / 120) * 100

        sessionWidget fullSession =
            div
                [ css
                    [ borderStyle solid
                    , borderWidth (px 1)
                    , borderColor (Css.hsl 0 1 0)
                    , borderRadius (Css.em 1)
                    , padding (Css.em 0.2)
                    , backgroundColor (Css.hsl 202 0.83 0.86)
                    , Css.width (pct (durationToWidgetWidthPct (Task.Session.duration fullSession)))
                    , overflow Css.hidden
                    , Css.height (Css.em 2)
                    ]
                ]
                [ text <| describeTaskPlan env fullSession ]
    in
    List.map sessionWidget (Task.Session.getFullSessions task)


activityColor task =
    let
        activityDerivation n =
            modBy 360 ((n + 1) * 333)
    in
    case Maybe.map String.length (Instance.getActivityIDString task) of
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


taskTooltip : ( Moment, HumanMoment.Zone ) -> Instance.AssignedAction -> String
taskTooltip ( time, timeZone ) task =
    -- hover tooltip
    String.concat <|
        List.intersperse "\n" <|
            List.filterMap identity
                ([ Just ("Class ID: " ++ Instance.getClassIDString task)
                 , Just ("Instance ID: " ++ Instance.getIDString task)
                 , Maybe.map (String.append "activity ID: ") (Instance.getActivityIDString task)
                 , Just ("importance: " ++ String.fromFloat (Instance.getImportance task))
                 , Just ("progress: " ++ Task.Progress.toString (Instance.getProgress task))
                 , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance starts: ") (Instance.getRelevanceStarts task)
                 , Maybe.map (HumanMoment.fuzzyDescription time timeZone >> String.append "relevance ends: ") (Instance.getRelevanceEnds task)
                 ]
                    ++ List.map (\( k, v ) -> Just ("instance " ++ k ++ ": " ++ v)) (RepDict.list (Reg.latest task.instance).extra)
                )


{-| This slider is an html input type=range so it does most of the work for us. (It's accessible, works with arrow keys, etc.) No need to make our own ad-hoc solution! We theme it to look less like a form control, and become the background of our AssignedAction entry.
-}
progressSlider : AssignedAction -> Html Msg
progressSlider task =
    let
        completion =
            getProgress task
    in
    input
        [ class "task-progress"
        , type_ "range"
        , value <| String.fromInt <| getPortion completion
        , Attr.min "0"
        , Attr.max <| String.fromInt <| getWhole completion
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
        , dynamicSliderThumbCss (getNormalizedPortion (getProgress task))
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


extractSliderInput : AssignedAction -> String -> Msg
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
timingInfo : ( Moment, HumanMoment.Zone ) -> AssignedAction -> Html Msg
timingInfo ( time, timeZone ) task =
    let
        effortDescription =
            describeEffort task

        uniquePrefix =
            "task-" ++ ID.toString (Instance.getID task) ++ "-"

        dateLabelNameAndID : String
        dateLabelNameAndID =
            uniquePrefix ++ "due-date-field"

        dueDate_editable =
            editableDateLabel ( time, timeZone )
                dateLabelNameAndID
                (Maybe.map (HumanMoment.dateFromFuzzy timeZone) (Instance.getExternalDeadline task))
                (attemptDateChange ( time, timeZone ) task (Instance.getExternalDeadline task) "Due")

        timeLabelNameAndID =
            uniquePrefix ++ "due-time-field"

        dueTime_editable =
            editableTimeLabel ( time, timeZone )
                timeLabelNameAndID
                deadlineTime
                (attemptTimeChange ( time, timeZone ) task (Instance.getExternalDeadline task) "Due")

        deadlineTime =
            case Maybe.map (HumanMoment.timeFromFuzzy timeZone) (Instance.getExternalDeadline task) of
                Just (Just timeOfDay) ->
                    Just timeOfDay

                _ ->
                    Nothing
    in
    node "ion-note"
        [ class "timing-info" ]
        [ text effortDescription ]


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


describeEffort : AssignedAction -> String
describeEffort task =
    let
        sayEffort amount =
            HumanDuration.breakdownNonzero amount
    in
    case ( sayEffort (Instance.getMinEffort task), sayEffort (Instance.getPredictedEffort task), sayEffort (Instance.getMaxEffort task) ) of
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


describeTaskPlan : ( Moment, HumanMoment.Zone ) -> Task.Session.FullSession -> String
describeTaskPlan ( time, timeZone ) fullSession =
    HumanMoment.fuzzyDescription time timeZone (Task.Session.start fullSession)


{-| Get the date out of a date input.
-}
attemptDateChange : ( Moment, HumanMoment.Zone ) -> AssignedAction -> Maybe FuzzyMoment -> String -> String -> Msg
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
attemptTimeChange : ( Moment, HumanMoment.Zone ) -> AssignedAction -> Maybe FuzzyMoment -> String -> String -> Msg
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


viewControls : List Filter -> Moment -> HumanMoment.Zone -> Profile -> Html Msg
viewControls visibilityFilters time zone profile =
    let
        sortedTasks =
            allFullTaskInstances profile ( time, zone )

        tasksCompleted =
            List.length (List.filter Instance.completed sortedTasks)

        tasksLeft =
            List.length sortedTasks - tasksCompleted
    in
    footer
        [ class "footer"
        , Attr.hidden (List.isEmpty sortedTasks)
        ]
        [ Html.Styled.Lazy.lazy viewControlsCount tasksLeft
        , Html.Styled.Lazy.lazy viewControlsFilters visibilityFilters
        , Html.Styled.Lazy.lazy viewControlsClear tasksCompleted
        ]


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
            , Attr.checked isCurrent
            , onClick (Refilter changeList)
            , classList [ ( "selected", isCurrent ) ]
            , Attr.name name
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
        , Attr.hidden (tasksCompleted == 0)
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
    | EditingClassTitle AssignedAction String
    | StopEditing
    | UpdateTitle AssignedAction String
    | Add
    | Delete AssignedActionID
    | DeleteComplete
    | UpdateProgress AssignedAction Portion
    | FocusSlider AssignedAction Bool
    | UpdateTaskDate AssignedAction String (Maybe FuzzyMoment)
    | UpdateNewEntryField String
    | NoOp
    | TodoistServerResponse Todoist.Msg
    | MarvinServerResponse Marvin.Msg
    | StartTracking AssignedActionID ActivityID
    | StopTracking AssignedActionID
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
                        newAction : Change.Creator (Reg Class.ActionClassSkel)
                        newAction c =
                            let
                                newClassChanger : Reg Class.ActionClassSkel -> List Change
                                newClassChanger newClass =
                                    [ RepDb.addNew (Instance.initWithClass (ID.fromPointer (Reg.getPointer newClass))) profile.taskInstances
                                    ]
                            in
                            Class.newActionClassSkel c (Class.normalizeTitle newTaskTitle) newClassChanger

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

                logFocusError domErrorResult =
                    case domErrorResult of
                        Err (Browser.Dom.NotFound idNotFound) ->
                            LogError ("Could not find Dom Element " ++ idNotFound)

                        _ ->
                            NoOp
            in
            ( Normal filters expanded typedSoFar (Just <| EditingProjectTitle action.classID newTitleSoFar)
            , Change.none
            , Cmd.none
              -- Process.sleep 1000
              --     |> Job.andThen (\_ -> Browser.Dom.focus ("task-title-" ++ Instance.getIDString action))
              --     |> Job.attempt logFocusError
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
            ( let
                (Normal filters expanded typedSoFar _) =
                    state
              in
              Normal filters expanded typedSoFar Nothing
            , Change.saveChanges "Updating project title" [ Instance.setProjectTitle newTitle action ]
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
              -- TODO { profile | taskInstances = IntDict.filter (\_ t -> not (Instance.completed t)) profile.taskInstances }
            , Cmd.none
            )

        UpdateProgress givenTask newCompletion ->
            -- let
            --     updateTaskInstance t =
            --         Instance.setCompletion newCompletion
            --
            --     oldProgress =
            --         Instance.instanceProgress givenTask
            --
            --     profile1WithUpdatedInstance =
            --         { profile | taskInstances = IntDict.update givenTask.instance.id (Maybe.map updateTaskInstance) profile.taskInstances }
            -- in
            -- -- how does the new completion status compare to the previous?
            -- case ( isMax oldProgress, isMax ( newCompletion, getUnits oldProgress ) ) of
            --     ( False, True ) ->
            --         let
            --             ( viewState2, profile2WithTrackingStopped, trackingStoppedCmds ) =
            --                 update (StopTracking (Instance.getID givenTask)) state profile1WithUpdatedInstance env
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


urlTriggers : Profile -> ( Moment, HumanMoment.Zone ) -> List ( String, Dict.Dict String Msg )
urlTriggers profile ( time, timeZone ) =
    let
        fullTaskInstances =
            instanceListNow profile ( time, timeZone )

        tasksIDsWithDoneMsg =
            List.map doneTriggerEntry fullTaskInstances

        doneTriggerEntry fullInstance =
            ( ID.toString (Instance.getID fullInstance), UpdateProgress fullInstance (getWhole (Instance.getProgress fullInstance)) )

        taskIDsWithStartMsg =
            List.filterMap startTriggerEntry fullTaskInstances
                |> List.map (\( entryID, entryStart, _ ) -> ( entryID, entryStart ))

        taskIDsWithStopMsg =
            List.filterMap startTriggerEntry fullTaskInstances
                |> List.map (\( entryID, _, entryStop ) -> ( entryID, entryStop ))

        startTriggerEntry fullInstance =
            case Instance.getActivityID fullInstance of
                Nothing ->
                    Nothing

                Just hasActivityID ->
                    Just
                        ( ID.toString (Instance.getID fullInstance)
                        , StartTracking (Instance.getID fullInstance) hasActivityID
                        , StopTracking (Instance.getID fullInstance)
                        )
    in
    [ ( "complete", Dict.fromList tasksIDsWithDoneMsg )
    , ( "startTask", Dict.fromList taskIDsWithStartMsg )
    , ( "stopTask", Dict.fromList taskIDsWithStopMsg )
    ]
