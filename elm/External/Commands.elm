port module External.Commands exposing (changeActivity, hideWindow, toast)

import External.Tasker exposing (..)
import Json.Encode exposing (Value, string)


toast message =
    flash message


changeActivity newName newTotal =
    Cmd.batch
        [ variableOut ( "selected", newName )
        ]


hideWindow =
    exit ()
