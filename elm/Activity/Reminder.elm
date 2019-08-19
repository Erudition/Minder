module Activity.Reminder exposing (Action(..), Alarm, Intent, NotificationAction, encodeAction, encodeAlarm, reminder, reminder3, scheduleExcusedReminders, scheduleOffTaskReminders, scheduleOnTaskReminders)

import External.Notification as Notif exposing (Notification)
import Json.Encode as Encode
import Json.Encode.Extra as Encode
import List.Extra as List
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future, past)


type alias Intent =
    String


reminder : { scheduledFor : Moment, title : String, subtitle : String } -> Alarm
reminder { scheduledFor, title, subtitle } =
    { schedule = scheduledFor
    , actions =
        [ Notify <| Notif.basic title subtitle ]
    }


reminder3 : Moment -> String -> String -> Alarm
reminder3 scheduledFor title subtitle =
    { schedule = scheduledFor
    , actions =
        [ Notify <| Notif.basic title subtitle ]
    }


type alias NotificationAction =
    { label : String
    , action : Intent
    , icon : String
    }


type alias Alarm =
    { schedule : Moment
    , actions : List Action
    }


encodeAlarm : Alarm -> Encode.Value
encodeAlarm v =
    Encode.object
        [ ( "schedule", Encode.int <| Moment.toUnixTimeInt v.schedule )
        , ( "actions", Encode.list encodeAction v.actions )
        ]


type Action
    = Notify Notification
    | RunTaskerTask String String
    | SendIntent


encodeAction : Action -> Encode.Value
encodeAction v =
    case v of
        Notify notif ->
            Encode.object [ ( "notify", Notif.encodeNotification notif ) ]

        RunTaskerTask name param ->
            Encode.string "RunTaskerTask"

        SendIntent ->
            Encode.string "SendIntent"


scheduleOnTaskReminders : Moment -> Duration -> List Alarm
scheduleOnTaskReminders now fromNow =
    let
        fractionLeft denom =
            future now <| Duration.subtract fromNow (Duration.scale fromNow (1 / denom))
    in
    [ reminder3 (fractionLeft 2)
        "Half-way done!"
        "1/2 time left for activity."
    , reminder3 (fractionLeft 3)
        "Two-thirds done!"
        "1/3 time left for activity."
    , reminder3 (fractionLeft 4)
        "Three-Quarters done!"
        "1/4 time left for activity."
    , reminder3 (future now fromNow)
        "Time's up!"
        "Reached maximum time allowed for this."
    ]


scheduleOffTaskReminders : Moment -> List Alarm
scheduleOffTaskReminders now =
    [ reminder3 now
        "Get back on task now!"
        "Off task, not excused!"
    ]


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Alarm
scheduleExcusedReminders now excusedLimit timeLeft =
    let
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
            reminder
                { scheduledFor = beforeTimesUp amountLeft
                , title = "Finish up! Only " ++ write amountLeft ++ " left!"
                , subtitle = "Excused for up to " ++ write excusedLimit
                }

        write durLeft =
            abbreviatedSpaced <| breakdownHM durLeft

        interimReminders =
            [ reminder
                { scheduledFor = future now (dur (Minutes 10))
                , title = "Distraction taken care of?"
                , subtitle = "Get back on task as soon as possible - do this later!"
                }
            , reminder
                { scheduledFor = future now (dur (Minutes 20))
                , title = "Ready to get back on task?"
                , subtitle = "You have important goals to meet!"
                }
            , reminder
                { scheduledFor = future now (dur (Minutes 30))
                , title = "Can this wait?"
                , subtitle = "Why not put this in your task list for later?"
                }
            ]
    in
    if substantialTimeLeft then
        List.map buildGettingCloseReminder gettingCloseList

    else
        []
