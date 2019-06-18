module IntDictExtra exposing (filterKeys, filterValues, mapValues)

import IntDict exposing (IntDict)


mapValues : (a -> b) -> IntDict a -> IntDict b
mapValues func dict =
    IntDict.map (\_ v -> func v) dict


filterValues : (v -> Bool) -> IntDict v -> IntDict v
filterValues func dict =
    IntDict.filter (\_ v -> func v) dict


filterKeys : (Int -> Bool) -> IntDict v -> IntDict v
filterKeys func dict =
    IntDict.filter (\k _ -> func k) dict
