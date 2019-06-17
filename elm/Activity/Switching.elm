module Activity.Switching exposing (currentActivityFromApp, sameActivity, switchActivity, switchPopup)

import Activity.Activity as Activity exposing (..)
import Activity.Measure as Measure
import Activity.Reminder exposing (..)
import AppData exposing (..)
import Environment exposing (..)
import External.Commands as Commands
import External.Tasker as Tasker
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment exposing (..)
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
        [ Commands.toast (switchPopup updatedApp.timeline env newActivity oldActivity)
        , Tasker.variableOut ( "ActivityTotalSec", Measure.exportExcusedUsageSeconds app env.time newActivity )
        , Tasker.variableOut ( "ActivityTotal", String.fromInt <| Duration.inMinutesRounded (Measure.excusedUsage app.timeline env.time newActivity) )
        , Tasker.variableOut ( "ElmSelected", getName newActivity )
        , Tasker.variableOut ( "PreviousActivityTotal", Measure.exportLastSession updatedApp oldActivity )
        , Commands.hideWindow
        , Commands.scheduleNotify <| scheduleExcusedReminders env.time (HumanDuration.toDuration <| Tuple.second <| Activity.excusableFor newActivity) (Measure.excusedLeft updatedApp.timeline env.time newActivity)
        ]
    )


sameActivity : ActivityId -> AppData -> Environment -> ( AppData, Cmd msg )
sameActivity activityId app env =
    let
        activity =
            currentActivityFromApp app
    in
    ( app
    , Cmd.batch
        [ Commands.toast (switchPopup app.timeline env activity activity)
        , Commands.changeActivity
            (getName activity)
            (Measure.exportExcusedUsageSeconds app env.time activity)
            (Measure.exportLastSession app activity)
        , Commands.hideWindow
        ]
    )


switchPopup : Timeline -> Environment -> Activity -> Activity -> String
switchPopup timeline env new old =
    let
        timeSpentString dur =
            singleLetterSpaced (breakdownMS dur)

        timeSpentLastSession =
            Maybe.withDefault Duration.zero (List.head (Measure.sessions timeline old.id))
    in
    timeSpentString timeSpentLastSession
        ++ " spent on "
        ++ getName old
        ++ "\n"
        ++ getName old
        ++ " ➤ "
        ++ getName new
        ++ "\n"
        ++ "Starting from "
        ++ timeSpentString (Measure.excusedUsage timeline env.time new)


currentActivityFromApp : AppData -> Activity
currentActivityFromApp app =
    currentActivity (allActivities app.activities) app.timeline


scheduleReminders : Moment -> Duration -> List Reminder
scheduleReminders now fromNow =
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
