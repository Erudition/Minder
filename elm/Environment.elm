module Environment exposing (Environment, preInit)

-- "Environment"

import Browser.Navigation as Nav exposing (..)
import Dict
import NativeScript.Notification as Notif
import Replicated.Codec
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op exposing (Op)
import SmartTime.Human.Clock
import SmartTime.Human.Moment exposing (Zone, utc)
import SmartTime.Moment exposing (Moment, zero)


{-| Part three of our three-part Model: "environment".
Read-only; contains all the facts about our environment.

TODO FUTURE fields:

  - Platform
  - Browser (User Agent)
  - Geolocation

-}
type alias Environment =
    { time : Moment -- current time (effectively)
    , navkey : Maybe Nav.Key -- instance-specific (can't store it)
    , timeZone : Zone -- according to browser
    , launchTime : Moment -- when we officially started the session
    , notifPermission : Notif.PermissionStatus
    }


{-| Empty Environment before the init function fills in all the details.
-}
preInit : Maybe Nav.Key -> Environment
preInit maybeKey =
    { time = zero -- temporary placeholder
    , navkey = maybeKey -- passed from init
    , timeZone = utc -- temporary placeholder
    , launchTime = zero -- temporary placeholder
    , notifPermission = Notif.Denied
    }
