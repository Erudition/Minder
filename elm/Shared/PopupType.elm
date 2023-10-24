module Shared.PopupType exposing (..)

import Browser.Navigation exposing (..)
import Element exposing (..)
import Html exposing (Html)
import Json.Decode.Exploration exposing (..)
import List.Nonempty exposing (Nonempty(..))
import NativeScript.Commands exposing (..)
import SmartTime.Human.Duration exposing (HumanDuration(..))
import Task.Assignable exposing (Assignable)
import Task.Assignment exposing (Assignment)


type PopupType
    = AssignmentEditor (Maybe Assignment)
    | AssignableEditor (Maybe Assignable)
    | JustText (Html ())
