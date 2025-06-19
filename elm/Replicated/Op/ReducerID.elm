module Replicated.Op.ReducerID exposing (..)


lwwTag =
    "lww"


repListTag =
    "replist"


type ReducerID
    = LWWReducer
    | RepListReducer


fromString : String -> Result String ReducerID
fromString input =
    if input == lwwTag then
        Ok LWWReducer

    else if input == repListTag then
        Ok RepListReducer

    else
        Err input


toString : ReducerID -> String
toString idString =
    case idString of
        LWWReducer ->
            lwwTag

        RepListReducer ->
            repListTag
