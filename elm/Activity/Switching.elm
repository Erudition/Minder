module Activity.Switching exposing (currentActivityFromApp, determineNextTask, switchActivity)

import Activity.Activity as Activity exposing (..)
import Activity.Measure as Measure
import AppData exposing (..)
import Environment exposing (..)
import External.Commands as Commands
import External.Tasker as Tasker
import IntDict
import List.Extra as List
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Random
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future, past)
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
                        ++ scheduleOffTaskReminders (future env.time excusedLeft)

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
        , channelDescription = Just "A subtle reminder of the currently tracking activity."
        , autoCancel = Just False
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
        , importance = Just Notif.Low
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
            HumanDuration.singleLetterSpaced (HumanDuration.breakdownMS dur)

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


scheduleOnTaskReminders : Moment -> Duration -> List Notification
scheduleOnTaskReminders now timeLeft =
    let
        blank =
            Notif.blank "Override me!"

        reminderBase =
            { blank | expiresAfter = Just (Duration.fromMinutes 1) }

        fractionLeft denom =
            future now <| Duration.subtract timeLeft (Duration.scale timeLeft (1 / denom))
    in
    [ { reminderBase
        | at = Just <| fractionLeft 2
        , title = Just "Half-way done!"
        , body = Just "1/2 time left for activity."
        , subtitle = Just "Working on: XYZ"
      }
    , { reminderBase
        | at = Just <| fractionLeft 3
        , title = Just "Two-thirds done!"
        , body = Just "1/3 time left for activity."
        , subtitle = Just "Working on: XYZ"
      }
    , { reminderBase
        | at = Just <| fractionLeft 4
        , title = Just "Three-quarters done!"
        , body = Just "1/4 time left for activity."
        , subtitle = Just "Working on: XYZ"
      }
    , { reminderBase
        | at = Just <| future now timeLeft
        , title = Just "Three-quarters done!"
        , body = Just "1/4 time left for activity."
        , subtitle = Just "Working on: XYZ"
      }
    ]


scheduleOffTaskReminders : Moment -> List Notification
scheduleOffTaskReminders now =
    let
        blank =
            Notif.blank "Override me!"

        base =
            { blank
                | id = Just 1
                , channel = "Off Task Warnings"
                , channelDescription = Just "These reminders are meant to be-in-your-face and annoying, so you don't ignore them."
                , actions = actions
                , importance = Just Notif.Max
                , expiresAfter = Just (Duration.fromMinutes 1)
            }

        buzz count =
            List.repeat count
                ( Duration.fromMs 100
                , Duration.fromMs 100
                )

        actions =
            [ { id = "SnoozeButton", button = Notif.Button "Snooze", launch = False }
            , { id = "LaunchButton", button = Notif.Button "Go", launch = True }
            , { id = "ZapButton", button = Notif.Button "Zap", launch = False }
            ]
    in
    [ { base
        | at = Just <| now
        , subtitle = Just "Off Task!"
        , title = Just "You can do this later"
        , body = Just "Should do: XYZ"
        , vibratePattern = Just (buzz 4)
        , channel = "Off Task, First Warning"
      }
    , { base
        | at = Just <| future now (Duration.fromSeconds 30.0)
        , subtitle = Just "Off Task! Second Warning"
        , title = Just "You have more important things to do right now!"
        , body = Just "Should do: XYZ"
        , vibratePattern = Just (buzz 6)
        , channel = "Off Task, Second Warning"
      }
    , { base
        | at = Just <| future now (Duration.fromSeconds 60.0)
        , subtitle = Just "Off Task! Third Warning"
        , title = Just "You have more important things to do right now!"
        , body = Just "Should do: XYZ"
        , vibratePattern = Just (buzz 8)
        , channel = "Off Task, Third Warning"
      }
    , { base
        | at = Just <| future now (Duration.fromSeconds 90.0)
        , subtitle = Just "Off Task!"
        , title = Just "You have more important things to do right now!"
        , interval = Just Notif.Minute
        , body = Just "Should do: XYZ"
        , vibratePattern = Just (buzz 10)
      }
    ]


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Notification
scheduleExcusedReminders now excusedLimit timeLeft =
    let
        blank =
            Notif.blank "Override me!"

        base =
            { blank
                | id = Just 7
                , channel = "Excused Reminders"
                , actions = actions
            }

        actions =
            [ { id = "BackOnTask", button = Notif.Button "OK I'm Ready", launch = False }
            ]

        firstIsGreater first last =
            Duration.compare first last == GT

        firstIsLess first last =
            Duration.compare first last == LT

        substantialTimeLeft =
            -- Don't bother with reminders if there's under 30 sec left
            firstIsGreater timeLeft (Duration.fromSeconds 30.0)

        timesUp =
            -- The Moment the excused time expires, if it continues to be used without interruption
            future now timeLeft

        beforeTimesUp timeBefore =
            -- get Moments before the expiration Moment, to schedule "time left" reminders. Don't make the mistake of using `future` from now - we should be working backwards from the expiry time for "time left".
            past timesUp timeBefore

        halfLeftThisSession =
            -- It would be annoying to immediately get warned "5 minutes left" when the period is only 7 minutes, so we make sure at least half the time is used before showing warnings
            Duration.scale timeLeft (1 / 2)

        gettingCloseList =
            List.takeWhile (firstIsGreater halfLeftThisSession)
                [ dur (Minutes 1)
                , dur (Minutes 2)
                , dur (Minutes 3)
                , dur (Minutes 5)
                , dur (Minutes 10)
                , dur (Minutes 30)
                ]

        buildGettingCloseReminder amountLeft =
            { base
                | at = Just <| beforeTimesUp amountLeft
                , title = Just <| "Finish up! Only " ++ write amountLeft ++ " left!"
                , subtitle = Just <| "Excused for up to " ++ write excusedLimit
            }

        write durLeft =
            abbreviatedSpaced <| HumanDuration.breakdownNonzero durLeft

        interimReminders =
            [ { base
                | at = Just <| future now (dur (Minutes 10))
                , title = Just "Distraction taken care of?"
                , subtitle = Just <| pickEncouragementMessage (future now (dur (Minutes 10)))
              }
            , { base
                | at = Just <| future now (dur (Minutes 20))
                , title = Just "Ready to get back on task?"
                , subtitle = Just <| pickEncouragementMessage (future now (dur (Minutes 20)))
              }
            , { base
                | at = Just <| future now (dur (Minutes 30))
                , title = Just "Can this wait?"
                , subtitle = Just <| pickEncouragementMessage (future now (dur (Minutes 30)))
              }
            ]

        pickEncouragementMessage time =
            Tuple.first <| Random.step encouragementMessages (Moment.useAsRandomSeed time)

        encouragementMessages =
            Random.uniform
                "Get back on task as soon as possible - do this later!"
                [ "You have important goals to meet!"
                , "Why not put this in your task list for later?"
                ]
    in
    if substantialTimeLeft then
        List.map buildGettingCloseReminder gettingCloseList

    else
        []
