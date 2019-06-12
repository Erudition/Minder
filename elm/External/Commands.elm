port module External.Commands exposing (changeActivity, hideWindow, toast)

import Activity.Reminder exposing (..)
import External.Capacitor exposing (..)
import External.Tasker exposing (..)
import Json.Encode as Encode exposing (Value, string)
import SmartTime.Moment as Moment


scheduleNotify : List Reminder -> Cmd msg
scheduleNotify reminderList =
    notificationsOut (Encode.list encodeNotification reminderList)


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


changeActivity newName newTotal oldTotal =
    Cmd.batch
        [ variableOut ( "ActivityTotalSec", newTotal )
        , variableOut ( "ElmSelected", newName )
        , variableOut ( "PreviousActivityTotal", oldTotal )
        ]


hideWindow =
    exit ()
