port module External.Commands exposing (toast)

import External.Tasker exposing (..)
import Json.Encode exposing (Value, string)


toast message =
    flash message


changeActivity newActivity =
    variableOut ( "Timetrack", string newActivity )
