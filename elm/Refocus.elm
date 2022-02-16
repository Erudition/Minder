module Refocus exposing (refreshTracking, switchActivity, switchTracking, whatsImportantNow)

import Activity.Activity as Activity exposing (..)
import Activity.Switch exposing (Switch(..), newSwitch, switchToActivity)
import Activity.Timeline as Timeline exposing (Timeline)
import Environment exposing (..)
import External.Commands as Commands
import Helpers exposing (multiline)
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty)
import Log
import Maybe.Extra as Maybe
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif exposing (Notification)
import Profile exposing (Profile)
import Random
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Human.Moment as HumanMoment
import SmartTime.Moment as Moment exposing (Moment, future, past)
import SmartTime.Period as Period exposing (Period)
import Task.ActionClass exposing (ActionClassID)
import Task.AssignedAction exposing (AssignedAction, AssignedActionID)
import Task.Entry
import Task.Progress
import ZoneHistory


type FocusStatus
    = Free
    | Traction TractionDetails
    | Excused ExcusedDetails
    | Distraction DistractionDetails


{-| Everything I might need to make it nice to work with
DO NOT INCLUDE STUFF THAT CHANGES WITH TIME, just calculate it based on .now
since then we can recursively call with "later" statuses
-}
type alias StatusDetails =
    { now : Moment
    , zone : HumanMoment.Zone
    , oldActivity : Activity
    , lastSession : Duration
    , oldInstanceMaybe : Maybe AssignedAction
    , newActivity : Activity
    , newActivityTodayTotal : Duration
    , newInstanceMaybe : Maybe AssignedAction
    }


