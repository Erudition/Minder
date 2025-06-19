module Replicated.Op.ReducerID exposing (..)


type ReducerID
    = LWWReducer
    | RepListReducer


type alias ReducerIDString =
    String


lwwTag : ReducerIDString
lwwTag =
    "lww"


repListTag : ReducerIDString
repListTag =
    "replist"


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
