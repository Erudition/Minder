module Activity.Switching exposing (currentActivityFromApp, switchActivity, switchPopup)

import Activity.Activity exposing (..)
import Activity.Measure as Measure
import Activity.Reminder exposing (..)
import AppData exposing (..)
import Environment exposing (..)
import External.Commands as Commands
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.HumanDuration as HumanDuration exposing (..)
import Time
import Time.Extra as Time


switchActivity : ActivityId -> AppData -> Environment -> ( AppData, Cmd msg )
switchActivity activityId app env =
    let
        updatedApp =
            { app | timeline = Switch env.time activityId :: app.timeline }

        newActivity =
            getActivity (allActivities app.activities) activityId

        oldActivity =
            currentActivityFromApp app
    in
    ( updatedApp
    , Cmd.batch
        [ Commands.toast "In the command list that causes problems"
        , Commands.toast (switchPopup updatedApp.timeline newActivity oldActivity)
        , Commands.changeActivity (getName newActivity) (Measure.exportActivityUsage app env newActivity)
        , Commands.hideWindow

        -- , Commands.scheduleNotify (scheduleReminders env.time (timeLeft newActivity))
        ]
    )


switchPopup : Timeline -> Activity -> Activity -> String
switchPopup timeline new old =
    let
        timeSpentString dur =
            singleLetterSpaced (breakdownMS dur)

        timeSpent =
            Maybe.withDefault Duration.zero (List.head (Measure.sessions timeline old.id))

        total =
            Duration.inSecondsRounded <| Measure.total timeline old.id
    in
    timeSpentString timeSpent
        ++ getName old
        ++ " ("
        ++ String.fromInt total
        ++ " s)"
        ++ " ➤ "
        ++ getName new
        ++ "\n"


currentActivityFromApp : AppData -> Activity
currentActivityFromApp app =
    currentActivity (allActivities app.activities) app.timeline


scheduleReminders : Moment -> Duration -> List Reminder
scheduleReminders now fromNow =
    let
        limit =
            Duration.inMs fromNow

        future distance =
            Time.millisToPosix <| Time.posixToMillis now + distance

        fractionLeft denom =
            future <| limit - (limit // denom)
    in
    [ Reminder "Half-way done!"
        "1/2 time left for activity."
        (fractionLeft 2)
        []
    , Reminder "Two-thirds done!"
        "1/3 time left for activity."
        (fractionLeft 3)
        []
    , Reminder "Three-Quarters done!"
        "1/4 time left for activity."
        (fractionLeft 4)
        []
    , Reminder "Time's up!"
        "Reached maximum time allowed for this."
        (future limit)
        []
    ]
