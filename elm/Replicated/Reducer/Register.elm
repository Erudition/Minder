module Replicated.Reducer.Register exposing (..)

import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Helpers
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import Replicated.Node.Node exposing (Node)
import Replicated.Node.NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Change, Op, Payload, ReducerID)
import Replicated.Op.OpID as OpID exposing (OpID)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the Register Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type Register
    = Register
        { id : OpID.ObjectID
        , version : OpID.ObjectVersion
        , fields : Dict FieldSlot ( OpID, FieldPayload )
        , included : Object.InclusionInfo
        }


type alias FieldPayload =
    String


reducerID : Op.ReducerID
reducerID =
    "lww"


getID (Register register) =
    register.id


empty : OpID.ObjectID -> Register
empty objectID =
    Register { id = objectID, included = Object.All, version = objectID, fields = Dict.empty }


build : Node -> Object -> Register
build node object =
    let
        fieldsDict =
            Dict.foldl addFieldEntry Dict.empty object.events

        addFieldEntry : OpID.OpIDString -> Object.KeptEvent -> Dict FieldSlot ( OpID, FieldPayload ) -> Dict FieldSlot ( OpID, FieldPayload )
        addFieldEntry key (Object.KeptEvent { id, payload }) buildingDict =
            case extractFieldEventFromObjectPayload payload of
                Just ( ( fieldSlot, fieldName ), fieldPayload ) ->
                    Dict.insert fieldSlot ( id, fieldPayload ) buildingDict

                Nothing ->
                    buildingDict
    in
    Register { id = object.creation, version = object.lastSeen, included = Object.All, fields = fieldsDict }


extractFieldEventFromObjectPayload : Payload -> Maybe ( FieldIdentifier, FieldPayload )
extractFieldEventFromObjectPayload payload =
    case String.split "\t" payload of
        fieldSlotString :: fieldName :: rest ->
            case String.toInt fieldSlotString of
                Just fieldSlot ->
                    Just ( ( fieldSlot, fieldName ), String.concat rest )

                Nothing ->
                    Nothing

        _ ->
            Nothing


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> FieldPayload -> Payload
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    String.fromInt fieldSlot ++ "\t" ++ fieldName ++ "\t" ++ fieldPayload


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


changeField : Op.TargetObject -> FieldIdentifier -> (fieldVal -> String) -> fieldVal -> Change
changeField targetObject fieldIdentifier stringifier newValue =
    let
        newPayload =
            encodeFieldPayloadAsObjectPayload fieldIdentifier (stringifier newValue)
    in
    Op.Chunk { object = targetObject, objectChanges = [ Op.NewPayload newPayload ] }


buildRW : OpID.ObjectID -> FieldIdentifier -> (fieldVal -> String) -> fieldVal -> RW fieldVal
buildRW objectID fieldIdentifier stringifier head =
    { get = head
    , set = \new -> changeField (Op.ExistingObject objectID) fieldIdentifier stringifier new
    }


type alias RWH fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    , history : List ( OpID, fieldVal )
    }


buildRWH : OpID.ObjectID -> FieldIdentifier -> (fieldVal -> String) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH objectID fieldIdentifier stringifier head rest =
    { get = head
    , set = \new -> changeField (Op.ExistingObject objectID) fieldIdentifier stringifier new
    , history = rest
    }
