module Shared.Model exposing (..)

import Activity.HistorySession exposing (HistorySession(..))
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Element exposing (..)
import External.Commands exposing (..)
import Html exposing (Html)
import Json.Decode.Exploration exposing (..)
import List.Nonempty exposing (Nonempty(..))
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import Shared.PopupType exposing (PopupType(..))
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment exposing (Zone, utc)
import SmartTime.Moment exposing (Moment, zero)


{-| Our whole app's Model.
Intentionally minimal - we originally went with the common elm habit of stuffing any and all kinds of 'state' into the model, but we find it cleaner to separate the _"real" state_ (transient stuff, e.g. "dialog box is open", all stored in the page's URL (`viewState`)) from _"application data"_ (e.g. "task is due thursday", all stored in App "Database").
-}
type alias Shared =
    { viewportSize : { width : Int, height : Int }
    , viewportSizeClass : Element.DeviceClass
    , windowVisibility : Browser.Events.Visibility
    , darkThemeActive : Bool
    , time : Moment -- current time (effectively)
    , navkey : Maybe Nav.Key -- instance-specific (can't store it)
    , timeZone : Zone -- according to browser
    , launchTime : Moment -- when we officially started the session
    , notifPermission : Notif.PermissionStatus
    , modal : Maybe PopupType
    }


initialShared : Maybe Nav.Key -> Flags -> Shared
initialShared maybeKey flags =
    { time = zero -- temporary placeholder
    , navkey = maybeKey -- passed from init
    , timeZone = utc -- temporary placeholder
    , launchTime = zero -- temporary placeholder
    , notifPermission = Notif.Denied
    , viewportSize = { width = 0, height = 0 }
    , viewportSizeClass = Element.Phone
    , windowVisibility = Browser.Events.Visible
    , darkThemeActive = flags.darkTheme
    , modal = Nothing
    }


type alias Flags =
    { darkTheme : Bool }
