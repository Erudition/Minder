module Refocus exposing (refreshTracking, switchActivity, switchTracking, whatsImportantNow)

import Activity.Activity as Activity exposing (..)
import Activity.Switch exposing (Switch(..), newSwitch, switchToActivity)
import Activity.Timeline as Timeline exposing (Timeline)
import Environment exposing (..)
import External.Commands as Commands
import Helpers exposing (multiline)
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty)
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Profile exposing (Profile)
import Random
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future, past)
import SmartTime.Period as Period exposing (Period)
import Task.Class exposing (ClassID)
import Task.Entry
import Task.Instance exposing (Instance, InstanceID)
import Task.Progress
import ZoneHistory


type FocusStatus
    = Free
    | OnTask OnTaskDetails
    | Excused ExcusedDetails
    | OffTask OffTaskDetails


{-| Everything I might need to make it nice to work with
-}
type alias StatusDetails =
    { now : Moment
    , oldActivity : Activity
    , lastSession : Duration
    , oldInstanceMaybe : Maybe Instance
    , newActivity : Activity
    , newActivityTodayTotal : Duration
    , newInstanceMaybe : Maybe Instance
    }


type alias OnTaskDetails =
    { win : FocusItem
    , spent : Duration
    , remaining : Duration
    , until : Moment
    }


type alias ExcusedDetails =
    { win : FocusItem
    , urgency : WINUrgency
    , used : Duration
    , limit : Duration
    , remaining : Duration
    , until : Moment
    }


type alias FocusItem =
    ( Activity, Maybe Instance )


type alias OffTaskDetails =
    { win : FocusItem
    , reason : OffTaskReason
    , urgency : WINUrgency
    }


type OffTaskReason
    = NotExcused
    | OverExcused
    | TooLongOnTask
    | NoLongerWIN
    | BadTime


type WINUrgency
    = Gentle
    | Strong


prioritizeTasks : Profile -> Environment -> List Instance
prioritizeTasks profile env =
    Task.Instance.prioritize env.time env.timeZone <|
        List.filter (Task.Instance.completed >> not) <|
            Profile.instanceListNow profile env


whatsImportantNow : Profile -> Environment -> Maybe ( FocusItem, WINUrgency )
whatsImportantNow profile env =
    let
        -- TODO allow activities to be WIN
        topPickMaybe =
            List.head <|
                prioritizeTasks profile env

        topPickActivityMaybe =
            Maybe.map (Profile.getActivityByID profile) (Maybe.andThen Task.Instance.getActivityID topPickMaybe)
    in
    case ( topPickActivityMaybe, topPickMaybe ) of
        ( Just topPickActivity, Just topPick ) ->
            Just ( ( topPickActivity, Just topPick ), Gentle )

        _ ->
            Nothing


switchActivity : ActivityID -> Profile -> Environment -> ( Profile, Cmd msg )
switchActivity newActivityID profile env =
    switchTracking newActivityID Nothing profile env


refreshTracking : Profile -> Environment -> ( Profile, Cmd msg )
refreshTracking profile env =
    switchTracking (Profile.currentActivityID profile) (Timeline.currentInstanceID profile.timeline) profile env


switchTracking : ActivityID -> Maybe InstanceID -> Profile -> Environment -> ( Profile, Cmd msg )
switchTracking newActivityID newInstanceIDMaybe profile env =
    let
        ( newStatusDetails, newFocusStatus ) =
            determineNewStatus newActivityID newInstanceIDMaybe profile env
    in
    reactToStatusChange newStatusDetails newFocusStatus profile


