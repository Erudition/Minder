module Environment exposing (Environment)

-- "Environment"

import Browser.Navigation as Nav exposing (..)
import Time


{-| Part three of our three-part Model: "environment".
Read-only; contains all the facts about our environment.

TODO FUTURE fields:

  - Platform
  - Browser (User Agent)
  - Geolocation

-}
type alias Environment =
    { time : Time.Posix -- current time (effectively)
    , navkey : Nav.Key -- instance-specific (can't store it)
    , timeZone : Time.Zone -- according to browser
    }
