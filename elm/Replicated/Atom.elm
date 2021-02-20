module Replicated.Atom exposing (..)

import Replicated.Identifier exposing (..)


type Atom
    = IDAtom RonUUID
    | IntAtom Int
    | FloatAtom Float
    | StringAtom String
