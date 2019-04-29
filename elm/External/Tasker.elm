port module External.Tasker exposing (exit, flash, variableOut)

import Json.Encode exposing (Value)


port flash : Value -> Cmd msg


port exit : () -> Cmd msg


port variableOut : ( String, Value ) -> Cmd msg
