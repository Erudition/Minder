module Incubator.IntDict.Extra exposing (filterKeys, filterMap, filterValues, mapValues)

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


{-| Apply a function that may or may not succeed to all entries in a dictionary,
but only keep the successes.
let
isTeen n a =
if 13 <= n && n <= 19 then
Just <| String.toUpper a
else
Nothing
in
Dict.fromList [ ( 5, "Jack" ), ( 15, "Jill" ), ( 20, "Jones" ) ]
|> filterMap isTeen
--> Dict.fromList [ ( 15, "JILL" ) ]
-}
filterMap : (Int -> a -> Maybe b) -> IntDict a -> IntDict b
filterMap f dict =
    IntDict.foldl
        (\k v acc ->
            case f k v of
                Just newVal ->
                    IntDict.insert k newVal acc

                Nothing ->
                    acc
        )
        IntDict.empty
        dict
