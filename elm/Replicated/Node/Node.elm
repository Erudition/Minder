module Replicated.Node.Node exposing (..)

import Dict exposing (Dict)
import List.Extra
import Replicated.Identifier exposing (..)
import Replicated.Node.NodeID exposing (NodeID, codec, fromString)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Change, Op, ReducerID, create)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, ObjectIDString, OpID, OutCounter)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment exposing (Moment)


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


applyLocalChanges : Moment -> Node -> List Change -> ( List Op, Node )
applyLocalChanges time node changes =
    let
        initialAccumulator =
            ( OpID.firstCounter time, Nothing )

        finishOneOp : ( InCounter, Maybe OpID ) -> Change -> ( ( OutCounter, Maybe OpID ), Op )
        finishOneOp ( inCounter, lastIDMaybe ) givenChange =
            let
                ( newID, outCounter ) =
                    OpID.generate inCounter node.identity givenChange.reversion

                objectLastSeenID =
                    getObjectLastSeenID node givenChange.reducerID givenChange.objectID
            in
            ( ( outCounter, Just newID ), Op.fromChange newID (Maybe.withDefault objectLastSeenID lastIDMaybe) givenChange )

        ( finalCounter, finishedOps ) =
            List.Extra.mapAccuml finishOneOp initialAccumulator changes

        updatedNode =
            List.foldl updateNodeWithSingleOp node finishedOps
    in
    ( finishedOps, updatedNode )


getObjectLastSeenID : Node -> ReducerID -> ObjectID -> OpID
getObjectLastSeenID node reducer objectID =
    let
        relevantObjectTypeDatabase =
            Maybe.withDefault Dict.empty <| Dict.get reducer node.db

        relevantObject =
            Dict.get (OpID.toString objectID) relevantObjectTypeDatabase
    in
    Maybe.withDefault objectID <| Maybe.map .latest relevantObject


type alias ReducerNameString =
    String


updateNodeWithSingleOp op node =
    { node | db = applyOpToDb node.db op }


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


getObjectIfExists : Node -> OpID.ObjectID -> Maybe Object
getObjectIfExists node objectID =
    let
        registerDatabase =
            Maybe.withDefault Dict.empty (Dict.get "lww" node.db)
    in
    Dict.get (OpID.toString objectID) registerDatabase



-- PEER


type alias Peer =
    { identity : NodeID }


peerCodec : Codec String Peer
peerCodec =
    RS.record Peer
        |> RS.field .identity codec
        |> RS.finishRecord