determineNewStatus : ActivityID -> Maybe InstanceID -> Profile -> Environment -> ( StatusDetails, FocusStatus )
determineNewStatus newActivityID newInstanceIDMaybe profile env =
    let
        updatedApp =
            if (newActivityID == oldActivityID) && (newInstanceIDMaybe == oldInstanceIDMaybe) then
                profile

            else
                { profile | timeline = newSwitch env.time newActivityID newInstanceIDMaybe :: profile.timeline }

        newActivity =
            Profile.getActivityByID profile newActivityID

        oldActivity =
            Profile.getActivityByID profile oldActivityID

        oldActivityID =
            Profile.currentActivityID profile

        oldInstanceIDMaybe =
            Activity.Switch.getInstanceID (Timeline.latestSwitch profile.timeline)

        suggestions =
            suggestedTasks profile env

        allTasks =
            Profile.instanceListNow profile env

        trackingTask =
            case newInstanceIDMaybe of
                Nothing ->
                    Nothing

                Just instanceID ->
                    List.head <| List.filter (.instance >> .id >> (==) instanceID) allTasks

        statusDetails =
            { now = env.time
            , oldActivity = Activity.getActivity oldActivityID (allActivities profile.activities)
            , lastSession = Maybe.withDefault Duration.zero <| Timeline.lastSession updatedApp.timeline oldActivityID
            , oldInstanceMaybe = Maybe.andThen (Profile.getInstanceByID profile env) (Activity.Switch.getInstanceID (Timeline.latestSwitch profile.timeline))
            , newActivity = Activity.getActivity newActivityID (allActivities profile.activities)
            , newActivityTodayTotal =
                Timeline.totalLive env.time updatedApp.timeline newActivityID
            , newInstanceMaybe = Maybe.andThen (\instanceID -> List.head <| List.filter (.instance >> .id >> (==) instanceID) allTasks) newInstanceIDMaybe
            }
    in
    case whatsImportantNow profile env of
        Nothing ->
            -- ALL DONE
            ( statusDetails, Free )

        Just ( ( nextActivity, nextInstanceMaybe ) as win, urgency ) ->
            -- MORE TO BE DONE
            let
                -- ALL EXCUSED CHECKS BELOW --
                excusedUsageString =
                    writeDur <| excusedUsage

                excusedUsage =
                    Timeline.excusedUsage updatedApp.timeline env.time ( newActivityID, newActivity )

                excusedLeft =
                    Timeline.excusedLeft updatedApp.timeline env.time ( newActivityID, Activity.getActivity newActivityID (allActivities profile.activities) )

                isThisTheRightNextTask =
                    case ( newInstanceIDMaybe, Maybe.map Task.Instance.getID nextInstanceMaybe ) of
                        ( Just newInstanceID, Just nextInstanceID ) ->
                            newInstanceID == nextInstanceID

                        _ ->
                            False

                newInstanceMaybe =
                    Maybe.andThen (Profile.getInstanceByID profile env) newInstanceIDMaybe
            in
            case ( newInstanceMaybe, isThisTheRightNextTask, nextActivity == newActivity ) of
                ( Just newInstance, True, _ ) ->
                    let
                        timeSpent =
                            -- TODO is this the time spent on the task?
                            Timeline.totalLive env.time updatedApp.timeline newActivityID

                        timeRemaining =
                            Duration.subtract newInstance.class.maxEffort timeSpent

                        onTaskDetails =
                            { win = win
                            , spent = timeSpent
                            , remaining = timeRemaining
                            , until = future env.time timeRemaining
                            }
                    in
                    ( statusDetails, OnTask onTaskDetails )

                -- with no task, is this the right next activity?
                ( _, _, True ) ->
                    Debug.todo "on task with only an activity"

                _ ->
                    if Duration.isPositive excusedLeft then
                        let
                            excusedDetails =
                                { used = excusedUsage
                                , urgency = urgency
                                , limit = Timeline.excusableLimit newActivity
                                , remaining = excusedLeft
                                , until = future statusDetails.now excusedLeft
                                , win = win
                                }
                        in
                        -- OFF TASK BUT STILL EXCUSED ---------------------
                        ( statusDetails
                        , Excused excusedDetails
                        )

                    else
                        let
                            offTaskDetails =
                                { win = win
                                , reason = determineOffTaskReason
                                , urgency = urgency
                                }

                            determineOffTaskReason =
                                -- TODO
                                NotExcused
                        in
                        -- OFF TASK
                        ( statusDetails
                        , OffTask offTaskDetails
                        )


