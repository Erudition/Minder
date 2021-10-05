module Environment exposing (Environment, preInit)

-- "Environment"

import Browser.Navigation as Nav exposing (..)
import Dict
import Replicated.Node.Node as Node exposing (Node, blankNode)
import Replicated.Op.Op exposing (Op)
import Replicated.ReplicaCodec
import Replicated.Testing
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
    , node : ( Node, Result (Replicated.ReplicaCodec.Error String) Replicated.Testing.ExampleObject )
    }


{-| Empty Environment before the init function fills in all the details.
-}
preInit : Maybe Nav.Key -> Environment
preInit maybeKey =
    { time = zero -- temporary placeholder
    , navkey = maybeKey -- passed from init
    , timeZone = utc -- temporary placeholder
    , launchTime = zero -- temporary placeholder
    , node = ( Debug.log "here's the node" <| Replicated.Testing.fakeNodeWithModifications, Debug.log "here's the example object decoded!" <| Replicated.Testing.exampleObjectReDecoded Replicated.Testing.fakeNodeWithModifications )
    }
