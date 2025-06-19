module Replicated.Op.Op exposing (ClosedChunk, Op(..), Reference(..), create, id, initObject, objectHeader, objectID, opIDFromReference, payload, reducerID, reference, referenceToString)

{-| Just Ops - already-happened events and such. Ignore Frames for now, they are "write batches" so once they're written they will slef-concatenate in the list of Ops.
-}

import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Parser.Advanced as Parser exposing ((|.), (|=), Token(..), float, inContext, succeed, symbol)
import Replicated.Op.ID as OpID exposing (ObjectID, OpID)
import Replicated.Op.ObjectHeader as ObjectHeader exposing (ObjectHeader)
import Replicated.Op.Payload as Payload exposing (Payload)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import Result.Extra
import Set exposing (Set)
import SmartTime.Moment as Moment


{-| Closed Ops have all their pieces, ready to use in memory. They may have come from Open Ops where some missing (implied) pieces had to be deduced.

We now merge in the OpPattern as well.

Not implemented:

Op with "+" in ID, "-" in Ref = "Acknowledgement"
Op with "$", "+" or "$", "-" = "Annotation"
where $ is the same as an omitted ID atom

-}
type Op
    = NormalOp NormalOpInfo
    | DeletionOp DeletionOpInfo
    | UnDeletionOp UnDeletionOpInfo
    | CreationOp ObjectHeader


type alias ClosedChunk =
    List Op


{-| A generic Op. Unused
-}
type alias ClosedOpInfo =
    { operationID : OpID
    , reducer : ReducerID
    , object : ObjectID
    , reference : Reference
    , payload : Payload
    }


{-| Reducer is implied by object. Ref cannot be a reducer.

Unchecked: Referenced Op must be a Normal or Creation Op (referencing an Un/Deletion Op is Acknowledgement, not yet implemented)

-}
type alias NormalOpInfo =
    { operationID : OpID
    , object : ObjectHeader
    , earlierOpRef : Op
    , payload : Payload
    }


{-| Cannot have payload. Object is implied by reference. Reducer is implied by object. Ref cannot be a reducer.
-}
type alias DeletionOpInfo =
    { operationID : OpID
    , revertedOpRef : Op
    }


{-| Cannot have payload. Object is implied by reference. Reducer is implied by object. Ref cannot be a reducer.
-}
type alias UnDeletionOpInfo =
    { operationID : OpID
    , revertedOpRef : Op
    }



-- CLOSED OP PARTS


type Reference
    = OpReference Op
    | ReducerReference ReducerID


referenceToString : Reference -> String
referenceToString givenRef =
    case givenRef of
        OpReference op ->
            OpID.toString (id op)

        ReducerReference givenReducerID ->
            ReducerID.toString givenReducerID


opIDFromReference : Reference -> Maybe OpID
opIDFromReference givenRef =
    case givenRef of
        OpReference op ->
            Just (id op)

        _ ->
            Nothing


create : ReducerID -> ObjectID -> OpID -> Reference -> Payload -> Result String Op
create givenReducerID givenObjectID opID givenReference givenPayload =
    -- TODO split into createNormalOp, createDeletionOp, etc since only Node does this and it already can validate the Op type
    case ( OpID.isDeletion opID, Maybe.map OpID.isDeletion (opIDFromReference givenReference), givenReference ) of
        ( False, Just False, OpReference earlierOp ) ->
            -- "+", "+"
            Ok <|
                NormalOp
                    { operationID = opID
                    , object = ObjectHeader givenObjectID givenReducerID
                    , earlierOpRef = earlierOp
                    , payload = givenPayload
                    }

        ( True, Just False, OpReference earlierOp ) ->
            -- "-", "+"
            Ok <|
                DeletionOp
                    { operationID = opID
                    , revertedOpRef = earlierOp
                    }

        ( True, Just True, OpReference earlierOp ) ->
            -- "-", "-"
            Ok <|
                UnDeletionOp
                    { operationID = opID
                    , revertedOpRef = earlierOp
                    }

        ( False, Nothing, ReducerReference _ ) ->
            -- "+", "$"
            Ok <|
                CreationOp
                    { reducer = givenReducerID
                    , operationID = opID
                    }

        _ ->
            Err "Corrupt Op"


initObject : ReducerID -> OpID -> Op
initObject givenReducer opID =
    CreationOp
        { reducer = givenReducer
        , operationID = opID
        }


reference : Op -> Reference
reference op =
    case op of
        NormalOp { earlierOpRef } ->
            OpReference earlierOpRef

        DeletionOp { revertedOpRef } ->
            OpReference revertedOpRef

        UnDeletionOp { revertedOpRef } ->
            OpReference revertedOpRef

        CreationOp info ->
            ReducerReference info.reducer


reducerID : Op -> ReducerID
reducerID op =
    case op of
        NormalOp info ->
            info.object.reducer

        DeletionOp info ->
            reducerID info.revertedOpRef

        UnDeletionOp info ->
            reducerID info.revertedOpRef

        CreationOp info ->
            info.reducer


payload : Op -> Payload
payload op =
    case op of
        NormalOp info ->
            info.payload

        _ ->
            []


id : Op -> OpID
id op =
    case op of
        NormalOp info ->
            info.operationID

        DeletionOp info ->
            info.operationID

        UnDeletionOp info ->
            info.operationID

        CreationOp info ->
            info.operationID


objectHeader : Op -> ObjectHeader
objectHeader op =
    case op of
        NormalOp info ->
            info.object

        DeletionOp info ->
            objectHeader info.revertedOpRef

        UnDeletionOp info ->
            objectHeader info.revertedOpRef

        CreationOp header ->
            header


objectID : Op -> OpID
objectID op =
    (objectHeader op).operationID
