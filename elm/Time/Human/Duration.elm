module Time.Human.Duration exposing (Duration(..))

import Time exposing (..)
import Time.Duration exposing (..)
import Time.Extra exposing (..)



-- some duration = sum [Hours 5, Minutes 47, ]


type HumanFixedUnits
    = Days Int -- only fixed amount if using TAI
    | Hours Int
    | Minutes Int
    | Seconds Int
    | Milliseconds Int


add : Duration -> Duration -> Duration


sum : List WholeUnits -> Duration



-- fromHumanDuration = sum


addWholeDays : Int


breakdownHMS : Duration -> ( Maybe Int, Maybe Int, Maybe Int )


breakdownHM : Duration -> ( Maybe Int, Maybe Int, Maybe Int )


type Epoch
    = Unix
    | ModernUTC


type TimeScale
    = Unix
    | TAI
