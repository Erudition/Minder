module Replicated.Reducer.Field exposing (..)


type alias RW a =
    { get : a
    , set : a -> Change
    }


type alias RWH a =
    { get : a
    , set : a -> Change
    , history : FieldHistory
    }


type alias Change =
    ()


type alias FieldHistory =
    ()
