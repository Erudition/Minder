module Environment exposing (Environment, preInit)

-- "Environment"

import Browser.Navigation as Nav exposing (..)
import SmartTime.Moment exposing (Moment, Zone, utc, zero)


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
    }


{-| Empty Environment before the init function fills in all the details.
-}
preInit : Maybe Nav.Key -> Environment
preInit maybeKey =
    { time = zero -- temporary placeholder
    , navkey = maybeKey -- passed from init
    , timeZone = utc -- temporary placeholder
    }
