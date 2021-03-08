module Replicated.Op exposing (..)

import Dict exposing (Dict)
import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Atom exposing (..)
import Replicated.Identifier exposing (..)
import Replicated.Value exposing (Value)
import Set exposing (Set)



-- MONOLITHIC OP LOGS --------------------------


{-| The big list of all the Ops we know about.
-}
type alias OpLog =
    List Op


{-| A raw OpLog is a big list of unparsed RawOps.
There's no need for duplicates so we import it as a Set.

A simple place to start - but rather than importing a RawOpLog, it's more performant to import on an object-by-object basis, so we can take advantage of database management systems. (See ObjectOpLog)

-}
type alias RawOpLog =
    Set RawOp



-- OPS ----------------------------------------------


type alias Op =
    { specifier : Specifier
    , payload : Payload
    }


{-| A blob that can be parsed into an Op.
TODO String for now, Bytes later?
-}
type alias RawOp =
    Value



-- PARTS OF AN OP: SPECIFIERS -----------------------


type alias Specifier =
    -- eight 64-bit numbers
    { object : SpecObject
    , event : Event
    }


type alias SpecObject =
    -- all omitted in short (closed) form, deduced via full database
    { reducer : RonUUID -- AKA the DATATYPE (RDT) -
    , creation : RonUUID -- Points to the creation Op of the target object.
    }


type alias RawSpecObject =
    Value


type alias Event =
    { stamp : EventStamp -- uniquely identifies this event itself
    , reference : EventStamp -- also called "name" or "reference" or the RDT's "method"
    }


type alias RawSpecEvent =
    Value


type alias Payload =
    Value


type OpPattern
    = NormalOp
    | DeletionOp
    | UnDeletionOp
    | CreationOp
    | Acknowledgement
    | Annotation


{-| A bunch of Ops that are all about the same object - consisting of, at a minimum, the object's creation Op.
-}
type alias Group =
    Nonempty Op


{-| Groups Ops together by target object.
For monolithic OpLogs; not needed for pre-separated logs.
-}
groupByObject : OpLog -> List Group
groupByObject opLog =
    let
        sameObject : Op -> SpecObject
        sameObject op =
            op.specifier.object

        toNonempty ( head, tail ) =
            Nonempty head tail
    in
    List.map toNonempty (List.Extra.gatherEqualsBy sameObject opLog)
