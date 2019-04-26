port module TaskerShim exposing (flash)

import Json.Encode exposing (Value)


port flash : Value -> Cmd msg
