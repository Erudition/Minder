port module External.Tasker exposing (flash)

import Json.Encode exposing (Value)


port flash : Value -> Cmd msg
