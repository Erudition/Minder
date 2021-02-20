module Replicated.Op exposing (..)

import Dict exposing (Dict)
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Atom exposing (..)
import Replicated.Identifier exposing (..)
import Set exposing (Set)


type alias Op =
    { specifier : Specifier
    , payload : Payload
    }


type alias Specifier =
    -- eight 64-bit numbers
    { object : SpecObject
    , event : SpecEvent
    }


type alias SpecObject =
    -- all omitted in short (closed) form, deduced via full database
    { reducer : RonUUID -- AKA the DATATYPE (RDT) -
    , creation : RonUUID -- Points to the creation Op of the target object.
    }


type alias SpecEvent =
    { stamp : EventStamp -- uniquely identifies this event itself
    , location : EventStamp -- also called "name" or "reference" or the RDT's "method"
    }


type alias Payload =
    List Atom


type OpPattern
    = NormalOp
    | DeletionOp
    | UnDeletionOp
    | CreationOp
    | Acknowledgement
    | Annotation


type alias Tree =
    Set Op


type alias Chunk =
    List Op


type alias Frame =
    List Op


type alias OpLog =
    List Op


type alias GatheredObjectOpLog =
    List (Nonempty Op)


gatherObjects : OpLog -> GatheredObjectOpLog
gatherObjects opLog =
    -- TODO - prune the SpecObject from the outputs
    let
        sameObject : Op -> SpecObject
        sameObject op =
            op.specifier.object

        toNonempty ( head, tail ) =
            Nonempty head tail
    in
    List.map toNonempty (List.Extra.gatherEqualsBy sameObject opLog)


type alias ObjectLog =
    { id : SpecObject
    , events : Dict ( EventStamp, EventStamp ) Payload
    }


toObjectLog : Nonempty Op -> ObjectLog
toObjectLog singleObjectLog =
    let
        thisObject =
            (List.Nonempty.head singleObjectLog).specifier.object

        strippedObjectLog =
            List.map toComparable (List.Nonempty.toList singleObjectLog)

        objectEventsDict =
            Dict.fromList strippedObjectLog

        toComparable op =
            ( ( op.specifier.event.stamp, op.specifier.event.location ), op.payload )
    in
    { id = thisObject
    , events = objectEventsDict
    }
