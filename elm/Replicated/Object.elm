module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Replicated.Identifier exposing (..)
import Replicated.Op exposing (EventStampString, Op, Payload)
import Replicated.Serialize as RS
import SmartTime.Moment as Moment exposing (Moment)


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


applyOp : Op -> Maybe Object -> Maybe Object
applyOp newOp oldObjectMaybe =
    let
        newEvent =
            Event { reference = newOp.referenceID, payload = newOp.payload }

        newCreationTry =
            objectIDtoEventStamp newOp.objectID
    in
    case ( oldObjectMaybe, newCreationTry, newOp.payload ) of
        ( Just oldObject, _, _ ) ->
            Just
                { creation = oldObject.creation
                , events = Dict.insert newOp.operationID newEvent oldObject.events
                , included = oldObject.included
                }

        ( Nothing, Just eventStamp, "" ) ->
            Just
                { creation = eventStamp
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
