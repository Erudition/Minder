module Incubator.Safenums.Posnum exposing (..)

import Incubator.Safenums.Safenum exposing (..)



-- Strictly functions that produce posnums!
-- BASIC GUARANTEED


posnum : number -> Posnum number
posnum num =
    Safenum (abs num)


add : Posnum number -> Posnum number -> Posnum number
add (Safenum pos1) (Safenum pos2) =
    Safenum (pos1 + pos2)


multiply : Posnum number -> Posnum number -> Posnum number
multiply (Safenum pos1) (Safenum pos2) =
    Safenum (pos1 * pos2)


difference : Posnum number -> Posnum number -> Posnum number
difference (Safenum pos1) (Safenum pos2) =
    Safenum (abs (pos1 - pos2))



-- OTHER GUARANTEED
-- NOT GUARANTEED


trySubtract : Safenum number any -> Safenum number any -> Maybe (Posnum number)
trySubtract (Safenum pos1) (Safenum pos2) =
    let
        result =
            pos1 - pos2
    in
    case result > 0 of
        True ->
            Just (Safenum result)

        False ->
            Nothing
