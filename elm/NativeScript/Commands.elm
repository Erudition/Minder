port module NativeScript.Commands exposing (notify)

import Json.Encode as Encode exposing (Value, string)
import NativeScript.Notification as Notification


notify : List Notification.Notification -> Cmd msg
notify notification =
    ns_notify (Encode.list Notification.encode notification)


port ns_notify : Encode.Value -> Cmd msg
