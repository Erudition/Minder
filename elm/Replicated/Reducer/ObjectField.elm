module Replicated.ObjectField exposing (..)

import Dict exposing (Dict)
import Replicated.Atom exposing (..)
import Replicated.Identifier exposing (..)
import Replicated.Op exposing (..)


type Field atom
    = Field String (Dict String atom)


type alias ExampleObject =
    { person : Field Int
    , name : Field String
    }


set : ObjectID -> Field a -> a -> Op
set unknown (Field fieldName dict) newValue =
    Dict.insert "newKey" newValue dict
