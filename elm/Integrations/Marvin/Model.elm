module Integrations.Marvin.Model exposing (..)

import Integrations.Marvin.MarvinItem exposing (..)


type alias MarvinModel =
    { tasks : Dict String MarvinItem
    , labels : Dict String MarvinLabel
    , timeBlocks : Dict String MarvinTimeBlock
    }
