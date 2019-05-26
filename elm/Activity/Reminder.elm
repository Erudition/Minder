module Activity.Reminder exposing (Alarm, NotificationAction, Reminder)

import Time


type alias Moment =
    Time.Posix


type alias Intent =
    String


type alias Reminder =
    { title : String
    , subtitle : String
    , schedule : Moment
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
