module Activity.Reminder exposing (Alarm, Intent, NotificationAction, Reminder, scheduleExcusedReminders)

import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (abbreviatedSpaced, breakdownHM)
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
scheduleExcusedReminders : Moment -> Duration -> List Reminder
scheduleExcusedReminders now timeLeft =
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
    in
    [ { scheduledFor = future now halfLeft
      , title = "Half Time!"
      , subtitle = write halfLeft ++ " left"
      , actions = []
      }
    , { scheduledFor = future now thirdLeft
      , title = "Excused for " ++ write (difference timeLeft thirdLeft) ++ " more"
      , subtitle = "Only one third left"
      , actions = []
      }
    , { scheduledFor = future now quarterLeft
      , title = "Excused for " ++ write (difference timeLeft quarterLeft) ++ " more"
      , subtitle = "Only one quarter left"
      , actions = []
      }
    , { scheduledFor = future now fifthLeft
      , title = "Excused for " ++ write (difference timeLeft fifthLeft) ++ " more"
      , subtitle = "Only one fifth left"
      , actions = []
      }
    ]
