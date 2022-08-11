module Replicated.Reducer.Register exposing (..)

import Bytes.Decode
import Bytes.Encode
import Console
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
type Register i userType
    = Register
        { pointer : Change.Pointer
        , fields : Dict FieldSlot FieldHistoryBackwards -- backwards history
        , included : Object.InclusionInfo
        , toRecord : Maybe Moment -> Register i userType -> userType
        , init : i
        }


type alias FieldPayload =
    Nonempty Op.OpPayloadAtom


type alias FieldHistoryBackwards =
    Nonempty ( OpID, FieldPayload )


reducerID : Op.ReducerID
reducerID =
    "lww"


getPointer : Register i userType -> Change.Pointer
getPointer (Register register) =
    register.pointer



-- empty : OpID.ObjectID -> Register userType
-- empty objectID =
--     Register { pointer = Change.ExistingObjectPointer objectID, included = Object.All, fields = Dict.empty }


build : Object -> (Maybe Moment -> Register i userType -> userType) -> i -> Register i userType
build object regToRecord initialInputs =
    let
        fieldsDict =
            -- object.events is a dict, so always ID order, so always oldest to newest.
            -- we want newest to oldest list, but folding reverses the list, so stick with foldL
            -- (warn: foldL/foldR applies the arguments in opposite order to the folding function)
            AnyDict.foldl addFieldEntry Dict.empty (Object.getEvents object)

        addFieldEntry : OpID -> Object.Event -> Dict FieldSlot FieldHistoryBackwards -> Dict FieldSlot FieldHistoryBackwards
        addFieldEntry eventID event buildingDict =
            case extractFieldEventFromObjectPayload (Object.eventPayload event) of
                Ok ( ( fieldSlot, fieldName ), fieldPayload ) ->
                    let
                        logMsg =
                            "Adding to " ++ Console.underline fieldName ++ " field history"
                    in
                    Dict.update fieldSlot (addUpdate ( eventID, fieldPayload )) buildingDict

                Err problem ->
                    Log.logSeparate ("WARNING " ++ problem) (Object.eventPayload event) buildingDict

        addUpdate : ( OpID, FieldPayload ) -> Maybe FieldHistoryBackwards -> Maybe FieldHistoryBackwards
        addUpdate newUpdate existingUpdatesMaybe =
            Just
                (Nonempty newUpdate
                    (Maybe.withDefault []
                        (Maybe.map Nonempty.toList existingUpdatesMaybe)
                    )
                )
    in
    Register { pointer = Object.getPointer object, included = Object.All, fields = fieldsDict, toRecord = regToRecord, init = initialInputs }


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


latest : Register i record -> record
latest ((Register registerDetails) as reg) =
    registerDetails.toRecord Nothing reg


getFieldLatestOnly : Register i userType -> FieldIdentifier -> Maybe FieldPayload
getFieldLatestOnly (Register register) ( fieldSlot, _ ) =
    Dict.get fieldSlot register.fields
        |> Maybe.map Nonempty.head
        |> Maybe.map Tuple.second


getFieldHistory : Register i userType -> FieldIdentifier -> List ( OpID, FieldPayload )
getFieldHistory (Register register) ( desiredFieldSlot, name ) =
    Dict.get desiredFieldSlot register.fields
        |> Maybe.map Nonempty.toList
        |> Maybe.withDefault []


getFieldHistoryValues : Register i userType -> FieldIdentifier -> List FieldPayload
getFieldHistoryValues register field =
    List.map Tuple.second (getFieldHistory register field)


type alias RW fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    }


buildRW : Change.Pointer -> FieldIdentifier -> (fieldVal -> List Change.Atom) -> fieldVal -> RW fieldVal
buildRW targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = latestValue
    , set = \new -> Change.Chunk { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange new) ] }
    }


type alias RWH fieldVal =
    { get : fieldVal
    , set : fieldVal -> Change
    , history : List ( OpID, fieldVal )
    }


buildRWH : Change.Pointer -> FieldIdentifier -> (fieldVal -> List Change.Atom) -> fieldVal -> List ( OpID, fieldVal ) -> RWH fieldVal
buildRWH targetObject ( fieldSlot, fieldName ) nestedRonEncoder latestValue rest =
    let
        nestedChange newValue =
            encodeFieldPayloadAsObjectPayload ( fieldSlot, fieldName ) (nestedRonEncoder newValue)
    in
    { get = latestValue
    , set = \new -> Change.Chunk { target = targetObject, objectChanges = [ Change.NewPayload (nestedChange new) ] }
    , history = rest
    }
