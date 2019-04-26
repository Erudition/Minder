port module External.Commands exposing (toast)

import External.Tasker exposing (..)
import Json.Encode exposing (Value)


toast message =
    flash message
