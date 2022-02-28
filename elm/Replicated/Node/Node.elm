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
    { identity : NodeID
    , objects : ObjectsByCreationDb
    , root : Maybe ObjectID -- TODO should this be maybe?
    , lastUsedCounter : OutCounter
    , peers : List Peer
    }


{-| Start our program, persisting the identity we had last time.
-}
initFromSaved : String -> Int -> List Op -> Result InitError Node
initFromSaved foundIdentity foundCounter inputDatabase =
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
                , lastUsedCounter = OpID.importCounter foundCounter
                }

        Nothing ->
            Err DecodingOldIdentityProblem


type InitError
    = DecodingOldIdentityProblem


firstSessionEver : NodeID
firstSessionEver =
    { primus = 0, peer = 0, client = 0, session = 0 }


startNewNode : Moment -> Node
startNewNode now =
    { identity = firstSessionEver, peers = [], objects = Dict.empty, root = Nothing, lastUsedCounter = OpID.firstCounter now }


applyLocalChanges : Moment -> Node -> List Change -> ( List Op, Node )
applyLocalChanges time node changes =
    let
        ( finalCounter, listOfFinishedOpsLists ) =
            List.Extra.mapAccuml (oneChangeToOps node) node.lastUsedCounter (combineSameObjectChunks changes)

        finishedOps =
            List.concat listOfFinishedOpsLists

        updatedNode =
            List.foldl updateNodeWithSingleOp node finishedOps
    in
    ( finishedOps, updatedNode )


combineSameObjectChunks : List Change -> List Change
combineSameObjectChunks changes =
    let
        sameObjectID change1 change2 =
            case ( change1, change2 ) of
                ( Op.Chunk chunk1, Op.Chunk chunk2 ) ->
                    case ( chunk1.object, chunk2.object ) of
                        ( Op.ExistingObject objectID1, Op.ExistingObject objectID2 ) ->
                            objectID1 == objectID2

                        _ ->
                            False

        sameObjectGroups =
            List.Extra.gatherWith sameObjectID changes

        combineGroupedItems group =
            case group of
                ( singleItem, [] ) ->
                    [ singleItem ]

                ( Op.Chunk { object, objectChanges }, rest ) ->
                    [ Op.Chunk { object = object, objectChanges = objectChanges ++ List.concatMap extractChanges rest } ]

        extractChanges (Op.Chunk { objectChanges }) =
            objectChanges
    in
    List.concatMap combineGroupedItems sameObjectGroups


{-| Passed to mapAccuml, so must have accumulator and change as last params
-}
oneChangeToOps : Node -> InCounter -> Change -> ( OutCounter, List Op )
oneChangeToOps node inCounter change =
    case change of
        Op.Chunk chunkRecord ->
            let
                ( ( outCounter, _ ), chunkOps ) =
                    chunkToOps node ( inCounter, Nothing ) chunkRecord
            in
            ( outCounter, chunkOps )


{-| Turns a change Chunk (same-object changes) into finalized ops.
in mapAccuml form
-}
chunkToOps : Node -> ( InCounter, Maybe ObjectID ) -> { object : Op.TargetObject, objectChanges : List Op.ObjectChange } -> ( ( OutCounter, Maybe ObjectID ), List Op )
chunkToOps node ( inCounter, _ ) { object, objectChanges } =
    let
        -- I'm pretty proud of this concotion, it took me DAYS to figure a concise way to get the prereqs all stamped BEFORE the object initialization op and the object changes (the prereqs are nested in the object that doesn't exist yet).
        ( postPrereqCounter, processedChanges ) =
            List.Extra.mapAccuml (objectChangeToUnstampedOp node) inCounter objectChanges

        allPrereqOps =
            List.concatMap .prerequisiteOps processedChanges

        allUnstampedChunkOps =
            List.map .thisObjectOp processedChanges

        { reducerID, objectID, lastSeen, initializationOps, postInitCounter } =
            getOrInitObject node postPrereqCounter object

        stampChunkOps : ( InCounter, OpID ) -> UnstampedChunkOp -> ( ( OutCounter, OpID ), Op )
        stampChunkOps ( stampInCounter, opIDToReference ) givenUCO =
            let
                ( newID, stampOutCounter ) =
                    OpID.generate stampInCounter node.identity givenUCO.reversion

                stampedOp =
                    Op.create reducerID objectID newID (Just <| Maybe.withDefault opIDToReference givenUCO.reference) givenUCO.payload
            in
            ( ( stampOutCounter, newID ), stampedOp )

        ( ( counterAfterObjectChanges, newLastSeen ), objectChangeOps ) =
            List.Extra.mapAccuml stampChunkOps ( postInitCounter, lastSeen ) allUnstampedChunkOps
    in
    ( ( counterAfterObjectChanges, Just objectID ), allPrereqOps ++ initializationOps ++ objectChangeOps )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Op.Payload, reversion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> InCounter -> Op.ObjectChange -> ( OutCounter, { prerequisiteOps : List Op, thisObjectOp : UnstampedChunkOp } )
objectChangeToUnstampedOp node inCounter objectChange =
    let
        outputHelper : UnstampedChunkOp -> ( OutCounter, { prerequisiteOps : List Op, thisObjectOp : UnstampedChunkOp } )
        outputHelper unstampedChunkOp =
            ( inCounter
            , { prerequisiteOps = []
              , thisObjectOp = unstampedChunkOp
              }
            )
    in
    case objectChange of
        Op.NewPayload payload ->
            outputHelper { reference = Nothing, payload = payload, reversion = False }

        Op.NewPayloadWithRef { payload, ref } ->
            outputHelper { reference = Just ref, payload = payload, reversion = False }

        Op.RevertOp opIDToRevert ->
            outputHelper { reference = Just opIDToRevert, payload = "", reversion = True }

        Op.NestedObject (Op.Chunk chunk) newObjectIDToPayload ->
            let
                ( ( postPrereqCounter, subObjectIDMaybe ), prereqOps ) =
                    chunkToOps node ( inCounter, Nothing ) chunk

                pointerPayload =
                    -- subObjectIDMaybe should never be nothing, but we have no way to pass an initial value to mapAccuml without wrapping in maybe...
                    Maybe.map newObjectIDToPayload subObjectIDMaybe
                        |> Maybe.withDefault ""
            in
            ( postPrereqCounter
            , { prerequisiteOps = prereqOps
              , thisObjectOp = { reference = Nothing, payload = pointerPayload, reversion = False }
              }
            )


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
