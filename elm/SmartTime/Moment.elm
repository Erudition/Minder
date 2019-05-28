module SmartTime.Moment exposing (moment)

import SmartTime.Duration exposing (..)
import Time



-- SHH, secretely we just use an Int under the hood, rather than an (Epoch, Duration) pair. But that's just for computational efficiency! We assume the same Epoch everywhere when storing these values, but our API does not need to know this.


type alias Moment =
    Moment Int



{- Create a Moment. A Moment is an `Epoch` and some `Duration` -- the amount of time since that Epoch -- which gives us a globally fixed point in time. You can shift this moment forward or backward by adding other `Duration` values to it.  -}


moment : Duration -> Epoch -> Moment
moment duration epoch =
    case epoch of
        UnixEpoch ->
            Moment (inMs duration)

        GPSEpoch ->
            -- TODO
            Moment (inMs duration)

        HumanEraStart ->
            -- TODO
            Moment (inMs duration)


type alias MsSinceUnixEpoch =
    Time.Posix


fromJsTime : Float -> Moment
fromJsTime elmTime =
    Milliseconds (Time.posixToMillis elmTime)


fromUnixTime : Int


type Epoch
    = UnixEpoch
    | GPSEpoch
    | HumanEraStart
