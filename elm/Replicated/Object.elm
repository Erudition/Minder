module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Json.Encode as JE
import Replicated.Op.Op as Op exposing (Op, OpPayloadAtoms)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| The most generic "object", to be inherited by other replicated data types for specific functionality.
-}
type alias Object =
    { reducer : Op.ReducerID
    , creation : ObjectID
    , events : Dict OpIDString KeptEvent
    , included : InclusionInfo
    , lastSeen : OpID
    }


getID : Object -> ObjectID
getID object =
    object.creation


getReducer : Object -> Op.ReducerID
getReducer object =
    object.reducer


{-| We assume creation op IDs were checked already, this is just post-init events
-}
allOtherOpIDs : Object -> List OpID
allOtherOpIDs object =
    -- TODO for performance, should we keep this list in memory?
    -- TODO what about non-kept events?
    List.map eventID (Dict.values object.events)


type alias EventPayload =
    Op.OpPayloadAtoms


{-| An event that has not been undone/deleted.
-}
type
    KeptEvent
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = KeptEvent { id : OpID, reference : OpID, payload : EventPayload }


eventReference : KeptEvent -> OpID
eventReference (KeptEvent event) =
    event.reference


eventID : KeptEvent -> OpID
eventID (KeptEvent event) =
    event.id


eventPayload : KeptEvent -> EventPayload
eventPayload (KeptEvent event) =
    event.payload


eventPayloadAsJson : KeptEvent -> JE.Value
eventPayloadAsJson (KeptEvent event) =
    case List.map Op.atomToJsonValue event.payload of
        [] ->
            JE.null

        [ single ] ->
            single

        multiple ->
            JE.list identity multiple


{-| Apply an incoming Op to an object if we have it.
Ops must have a reference.
-}
applyOp : Op -> Maybe Object -> Maybe Object
applyOp newOp oldObjectMaybe =
    let
        opPayloadToEventPayload opPayload =
            case opPayload of
                [ singleAtom ] ->
                    Op.atomToJsonValue singleAtom

                multipleAtoms ->
                    JE.list Op.atomToJsonValue multipleAtoms

        newEvent givenRef =
            KeptEvent { id = Op.id newOp, reference = givenRef, payload = Op.payload newOp }
    in
    case ( oldObjectMaybe, Op.reference newOp ) of
        ( Just oldObject, Op.OpReference ref ) ->
            Just
                { reducer = oldObject.reducer
                , creation = oldObject.creation
                , events =
                    if Op.pattern newOp == Op.DeletionOp then
                        Dict.remove (OpID.toString ref) oldObject.events

                    else
                        Dict.insert (OpID.toString <| Op.id newOp) (newEvent ref) oldObject.events
                , included = oldObject.included
                , lastSeen = OpID.latest oldObject.lastSeen (Op.id newOp)
                }

        ( Nothing, Op.ReducerReference reducerID ) ->
            Just
                { reducer = reducerID
                , creation = Op.id newOp -- TODO or should it be the Op's ObjectID?
                , events = Dict.empty
                , included = All
                , lastSeen = Op.id newOp
                }

        ( Just oldObject, Op.ReducerReference reducerID ) ->
            Debug.todo <| "this object exists: \n" ++ Debug.toString oldObject ++ "\n but the op I got to apply to it: \n" ++ Debug.toString newOp ++ "\n referenced a reducer, as if it's trying to initialize it again?"

        ( Nothing, Op.OpReference ref ) ->
            Debug.todo "this op referenced an opID, but it's object was not found"


type InclusionInfo
    = All
    | EverythingAfter Moment
    | LatestSnapshotOnly


type ReducerWarning
    = OpDecodeFailed OpIDString OpPayloadAtoms
