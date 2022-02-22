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
    { identity : NodeID, peers : List Peer, objects : ObjectsByCreationDb, root : Maybe ObjectID }


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
                , objects = Dict.empty
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
    { identity = firstSessionEver, peers = [], objects = Dict.empty, root = Nothing }


applyLocalChanges : Moment -> Node -> List Change -> ( List Op, Node )
applyLocalChanges time node changes =
    let
        initialAccumulator =
            OpID.firstCounter time

        ( finalCounter, listOfFinishedOpsLists ) =
            List.Extra.mapAccuml (oneChangeToOps node) initialAccumulator changes

        finishedOps =
            List.concat listOfFinishedOpsLists

        updatedNode =
            List.foldl updateNodeWithSingleOp node finishedOps
    in
    ( finishedOps, updatedNode )


{-| Passed to mapAccuml, so must have accumulator and change as last params
-}
oneChangeToOps : Node -> InCounter -> Change -> ( OutCounter, List Op )
oneChangeToOps node inCounter change =
    case change of
        Op.Chunk chunk ->
            chunkToOps node inCounter chunk


chunkToOps : Node -> InCounter -> { object : Op.TargetObject, objectChanges : List Op.ObjectChange } -> ( OutCounter, List Op )
chunkToOps node inCounter { object, objectChanges } =
    let
        { reducerID, objectID, lastSeen, initializationOps, postInitCounter } =
            getOrInitObject node inCounter object

        objectChangeOps =
            List.Extra.mapAccuml (objectChangeToOp node reducerID objectID) ( inCounter, lastSeen ) objectChanges
    in
    ( someFinalCounter, [] )


objectChangeToOp : Node -> ReducerID -> ObjectID -> ( InCounter, OpID ) -> Op.ObjectChange -> ( ( OutCounter, OpID ), { pre : List Op, post : List Op } )
objectChangeToOp node reducerID objectID ( inCounter, lastOpID ) objectChange =
    let
        newOpHelper : OpID -> Op.Payload -> ( OutCounter, Op )
        newOpHelper =
            let
                ( newID, outCounter ) =
                    OpID.generate inCounter node.identity False
            in
            Op.create reducerID objectID newID
    in
    case objectChange of
        Op.NewPayload payload ->
            let
                ( outCounter, newOp ) =
                    newOpHelper inCounter lastOpID payload
            in
            ( ( outCounter, Op.id newOp ), { pre = [], post = [ newOp ] } )

        Op.NewPayloadWithRef { payload, ref } ->
            let
                ( outCounter, newOp ) =
                    newOpHelper inCounter ref payload
            in
            ( ( outCounter, Op.id newOp ), { pre = [], post = [ newOp ] } )

        Op.NestedObject change ->
            let
                ( outCounter, nestedOps ) =
                    oneChangeToOps node inCounter change
            in
            { pre = nestedOps, post = [] }

        Op.RevertOp opIDToRevert ->
            let
                ( outCounter, reversionOp ) =
                    opThatRevertsAnOp node inCounter opIDToRevert
            in
            { pre = [], post = [ reversionOp ] }


getOrInitObject :
    Node
    -> InCounter
    -> Op.TargetObject
    ->
        { reducerID : ReducerID
        , objectID : ObjectID
        , lastSeen : OpID
        , initializationOps : List Op
        , postInitCounter : OutCounter
        }
getOrInitObject node inCounter targetObject =
    case targetObject of
        Op.ExistingObject objectID ->
            case Dict.get (OpID.toString objectID) node.objects of
                Nothing ->
                    Debug.todo ("object was supposed to pre-exist but couldn't find it: " ++ OpID.toString objectID)

                Just foundObject ->
                    { reducerID = foundObject.reducer
                    , objectID = foundObject.creation
                    , lastSeen = foundObject.lastSeen
                    , initializationOps = []
                    , postInitCounter = inCounter
                    }

        Op.NewObject reducerID ->
            let
                ( newID, outCounter ) =
                    OpID.generate inCounter node.identity False
            in
            { reducerID = reducerID
            , objectID = newID
            , lastSeen = newID
            , initializationOps = [ Op.initObject reducerID newID ]
            , postInitCounter = outCounter
            }


opThatRevertsAnOp : Node -> InCounter -> OpID -> ( OutCounter, Op )
opThatRevertsAnOp node inCounter ( opReducerID, opObjectID, opIDToRevert ) =
    let
        reversionOp =
            Op.create opReducerID opObjectID newID (Just opIDToRevert) ""

        ( newID, outCounter ) =
            OpID.generate inCounter node.identity True
    in
    ( outCounter, reversionOp )



-- getObjectLastSeenID : Node -> ReducerID -> ObjectID -> OpID
-- getObjectLastSeenID node reducer objectID =
--     let
--         relevantObject =
--             Dict.get (OpID.toString objectID) node.objects
--     in
--     Maybe.withDefault objectID <| Maybe.map .lastSeen relevantObject


updateNodeWithSingleOp op node =
    { node | objects = updateObject node.objects op }


updateObject : ObjectsByCreationDb -> Op -> ObjectsByCreationDb
updateObject oBCDict newOp =
    -- we have an object objects. Do work inside it, and return it
    Dict.update (OpID.toString (Op.object newOp)) (Object.applyOp newOp) oBCDict


type alias ObjectsByCreationDb =
    Dict ObjectIDString Object


getObjectIfExists : Node -> OpID.ObjectID -> Maybe Object
getObjectIfExists node objectID =
    Dict.get (OpID.toString objectID) node.objects



-- PEER


type alias Peer =
    { identity : NodeID }


peerCodec : Codec String Peer
peerCodec =
    RS.record Peer
        |> RS.field .identity codec
        |> RS.finishRecord