reactToStatusChange : StatusDetails -> FocusStatus -> Profile -> ( Profile, Cmd msg )
reactToStatusChange status focusStatus profile =
    case focusStatus of
        Free ->
            ( profile, newlyFreeReaction status )

        OnTask onTask ->
            case status.newInstanceMaybe of
                Just newInstance ->
                    ( profile, newlyOnTaskReaction status onTask )

                Nothing ->
                    Debug.todo "on task with only an activity"

        Excused excused ->
            ( profile
            , newlyExcusedReaction status excused
            )

        OffTask offTask ->
            ( profile
            , newlyOffTaskReaction status offTask
            )



-- REACTIONS


newlyFreeReaction : StatusDetails -> Cmd msg
newlyFreeReaction status =
    Cmd.batch
        [ switchToast status "Liesure time"
        , notify <| freeSticky status
        , cancelAll (offTaskReminderIDs ++ onTaskReminderIDs)
        ]


newlyOnTaskReaction : StatusDetails -> OnTaskDetails -> Cmd msg
newlyOnTaskReaction status onTask =
    Cmd.batch
        [ switchToast status "✔️"
        , notify <|
            onTaskSticky status onTask
                ++ scheduleOnTaskReminders status onTask
        , cancelAll (offTaskReminderIDs ++ excusedReminderIDs)
        ]


newlyExcusedReaction status excused =
    let
        eventualOffTaskDetails =
            { win = excused.win
            , urgency = excused.urgency
            , reason = OverExcused
            }
    in
    Cmd.batch
        [ switchToast status "❌"
        , notify <|
            [ excusedSticky status excused
            ]
                ++ scheduleExcusedReminders status excused
                ++ scheduleOffTaskReminders status eventualOffTaskDetails
        , cancelAll (offTaskReminderIDs ++ onTaskReminderIDs)
        ]


newlyOffTaskReaction status offTask =
    Cmd.batch
        [ switchToast status "❌"
        , notify <|
            offTaskSticky status offTask
                ++ scheduleOffTaskReminders status offTask
        , cancelAll (onTaskReminderIDs ++ excusedReminderIDs)
        ]


switchToast : StatusDetails -> String -> Cmd msg
switchToast status addedText =
    multiLineToast
        [ [ getName status.oldActivity, "stopped after", writeDur status.lastSession ]
        , [ getName status.oldActivity, "➤", getName status.newActivity ]
        , [ writeDur status.newActivityTodayTotal, "today" ]
        , [ addedText ]
        ]



---    NOTIF HELPERS


cancelAll idList =
    Cmd.batch <| List.map notifyCancel idList


offTaskReminderIDs =
    [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]


onTaskReminderIDs =
    [ 0 ]


excusedReminderIDs =
    [ 100 ]


statusIDs =
    [ stickyID ]


stickyID =
    42



-- HELPERS


multiLineToast message =
    Commands.toast (multiline message)


writeDur givenDur =
    HumanDuration.singleLetterSpaced <|
        HumanDuration.trimToSmall <|
            HumanDuration.breakdownHMS givenDur


summarizeFocusItem : FocusItem -> String
summarizeFocusItem ( winActivity, winInstanceMaybe ) =
    Maybe.withDefault (Activity.getName winActivity) <| Maybe.map Task.Instance.getTitle winInstanceMaybe



-- STICKY NOTIFICATION


stickyBase : Notification
stickyBase =
    let
        statusChannel =
            { id = "activity"
            , name = "Tracking Status"
            , description = Just "The current activity, task and more."
            , sound = Nothing
            , importance = Just Notif.High
            , led = Nothing -- TODO activityHue
            , vibrate = Nothing
            , group = Nothing
            }

        blank =
            Notif.build statusChannel

        defaultActions =
            [ { id = "start=next", button = Notif.Button "Go", launch = True }
            , { id = "addTask"
              , button =
                    Notif.Input
                        { title = "Capture"
                        , placeholder = "Quickly add a draft"
                        , choices = []
                        , editable = True
                        , autoReplies = False
                        }
              , launch = False
              }

            -- , { id = "testInput"
            --   , button =
            --         Notif.Input
            --             { title = "Test"
            --             , placeholder = "Stuff that goes here"
            --             , choices = [ "WOW", "Bleh", "Nah", "Sweet" ]
            --             , editable = False
            --             , autoReplies = False
            --             }
            --   , launch = False
            --   }
            , { id = "sync=marvin", button = Notif.Button "Sync Marvin", launch = False }
            ]
    in
    { blank
        | id = Just stickyID
        , group = Just (Notif.GroupKey "status")
        , showWhen = Just True
        , autoCancel = Just False
        , ongoing = Just True
        , chronometer = Just True
        , bigTextStyle = Just True
        , actions = defaultActions
    }


