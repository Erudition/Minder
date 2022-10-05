module Integrations.Marvin.Model exposing (..)

import Integrations.Marvin.MarvinItem exposing (..)
import Dict exposing (Dict)


type alias MarvinModel =
    { tasks : Dict String MarvinItem
    , labels : Dict String MarvinLabel
    , timeBlocks : Dict String MarvinTimeBlock
    }