type alias TractionDetails =
    { win : FocusItem
    , urgency : WINUrgency
    , spent : Duration
    , remaining : Duration
    , limit : Duration
    , until : Moment
    , target : Maybe Moment
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
    ( Activity, Maybe AssignedAction )


type alias DistractionDetails =
    { win : FocusItem
    , reason : DistractionReason
    , urgency : WINUrgency
    }


type DistractionReason
    = NotExcused
    | OverExcused
    | TooLongOnTask
    | NoLongerWIN
    | BadTime


type WINUrgency
    = Gentle
    | Strong


prioritizeTasks : Profile -> Environment -> List AssignedAction
prioritizeTasks profile env =
    Task.AssignedAction.prioritize env.time env.timeZone <|
        List.filter (Task.AssignedAction.completed >> not) <|
            Profile.instanceListNow profile env


whatsImportantNow : Profile -> Environment -> Maybe ( FocusItem, WINUrgency )
whatsImportantNow profile env =
    let
        prioritized =
            -- Must have an activity to tell
            List.filter (\i -> i.class.activity /= Nothing)
                (prioritizeTasks profile env)

        -- TODO allow activities to be WIN
        topPickMaybe =
            List.head <|
                prioritized

        topPickActivityMaybe =
            Maybe.map (Profile.getActivityByID profile) (Maybe.andThen Task.AssignedAction.getActivityID topPickMaybe)
    in
    case ( topPickActivityMaybe, topPickMaybe ) of
        ( Just topPickActivity, Just topPick ) ->
            Just ( ( topPickActivity, Just topPick ), Gentle )

        somethingelse ->
            Log.logSeparate "top pick" somethingelse Nothing


switchActivity : ActivityID -> Profile -> Environment -> ( Profile, Cmd msg )
switchActivity newActivityID profile env =
    switchTracking newActivityID Nothing profile env


refreshTracking : Profile -> Environment -> ( Profile, Cmd msg )
refreshTracking profile env =
    switchTracking (Profile.currentActivityID profile) (Timeline.currentInstanceID profile.timeline) profile env


switchTracking : ActivityID -> Maybe AssignedActionID -> Profile -> Environment -> ( Profile, Cmd msg )
switchTracking newActivityID newInstanceIDMaybe oldProfile env =
    let
        updatedProfile =
            { oldProfile | timeline = newSwitch env.time newActivityID newInstanceIDMaybe :: oldProfile.timeline }

        oldInstanceIDMaybe =
            Activity.Switch.getInstanceID (Timeline.latestSwitch oldProfile.timeline)
    in
    if
        (Profile.currentActivityID oldProfile == newActivityID)
            && (newInstanceIDMaybe == oldInstanceIDMaybe)
    then
        -- we didn't change what we were tracking
        ( oldProfile, Cmd.none )

    else
        -- we actually changed tracking, add switch to timeline
        let
            ( newStatusDetails, newFocusStatus ) =
                determineNewStatus ( newActivityID, newInstanceIDMaybe ) oldProfile updatedProfile env

            ( reactionNow, checkbackTimeMaybe ) =
                reactToStatusChange False newStatusDetails newFocusStatus updatedProfile

            reactionWhenExpired =
                case checkbackTimeMaybe of
                    Nothing ->
                        Cmd.none

                    Just checkbackTime ->
                        let
                            -- everything stays the same, just in the future
                            ( futureStatusDetails, futureFocusStatus ) =
                                determineNewStatus ( newActivityID, newInstanceIDMaybe ) updatedProfile updatedProfile { env | time = checkbackTime }
                        in
                        Tuple.first (reactToStatusChange True futureStatusDetails futureFocusStatus updatedProfile)

            suggestions =
                suggestedTasks updatedProfile env
        in
        ( updatedProfile, Cmd.batch [ reactionNow, Debug.log "FUTURE REACTION" reactionWhenExpired, notify suggestions ] )


determineNewStatus : ( ActivityID, Maybe AssignedActionID ) -> Profile -> Profile -> Environment -> ( StatusDetails, FocusStatus )
determineNewStatus ( newActivityID, newInstanceIDMaybe ) oldProfile newProfile env =
    let
        newActivity =
            Profile.getActivityByID newProfile newActivityID

        oldActivity =
            Profile.getActivityByID newProfile oldActivityID

        oldActivityID =
            Profile.currentActivityID oldProfile

        oldInstanceIDMaybe =
            Activity.Switch.getInstanceID (Timeline.latestSwitch oldProfile.timeline)

        allTasks =
            Profile.instanceListNow newProfile env

        trackingTask =
            case newInstanceIDMaybe of
                Nothing ->
                    Nothing

                Just instanceID ->
                    List.head <| List.filter (.instance >> .id >> (==) instanceID) allTasks

        statusDetails =
            { now = env.time
            , zone = env.timeZone
            , oldActivity = Activity.getActivity oldActivityID (allActivities newProfile.activities)
            , lastSession = Maybe.withDefault Duration.zero <| Timeline.lastSession newProfile.timeline oldActivityID
            , oldInstanceMaybe = Maybe.andThen (Profile.getInstanceByID newProfile env) oldInstanceIDMaybe
            , newActivity = Activity.getActivity newActivityID (allActivities newProfile.activities)
            , newActivityTodayTotal =
                Timeline.totalLive env.time newProfile.timeline newActivityID
            , newInstanceMaybe = Maybe.andThen (\instanceID -> List.head <| List.filter (.instance >> .id >> (==) instanceID) allTasks) newInstanceIDMaybe
            }
    in
    case whatsImportantNow newProfile env of
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
                    Timeline.excusedUsage newProfile.timeline env.time ( newActivityID, newActivity )

                excusedLeft =
                    Timeline.excusedLeft newProfile.timeline env.time ( newActivityID, Activity.getActivity newActivityID (allActivities newProfile.activities) )

                isThisTheRightNextTask =
                    case ( newInstanceIDMaybe, Maybe.map Task.AssignedAction.getID nextInstanceMaybe ) of
                        ( Just newInstanceID, Just nextInstanceID ) ->
                            newInstanceID == nextInstanceID

                        _ ->
                            False

                newInstanceMaybe =
                    Maybe.andThen (Profile.getInstanceByID newProfile env) newInstanceIDMaybe
            in
            case ( newInstanceMaybe, isThisTheRightNextTask, nextActivity == newActivity ) of
                ( Just newInstance, True, _ ) ->
                    let
                        timeSpent =
                            -- TODO is this the time spent on the task?
                            Timeline.totalLive env.time newProfile.timeline newActivityID

                        maxTimeRemaining =
                            Duration.subtract newInstance.class.maxEffort timeSpent

                        remainingToTarget =
                            Duration.subtract newInstance.class.predictedEffort timeSpent

                        intendToFinishDuringThisSession =
                            -- TODO false if less time available than needed
                            True

                        targetIfApplicable =
                            if intendToFinishDuringThisSession then
                                Just (future env.time remainingToTarget)

                            else
                                Nothing

                        tractionDetails =
                            { win = win
                            , urgency = urgency
                            , spent = timeSpent
                            , remaining =
                                if intendToFinishDuringThisSession then
                                    maxTimeRemaining

                                else
                                    remainingToTarget

                            -- TODO
                            , limit = maxTimeRemaining
                            , until = future env.time maxTimeRemaining
                            , target = targetIfApplicable
                            }
                    in
                    ( statusDetails, Traction tractionDetails )

                -- with no task, is this the right next activity?
                -- ( Nothing, _, True ) ->
                --     let
                --         timeSpent =
                --             -- TODO is this the time spent on the task?
                --             Timeline.totalLive env.time newProfile.timeline newActivityID
                --
                --         timeRemaining =
                --             -- TODO
                --             Duration.anHour
                --
                --         tractionDetails =
                --             { win = win
                --             , urgency = urgency
                --             , spent = timeSpent
                --             , remaining = timeRemaining
                --             , until = future env.time timeRemaining
                --             }
                --     in
                --     ( statusDetails, Traction tractionDetails )
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
                            distractionDetails =
                                { win = win
                                , reason = determineDistractionReason
                                , urgency = urgency
                                }

                            determineDistractionReason =
                                -- TODO
                                NotExcused
                        in
                        -- OFF TASK
                        ( statusDetails
                        , Distraction distractionDetails
                        )


type alias CheckBack =
    Moment


reactToStatusChange : Bool -> StatusDetails -> FocusStatus -> Profile -> ( Cmd msg, Maybe CheckBack )
reactToStatusChange isExtrapolated status focusStatus profile =
    case focusStatus of
        Free ->
            ( newlyFreeReaction status, Nothing )

        Distraction distraction ->
            ( newlyDistractionReaction isExtrapolated status distraction, Nothing )

        Excused excused ->
            ( newlyExcusedReaction isExtrapolated status excused, Just excused.until )

        Traction traction ->
            ( newlyTractionReaction status traction, Just traction.until )



-- REACTIONS


newlyFreeReaction : StatusDetails -> Cmd msg
newlyFreeReaction status =
    Cmd.batch
        [ switchToast status "Liesure time"
        , notify <| freeSticky status
        , cancelAll (distractionReminderIDs ++ tractionReminderIDs)
        ]


newlyTractionReaction : StatusDetails -> TractionDetails -> Cmd msg
newlyTractionReaction status traction =
    Cmd.batch
        [ switchToast status "✔️"
        , notify <|
            tractionSticky status traction Duration.zero
                ++ scheduleTractionReminders status traction
        , cancelAll (distractionReminderIDs ++ excusedReminderIDs)
        ]


newlyExcusedReaction isExtrapolated status excused =
    Cmd.batch <|
        [ notify <|
            excusedSticky status excused Duration.zero
                ++ scheduleExcusedReminders status excused
        ]
            ++ (if not isExtrapolated then
                    [ switchToast status "❌ Not W.I.N. Excused."
                    , cancelAll (distractionReminderIDs ++ tractionReminderIDs)
                    ]

                else
                    []
               )


newlyDistractionReaction isExtrapolated status distraction =
    let
        realTimeOnly =
            if not isExtrapolated then
                [ switchToast status "❌ Not W.I.N. "
                , cancelAll (distractionReminderIDs ++ tractionReminderIDs ++ excusedReminderIDs) -- TODO safe to cancel first reminder at same time as scheduling it?
                ]

            else
                []
    in
    Cmd.batch <|
        realTimeOnly
            ++ [ notify <|
                    distractionSticky status distraction Duration.zero
                        ++ scheduleDistractionReminders status distraction
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


distractionReminderIDs =
    -- TODO better way (merge into one?)
    [ 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711 ]


tractionReminderIDs =
    [ 200, 201, 202, 203, 204 ]


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
    Maybe.withDefault (Activity.getName winActivity) <| Maybe.map Task.AssignedAction.getTitle winInstanceMaybe



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


notifUpdateSpacing =
    Duration.fromSeconds 30


freeSticky : StatusDetails -> List Notification
freeSticky status =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe |> Maybe.map Task.AssignedAction.getTitle

        final =
            { stickyBase
                | title = title
                , at = Just status.now
                , when = Just (past status.now status.newActivityTodayTotal)
                , subtitle = Just (Activity.getName status.newActivity ++ " (no other plans)")
                , body = Maybe.map (\nt -> "What's Important Now: " ++ nt.class.title) status.newInstanceMaybe
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.AssignedAction.instanceProgress task)) (Task.Progress.getWhole (Task.AssignedAction.instanceProgress task))

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


tractionSticky : StatusDetails -> TractionDetails -> Duration -> List Notification
tractionSticky status traction elapsed =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe |> Maybe.map Task.AssignedAction.getTitle

        notifTime =
            Moment.future status.now elapsed

        lifetime =
            Moment.difference notifTime traction.until

        sessionTotal =
            -- TODO this is activity today total not focus session total
            Duration.add status.newActivityTodayTotal elapsed

        final =
            { stickyBase
                | title = title
                , at = Just notifTime
                , when = Just (past notifTime sessionTotal)
                , subtitle = Just ("On Task (" ++ Activity.getName status.newActivity ++ ")")
                , body = Just ("Doing what's important now: " ++ summarizeFocusItem traction.win)
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.AssignedAction.instanceProgress task)) (Task.Progress.getWhole (Task.AssignedAction.instanceProgress task))

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

        nextUpdateMoment =
            Moment.future notifTime notifUpdateSpacing

        laterUpdates =
            -- TODO not yet supported in LocalNotifications plugin - can schedule one update, but only one entry per ID in the Store is retrieved, so the last update to be scheduled becomes the content for every delayed update (even though the updates will happen at all the specified times)
            if Moment.isEarlier nextUpdateMoment traction.until then
                tractionSticky status traction (Duration.add notifUpdateSpacing elapsed)

            else
                []
    in
    [ final ]


