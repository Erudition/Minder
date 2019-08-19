port module External.Commands exposing (hideWindow, scheduleNotify, toast)

import Activity.Reminder exposing (..)
import External.Capacitor exposing (..)
import External.Tasker exposing (..)
import Json.Encode as Encode exposing (Value, string)
import SmartTime.Moment as Moment


scheduleNotify : List Alarm -> Cmd msg
scheduleNotify alarmList =
    let
        orderedList =
            -- need to be in order, for tasker implementation
            List.sortWith compareReminders alarmList

        compareReminders a b =
            Moment.compareLateness a.schedule b.schedule

        alarmsObject =
            Encode.object [ ( "alarms", Encode.list encodeAlarm orderedList ) ]
    in
    variableOut ( "scheduled", Encode.encode 0 alarmsObject )


compileList : List String -> String
compileList reminderList =
    String.concat <| List.intersperse "§" <| reminderList


toast : String -> Cmd msg
toast message =
    flash message



--
-- changeActivity newName newTotal newMax oldTotal =
--     Cmd.batch
--         [ variableOut ( "OnTaskTotalSec", newTotal )
--         , variableOut ( "ExcusedTotalSec", newTotal )
--         , variableOut ( "ExcusedMaxSec", newMax )
--         , variableOut ( "ElmSelected", newName )
--         , variableOut ( "PreviousSessionTotal", oldTotal )
--         ]


hideWindow : Cmd msg
hideWindow =
    exit ()
