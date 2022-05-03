module Replicated.Reducer.Register exposing (..)

import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Helpers
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Node.Node exposing (Node)
import Replicated.Node.NodeID exposing (NodeID)
import Replicated.Object as Object exposing (EventPayload, Object)
import Replicated.Op.Op as Op exposing (Change, Op, ReducerID)
import Replicated.Op.OpID as OpID exposing (OpID)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the Register Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type Register
    = Register
        { id : OpID.ObjectID
        , version : OpID.ObjectVersion
        , fields : Dict FieldSlot (List ( OpID, FieldPayload ))
        , included : Object.InclusionInfo
        }


type alias FieldPayload =
    JE.Value


reducerID : Op.ReducerID
reducerID =
    "lww"


getID (Register register) =
    register.id


getVersion (Register register) =
    register.version


empty : OpID.ObjectID -> Register
empty objectID =
    Register { id = objectID, included = Object.All, version = objectID, fields = Dict.empty }


build : Node -> Object -> Register
build node object =
    let
        fieldsDict =
            -- for some reason foldL puts older events first, so foldR for now. TODO more efficient to have the list already reversed?
            Dict.foldr addFieldEntry Dict.empty (Debug.log "\n\nobj events reg" object.events)

        addFieldEntry : OpID.OpIDString -> Object.KeptEvent -> Dict FieldSlot (List ( OpID, FieldPayload )) -> Dict FieldSlot (List ( OpID, FieldPayload ))
        addFieldEntry key (Object.KeptEvent { id, payload }) buildingDict =
            case extractFieldEventFromObjectPayload payload of
                Just ( ( fieldSlot, fieldName ), fieldPayload ) ->
                    Dict.update fieldSlot (addUpdate ( id, fieldPayload )) buildingDict

                Nothing ->
                    Log.logSeparate "warning - failed to extract field event" payload buildingDict

        addUpdate : ( OpID, FieldPayload ) -> Maybe (List ( OpID, FieldPayload )) -> Maybe (List ( OpID, FieldPayload ))
        addUpdate newUpdate existingUpdatesMaybe =
            Just (newUpdate :: Maybe.withDefault [] existingUpdatesMaybe)
    in
    Register { id = object.creation, version = object.lastSeen, included = Object.All, fields = Debug.log "final fields dict" fieldsDict }


extractFieldEventFromObjectPayload : EventPayload -> Maybe ( FieldIdentifier, FieldPayload )
extractFieldEventFromObjectPayload payload =
    case JD.decodeValue (JD.list JD.value) payload of
        Ok (fieldSlotValue :: fieldNameEncoded :: [ rest ]) ->
            case ( JD.decodeValue JD.int fieldSlotValue, JD.decodeValue JD.string fieldNameEncoded ) of
                ( Ok fieldSlot, Ok fieldName ) ->
                    Just ( ( fieldSlot, fieldName ), rest )

                _ ->
                    Nothing

        _ ->
            Nothing


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> Op.ChangePayload -> Op.ChangePayload
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    [ Op.ValueAtom (JE.int fieldSlot)
    , Op.ValueAtom (JE.string fieldName)
    ]
        ++ fieldPayload


merge : Nonempty Register -> Register
merge registers =
    let
        (Register firstDetails) =
            Nonempty.head registers

        highestVersion : OpID.ObjectVersion
        highestVersion =
            Nonempty.head (Nonempty.sortBy OpID.toString (Nonempty.map getVersion registers))

        minimumInclusion =
            -- TODO
            Object.All

        getFields (Register reg) =
            reg.fields
    in
    Register
        { id = firstDetails.id
        , version = highestVersion
        , fields = Nonempty.foldl1 Dict.union (Nonempty.map getFields registers)
        , included = minimumInclusion
        }


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int


getFieldLatestOnly : Register -> FieldIdentifier -> Maybe FieldPayload
getFieldLatestOnly (Register register) ( fieldSlot, _ ) =
    Dict.get fieldSlot (Debug.log "* running getFieldLatestOnly on field list" <| register.fields)
        |> Maybe.andThen List.head
        |> Maybe.map Tuple.second


getFieldHistory : Register -> FieldIdentifier -> List ( OpID, FieldPayload )
getFieldHistory (Register register) ( desiredFieldSlot, name ) =
    Debug.log ("getting field history for " ++ name) <|
        (Dict.get desiredFieldSlot register.fields
            |> Maybe.withDefault []
        )


getFieldHistoryValues : Register -> FieldIdentifier -> List FieldPayload
getFieldHistoryValues register field =
    List.map Tuple.second (getFieldHistory register field)


type alias RW fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    }


buildRW : Op.Pointer -> FieldIdentifier -> (fieldVal -> Op.ChangePayload) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder head =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = head
    , set = \new -> Op.Chunk { target = targetObject, objectChanges = [ Op.NewPayload (nestedChange new) ] }
    }


type alias RWH fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    , history : List ( OpID, fieldVal )
    }


buildRWH : Op.Pointer -> FieldIdentifier -> (fieldVal -> Op.ChangePayload) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder head rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = head
    , set = \new -> Op.Chunk { target = targetObject, objectChanges = [ Op.NewPayload (nestedChange new) ] }
    , history = rest
    }
