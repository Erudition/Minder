module Replicated.Reducer.Register exposing (..)

import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change)
import Replicated.Node.Node exposing (Node)
import Replicated.Node.NodeID exposing (NodeID)
import Replicated.Object as Object exposing (EventPayload, I, Object, Placeholder)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (OpID, OpIDSortable)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the Register Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type Register userType
    = Register
        { pointer : Change.Pointer
        , included : Object.InclusionInfo
        , toRecord : Maybe Moment -> userType
        }


getPointer : Register userType -> Change.Pointer
getPointer (Register register) =
    register.pointer


build : Object -> (Maybe Moment -> userType) -> Register userType
build object regToRecord =
    Register { pointer = Object.getPointer object, included = Object.All, toRecord = regToRecord }



-- merge : Nonempty (Register userType) -> Register userType
-- merge registers =
--     let
--         (Register firstDetails) =
--             Nonempty.head registers
--
--         highestVersion : OpID.ObjectVersion
--         highestVersion =
--             Nonempty.head (Nonempty.sortBy OpID.toString (Nonempty.map getVersion registers))
--
--         minimumInclusion =
--             -- TODO
--             Object.All
--
--         getFields (Register reg) =
--             reg.fields
--     in
--     Register
--         { pointer = firstDetails.pointer
--         , version = highestVersion
--         , fields = Nonempty.foldl1 Dict.union (Nonempty.map getFields registers)
--         , included = minimumInclusion
--         }


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int


latest : Register record -> record
latest ((Register registerDetails) as reg) =
    registerDetails.toRecord Nothing
