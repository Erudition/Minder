module Replicated.Reducer.Register exposing (..)

import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Helpers
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change)
import Replicated.Node.Node exposing (Node)
import Replicated.Node.NodeID exposing (NodeID)
import Replicated.Object as Object exposing (EventPayload, Object)
import Replicated.Op.Op as Op exposing (Op)
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
    Nonempty Op.OpPayloadAtom


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
            Dict.foldr addFieldEntry Dict.empty object.events

        addFieldEntry : OpID.OpIDString -> Object.KeptEvent -> Dict FieldSlot (List ( OpID, FieldPayload )) -> Dict FieldSlot (List ( OpID, FieldPayload ))
        addFieldEntry key (Object.KeptEvent { id, payload }) buildingDict =
            case extractFieldEventFromObjectPayload payload of
                Ok ( ( fieldSlot, fieldName ), fieldPayload ) ->
                    Dict.update fieldSlot (addUpdate ( id, fieldPayload )) buildingDict

                Err problem ->
                    Log.logSeparate ("WARNING " ++ problem) payload buildingDict

        addUpdate : ( OpID, FieldPayload ) -> Maybe (List ( OpID, FieldPayload )) -> Maybe (List ( OpID, FieldPayload ))
        addUpdate newUpdate existingUpdatesMaybe =
            Just (newUpdate :: Maybe.withDefault [] existingUpdatesMaybe)
    in
    Register { id = object.creation, version = object.lastSeen, included = Object.All, fields = fieldsDict }


extractFieldEventFromObjectPayload : EventPayload -> Result String ( FieldIdentifier, FieldPayload )
extractFieldEventFromObjectPayload payload =
    case payload of
        (Op.IntegerAtom fieldSlot) :: (Op.NakedStringAtom fieldName) :: rest ->
            case rest of
                [] ->
                    Err <| "Register: Missing payload for field " ++ fieldName

                head :: tail ->
                    Ok ( ( fieldSlot, fieldName ), Nonempty head tail )

        badList ->
            Err ("Register: Failed to extract field slot, field name, event payload from the given op payload because the value list is supposed to have 3+ elements and I found " ++ String.fromInt (List.length badList))


encodeFieldPayloadAsObjectPayload : FieldIdentifier -> List Change.Atom -> List Change.Atom
encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) fieldPayload =
    [ Change.RonAtom (Op.IntegerAtom fieldSlot)
    , Change.RonAtom (Op.NakedStringAtom fieldName)
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
    Dict.get fieldSlot register.fields
        |> Maybe.andThen List.head
        |> Maybe.map Tuple.second


getFieldHistory : Register -> FieldIdentifier -> List ( OpID, FieldPayload )
getFieldHistory (Register register) ( desiredFieldSlot, name ) =
    Dict.get desiredFieldSlot register.fields
        |> Maybe.withDefault []


getFieldHistoryValues : Register -> FieldIdentifier -> List FieldPayload
getFieldHistoryValues register field =
    List.map Tuple.second (getFieldHistory register field)


type alias RW fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    }


buildRW : Change.Pointer -> FieldIdentifier -> (fieldVal -> List Change.Atom) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder head =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = head
    , set = \new -> Change.Chunk { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange new) ] }
    }


type alias RWH fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    , history : List ( OpID, fieldVal )
    }


buildRWH : Change.Pointer -> FieldIdentifier -> (fieldVal -> List Change.Atom) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder head rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = head
    , set = \new -> Change.Chunk { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange new) ] }
    , history = rest
    }
