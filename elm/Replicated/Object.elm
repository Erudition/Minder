module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Replicated.Op.Op as Op exposing (Op, Payload)
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


{-| An event that has not been undone/deleted.
-}
type
    KeptEvent
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = KeptEvent { id : OpID, reference : OpID, payload : Payload }


eventReference : KeptEvent -> OpID
eventReference (KeptEvent event) =
    event.reference


eventID : KeptEvent -> OpID
eventID (KeptEvent event) =
    event.id


eventPayload : KeptEvent -> Payload
eventPayload (KeptEvent event) =
    event.payload


create : Op.ReducerID -> OpID.ObjectID -> Op
create givenReducer givenObject =
    -- object creation Ops don't have references
    -- objectID is OpID
    -- Payload is not needed
    Op.create givenReducer givenObject givenObject Nothing ""


{-| Apply an incoming Op to an object if we have it.
Ops must have a reference.
-}
applyOp : Op -> Maybe Object -> Maybe Object
applyOp newOp oldObjectMaybe =
    let
        newEvent givenRef =
            KeptEvent { id = Op.id newOp, reference = givenRef, payload = Op.payload newOp }
    in
    case ( oldObjectMaybe, Op.reference newOp ) of
        ( Just oldObject, Just ref ) ->
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

        ( Nothing, Nothing ) ->
            -- assume empty payload means object creation
            Just
                { reducer = Op.reducer newOp
                , creation = Op.id newOp -- TODO or should it be the Op's ObjectID?
                , events = Dict.empty
                , included = All
                , lastSeen = Op.id newOp
                }

        _ ->
            Nothing


type InclusionInfo
    = All
    | EverythingAfter Moment
    | LatestSnapshotOnly
