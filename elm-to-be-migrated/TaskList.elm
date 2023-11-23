module TaskList exposing (ExpandedTask, Filter(..), Msg(..), NewTaskField, ViewState(..), attemptDateChange, defaultView, dynamicSliderThumbCss, extractSliderInput, filterName, onEnter, progressSlider, routeView, timingInfo, update, urlTriggers, view, viewControlsClear, viewControlsCount, viewControlsFilters, viewInput, visibilitySwap)





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


update : Msg -> ViewState -> Profile -> Shared -> ( ViewState, Change.Frame, Effect Msg )
update msg state profile env =


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
