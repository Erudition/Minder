module Activity.Switching exposing (currentActivityFromApp, switchActivity, switchPopup)

import Activity.Activity exposing (..)
import Activity.Measure as Measure
import AppData exposing (..)
import Environment exposing (..)
import External.Commands as Commands


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
        [ Commands.toast (switchPopup updatedApp.timeline newActivity oldActivity)
        , Commands.changeActivity (getName newActivity)
            (Measure.exportActivityUsage app env newActivity)
        , Commands.hideWindow
        ]
    )


switchPopup : Timeline -> Activity -> Activity -> String
switchPopup timeline new old =
    let
        timeSpentString num =
            String.fromInt num
                ++ "s "

        timeSpent =
            Maybe.map (\n -> n // 1000) (List.head (Measure.sessions timeline old.id))

        total =
            Measure.total timeline old.id // 1000
    in
    Maybe.withDefault "" (Maybe.map timeSpentString timeSpent)
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
