module Replicated.Codec.Initializer exposing (Initializer, Inputs, Skel, flatInit, mapFlat, mapOutput)

import Replicated.Change as Change exposing (Change, ChangeSet(..), Changer, ComplexAtom(..), Context, ObjectChange, Parent(..), Pointer(..))
import Replicated.Change.Location as Location exposing (Location)


{-| The type of function that produces a placeholder object. It may require a seed value.
-}
type alias Initializer seed thing =
    Inputs seed -> thing


{-| The inputs to a placeholder generator function.
-}
type alias Inputs seed =
    { parent : Change.Parent
    , position : Location
    , seed : seed
    }


type alias Skel =
    () -> List Change


flatInit : Initializer a a
flatInit { seed } =
    seed


{-| Change the type of an Initializer's input and output types when they are the same.
-}
mapFlat : (a -> b) -> (b -> a) -> Initializer a a -> Initializer b b
mapFlat fromAtoB fromBtoA initializerA =
    let
        runA : Inputs b -> a
        runA { parent, position, seed } =
            initializerA (Inputs parent position (fromBtoA seed))
    in
    \inputsB -> fromAtoB (runA inputsB)


{-| Change the type of an Initializer's output type, leaving the seed type the same.
-}
mapOutput : (a -> b) -> Initializer i a -> Initializer i b
mapOutput fromAtoB initializerA =
    let
        runA : Inputs i -> a
        runA { parent, position, seed } =
            initializerA (Inputs parent position seed)
    in
    \inputsB -> fromAtoB (runA inputsB)
