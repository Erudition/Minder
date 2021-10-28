module Activity.Switching exposing (currentActivityFromApp, determineNextTask, switchActivity)

import Activity.Activity as Activity exposing (..)
import Activity.Measure as Measure
import Environment exposing (..)
import External.Commands as Commands
import External.Tasker as Tasker
import IntDict
import List.Extra as List
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Profile exposing (..)
import Random
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future, past)
import SmartTime.Period as Period exposing (Period)
import Task.Entry
import Task.Instance exposing (Instance)
import Task.Progress
import Time
import Time.Extra as Time
import ZoneHistory


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


prioritizeTasks : Profile -> Environment -> List Instance
prioritizeTasks profile env =
    Task.Instance.prioritize env.time env.timeZone <|
        List.filter (Task.Instance.completed >> not) <|
            instanceListNow profile env


determineNextTask : Profile -> Environment -> Maybe Instance
determineNextTask profile env =
    List.head <|
        prioritizeTasks profile env


instanceListNow : Profile -> Environment -> List Instance
instanceListNow profile env =
    let
        ( fullClasses, warnings ) =
            Task.Entry.getClassesFromEntries ( profile.taskEntries, profile.taskClasses )

        zoneHistory =
            -- TODO use the real thing
            ZoneHistory.init env.time env.timeZone

        rightNow =
            Period.instantaneous env.time
    in
    Task.Instance.listAllInstances fullClasses profile.taskInstances ( zoneHistory, rightNow )


switchActivity : ActivityID -> Profile -> Environment -> ( Profile, Cmd msg )
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
            [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]

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

        suggestions =
            suggestedTasks app env
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
                , notify <| [ updateSticky env.time todayTotal newActivity "✔️ All Done" Nothing ] ++ suggestions
                , cancelAll (offTaskReminderIDs ++ onTaskReminderIDs)
                ]
            )

        Just nextTask ->
            -- MORE TO BE DONE
            case nextTask.class.activity of
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
                        , notify <|
                            [ updateSticky env.time todayTotal newActivity "❌ Unknown - No Activity" (Just nextTask) ]
                                ++ scheduleOffTaskReminders nextTask env.time
                                ++ suggestions
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
                                Duration.subtract nextTask.class.maxEffort timeSpent
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
                                [ updateSticky env.time todayTotal newActivity "✔️ On Task" (Just nextTask) ]
                                    ++ scheduleOnTaskReminders nextTask env.time timeRemaining
                                    ++ suggestions
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
                                [ updateSticky env.time todayTotal newActivity "⏸ Off Task (Excused)" (Just nextTask) ]
                                    ++ scheduleExcusedReminders env.time (Measure.excusableLimit newActivity) excusedLeft
                                    ++ scheduleOffTaskReminders nextTask (future env.time excusedLeft)
                                    ++ suggestions
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
                                [ updateSticky env.time todayTotal newActivity "❌ Off Task" (Just nextTask) ]
                                    ++ scheduleOffTaskReminders nextTask env.time
                                    ++ suggestions
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


updateSticky : Moment -> Duration -> Activity -> String -> Maybe Instance -> Notification
updateSticky now todayTotal newActivity status nextTaskMaybe =
    let
        statusChannel =
            Notif.basicChannel "Status"

        blank =
            Notif.build statusChannel

        actions =
            [ { id = "sync=marvin", button = Notif.Button "Sync Tasks", launch = False }
            , { id = "complete=next", button = Notif.Button "Complete", launch = False }
            ]
    in
    { blank
        | id = Just 42
        , autoCancel = Just False
        , title = Just (Activity.getName newActivity)
        , chronometer = Just True
        , when = Just (past now todayTotal)
        , subtitle = Just status
        , body = Maybe.map (\nt -> "Up next:" ++ nt.class.title) nextTaskMaybe
        , ongoing = Just True
        , badge = Nothing
        , icon = Nothing
        , silhouetteIcon = Nothing
        , update = Nothing
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


currentActivityFromApp : Profile -> ActivityID
currentActivityFromApp app =
    currentActivityID app.timeline


onTaskChannel : Notif.Channel
onTaskChannel =
    { id = "Task Progress", name = "Task Progress", description = Just "Reminders of time passing, as well as progress reports, while on task.", sound = Nothing, importance = Just Notif.High, led = Nothing, vibrate = Nothing }


scheduleOnTaskReminders : Instance -> Moment -> Duration -> List Notification
scheduleOnTaskReminders task now timeLeft =
    let
        blank =
            Notif.build onTaskChannel

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
        , subtitle = Just task.class.title
        , progress = Just (Notif.Progress 1 2)
      }
    , { reminderBase
        | at = Just <| fractionLeft 3
        , title = Just "Two-thirds done!"
        , body = Just "1/3 time left for this task."
        , subtitle = Just task.class.title
        , progress = Just (Notif.Progress 2 3)
      }
    , { reminderBase
        | at = Just <| fractionLeft 4
        , title = Just "Three-quarters done!"
        , body = Just "1/4 time left for this task."
        , subtitle = Just task.class.title
        , progress = Just (Notif.Progress 3 4)
      }
    , { reminderBase
        | at = Just <| future now timeLeft
        , title = Just "Time's up!"
        , body = Just "You have spent all of the time reserved for this task."
        , subtitle = Just task.class.title
      }
    ]


