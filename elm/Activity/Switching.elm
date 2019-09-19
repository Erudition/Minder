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
import Task.Task as Task exposing (Task)
import Time
import Time.Extra as Time


multiline : List (List String) -> String
multiline inputListOfLists =
    -- TODO Propose adding to String.Extra
    let
        unWords : List String -> String
        unWords wordsList =
            -- inverse of String.words
            String.concat (List.intersperse " " wordsList)

        unLines : List String -> String
        unLines linesList =
            String.concat (List.intersperse "\n" (List.filterNot String.isEmpty linesList))
    in
    unLines (List.map unWords inputListOfLists)


determineNextTask : AppData -> Environment -> Maybe Task.Task
determineNextTask app env =
    List.head <|
        Task.prioritize env.time env.timeZone <|
            List.filter (Task.completed >> not) <|
                IntDict.values app.tasks


switchActivity : ActivityID -> AppData -> Environment -> ( AppData, Cmd msg )
switchActivity newActivityID app env =
    let
        updatedApp =
            if newActivityID == oldActivityID then
                app

            else
                { app | timeline = Switch env.time newActivityID :: app.timeline }

        newActivity =
            Activity.getActivity newActivityID (allActivities app.activities)

        oldActivity =
            Activity.getActivity oldActivityID (allActivities app.activities)

        oldActivityID =
            currentActivityFromApp app

        formatDuration givenDur =
            HumanDuration.singleLetterSpaced <|
                HumanDuration.trimToSmall <|
                    HumanDuration.breakdownHMS givenDur

        sessionTotalString =
            formatDuration <| Maybe.withDefault Duration.zero lastSession

        lastSession =
            Measure.lastSession updatedApp.timeline oldActivityID

        todayTotalString =
            formatDuration <|
                todayTotal

        todayTotal =
            Measure.justTodayTotal updatedApp.timeline env newActivityID

        popup message =
            Commands.toast (multiline message)

        ( oldName, newName ) =
            ( getName oldActivity, getName newActivity )

        cancelAll idList =
            Cmd.batch <| List.map notifyCancel idList

        offTaskReminderIDs =
            [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

        onTaskReminderIDs =
            [ 0 ]

        excusedReminderIDs =
            [ 100 ]

        statusIDs =
            [ 42 ]

        describeTodayTotal =
            if Duration.isPositive todayTotal then
                [ "So far", todayTotalString, "today" ]

            else
                []
    in
    case determineNextTask app env of
        Nothing ->
            -- ALL DONE
            ( updatedApp
            , Cmd.batch
                [ popup
                    [ [ oldName, "stopped:", sessionTotalString ]
                    , [ oldName, "➤", newName ]
                    , describeTodayTotal
                    ]
                , notify [ updateSticky env.time todayTotal newActivity "✔️ All Done" ]
                , cancelAll (offTaskReminderIDs ++ onTaskReminderIDs)
                ]
            )

        Just nextTask ->
            -- MORE TO BE DONE
            case nextTask.activity of
                Nothing ->
                    -- Uh oh! next task has no activity!
                    ( updatedApp
                    , Cmd.batch
                        [ popup
                            [ [ "❌ Next Task has no Activity! " ]
                            , [ oldName, "stopped:", sessionTotalString ]
                            , [ oldName, "➤", newName ]
                            , describeTodayTotal
                            ]
                        , notify
                            (updateSticky env.time todayTotal newActivity "❌ Unknown - No Activity"
                                :: scheduleOffTaskReminders nextTask env.time
                            )
                        , cancelAll (offTaskReminderIDs ++ onTaskReminderIDs)
                        ]
                    )

                Just nextActivity ->
                    let
                        -- ALL EXCUSED CHECKS BELOW --
                        excusedUsageString =
                            formatDuration <| excusedUsage

                        excusedUsage =
                            Measure.excusedUsage updatedApp.timeline env.time ( newActivityID, newActivity )

                        excusedLeft =
                            Measure.excusedLeft updatedApp.timeline env.time ( newActivityID, Activity.getActivity newActivityID (allActivities app.activities) )

                        describeExcusedUsage =
                            if Duration.isPositive excusedUsage then
                                [ "Already used", excusedUsageString ]

                            else
                                []
                    in
                    if nextActivity == newActivityID then
                        let
                            timeSpent =
                                Measure.totalLive env.time updatedApp.timeline newActivityID

                            timeRemaining =
                                Duration.subtract nextTask.maxEffort timeSpent
                        in
                        -- ON TASK LOGIC ---------------------------
                        ( updatedApp
                        , Cmd.batch
                            [ popup
                                [ [ oldName, "stopped:", sessionTotalString ]
                                , [ oldName, "➤", newName, "✔️" ]
                                , describeTodayTotal
                                ]
                            , notify <|
                                updateSticky env.time todayTotal newActivity "✔️ On Task"
                                    :: scheduleOnTaskReminders nextTask env.time timeRemaining
                            , cancelAll (offTaskReminderIDs ++ excusedReminderIDs)
                            ]
                        )

                    else if Duration.isPositive excusedLeft then
                        -- OFF TASK BUT STILL EXCUSED ---------------------
                        ( updatedApp
                        , Cmd.batch
                            [ popup
                                [ [ oldName, "stopped:", sessionTotalString ]
                                , [ oldName, "➤", newName, "❌" ]
                                , describeExcusedUsage
                                ]
                            , notify <|
                                updateSticky env.time todayTotal newActivity "⏸ Off Task (Excused)"
                                    :: scheduleExcusedReminders env.time (Measure.excusableLimit newActivity) excusedLeft
                                    ++ scheduleOffTaskReminders nextTask (future env.time excusedLeft)
                            , cancelAll (offTaskReminderIDs ++ onTaskReminderIDs)
                            ]
                        )

                    else
                        -- OFF TASK
                        ( updatedApp
                        , Cmd.batch
                            [ popup
                                [ [ oldName, "stopped:", sessionTotalString ]
                                , [ oldName, "➤", newName, "❌" ]
                                , [ "Previously excused for", excusedUsageString ]
                                ]
                            , notify <|
                                updateSticky env.time todayTotal newActivity "❌ Off Task"
                                    :: scheduleOffTaskReminders nextTask env.time
                            , cancelAll (onTaskReminderIDs ++ excusedReminderIDs)
                            ]
                        )



-- Keep this here to reference for adding details to notifs
-- ( updatedApp
-- , Cmd.batch
--     [ Commands.toast (switchPopup updatedApp.timeline env ( activityID, newActivity ) ( oldActivityID, oldActivity ))
--     , Tasker.variableOut ( "OnTaskStatus", Activity.statusToString onTaskStatus )
--     , Tasker.variableOut ( "ExcusedUsage", Measure.exportExcusedUsageSeconds app env.time ( activityID, newActivity ) )
--     , Tasker.variableOut ( "OnTaskUsage", Measure.exportExcusedUsageSeconds app env.time ( activityID, newActivity ) )
--     , Tasker.variableOut ( "ActivityTotal", String.fromInt <| Duration.inMinutesRounded (Measure.excusedUsage app.timeline env.time ( activityID, newActivity )) )
--     , Tasker.variableOut ( "ExcusedLimit", String.fromInt <| Duration.inSecondsRounded (Measure.excusableLimit newActivity) )
--     , Tasker.variableOut ( "CurrentActivity", getName newActivity )
--     , Tasker.variableOut ( "PreviousSessionTotal", Measure.exportLastSession updatedApp oldActivityID )
--     , Commands.hideWindow
--     , scheduleReminders app env updatedApp.timeline onTaskStatus ( activityID, newActivity )
--     , exportNextTask app env
--     ]
-- )


updateSticky : Moment -> Duration -> Activity -> String -> Notification
updateSticky now todayTotal newActivity status =
    let
        blank =
            Notif.blank "Status"

        actions =
            [ { id = "sync=todoist", button = Notif.Button "Sync Tasks", launch = False }
            , { id = "complete=next", button = Notif.Button "Complete", launch = False }
            ]
    in
    { blank
        | id = Just 42
        , channelDescription = Just "A subtle reminder of the currently tracking activity."
        , autoCancel = Just False
        , title = Just (Activity.getName newActivity)
        , chronometer = Just True
        , when = Just (past now todayTotal)
        , subtitle = Just status
        , body = Nothing
        , ongoing = Just True
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
        , countdown = Nothing
        , progress = Nothing
        , actions = actions
    }


currentActivityFromApp : AppData -> ActivityID
currentActivityFromApp app =
    currentActivityID app.timeline


scheduleOnTaskReminders : Task -> Moment -> Duration -> List Notification
scheduleOnTaskReminders task now timeLeft =
    let
        blank =
            Notif.blank "Override me!"

        reminderBase =
            { blank
                | id = Just 0
                , expiresAfter = Just (Duration.fromMinutes 1)
                , when = Just (future now timeLeft)
                , accentColor = Just "green"
            }

        fractionLeft denom =
            future now <| Duration.subtract timeLeft (Duration.scale timeLeft (1 / denom))
    in
    [ { reminderBase
        | at = Just <| fractionLeft 2
        , title = Just "Half-way done!"
        , body = Just "1/2 time left for this task."
        , subtitle = Just task.title
        , progress = Just (Notif.Progress 1 2)
      }
    , { reminderBase
        | at = Just <| fractionLeft 3
        , title = Just "Two-thirds done!"
        , body = Just "1/3 time left for this task."
        , subtitle = Just task.title
        , progress = Just (Notif.Progress 2 3)
      }
    , { reminderBase
        | at = Just <| fractionLeft 4
        , title = Just "Three-quarters done!"
        , body = Just "1/4 time left for this task."
        , subtitle = Just task.title
        , progress = Just (Notif.Progress 3 4)
      }
    , { reminderBase
        | at = Just <| future now timeLeft
        , title = Just "Time's up!"
        , body = Just "You have spent all of the time reserved for this task."
        , subtitle = Just task.title
      }
    ]


scheduleOffTaskReminders : Task -> Moment -> List Notification
scheduleOffTaskReminders nextTask now =
    let
        blank =
            Notif.blank "Override me!"

        base =
            { blank
                | channel = "Off Task Warnings"
                , channelDescription = Just "These reminders are meant to be-in-your-face and annoying, so you don't ignore them."
                , actions = actions
                , importance = Just Notif.Max
                , expiresAfter = Just (Duration.fromSeconds 59)
                , title = Just ("Do now: " ++ nextTask.title)
                , sound = Just (Notif.CustomSound "eek")
                , accentColor = Just "red"
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

        pickEncouragementMessage time =
            Tuple.first <| Random.step encouragementMessages (Moment.useAsRandomSeed time)

        encouragementMessages =
            Random.uniform
                "Do this later"
                [ "You have important goals to meet!"
                , "Why not put this in your task list for later?"
                , "This was not part of the plan"
                , "Get back on task now!"
                ]

        goesOffAt : Int -> Moment
        goesOffAt reminderNum =
            future now (Duration.fromSeconds (30 * (toFloat reminderNum - 1)))

        reminderTemplate : Int -> Notification
        reminderTemplate reminderNum =
            { base
                | id = Just reminderNum
                , at = Just (goesOffAt reminderNum)
                , subtitle = Just <| "Off Task! Warning " ++ String.fromInt reminderNum
                , body = Just <| pickEncouragementMessage (goesOffAt reminderNum)
                , vibratePattern = Just (buzz 10)
                , channel = "Off Task"
                , when = Just (goesOffAt (reminderNum + 1))
                , countdown = Just True
                , chronometer = Just True
                , expiresAfter = Just (Duration.fromSeconds 29)
            }

        stopAfterCount =
            10

        giveUpNotif =
            { base
                | id = Just (stopAfterCount + 1)
                , at = Just (goesOffAt (stopAfterCount + 1))
                , subtitle = Just <| "Off Task warnings have failed."
                , body = Just <| "Gave up after " ++ String.fromInt stopAfterCount
                , vibratePattern = Nothing
                , channel = "Status"
                , when = Just (goesOffAt (stopAfterCount + 1))
                , countdown = Just False
                , chronometer = Just False
                , expiresAfter = Just (Duration.fromHours 2)
            }
    in
    [ { base
        | id = Just 1
        , at = Just <| now
        , subtitle = Just "Off Task!"
        , body = Just <| pickEncouragementMessage now
        , vibratePattern = Just (buzz 4)
        , channel = "Off Task, First Warning"
        , when = Just <| future now (Duration.fromSeconds 30.0)
        , countdown = Just True
        , chronometer = Just True
        , expiresAfter = Just (Duration.fromSeconds 29)
      }
    , { base
        | id = Just 2
        , at = Just <| future now (Duration.fromSeconds 30.0)
        , subtitle = Just "Off Task! Second Warning"
        , body = Just <| pickEncouragementMessage (future now (Duration.fromSeconds 30.0))
        , vibratePattern = Just (buzz 6)
        , channel = "Off Task, Second Warning"
        , when = Just <| future now (Duration.fromSeconds 60.0)
        , countdown = Just True
        , chronometer = Just True
        , expiresAfter = Just (Duration.fromSeconds 29)
      }
    , { base
        | id = Just 3
        , at = Just <| future now (Duration.fromSeconds 60.0)
        , subtitle = Just "Off Task! Third Warning"
        , body = Just <| pickEncouragementMessage (future now (Duration.fromSeconds 60.0))
        , vibratePattern = Just (buzz 8)
        , channel = "Off Task, Third Warning"
        , when = Just <| future now (Duration.fromSeconds 90.0)
        , countdown = Just True
        , chronometer = Just True
        , expiresAfter = Just (Duration.fromSeconds 29)
      }
    ]
        ++ List.map reminderTemplate (List.range 4 stopAfterCount)
        ++ [ giveUpNotif ]


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Notification
scheduleExcusedReminders now excusedLimit timeLeft =
    let
        blank =
            Notif.blank "Override me!"

        base =
            { blank
                | id = Just 100
                , channel = "Excused Reminders"
                , actions = actions
                , when = Just timesUp
                , countdown = Just True
                , chronometer = Just True
                , accentColor = Just "gold"
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
                [ Duration.zero
                , dur (Minutes 1)
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
                , progress = Just (Notif.Progress (Duration.inMs amountLeft) (Duration.inMs excusedLimit))
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
