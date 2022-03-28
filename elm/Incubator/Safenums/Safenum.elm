module Incubator.Safenums.Safenum exposing (..)

{-| Type-safe Elm numbers with no runtime cost.
Prevents runtime errors and misbehavior caused by the core math functions.
All types are guaranteed to be finite (not `Infinity` or `-Infinity`)
and otherwise valid (not `NaN`).
-}


type Safenum number constraints
    = Safenum number


type alias NonNegative =
    { notNegative : () }


type alias Positive =
    { notNegative : ()
    , notZero : ()
    }


type alias Negative =
    { notPositive : ()
    , notZero : ()
    }


type alias Between1and0 =
    { oneOrLess : ()
    , notNegative : ()
    }


type alias Anynum number c =
    Safenum number c


type alias Posnum number =
    Safenum number Positive


type alias Negnum number =
    Safenum number Negative


type alias Nonegnum number =
    Safenum number NonNegative


type alias Portion number =
    Safenum number Between1and0



-- Mapping mirror types


{-| Turn any function of two `Posnum`s into a function of two `Negnum`s.
-}
mapNegative : (Posnum number -> Posnum number -> Posnum number) -> Negnum number -> Negnum number -> Negnum number
mapNegative posVersion (Safenum neg1) (Safenum neg2) =
    let
        (Safenum posResult) =
            posVersion (Safenum -neg1) (Safenum -neg2)
    in
    Safenum -posResult
