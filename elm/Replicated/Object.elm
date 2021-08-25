module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Replicated.Op as Op exposing (Op, Payload)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| The most generic "object", to be inherited by other replicated data types for specific functionality.
-}
type alias Object =
    { creation : ObjectID
    , events : Dict OpIDString Event
    , included : InclusionInfo
    }


type
    Event
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = Event { reference : OpID, payload : Payload }


applyOp : Op -> Maybe Object -> Maybe Object
applyOp newOp oldObjectMaybe =
    let
        newEvent =
            Event { reference = Op.reference newOp, payload = Op.payload newOp }
    in
    case ( oldObjectMaybe, Op.payload newOp ) of
        ( Just oldObject, _ ) ->
            Just
                { creation = oldObject.creation
                , events = Dict.insert (OpID.toString <| Op.id newOp) newEvent oldObject.events
                , included = oldObject.included
                }

        ( Nothing, "" ) ->
            -- assume empty payload means object creation
            Just
                { creation = Op.id newOp -- TODO or should it be the Op's ObjectID?
                , events = Dict.empty
                , included = All
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
