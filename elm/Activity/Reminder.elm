module Activity.Reminder exposing (Alarm, Intent, NotificationAction, Reminder, scheduleExcusedReminders)

import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future)


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
    , action : Intent
    }


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Reminder
scheduleExcusedReminders now excusableLimit timeLeft =
    let
        halfLeft =
            Duration.scale timeLeft (1 / 2)

        thirdLeft =
            Duration.scale timeLeft (2 / 3)

        quarterLeft =
            Duration.scale timeLeft (3 / 4)

        fifthLeft =
            Duration.scale timeLeft (4 / 5)

        write durLeft =
            abbreviatedSpaced <| breakdownHM durLeft

        yetToPass reminder =
            -- Reminder is scheduled for later than now
            Moment.compare reminder.scheduledFor now == Moment.Later
    in
    if not (Duration.isZero timeLeft) then
        List.filter yetToPass
            [ { scheduledFor = future now halfLeft
              , title = write halfLeft ++ " left"
              , subtitle = "Ready for you to get back on task"
              , actions = []
              }
            , { scheduledFor = future now thirdLeft
              , title = "Excused for " ++ write thirdLeft ++ " more"
              , subtitle = "Save some excused time for when you really need it!"
              , actions = []
              }
            , { scheduledFor = future now quarterLeft
              , title = "Excused for " ++ write quarterLeft ++ " more"
              , subtitle = "Don't wait to get back on task"
              , actions = []
              }
            , { scheduledFor = future now fifthLeft
              , title = "Excused for " ++ write fifthLeft ++ " more"
              , subtitle = "Can you finish this later?"
              , actions = []
              }
            , { scheduledFor = future now (dur (Minutes 5))
              , title = "5 minutes left!"
              , subtitle = "Can you get back on task now?"
              , actions = []
              }
            , { scheduledFor = future now (dur (Minutes 1))
              , title = "1 minute left!"
              , subtitle = "Stop now. You can come back to this later."
              , actions = []
              }
            ]

    else
        []
