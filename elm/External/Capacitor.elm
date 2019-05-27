port module External.Capacitor exposing (notificationsOut)

import Json.Encode as Encode


port notificationsOut : Encode.Value -> Cmd msg
