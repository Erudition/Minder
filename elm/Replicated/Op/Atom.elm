module Replicated.Op.Atom exposing (..)

import Json.Encode as JE
import Replicated.Op.ID as OpID exposing (OpID)


type Atom
    = NakedStringAtom String
    | StringAtom String
    | IDPointerAtom OpID
    | OtherUUIDAtom String
    | IntegerAtom Int
    | FloatAtom Float


toJsonValue : Atom -> JE.Value
toJsonValue atom =
    case atom of
        NakedStringAtom string ->
            JE.string string

        StringAtom string ->
            JE.string string

        IDPointerAtom opID ->
            JE.string (OpID.toRonPointerString opID)

        OtherUUIDAtom uuid ->
            JE.string uuid

        IntegerAtom int ->
            JE.int int

        FloatAtom float ->
            JE.float float


{-| Convert an atom into the raw string to be put in a RON Op.
TODO : generate naked atoms when unambiguous.
-}
toRonString : Atom -> String
toRonString atom =
    case atom of
        NakedStringAtom string ->
            string

        StringAtom string ->
            let
                ronSafeString =
                    String.replace "'" "\\'" string
            in
            "'" ++ ronSafeString ++ "'"

        OtherUUIDAtom string ->
            string

        IDPointerAtom opID ->
            OpID.toRonPointerString opID

        IntegerAtom int ->
            String.fromInt int

        FloatAtom float ->
            String.fromFloat float


fromJsonValue : JE.Value -> Atom
fromJsonValue valueJE =
    -- --                atomToValue inputString =
    --                     case JD.decodeString JD.value ("\"" ++ inputString ++ "\"") of
    --                         Ok val ->
    --                             val
    --
    --                         Err err ->
    --                             Debug.todo <| "couldn't convert atom (" ++ inputString ++ ") to JD.Value - " ++ Debug.toString err
    StringAtom (JE.encode 0 valueJE)