offTaskSticky : StatusDetails -> OffTaskDetails -> List Notification
offTaskSticky status offTask =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe |> Maybe.map Task.Instance.getTitle

        final =
            { stickyBase
                | title = title
                , when = Just (past status.now status.newActivityTodayTotal)
                , subtitle = Just ("Off Task (" ++ Activity.getName status.newActivity ++ ")")
                , body = Maybe.map (\nt -> "What's Important Now: " ++ nt.class.title) status.newInstanceMaybe
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress task)) (Task.Progress.getWhole (Task.Instance.instanceProgress task))

                        Nothing ->
                            Nothing
                , actions =
                    case status.newInstanceMaybe of
                        Just instance ->
                            stickyBase.actions ++ actionsIfTaskPresent instance

                        Nothing ->
                            stickyBase.actions
                , accentColor = Just "red"
            }
    in
    [ final, { final | ongoing = Just False, id = Just 420 } ]


onTaskSticky : StatusDetails -> OnTaskDetails -> List Notification
onTaskSticky status onTask =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe |> Maybe.map Task.Instance.getTitle

        final =
            { stickyBase
                | title = title
                , when = Just (past status.now status.newActivityTodayTotal)
                , subtitle = Just ("On Task (" ++ Activity.getName status.newActivity ++ ")")
                , body = Maybe.map (\nt -> "Doing what's important now: " ++ nt.class.title) status.newInstanceMaybe
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress task)) (Task.Progress.getWhole (Task.Instance.instanceProgress task))

                        Nothing ->
                            Nothing
                , actions =
                    case status.newInstanceMaybe of
                        Just instance ->
                            stickyBase.actions ++ actionsIfTaskPresent instance

                        Nothing ->
                            stickyBase.actions
                , accentColor = Just "green"
            }
    in
    [ final, { final | ongoing = Just False, id = Just 420 } ]


freeSticky : StatusDetails -> List Notification
freeSticky status =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe |> Maybe.map Task.Instance.getTitle

        final =
            { stickyBase
                | title = title
                , when = Just (past status.now status.newActivityTodayTotal)
                , subtitle = Just (Activity.getName status.newActivity ++ " - ")
                , body = Maybe.map (\nt -> "What's Important Now: " ++ nt.class.title) status.newInstanceMaybe
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress task)) (Task.Progress.getWhole (Task.Instance.instanceProgress task))

                        Nothing ->
                            Nothing
                , actions =
                    case status.newInstanceMaybe of
                        Just instance ->
                            stickyBase.actions ++ actionsIfTaskPresent instance

                        Nothing ->
                            stickyBase.actions
                , accentColor = Nothing
                , ongoing = Just False
            }
    in
    [ final ]


excusedSticky : StatusDetails -> ExcusedDetails -> Notification
excusedSticky status excused =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.Instance.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe
                |> Maybe.map Task.Instance.getTitle

        ( winActivity, winInstanceMaybe ) =
            excused.win
    in
    { stickyBase
        | title = title
        , chronometer = Just True
        , when = Just excused.until
        , subtitle = Just (Activity.getName status.newActivity ++ " (excused up to " ++ writeDur excused.limit ++ ")")
        , body = Just ("What's Important Now: \n" ++ summarizeFocusItem excused.win)
        , countdown = Just True
        , progress =
            case status.newInstanceMaybe of
                Just task ->
                    Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress task)) (Task.Progress.getWhole (Task.Instance.instanceProgress task))

                Nothing ->
                    -- show the decreasing amount of time left
                    Just <| Notif.Progress (Duration.inMs excused.remaining) (Duration.inMs excused.limit)
        , actions =
            case status.newInstanceMaybe of
                Just instance ->
                    stickyBase.actions ++ actionsIfTaskPresent instance

                Nothing ->
                    stickyBase.actions
        , accentColor = Just "yellow"
    }


