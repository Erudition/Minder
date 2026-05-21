module Replicated.Op.ReducerID exposing (..)


type ReducerID
    = RegisterReducer
    | RepListReducer
    | RepDictReducer
    | StoreReducer


type alias ReducerIDString =
    String


lwwTag : ReducerIDString
lwwTag =
    "lww"


repListTag : ReducerIDString
repListTag =
    "replist"


repDictTag : ReducerIDString
repDictTag =
    "repdict"


storeTag : ReducerIDString
storeTag =
    "store"


fromString : String -> Result String ReducerID
fromString input =
    if input == lwwTag then
        Ok RegisterReducer

    else if input == repListTag then
        Ok RepListReducer

    else if input == repDictTag then
        Ok RepDictReducer

    else if input == storeTag then
        Ok StoreReducer

    else
        Err input


toString : ReducerID -> String
toString idString =
    case idString of
        RegisterReducer ->
            lwwTag

        RepListReducer ->
            repListTag

        RepDictReducer ->
            repDictTag

        StoreReducer ->
            storeTag
