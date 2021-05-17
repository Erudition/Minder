module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Replicated.Identifier exposing (..)
import Replicated.Op exposing (EventStampString, Op, Payload)
import SmartTime.Moment exposing (Moment)


{-| The most generic "object", to be inherited by other replicated data types for specific functionality.
-}
type alias Object =
    { creation : EventStamp
    , events : Dict EventStampString Event
    , included : InclusionInfo
    }


type
    Event
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = Event { reference : ReferenceString, payload : Payload }


type alias ReferenceString =
    String


applyOp : Op -> Object -> Object
applyOp newOp oldObject =
    let
        newEvent =
            Event { reference = newOp.referenceID, payload = newOp.payload }
    in
    { creation = oldObject.creation
    , events = Dict.insert newOp.operationID newEvent oldObject.events
    , included = oldObject.included
    }


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
