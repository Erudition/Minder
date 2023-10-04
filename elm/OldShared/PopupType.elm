module OldShared.PopupType exposing (..)

import Activity.HistorySession exposing (HistorySession)
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Element exposing (..)
import External.Commands exposing (..)
import Html exposing (Html)
import Json.Decode.Exploration exposing (..)
import List.Nonempty exposing (Nonempty(..))
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment exposing (Zone, utc)
import SmartTime.Moment exposing (Moment, zero)
import Task.Assignable as Assignable exposing (Assignable)
import Task.Assignment as Assignment exposing (Assignment)


type PopupType
    = AssignmentEditor (Maybe Assignment)
    | AssignableEditor (Maybe Assignable)
    | JustText (Html ())
