port module External.Commands exposing (changeActivity, hideWindow, scheduleNotify, toast)

import Activity.Reminder exposing (..)
import External.Capacitor exposing (..)
import External.Tasker exposing (..)
import Json.Encode as Encode exposing (Value, string)
import SmartTime.Moment as Moment


scheduleNotify : List Reminder -> Cmd msg
scheduleNotify reminderList =
    variableOut ( "Scheduled", compileList (List.map taskerEncodeNotification reminderList) )


taskerEncodeNotification : Reminder -> String
taskerEncodeNotification reminder =
    String.concat <|
        List.intersperse ";" <|
            [ String.fromInt <| Moment.toUnixTimeInt reminder.scheduledFor
            , reminder.title
            , reminder.subtitle
            ]


compileList : List String -> String
compileList reminderList =
    String.concat <| List.intersperse "§" <| reminderList


encodeNotification : Reminder -> Encode.Value
encodeNotification v =
    let
        encodeNotificationButton button =
            Encode.object
                [ ( "label", Encode.string button.label )
                , ( "action", Encode.string button.action )
                , ( "icon", Encode.string button.icon )
                ]
    in
    Encode.object
        [ ( "title", Encode.string v.title )
        , ( "subtitle", Encode.string v.subtitle )
        , ( "scheduledFor", Encode.int (Moment.toSmartInt v.scheduledFor) )
        , ( "actions", Encode.list encodeNotificationButton v.actions )
        ]


toast : String -> Cmd msg
toast message =
    flash message


changeActivity newName newTotal newMax oldTotal =
    Cmd.batch
        [ variableOut ( "ExcusedTotalSec", newTotal )
        , variableOut ( "ExcusedMaxSec", newMax )
        , variableOut ( "ElmSelected", newName )
        , variableOut ( "PreviousSessionTotal", oldTotal )
        ]


hideWindow =
    exit ()
