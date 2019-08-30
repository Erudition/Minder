module Activity.Reminder exposing (scheduleExcusedReminders, scheduleOffTaskReminders, scheduleOnTaskReminders)

import Json.Encode as Encode
import Json.Encode.Extra as Encode
import List.Extra as List
import List.Nonempty as Nonempty
import NativeScript.Notification as Notif exposing (Notification)
import Random
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration(..), abbreviatedSpaced, breakdownHM, dur)
import SmartTime.Moment as Moment exposing (Moment, future, past)


reminderBase : Notification
reminderBase =
    let
        blank =
            Notif.blank "Override me!"
    in
    { blank | timeout = Just (Duration.fromMinutes 1) }


scheduleOnTaskReminders : Moment -> Duration -> List Notification
scheduleOnTaskReminders now timeLeft =
    let
        fractionLeft denom =
            future now <| Duration.subtract timeLeft (Duration.scale timeLeft (1 / denom))
    in
    [ { reminderBase
        | at = Just <| fractionLeft 2
        , title = Just "Half-way done!"
        , subtitle = Just "1/2 time left for activity."
      }
    , { reminderBase
        | at = Just <| fractionLeft 3
        , title = Just "Two-thirds done!"
        , subtitle = Just "1/3 time left for activity."
      }
    , { reminderBase
        | at = Just <| fractionLeft 4
        , title = Just "Three-quarters done!"
        , subtitle = Just "1/4 time left for activity."
      }
    , { reminderBase
        | at = Just <| future now timeLeft
        , title = Just "Three-quarters done!"
        , subtitle = Just "1/4 time left for activity."
      }
    ]


scheduleOffTaskReminders : Moment -> List Notification
scheduleOffTaskReminders now =
    let
        base =
            { reminderBase
                | id = Just 1
                , channel = "Off Task Warnings"
                , actions = actions
            }

        actions =
            [ { id = "SnoozeButton", button = Notif.Button "Snooze", launch = False }
            , { id = "LaunchButton", button = Notif.Button "Go", launch = True }
            , { id = "ZapButton", button = Notif.Button "Zap", launch = False }
            ]
    in
    [ { base
        | at = Just <| now
        , subtitle = Just "Off Task!"
        , title = Just "You can do this later"
      }
    , { base
        | at = Just <| future now (Duration.fromSeconds 30.0)
        , subtitle = Just "Off Task! Second Warning"
        , title = Just "You have more important things to do right now!"
      }
    , { base
        | at = Just <| future now (Duration.fromSeconds 60.0)
        , subtitle = Just "Off Task! Third Warning"
        , title = Just "You have more important things to do right now!"
      }
    , { base
        | at = Just <| future now (Duration.fromSeconds 90.0)
        , subtitle = Just "Off Task!"
        , title = Just "You have more important things to do right now!"
        , interval = Just Notif.Minute
      }
    ]


{-| Calculate the interim reminders before the activity expires from being excused.
-}
scheduleExcusedReminders : Moment -> Duration -> Duration -> List Notification
scheduleExcusedReminders now excusedLimit timeLeft =
    let
        base =
            { reminderBase
                | id = Just 7
                , channel = "Excused Reminders"
                , actions = actions
            }

        actions =
            [ { id = "Done", button = Notif.Button "OK I'm Ready", launch = False }
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
                [ dur (Minutes 1)
                , dur (Minutes 2)
                , dur (Minutes 3)
                , dur (Minutes 5)
                , dur (Minutes 10)
                , dur (Minutes 30)
                ]

        buildGettingCloseReminder amountLeft =
            { reminderBase
                | at = Just <| beforeTimesUp amountLeft
                , title = Just <| "Finish up! Only " ++ write amountLeft ++ " left!"
                , subtitle = Just <| "Excused for up to " ++ write excusedLimit
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

        pickEncouragementMessage time =
            Tuple.first <| Random.step encouragementMessages (Moment.useAsRandomSeed time)

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
