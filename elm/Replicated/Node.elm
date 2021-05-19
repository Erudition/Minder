module Replicated.Node exposing (..)

import Dict exposing (Dict)
import Replicated.Identifier exposing (..)
import Replicated.Object as Object exposing (Object)
import Replicated.Op exposing (Frame, Op)
import Replicated.Serialize as RS exposing (Codec)


{-| Represents this one instance in the user's network of instances, with its own ID and log of ops.
-}
type alias Node =
    { identity : NodeID, peers : List Peer, db : ReplicaTree }


{-| Start our program, persisting the identity we had last time.
-}
initFromSaved : String -> List Frame -> Result InitError Node
initFromSaved foundIdentity inputDatabase =
    let
        lastIdentity =
            RS.decodeFromString nodeIDCodec foundIdentity

        bumpSessionID nodeID =
            { nodeID | session = nodeID.session + 1 }
    in
    case lastIdentity of
        Ok oldNodeID ->
            Ok
                { identity = bumpSessionID oldNodeID
                , peers = []
                , db = Dict.empty
                }

        Err _ ->
            Err DecodingOldIdentityProblem


type InitError
    = DecodingOldIdentityProblem


firstSessionEver : NodeID
firstSessionEver =
    { primus = 0, peer = 0, client = 0, session = 0 }



--replicaCodec : RS.Codec e Node
--replicaCodec =
--    RS.record Node
--        |> RS.field .identity nodeIDCodec
--        |> RS.field .peers (RS.list peerCodec)
--        |> RS.field .db (RS.dict RS.string objectsByCreationCodec)
--        |> RS.finishRecord


type alias ReducerNameString =
    String


{-| Takes a single (e.g. newly received) Op and inserts it deep into the structure
-}
applyOpToDb : ReplicaTree -> Op -> ReplicaTree
applyOpToDb previous newOp =
    let
        updatedValue maybeOBCD =
            -- If we've never seen this object before, we won't get a db, so make a fresh one
            Just <| updateObject newOp (Maybe.withDefault Dict.empty maybeOBCD)
    in
    Dict.update newOp.reducerID updatedValue previous


updateObject : Op -> ObjectsByCreationDb -> ObjectsByCreationDb
updateObject newOp oBCDict =
    -- we have an object db. Do work inside it, and return it
    Dict.update newOp.objectID (Maybe.map (Object.applyOp newOp)) oBCDict


type alias ReplicaTree =
    Dict ReducerNameString ObjectsByCreationDb


type alias ObjectsByCreationDb =
    Dict ObjectID Object



-- PEER


type alias Peer =
    { identity : NodeID }


peerCodec : Codec e Peer
peerCodec =
    RS.record Peer
        |> RS.field .identity nodeIDCodec
        |> RS.finishRecord
