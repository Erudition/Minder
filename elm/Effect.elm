module Effect exposing (..)

import Popups exposing (Popup)


type Effect
    = OpenPopup Popup
    | NoOp
