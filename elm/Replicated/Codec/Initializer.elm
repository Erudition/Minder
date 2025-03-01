module Replicated.Codec.Initializer exposing (Initializer, Inputs, Skel, flatInit)

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
