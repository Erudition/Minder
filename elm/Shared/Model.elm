module Shared.Model exposing (Model)

import Browser.Events
import Browser.Navigation exposing (..)
import Element exposing (..)
import Json.Decode.Exploration exposing (..)
import List.Nonempty exposing (Nonempty(..))
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import Profile exposing (Profile)
import Shared.PopupType exposing (PopupType(..))
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment exposing (Zone)
import SmartTime.Moment exposing (Moment)


{-| Our whole app's Model.
Intentionally minimal - we originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is due thursday", all stored in App "Database").
-}
type alias Model =
    { replica : Profile
    , viewportSize : { width : Int, height : Int }
    , viewportSizeClass : Element.DeviceClass
    , windowVisibility : Browser.Events.Visibility
    , darkThemeActive : Bool
    , time : Moment -- current time (effectively)

    --, navkey : Maybe Nav.Key -- not needed by elm-land
    , timeZone : Zone -- according to browser
    , launchTime : Moment -- when we officially started the session
    , notifPermission : Notif.PermissionStatus
    , modal : Maybe PopupType
    }
