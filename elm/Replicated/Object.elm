module Replicated.Object exposing (..)

import Dict exposing (Dict)
import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Atom exposing (..)
import Replicated.Identifier exposing (..)
import Replicated.Op as Op exposing (Op)
import Set exposing (Set)
import SmartTime.Moment exposing (Moment)


type alias Event =
    ( Op.Event, Op.Payload )


type alias Tree =
    { root : Op.SpecObject
    , events : List Event
    , included : InclusionInfo
    }


{-| A log of raw (unparsed) ops that we know in advance are all about the same object. For example, if we got it from a key-value database where each object gets a key.
-}
type alias RawObjectLog =
    { object : Op.RawSpecObject
    , events : Set RawObjectEvent
    , included : RawInclusionInfo
    }


type InclusionInfo
    = All
    | EverythingAfter Moment
    | LatestSnapshotOnly


{-| Unparsed information about what log entries were not retrieved from the database.
-}
type alias RawInclusionInfo =
    Op.Value


{-| Unparsed information about an event within a known object.
-}
type alias RawObjectEvent =
    Op.Value


{-| Convert a Tree (just a list of same-object Ops) to an ObjectLog.
Removes all the redundant metadata from the Ops and stores it in one place.

ObjectLogs get passed on to reducers for further interpretation.

-}
fromGroup : Op.Group -> Tree
fromGroup singleObjectLog =
    let
        commonObjectDetails =
            (List.Nonempty.head singleObjectLog).specifier.object

        nonCreationOps =
            List.Nonempty.tail singleObjectLog

        eventLog =
            List.map toEvent nonCreationOps

        toEvent op =
            ( op.specifier.event, op.payload )
    in
    { root = commonObjectDetails
    , events = eventLog
    , included = All
    }
