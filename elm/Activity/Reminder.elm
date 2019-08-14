module Activity.Reminder exposing (Alarm, Intent, NotificationAction, Reminder, scheduleExcusedReminders, scheduleOffTaskReminders, scheduleOnTaskReminders)

import List.Extra as List
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future, past)


type alias Intent =
    String


type alias Reminder =
    { scheduledFor : Moment
    , title : String
    , subtitle : String
    , actions : List NotificationAction
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


type Action
    = Notify Notification
    | RunTaskerTask
    | SendIntent


type alias Notification =
    { id : String -- 1
    , persistent : Bool -- 2
    , timeout : Duration -- 3
    , update : UpdateStrategy -- 4: not supported in autonotification variables
    , priority : Priority -- 5
    , privacy : Privacy -- 6: not supported in autonotification variables
    , useHTML : Bool -- 7: not supported in autonotification variables
    , title : String -- 8
    , titleExpanded : String -- 9
    , body : String -- 10 ("text")
    , bodyExpanded : String -- 11 ("text expanded")
    , subtext : String -- 12
    , detail : Detail -- 13 & 14: need to be Int?
    , ticker : String -- 15
    , icon : String -- 16
    , statusIcon : String -- 17
    , statusTextSize : Int -- 18 (in sp)
    , backgroundColor : String -- 19
    , colorFromMedia : Bool -- 20: not supported in autonotification variables
    , badge : BadgeType -- 21:  not supported in autonotification variables
    , picture : String -- 22
    , pictureCacheAllowed : Bool -- 23  not supported in autonotification variables
    , pictureExpandedIcon : String -- 24
    , mediaLayout : Bool -- 25 not supported in autonotification variables
    , media : Maybe MediaInfo -- 26
    , url : String --29
    , time : Maybe Moment
    , chronometer : Bool
    , countdown : Bool
    }


type Priority
    = Default
    | Low
    | High
    | Min
    | Max


type Privacy
    = Public
    | Private
    | PrivateWithPublicVersion Notification
    | Secret


type UpdateStrategy
    = New
    | Replace
    | Append


type Detail
    = Number Int
    | Info String


type BadgeType
    = NoBadge
    | SmallIcon
    | LargeIcon


type alias MediaInfo =
    { title : String
    }


type alias Events msg =
    { onCreate : Maybe msg --27
    , onTouch : Maybe msg --28
    , onDismiss : Maybe msg --30
    }


scheduleOnTaskReminders : Moment -> Duration -> List Reminder
scheduleOnTaskReminders now fromNow =
    let
        fractionLeft denom =
            future now <| Duration.subtract fromNow (Duration.scale fromNow (1 / denom))
    in
    [ Reminder (fractionLeft 2)
        "Half-way done!"
        "1/2 time left for activity."
        []
    , Reminder (fractionLeft 3)
        "Two-thirds done!"
        "1/3 time left for activity."
        []
    , Reminder (fractionLeft 4)
        "Three-Quarters done!"
        "1/4 time left for activity."
        []
    , Reminder (future now fromNow)
        "Time's up!"
        "Reached maximum time allowed for this."
        []
    ]


scheduleOffTaskReminders : Moment -> List Reminder
scheduleOffTaskReminders now =
    [ Reminder now
        "Get back on task now!"
        "Off task, not excused!"
        []
    ]


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Reminder
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
            { scheduledFor = beforeTimesUp amountLeft
            , title = "Finish up! Only " ++ write amountLeft ++ " left!"
            , subtitle = "Excused for up to " ++ write excusedLimit
            , actions = []
            }

        write durLeft =
            abbreviatedSpaced <| breakdownHM durLeft

        interimReminders =
            [ { scheduledFor = future now (dur (Minutes 10))
              , title = "Distraction taken care of?"
              , subtitle = "Get back on task as soon as possible - do this later!"
              }
            , { scheduledFor = future now (dur (Minutes 20))
              , title = "Ready to get back on task?"
              , subtitle = "You have important goals to meet!"
              }
            , { scheduledFor = future now (dur (Minutes 30))
              , title = "Can this wait?"
              , subtitle = "Why not put this in your task list for later?"
              }
            ]
    in
    if substantialTimeLeft then
        List.map buildGettingCloseReminder gettingCloseList

    else
        []
