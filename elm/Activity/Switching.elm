module Activity.Switching exposing (currentActivityFromApp, determineNextTask, switchActivity)

import Activity.Activity as Activity exposing (..)
import Activity.Measure as Measure
import Activity.Reminder exposing (..)
import AppData exposing (..)
import Environment exposing (..)
import External.Commands as Commands
import External.Tasker as Tasker
import IntDict
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment exposing (..)
import Task.Task as Task
import Time
import Time.Extra as Time


switchActivity : ActivityID -> AppData -> Environment -> ( AppData, Cmd msg )
switchActivity activityID app env =
    let
        updatedApp =
            { app | timeline = Switch env.time activityID :: app.timeline }

        newActivity =
            Activity.getActivity activityID (allActivities app.activities)

        oldActivity =
            Activity.getActivity oldActivityID (allActivities app.activities)

        oldActivityID =
            currentActivityFromApp app

        onTaskStatus =
            determineOnTask activityID app env
    in
    ( updatedApp
    , Cmd.batch
        [ Commands.toast (switchPopup updatedApp.timeline env ( activityID, newActivity ) ( oldActivityID, oldActivity ))
        , Tasker.variableOut ( "OnTaskStatus", Activity.statusToString onTaskStatus )
        , Tasker.variableOut ( "ExcusedUsage", Measure.exportExcusedUsageSeconds app env.time ( activityID, newActivity ) )
        , Tasker.variableOut ( "OnTaskUsage", Measure.exportExcusedUsageSeconds app env.time ( activityID, newActivity ) )
        , Tasker.variableOut ( "ActivityTotal", String.fromInt <| Duration.inMinutesRounded (Measure.excusedUsage app.timeline env.time ( activityID, newActivity )) )
        , Tasker.variableOut ( "ExcusedLimit", String.fromInt <| Duration.inSecondsRounded (Measure.excusableLimit newActivity) )
        , Tasker.variableOut ( "CurrentActivity", getName newActivity )
        , Tasker.variableOut ( "PreviousSessionTotal", Measure.exportLastSession updatedApp oldActivityID )
        , Commands.hideWindow
        , scheduleReminders env updatedApp.timeline onTaskStatus ( activityID, newActivity )
        , exportNextTask app env
        ]
    )


scheduleReminders : Environment -> Timeline -> OnTaskStatus -> ( ActivityID, Activity ) -> Cmd msg
scheduleReminders env timeline onTaskStatus ( activityID, newActivity ) =
    case onTaskStatus of
        OnTask timeLeft ->
            notify <|
                updateSticky env.time timeLeft onTaskStatus newActivity
                    :: scheduleOnTaskReminders env.time timeLeft

        OffTask excusedLeft ->
            --TODO handle indefinitely excused
            if Duration.isPositive excusedLeft then
                notify <|
                    updateSticky env.time excusedLeft onTaskStatus newActivity
                        :: scheduleExcusedReminders env.time (Measure.excusableLimit newActivity) excusedLeft

            else
                notify <|
                    updateSticky env.time excusedLeft onTaskStatus newActivity
                        :: scheduleOffTaskReminders env.time

        AllDone ->
            notify [ updateSticky env.time Duration.zero onTaskStatus newActivity ]


updateSticky : Moment -> Duration -> OnTaskStatus -> Activity -> Notification
updateSticky moment timeLeft onTaskStatus newActivity =
    let
        blank =
            Notif.blank "Status"

        actions =
            [ { id = "sync=todoist", button = Notif.Button "Sync Tasks", launch = False }
            ]
    in
    { blank
        | id = Just 42
        , title = Just (Activity.getName newActivity)
        , subtitle = Just (Activity.statusToString onTaskStatus)
        , body = Nothing
        , ongoing = Just True
        , bigTextStyle = Nothing
        , groupedMessages = Nothing
        , groupSummary = Nothing
        , badge = Nothing
        , icon = Nothing
        , silhouetteIcon = Nothing
        , update = Nothing
        , priority = Nothing
        , privacy = Nothing
        , useHTML = Nothing
        , title_expanded = Nothing
        , body_expanded = Nothing
        , detail = Nothing
        , status_icon = Nothing
        , status_text_size = Nothing
        , background_color = Nothing
        , chronometer = Nothing
        , countdown = Nothing
        , progress = Nothing
        , actions = actions
    }


determineOnTask : ActivityID -> AppData -> Environment -> OnTaskStatus
determineOnTask activityID app env =
    let
        current =
            getActivity activityID (allActivities app.activities)

        excusedLeft =
            Measure.excusedLeft app.timeline env.time ( activityID, current )
    in
    case determineNextTask app env of
        Nothing ->
            AllDone

        Just nextTask ->
            case nextTask.activity of
                Nothing ->
                    OffTask excusedLeft

                Just nextActivity ->
                    if nextActivity == activityID then
                        OnTask nextTask.maxEffort

                    else
                        OffTask excusedLeft


determineNextTask : AppData -> Environment -> Maybe Task.Task
determineNextTask app env =
    List.head <|
        Task.prioritize env.time env.timeZone <|
            List.filter (Task.completed >> not) <|
                IntDict.values app.tasks


exportNextTask : AppData -> Environment -> Cmd msg
exportNextTask app env =
    let
        next =
            determineNextTask app env

        export task =
            Tasker.variableOut ( "NextTaskTitle", task.title )
    in
    Maybe.withDefault Cmd.none (Maybe.map export next)


switchPopup : Timeline -> Environment -> ( ActivityID, Activity ) -> ( ActivityID, Activity ) -> String
switchPopup timeline env (( newID, new ) as newKV) ( oldID, old ) =
    let
        timeSpentString dur =
            singleLetterSpaced (breakdownMS dur)

        timeSpentLastSession =
            Maybe.withDefault Duration.zero (List.head (Measure.sessions timeline oldID))
    in
    timeSpentString timeSpentLastSession
        ++ " spent on "
        ++ getName old
        ++ "\n"
        ++ getName old
        ++ " ➤ "
        ++ getName new
        ++ "\n"
        ++ "Starting from "
        ++ timeSpentString (Measure.excusedUsage timeline env.time newKV)


currentActivityFromApp : AppData -> ActivityID
currentActivityFromApp app =
    currentActivityID app.timeline