offTaskChannel : Int -> Notif.Channel
offTaskChannel step =
    let
        channelName =
            case step of
                1 ->
                    "Off Task, First Warning"

                2 ->
                    "Off Task! Second Warning"

                3 ->
                    "Off Task! Third Warning"

                _ ->
                    "Off Task Warnings"
    in
    { id = "Off Task Warnings"
    , name = channelName
    , description = Just "These reminders are meant to be-in-your-face and annoying, so you don't ignore them."
    , sound = Just (Notif.CustomSound "eek")
    , importance = Just Notif.Max
    , led = Nothing
    , vibrate = Just (urgentVibe (5 + step))
    }


offTaskActions : List Notif.Action
offTaskActions =
    [ { id = "SnoozeButton", button = Notif.Button "Snooze", launch = False }
    , { id = "LaunchButton", button = Notif.Button "Go", launch = True }
    , { id = "ZapButton", button = Notif.Button "Zap", launch = False }
    ]


scheduleOffTaskReminders : Instance -> Moment -> List Notification
scheduleOffTaskReminders nextTask now =
    let
        title =
            Just ("Do now: " ++ nextTask.class.title)
    in
    List.map (offTaskReminder now) (List.range 0 stopAfterCount)
        ++ [ giveUpNotif now ]


offTaskReminder : Moment -> Int -> Notification
offTaskReminder fireTime reminderNum =
    let
        reminderPeriod =
            Period.fromStart fireTime (reminderDistance reminderNum)

        base =
            Notif.build (offTaskChannel reminderNum)
    in
    { base
        | id = Just reminderNum
        , at = Just (Period.end reminderPeriod)
        , actions = offTaskActions
        , subtitle = Just <| "Off Task! Warning " ++ String.fromInt reminderNum
        , body = Just <| pickEncouragementMessage (Period.start reminderPeriod)
        , accentColor = Just "red"
        , when = Just (Period.end reminderPeriod)
        , countdown = Just True
        , chronometer = Just True
        , expiresAfter = Just (Duration.subtract (Period.length reminderPeriod) (Duration.fromSeconds 1))
    }


giveUpNotif : Moment -> Notification
giveUpNotif fireTime =
    let
        reminderPeriod =
            Period.fromStart fireTime (reminderDistance stopAfterCount)

        giveUpChannel =
            { id = "Gave Up Trying To Alert You"
            , name = "Gave Up Trying To Alert You"
            , description = Just "Lets you know when a previous reminder has exceeded the maximum number of attempts to catch your attention."
            , sound = Just (Notif.CustomSound "eek")
            , importance = Nothing
            , led = Nothing
            , vibrate = Nothing
            }

        base =
            Notif.build giveUpChannel
    in
    { base
        | id = Just (stopAfterCount + 1)
        , at = Just (Period.end reminderPeriod)
        , subtitle = Just <| "Off Task warnings have failed."
        , body = Just <| "Gave up after " ++ String.fromInt stopAfterCount
        , when = Just (Period.end reminderPeriod)
        , countdown = Just False
        , chronometer = Just False
        , expiresAfter = Just (Duration.fromHours 8)
    }


{-| How far apart should the reminders be?
-}
reminderDistance : Int -> Duration
reminderDistance reminderNum =
    Duration.fromSeconds <| toFloat (60 * reminderNum)


{-| How many reminders until we give up?
-}
stopAfterCount : Int
stopAfterCount =
    10



{- A single, quick vibration that is repeated rapidly the specified number of times.

-}


urgentVibe : Int -> Notif.VibrationSetting
urgentVibe count =
    Notif.CustomVibration <|
        List.repeat count
            ( Duration.fromMs 100
            , Duration.fromMs 100
            )


pickEncouragementMessage : Moment -> String
pickEncouragementMessage time =
    let
        encouragementMessages =
            Random.uniform
                "Do this later"
                [ "You have important goals to meet!"
                , "Why not put this in your task list for later?"
                , "This was not part of the plan"
                , "Get back on task now!"
                ]
    in
    Tuple.first <| Random.step encouragementMessages (Moment.useAsRandomSeed time)


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Notification
scheduleExcusedReminders now excusedLimit timeLeft =
    let
        excusedChannel =
            { id = "Excused Reminders", name = "Excused Reminders", description = Nothing, sound = Nothing, importance = Nothing, led = Nothing, vibrate = Nothing }

        scratch =
            Notif.build excusedChannel

        base =
            { scratch
                | id = Just 100
                , channel = excusedChannel
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


suggestedTasksChannel : Notif.Channel
suggestedTasksChannel =
    { id = "Suggested Tasks", name = "Suggested Tasks", description = Just "Other tasks you could start right now.", sound = Nothing, importance = Just Notif.Low, led = Nothing, vibrate = Nothing }


suggestedTasksGroup : Notif.GroupKey
suggestedTasksGroup =
    Notif.GroupKey "suggestions"


suggestedTaskNotif : Moment -> Instance -> Notification
suggestedTaskNotif now taskInstance =
    let
        base =
            Notif.build suggestedTasksChannel
    in
    { base
        | id = Just (9000 + taskInstance.class.id)
        , group = Just suggestedTasksGroup
        , at = Just now
        , title = Just <| taskInstance.class.title
        , body = Nothing
        , when = Nothing
        , countdown = Just False
        , chronometer = Just False
        , expiresAfter = Just (Duration.fromHours 8)
        , progress =
            --if Task.Instance.partiallyCompleted taskInstance then
            --    Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress taskInstance)) (Task.Progress.getWhole (Task.Instance.instanceProgress taskInstance))
            --
            --else
            Nothing
    }


suggestedTasks : Profile -> Environment -> List Notification
suggestedTasks profile env =
    let
        tasks =
            prioritizeTasks profile env
    in
    List.map (suggestedTaskNotif env.time) (List.take 5 tasks)
