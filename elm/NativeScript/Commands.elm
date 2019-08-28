port module NativeScript.Commands exposing (notify)

import Json.Encode as Encode exposing (Value, string)
import NativeScript.Notification as Notification


notify : Notification.Notification -> Cmd msg
notify notification =
    ns_scheduleNotification (Notification.encode notification)


port ns_scheduleNotification : Encode.Value -> Cmd msg
