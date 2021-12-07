module Log exposing (..)

import Debug


logMessage label _ =
    Debug.log label ()