onTaskChannel : Notif.Channel
onTaskChannel =
    { id = "Task Progress", name = "Task Progress", description = Just "Reminders of time passing, as well as progress reports, while on task.", sound = Nothing, importance = Just Notif.High, led = Nothing, vibrate = Nothing, group = Just "Reminders" }


scheduleOnTaskReminders : StatusDetails -> OnTaskDetails -> List Notification
scheduleOnTaskReminders status onTask =
    let
        blank =
            Notif.build onTaskChannel

        reminderBase =
            { blank
                | id = Just 0
                , expiresAfter = Just (Duration.fromMinutes 1)
                , when = Just (future status.now onTask.remaining)
                , accentColor = Just "green"
            }

        fractionLeft denom =
            future status.now <| Duration.subtract onTask.remaining (Duration.scale onTask.remaining (1 / denom))
    in
    [ { reminderBase
        | at = Just <| fractionLeft 2
        , title = Just "Half-way done!"
        , body = Just "1/2 time left for this task."
        , subtitle = Just (summarizeFocusItem onTask.win)
        , progress = Just (Notif.Progress 1 2)
      }
    , { reminderBase
        | at = Just <| fractionLeft 3
        , title = Just "Two-thirds done!"
        , body = Just "1/3 time left for this task."
        , subtitle = Just (summarizeFocusItem onTask.win)
        , progress = Just (Notif.Progress 2 3)
      }
    , { reminderBase
        | at = Just <| fractionLeft 4
        , title = Just "Three-quarters done!"
        , body = Just "1/4 time left for this task."
        , subtitle = Just (summarizeFocusItem onTask.win)
        , progress = Just (Notif.Progress 3 4)
      }
    , { reminderBase
        | at = Just <| future status.now onTask.remaining
        , title = Just "Time's up!"
        , body = Just "You have spent all of the time reserved for this task."
        , subtitle = Just (summarizeFocusItem onTask.win)
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
    , group = Just "Reminders"
    }


offTaskActions : List Notif.Action
offTaskActions =
    [ { id = "SnoozeButton", button = Notif.Button "Snooze", launch = False }
    , { id = "LaunchButton", button = Notif.Button "Go", launch = True }
    , { id = "ZapButton", button = Notif.Button "Zap", launch = False }
    ]


scheduleOffTaskReminders : StatusDetails -> OffTaskDetails -> List Notification
scheduleOffTaskReminders status offTask =
    let
        title =
            case offTask.win of
                ( _, Just winInstance ) ->
                    Just ("Do now: " ++ Task.Instance.getTitle winInstance)

                ( winActivity, Nothing ) ->
                    Just ("Do now: " ++ Activity.getName winActivity)
    in
    List.map (offTaskReminder status.now) (List.range 0 stopAfterCount)
        ++ [ giveUpNotif status.now ]


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
            , group = Just "Status"
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
        , accentColor = Just "brown"
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
scheduleExcusedReminders : StatusDetails -> ExcusedDetails -> List Notification
scheduleExcusedReminders status excused =
    let
        excusedChannel =
            { id = "Excused Reminders", name = "Excused Reminders", description = Nothing, sound = Nothing, importance = Nothing, led = Nothing, vibrate = Nothing, group = Just "Reminders" }

        scratch =
            Notif.build excusedChannel

        base =
            { scratch
                | id = Just 100
                , channel = excusedChannel
                , actions = actions
                , when = Just excused.until
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
            firstIsGreater excused.remaining (Duration.fromSeconds 30.0)

        beforeTimesUp timeBefore =
            -- get Moments before the expiration Moment, to schedule "time left" reminders. Don't make the mistake of using `future` from now - we should be working backwards from the expiry time for "time left".
            past excused.until timeBefore

        halfLeftThisSession =
            -- It would be annoying to immediately get warned "5 minutes left" when the period is only 7 minutes, so we make sure at least half the time is used before showing warnings
            Duration.scale excused.remaining (1 / 2)

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
                , subtitle = Just <| "Excused for up to " ++ write excused.limit
                , progress = Just (Notif.Progress (Duration.inMs amountLeft) (Duration.inMs excused.limit))
            }

        write durLeft =
            abbreviatedSpaced <| HumanDuration.breakdownNonzero durLeft

        interimReminders =
            [ { base
                | at = Just <| future status.now (dur (Minutes 10))
                , title = Just "Distraction taken care of?"
                , subtitle = Just <| pickEncouragementMessage (future status.now (dur (Minutes 10)))
              }
            , { base
                | at = Just <| future status.now (dur (Minutes 20))
                , title = Just "Ready to get back on task?"
                , subtitle = Just <| pickEncouragementMessage (future status.now (dur (Minutes 20)))
              }
            , { base
                | at = Just <| future status.now (dur (Minutes 30))
                , title = Just "Can this wait?"
                , subtitle = Just <| pickEncouragementMessage (future status.now (dur (Minutes 30)))
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
    { id = "Suggested Tasks", name = "Suggested Tasks", description = Just "Other tasks you could start right now.", sound = Nothing, importance = Just Notif.Default, led = Nothing, vibrate = Nothing, group = Just "Actionable" }


suggestedTasksGroup : Notif.GroupKey
suggestedTasksGroup =
    Notif.GroupKey "suggestions"


suggestedTaskNotif : Moment -> ( Instance, ActivityID ) -> Notification
suggestedTaskNotif now ( taskInstance, taskActivityID ) =
    let
        base =
            Notif.build suggestedTasksChannel

        actions =
            [ { id = "startTask=" ++ String.fromInt (Task.Instance.getID taskInstance), button = Notif.Button "Start", launch = False }
            ]
    in
    { base
        | id = Just <| taskClassNotifID taskInstance.class.id
        , group = Just suggestedTasksGroup
        , subtitle = Just "Suggested"
        , at = Just now
        , title = Just <| taskInstance.class.title
        , body = Nothing
        , actions = actions
        , when = Nothing
        , showWhen = Just False
        , countdown = Just False
        , chronometer = Just False
        , expiresAfter = Just (Duration.fromHours 1) -- TODO
        , progress =
            if Task.Instance.partiallyCompleted taskInstance then
                Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress taskInstance)) (Task.Progress.getWhole (Task.Instance.instanceProgress taskInstance))

            else
                Nothing
    }


suggestedTasks : Profile -> Environment -> List Notification
suggestedTasks profile env =
    let
        actionableTasks =
            List.filterMap withActivityID (prioritizeTasks profile env)

        withActivityID task =
            case Task.Instance.getActivityID task of
                Nothing ->
                    Nothing

                Just hasActivityID ->
                    Just ( task, hasActivityID )
    in
    List.map (suggestedTaskNotif env.time) (List.take 10 actionableTasks)


taskClassNotifID : ClassID -> Int
taskClassNotifID instanceID =
    9000 + instanceID


currentTaskNotif : Moment -> Instance -> Notification
currentTaskNotif now task =
    let
        currentID =
            Task.Instance.getID task

        currentTaskChannel =
            { id = "Current Task", name = "Current Task", description = Just "What you're working on.", sound = Nothing, importance = Just Notif.Max, led = Nothing, vibrate = Nothing, group = Just "Actionable" }

        blank =
            Notif.build currentTaskChannel

        actions =
            [ { id = "updateProgress=+20%", button = Notif.Button "+20%", launch = False }
            , { id = "stopTask=" ++ String.fromInt currentID, button = Notif.Button "Stop", launch = False }
            ]
    in
    { blank
        | id = Just <| taskClassNotifID task.class.id
        , autoCancel = Just False
        , title = Just task.class.title
        , chronometer = Just True
        , when = Just now
        , subtitle = Nothing
        , body = Nothing
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
        , progress = Just <| Notif.Progress (Task.Progress.getPortion (Task.Instance.instanceProgress task)) (Task.Progress.getWhole (Task.Instance.instanceProgress task))
        , actions = actions
    }
