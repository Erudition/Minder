module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Replicated.Op.Op as Op exposing (Op, Payload)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| The most generic "object", to be inherited by other replicated data types for specific functionality.
-}
type alias Object =
    { creation : ObjectID
    , events : Dict OpIDString KeptEvent
    , included : InclusionInfo
    , latest : OpID
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
                { creation = oldObject.creation
                , events =
                    if Op.pattern newOp == Op.DeletionOp then
                        Dict.remove (OpID.toString ref) oldObject.events

                    else
                        Dict.insert (OpID.toString <| Op.id newOp) (newEvent ref) oldObject.events
                , included = oldObject.included
                , latest = OpID.latest oldObject.latest (Op.id newOp)
                }

        ( Nothing, Nothing ) ->
            -- assume empty payload means object creation
            Just
                { creation = Op.id newOp -- TODO or should it be the Op's ObjectID?
                , events = Dict.empty
                , included = All
                , latest = Op.id newOp
                }

        _ ->
            Nothing


type InclusionInfo
    = All
    | EverythingAfter Moment
    | LatestSnapshotOnly



--{-| Convert a Tree (just a list of same-object Ops) to an ObjectLog.
--Removes all the redundant metadata from the Ops and stores it in one place.
--
--ObjectLogs get passed on to reducers for further interpretation.
--
---}
--fromGroup : Op.Group -> Object
--fromGroup singleObjectLog =
--    let
--        commonObjectDetails =
--            (List.Nonempty.head singleObjectLog).specifier.object
--
--        nonCreationOps =
--            List.Nonempty.tail singleObjectLog
--
--        eventLog =
--            List.map toEvent nonCreationOps
--
--        toEvent op =
--            ( op.specifier.event, op.payload )
--    in
--    { root = commonObjectDetails
--    , events = eventLog
--    , included = All
--    }
