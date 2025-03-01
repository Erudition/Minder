module Replicated.Codec.RegisterField.Initializer exposing (..)

import Replicated.Change as Change exposing (Change, ChangeSet(..), Changer, ComplexAtom(..), Context, ObjectChange, Parent(..), Pointer(..))


type alias RegisterFieldInitializer parentSeed remaining =
    parentSeed -> Change.Pointer -> remaining
