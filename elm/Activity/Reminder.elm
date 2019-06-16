module Activity.Reminder exposing (Alarm, Intent, NotificationAction, Reminder, scheduleExcusedReminders)

import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM)
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
scheduleExcusedReminders now maxExcused timeLeft =
    let
        halfLeft =
            Duration.scale maxExcused (1 / 2)

        thirdLeft =
            Duration.scale maxExcused (2 / 3)

        quarterLeft =
            Duration.scale maxExcused (3 / 4)

        fifthLeft =
            Duration.scale maxExcused (4 / 5)

        write durLeft =
            abbreviatedSpaced <| breakdownHM durLeft

        yetToPass reminder =
            Moment.compare reminder.scheduledFor now == GT
    in
    if not (Duration.isZero timeLeft) then
        List.filter yetToPass
            [ { scheduledFor = future now halfLeft
              , title = "Half Time!"
              , subtitle = write halfLeft ++ " left"
              , actions = []
              }
            , { scheduledFor = future now thirdLeft
              , title = "Excused for " ++ write thirdLeft ++ " more"
              , subtitle = "Only one third left"
              , actions = []
              }
            , { scheduledFor = future now quarterLeft
              , title = "Excused for " ++ write quarterLeft ++ " more"
              , subtitle = "Only one quarter left"
              , actions = []
              }
            , { scheduledFor = future now fifthLeft
              , title = "Excused for " ++ write fifthLeft ++ " more"
              , subtitle = "Only one fifth left"
              , actions = []
              }
            , { scheduledFor = future now (HumanDuration.toDuration (Minutes 5))
              , title = "Excused for " ++ write fifthLeft ++ " more"
              , subtitle = "Only one fifth left"
              , actions = []
              }
            ]

    else
        []
