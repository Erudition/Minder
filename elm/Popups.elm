module Popups exposing (..)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as HK
import Html.Styled as SH exposing (Html, li, node, text, toUnstyled)
import Html.Styled.Attributes as SHA exposing (attribute, class, href, placeholder, property, type_)
import Html.Styled.Events as SHE exposing (on, onClick)
import Json.Decode as JD
import Json.Encode as JE
import Profile exposing (Profile)
import Task.AssignedAction as AssignedAction exposing (AssignedAction)


type Popup
    = ProjectEditor AssignedAction
