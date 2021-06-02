module Replicated.Reducer.Field exposing (..)

import List.Extra as List
import Replicated.Reducer.LWWObject exposing (FieldChange(..), FieldIdentifier, FieldValue, LWWObject)


justLatest : Int -> LWWObject -> Maybe FieldValue
justLatest slot (LWWObject lww) =
    let
        getValueOfMatches (FieldChange change) =
            if Tuple.first change.field == slot then
                Just change.changedTo

            else
                Nothing
    in
    List.findMap getValueOfMatches lww.changeHistory


type alias RW a =
    { get : a
    , set : a -> Change
    }


type alias RWH a =
    { get : a
    , set : a -> Change
    , history : FieldHistory
    }


type Change
    = Change FieldIdentifier FieldValue


type alias FieldHistory =
    ()