excusedSticky : StatusDetails -> ExcusedDetails -> Duration -> List Notification
excusedSticky status excused elapsed =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe
                |> Maybe.map Task.AssignedAction.getTitle

        notifTime =
            Moment.future status.now elapsed

        lifetime =
            Moment.difference notifTime excused.until

        sessionTotal =
            -- TODO this is activity today total not focus session total
            Duration.add status.newActivityTodayTotal elapsed

        ( winActivity, winInstanceMaybe ) =
            excused.win

        remaining =
            Duration.subtract excused.remaining elapsed

        body =
            multiline
                [ [ "What's Important Now:" ]
                , [ summarizeFocusItem excused.win ]
                , [ "Status changed", HumanMoment.describeGapVsNow status.zone notifTime status.now ]
                ]

        final =
            { stickyBase
                | title = title
                , at = Just notifTime
                , chronometer = Just True
                , when = Just excused.until
                , subtitle = Just (Activity.getName status.newActivity ++ " (excused up to " ++ writeDur excused.limit ++ ")")
                , body = Just body
                , countdown = Just True
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.AssignedAction.instanceProgress task)) (Task.Progress.getWhole (Task.AssignedAction.instanceProgress task))

                        Nothing ->
                            -- show the decreasing amount of time left
                            -- Just <| Notif.Progress (Duration.inMs remaining) (Duration.inMs excused.limit)
                            Nothing
                , actions =
                    case status.newInstanceMaybe of
                        Just instance ->
                            stickyBase.actions ++ actionsIfTaskPresent instance

                        Nothing ->
                            stickyBase.actions
                , accentColor = Just "yellow"
                , expiresAfter = Just lifetime
                , maxMinutesLate = Just 0
            }

        nextUpdateMoment =
            Moment.future notifTime notifUpdateSpacing

        moreUpdates =
            Moment.isEarlier nextUpdateMoment excused.until

        laterUpdates =
            -- TODO not yet supported in LocalNotifications plugin - can schedule one update, but only one entry per ID in the Store is retrieved, so the last update to be scheduled becomes the content for every delayed update (even though the updates will happen at all the specified times)
            if moreUpdates then
                List.reverse <| excusedSticky status excused (Duration.add notifUpdateSpacing elapsed)

            else
                []
    in
    [ final ]


