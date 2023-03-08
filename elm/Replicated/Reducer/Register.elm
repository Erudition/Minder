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
import Replicated.Change as Change exposing (Change, Changer)
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Node.Node exposing (Node)
import Replicated.Node.NodeID exposing (NodeID)
import Replicated.Object as Object
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (OpID, OpIDSortable)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the Register Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type Reg userType
    = Register
        { pointer : Change.Pointer
        , included : Object.InclusionInfo
        , latest : userType

        -- since toRecord with Moment parameter meant late re-evaluation of entire decoder
        , older : Moment -> userType
        , history : FieldHistoryDict
        , init : Changer (Reg userType)
        }


type alias FieldPayload =
    Nonempty Op.OpPayloadAtom


type alias FieldHistoryBackwards =
    Nonempty ( OpID, FieldPayload )


type alias FieldHistoryDict =
    Dict FieldSlot FieldHistoryBackwards


getPointer : Reg userType -> Change.Pointer
getPointer (Register register) =
    register.pointer


getContext : Reg userType -> Change.Context
getContext (Register register) =
    -- TODO this function is a hack, no?
    Change.Context (Location.newSingle "RegLateFieldInit") (Change.becomeInstantParent register.pointer)


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias RW fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    }


type alias RWH fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    , history : List ( OpID, fieldVal )
    }


registerReducerID : Op.ReducerID
registerReducerID =
    "lww"


latest : Reg record -> record
latest (Register registerDetails) =
    registerDetails.latest


asOf : Moment -> Reg record -> record
asOf cutoff (Register registerDetails) =
    registerDetails.older cutoff
