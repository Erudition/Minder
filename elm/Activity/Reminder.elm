module Activity.Reminder exposing (Alarm, NotificationAction, Reminder)

import SmartTime.Duration as Duration exposing (..)
import SmartTime.HumanDuration as HumanDuration exposing (singleLetterSpaced)
import SmartTime.Moment as Moment exposing (Moment)


type alias Intent =
    String


type alias Reminder =
    { scheduledFor : Moment
    , title : String
    , subtitle : String
    , actions : List NotificationAction
    }


type alias RelativeReminder =
    { arrivesIn : Moment
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

Implementation note: It was tempting to use two Moments for this: now and expiresAt (the end time). But we can narrow our input even further: by passing in only a Duration, we actually still have all the information we need to work with to schedule all of the interim reminders - higher functions can translate that into actual times!

-}
scheduleExcusedReminders : Duration -> List RelativeReminder
scheduleExcusedReminders timeLeft =
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
            singleLetterSpaced <| breakdownHM durLeft
    in
    [ { arrivesIn = halfLeft
      , title = ""
      , subtitle = ""
      , actions = []
      }
    ]