distractionSticky : StatusDetails -> DistractionDetails -> Duration -> List Notification
distractionSticky status distraction elapsed =
    let
        actionsIfTaskPresent instance =
            [ { id = "stopTask=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Stop", launch = False }
            , { id = "complete=" ++ String.fromInt (Task.AssignedAction.getID instance), button = Notif.Button "Complete", launch = False }
            ]

        title =
            status.newInstanceMaybe |> Maybe.map Task.AssignedAction.getTitle

        notifTime =
            Moment.future status.now elapsed

        sessionTotal =
            -- TODO this is activity today total not focus session total
            Duration.add status.newActivityTodayTotal elapsed

        final =
            { stickyBase
                | title = title
                , at = Just notifTime
                , when = Just (past notifTime sessionTotal)
                , subtitle = Just ("Off Task (" ++ Activity.getName status.newActivity ++ ")")
                , body = Just ("What's Important Now: \n" ++ summarizeFocusItem distraction.win)
                , progress =
                    case status.newInstanceMaybe of
                        Just task ->
                            Just <| Notif.Progress (Task.Progress.getPortion (Task.AssignedAction.instanceProgress task)) (Task.Progress.getWhole (Task.AssignedAction.instanceProgress task))

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
    [ final ]


tractionChannel : Notif.Channel
tractionChannel =
    { id = "Task Progress", name = "Task Progress", description = Just "Reminders of time passing, as well as progress reports, while on task.", sound = Nothing, importance = Just Notif.High, led = Nothing, vibrate = Nothing, group = Just "Reminders" }


scheduleTractionReminders : StatusDetails -> TractionDetails -> List Notification
scheduleTractionReminders status traction =
    let
        blank =
            Notif.build tractionChannel

        reminderBase =
            { blank
                | expiresAfter = Just (Duration.fromMinutes 1)
                , when = Just (future status.now traction.remaining)
                , accentColor = Just "green"
                , maxMinutesLate = Just 0
            }

        fractionLeft denom =
            future status.now <| Duration.subtract traction.remaining (Duration.scale traction.remaining (1 / denom))
    in
    [ { reminderBase
        | id = Just 201
        , at = Just <| fractionLeft 2
        , title = Just "Half-way done!"
        , body = Just "1/2 time left for this task."
        , subtitle = Just (summarizeFocusItem traction.win)
        , progress = Just (Notif.Progress 1 2)
      }
    , { reminderBase
        | id = Just 202
        , at = Just <| fractionLeft 3
        , title = Just "Two-thirds done!"
        , body = Just "1/3 time left for this task."
        , subtitle = Just (summarizeFocusItem traction.win)
        , progress = Just (Notif.Progress 2 3)
      }
    , { reminderBase
        | id = Just 203
        , at = Just <| fractionLeft 4
        , title = Just "Three-quarters done!"
        , body = Just "1/4 time left for this task."
        , subtitle = Just (summarizeFocusItem traction.win)
        , progress = Just (Notif.Progress 3 4)
      }
    , { reminderBase
        | id = Just 204
        , at = Just <| future status.now traction.remaining
        , title = Just "Time's up!"
        , body = Just "You have spent all of the time reserved for this task."
        , subtitle = Just (summarizeFocusItem traction.win)
      }
    ]


distractionChannel : Int -> Notif.Channel
distractionChannel step =
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


distractionActions : List Notif.Action
distractionActions =
    [ { id = "SnoozeButton", button = Notif.Button "Snooze", launch = False }
    , { id = "LaunchButton", button = Notif.Button "Go", launch = True }
    , { id = "ZapButton", button = Notif.Button "Zap", launch = False }
    ]


scheduleDistractionReminders : StatusDetails -> DistractionDetails -> List Notification
scheduleDistractionReminders status distraction =
    let
        title =
            case distraction.win of
                ( _, Just winInstance ) ->
                    Just ("Do now: " ++ Task.AssignedAction.getTitle winInstance)

                ( winActivity, Nothing ) ->
                    Just ("Do now: " ++ Activity.getName winActivity)
    in
    List.map (distractionReminder status distraction) (List.range 0 stopAfterCount)
        ++ [ giveUpNotif status.now ]


distractionReminder : StatusDetails -> DistractionDetails -> Int -> Notification
distractionReminder status distraction reminderNum =
    let
        reminderStart =
            Moment.future status.now (reminderDistance reminderNum)

        base =
            Notif.build (distractionChannel reminderNum)
    in
    { base
        | id = Just (700 + reminderNum)
        , at = Just reminderStart
        , actions = distractionActions
        , subtitle = Just <| "Off Task! Warning #" ++ String.fromInt (reminderNum + 1)
        , body = Just <| pickEncouragementMessage reminderStart
        , accentColor = Just "red"
        , when = Just status.now
        , countdown = Just False
        , chronometer = Just True
        , expiresAfter = Just (reminderDistance 3)
        , maxMinutesLate = Just 0
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
        | id = Just (stopAfterCount + 701)
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


{-| A single, quick vibration that is repeated rapidly the specified number of times.
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
                , maxMinutesLate = Just 0
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



-- TASK SUGGESTIONS ----------------------------------


suggestedTasksChannel : Notif.Channel
suggestedTasksChannel =
    { id = "Suggested Tasks", name = "Suggested Tasks", description = Just "Other tasks you could start right now.", sound = Nothing, importance = Just Notif.Default, led = Nothing, vibrate = Nothing, group = Just "Actionable" }


suggestedTasksGroup : Notif.GroupKey
suggestedTasksGroup =
    Notif.GroupKey "suggestions"


suggestedTaskNotif : Moment -> ( AssignedAction, ActivityID ) -> Notification
suggestedTaskNotif now ( taskInstance, taskActivityID ) =
    let
        base =
            Notif.build suggestedTasksChannel

        actions =
            [ { id = "startTask=" ++ String.fromInt (Task.AssignedAction.getID taskInstance), button = Notif.Button "Start", launch = False }
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
            if Task.AssignedAction.partiallyCompleted taskInstance then
                Just <| Notif.Progress (Task.Progress.getPortion (Task.AssignedAction.instanceProgress taskInstance)) (Task.Progress.getWhole (Task.AssignedAction.instanceProgress taskInstance))

            else
                Nothing
    }


suggestedTasks : Profile -> Environment -> List Notification
suggestedTasks profile env =
    let
        actionableTasks =
            List.filterMap withActivityID (prioritizeTasks profile env)

        withActivityID task =
            case Task.AssignedAction.getActivityID task of
                Nothing ->
                    Nothing

                Just hasActivityID ->
                    Just ( task, hasActivityID )
    in
    List.map (suggestedTaskNotif env.time) (List.take 3 actionableTasks)


taskClassNotifID : ActionClassID -> Int
taskClassNotifID instanceID =
    9000 + instanceID



-- TASK CLEANUP ----------------------------------


type CleanupRequired
    = NeedsActivity
    | NeedsDuration


cleanupTasksChannel : Notif.Channel
cleanupTasksChannel =
    { id = "Quick Cleanup Prompts", name = "Quick Cleanup Prompts", description = Just "Prompts to clean up your tasks and drafts.", sound = Nothing, importance = Just Notif.Default, led = Nothing, vibrate = Nothing, group = Just "Actionable" }


cleanupTasksGroup : Notif.GroupKey
cleanupTasksGroup =
    Notif.GroupKey "cleanup"


cleanupTaskNotif : Moment -> ( AssignedAction, List CleanupRequired ) -> Notification
cleanupTaskNotif now ( taskInstance, needs ) =
    let
        base =
            Notif.build cleanupTasksChannel

        actions =
            [ { id = "startTask=" ++ String.fromInt (Task.AssignedAction.getID taskInstance), button = Notif.Button "Start", launch = False }
            ]
    in
    { base
        | id = Just <| taskClassNotifID taskInstance.class.id
        , group = Just cleanupTasksGroup
        , subtitle = Just "Missing Duration/Activity"
        , at = Just now
        , title = Just <| taskInstance.class.title
        , body = Nothing
        , actions = actions
        , when = Nothing
        , showWhen = Just False
        , countdown = Just False
        , chronometer = Just False
        , expiresAfter = Nothing
        , progress = Nothing
    }


cleanupTasks : Profile -> Environment -> List Notification
cleanupTasks profile env =
    let
        tasksToCleanup =
            List.filterMap needsCleanup (prioritizeTasks profile env)

        needsCleanup task =
            case Task.AssignedAction.getActivityID task of
                Nothing ->
                    Just ( task, [ NeedsActivity ] )

                Just hasActivityID ->
                    Nothing
    in
    List.map (cleanupTaskNotif env.time) (List.take 3 tasksToCleanup)


currentTaskNotif : Moment -> AssignedAction -> Notification
currentTaskNotif now task =
    let
        currentID =
            Task.AssignedAction.getID task

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
        , progress = Just <| Notif.Progress (Task.Progress.getPortion (Task.AssignedAction.instanceProgress task)) (Task.Progress.getWhole (Task.AssignedAction.instanceProgress task))
        , actions = actions
    }