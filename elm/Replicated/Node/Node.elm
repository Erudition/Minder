module Replicated.Node.Node exposing (..)

import Dict exposing (Dict)
import Replicated.Identifier exposing (..)
import Replicated.Node.NodeID exposing (NodeID, codec, fromString)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op, create)
import Replicated.Op.OpID as OpID exposing (ObjectID, ObjectIDString)
import Replicated.Serialize as RS exposing (Codec)


{-| Represents this one instance in the user's network of instances, with its own ID and log of ops.
-}
type alias Node =
    { identity : NodeID, peers : List Peer, db : ReplicaTree, root : Maybe ObjectID }


{-| Start our program, persisting the identity we had last time.
-}
initFromSaved : String -> List Op -> Result InitError Node
initFromSaved foundIdentity inputDatabase =
    let
        lastIdentity =
            fromString foundIdentity

        bumpSessionID nodeID =
            { nodeID | session = nodeID.session + 1 }
    in
    case lastIdentity of
        Just oldNodeID ->
            Ok
                { identity = bumpSessionID oldNodeID
                , peers = []
                , db = Dict.empty
                , root = Nothing
                }

        Nothing ->
            Err DecodingOldIdentityProblem


type InitError
    = DecodingOldIdentityProblem


firstSessionEver : NodeID
firstSessionEver =
    { primus = 0, peer = 0, client = 0, session = 0 }


blankNode : Node
blankNode =
    { identity = firstSessionEver, peers = [], db = Dict.empty, root = Nothing }



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
    Dict.update (Op.reducer newOp) updatedValue previous


updateObject : Op -> ObjectsByCreationDb -> ObjectsByCreationDb
updateObject newOp oBCDict =
    -- we have an object db. Do work inside it, and return it
    Dict.update (OpID.toString (Op.object newOp)) (Object.applyOp newOp) oBCDict


type alias ReplicaTree =
    Dict ReducerNameString ObjectsByCreationDb


type alias ObjectsByCreationDb =
    Dict ObjectIDString Object



-- PEER


type alias Peer =
    { identity : NodeID }


peerCodec : Codec String Peer
peerCodec =
    RS.record Peer
        |> RS.field .identity codec
        |> RS.finishRecord



-- TESTING


fakeOps : List Op
fakeOps =
    let
        ops =
            """
            @1200+0.0.0.0 :lww,
            @1244+0.0.0.0 :1200+0.0.0.0 [1,[[1,first],firstname]]
            """
    in
    Maybe.withDefault [] <| Result.toMaybe <| Debug.log "Importing op" <| Op.fromFrame ops


fakeNode =
    let
        apply op node =
            { node | db = applyOpToDb node.db op }
    in
    List.foldl apply blankNode fakeOps
