module Incubator.Safenums.Nonegnum exposing (..)

import Incubator.Safenums.Safenum exposing (..)



-- Others to Nonegnum GUARANTEED


takePortion : Portion number -> Nonegnum number -> Nonegnum number
takePortion (Safenum por) (Safenum nonegnum) =
    Safenum (nonegnum * por)
