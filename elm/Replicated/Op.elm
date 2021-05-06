module Replicated.Op exposing (..)

import Json.Encode
import List.Extra
import List.Nonempty exposing (Nonempty)
import Replicated.Identifier as Identifier exposing (..)
import Replicated.Serialize as RS exposing (Codec)
import Replicated.Value exposing (Value)
import Set exposing (Set)
import SmartTime.Moment as Moment



-- MONOLITHIC OP LOGS --------------------------


{-| The big list of all the Ops we know about.
-}



--type alias OpLog =
--    Set Op


{-| A raw OpLog is a big list of unparsed RawOps.
There's no need for duplicates so we import it as a Set.

A simple place to start - but rather than importing a RawOpLog, it's more performant to import on an object-by-object basis, so we can take advantage of database management systems. (See ObjectOpLog)

-}
type alias RawOpLog =
    List RawOp



-- OPS ----------------------------------------------


type alias Op =
    { reducerID : ReducerID
    , objectID : EventStampString
    , operationID : EventStampString
    , referenceID : EventStampString
    , payload : UninterpretedPayload
    }


type alias EventStampString =
    String


{-| A blob that can be parsed into an Op.
TODO String for now, Bytes later?
-}
type alias RawOp =
    Value


opCodec : Codec e Op
opCodec =
    let
        wrapper ( s, p ) =
            Op s p

        unwrapper op =
            ( op.specifier, op.payload )
    in
    RS.tuple specifierCodec RS.string |> RS.map wrapper unwrapper



-- PARTS OF AN OP: SPECIFIERS -----------------------


type alias Specifier =
    -- eight 64-bit numbers
    { object : SpecObject
    , event : Event
    }


specifierCodec : Codec e Specifier
specifierCodec =
    RS.record Specifier
        |> RS.field .object specObjectCodec
        |> RS.field .event eventCodec
        |> RS.finishRecord


type alias OpPointerString =
    String


type alias SpecObject =
    -- all omitted in short (closed) form, deduced via full database
    { reducer : ReducerAsString -- AKA the DATATYPE (RDT) -
    , creation : OpPointerString -- Points to the creation Op of the target object.
    }


specObjectCodec : Codec e SpecObject
specObjectCodec =
    RS.record SpecObject
        |> RS.field .reducer RS.string
        |> RS.field .creation RS.string
        |> RS.finishRecord


type alias RawSpecObject =
    Value


type alias RawEvent =
    Value


type alias UninterpretedPayload =
    String


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
