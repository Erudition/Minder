module Care exposing (..)

import List.Nonempty exposing (Nonempty)
import Replicated.Reducer.RepStore exposing (RepStore)


type Care
    = Self Self-- strictly the user alone, mind and body
    | Person Person-- Humans only
    | Creature Creature -- Pets, plants, other organisms
    | Place Place -- physical, only stationary places, not e.g. vehicle interiors
    | Object Object -- physical, includes enclosures and containers of other objects
    | Collection Collection -- physical, a swarm of related physical objects
    | Responsibility Responsibility -- duties/obligations/commitments not covered by other cares


type Self = Self

type Person
    = Person


type Creature
    = Creature


type Place
    = Place


type Object
    = Object


type Collection
    = Collection


type Responsibility
    = Responsibility


type alias Cares =
    RepStore


type alias Need =
    { title : String
    , tracked : Bool
    }


type alias Project =
    { caresFor : Nonempty Need
    , title : String
    }
