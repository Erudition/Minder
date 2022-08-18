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



-- type alias Register =
--     Codec.Register
-- getPointer : Register userType -> Change.Pointer
-- getPointer (Register register) =
--     register.pointer


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int



--
-- latest : Register record -> record
-- latest ((Register registerDetails) as reg) =
--     registerDetails.toRecord Nothing
