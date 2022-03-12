module Replicated.Node.Node exposing (..)

import Dict exposing (Dict)
import List.Extra as List
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
    , profiles : List ObjectID
    , lastUsedCounter : OutCounter
    , peers : List Peer
    }


{-| Start our program, persisting the identity we had last time.
-}
initFromSaved : String -> Int -> OpID -> List Op -> Result InitError Node
initFromSaved foundIdentity foundCounter foundRoot inputDatabase =
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
                , profiles = [ foundRoot ]
                , lastUsedCounter = OpID.importCounter foundCounter
                }

        Nothing ->
            Err DecodingOldIdentityProblem


type InitError
    = DecodingOldIdentityProblem


firstSessionEver : NodeID
firstSessionEver =
    { primus = 0, peer = 0, client = 0, session = 0 }


testNode : Node
testNode =
    { identity = firstSessionEver
    , peers = []
    , objects = Dict.empty
    , profiles = []
    , lastUsedCounter = OpID.testCounter
    }


startNewNode : Maybe Moment -> Change -> Node
startNewNode nowMaybe rootChange =
    let
        { updatedNode, created } =
            apply nowMaybe testNode [ rootChange ]

        newRoot =
            List.last created
                |> Maybe.map List.singleton
                |> Maybe.withDefault []

        nodeStartCounter =
            Maybe.withDefault OpID.testCounter (Maybe.map OpID.firstCounter nowMaybe)
    in
    { updatedNode | profiles = newRoot, lastUsedCounter = nodeStartCounter }


{-| Save your changes!
Always supply the current time (`Just moment`).
(Else, new Ops will be timestamped as if they occurred mere milliseconds after the previous save, which can cause them to always be considered "older" than other ops that happened between.)
If the clock is set backwards or another node loses track of time, we will never go backwards in timestamps.
-}
apply : Maybe Moment -> Node -> List Change -> { ops : List Op, updatedNode : Node, created : List ObjectID }
apply timeMaybe node changes =
    let
        fallbackCounter =
            Maybe.withDefault node.lastUsedCounter (Maybe.map OpID.firstCounter timeMaybe)

        frameStartCounter =
            OpID.highestCounter fallbackCounter node.lastUsedCounter

        ( finalCounter, listOfFinishedOpsLists ) =
            List.mapAccuml (oneChangeToOps node) frameStartCounter (combineSameObjectChunks changes)

        finishedOps =
            List.concat listOfFinishedOpsLists

        updatedNode =
            List.foldl updateNodeWithSingleOp node finishedOps

        creationOpsToObjectIDs op =
            case Op.pattern op of
                Op.CreationOp ->
                    Just (Op.object op)

                _ ->
                    Nothing
    in
    { ops = finishedOps
    , updatedNode = { updatedNode | lastUsedCounter = finalCounter }
    , created = List.filterMap creationOpsToObjectIDs finishedOps
    }


combineSameObjectChunks : List Change -> List Change
combineSameObjectChunks changes =
    let
        sameObjectID change1 change2 =
            case ( change1, change2 ) of
                ( Op.Chunk chunk1, Op.Chunk chunk2 ) ->
                    case ( chunk1.object, chunk2.object ) of
                        ( Op.ExistingObject objectID1, Op.ExistingObject objectID2 ) ->
                            objectID1 == objectID2

                        ( Op.NewObject reducerID1 pendingID1, Op.NewObject reducerID2 pendingID2 ) ->
                            pendingID1 == pendingID2 && reducerID1 == reducerID2

                        _ ->
                            False

        sameObjectGroups =
            List.gatherWith sameObjectID changes

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
                ( ( outCounter, createdObjectMaybe ), chunkOps ) =
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
            List.mapAccuml (objectChangeToUnstampedOp node) inCounter objectChanges

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
            List.mapAccuml stampChunkOps ( postInitCounter, lastSeen ) allUnstampedChunkOps
    in
    ( ( counterAfterObjectChanges, Just objectID ), allPrereqOps ++ initializationOps ++ objectChangeOps )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Op.Payload, reversion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> InCounter -> Op.ObjectChange -> ( OutCounter, { prerequisiteOps : List Op, thisObjectOp : UnstampedChunkOp } )
objectChangeToUnstampedOp node inCounter objectChange =
    let
        perPiece : Op.ChangeAtom -> { counter : OutCounter, prerequisiteOps : List Op, finalPiecePayload : String } -> { counter : OutCounter, prerequisiteOps : List Op, finalPiecePayload : String }
        perPiece piece accumulated =
            case piece of
                Op.JustString stringPiece ->
                    { counter = accumulated.counter
                    , finalPiecePayload = accumulated.finalPiecePayload ++ "\t" ++ stringPiece
                    , prerequisiteOps = accumulated.prerequisiteOps
                    }

                Op.QuoteNestedObject (Op.Chunk chunkDetails) ->
                    let
                        ( ( postPrereqCounter, subObjectIDMaybe ), newPrereqOps ) =
                            chunkToOps node ( accumulated.counter, Nothing ) chunkDetails

                        pointerPayload =
                            Maybe.map newObjectIDToPayload subObjectIDMaybe
                                |> Maybe.withDefault ""
                    in
                    { counter = postPrereqCounter
                    , prerequisiteOps = accumulated.prerequisiteOps ++ newPrereqOps
                    , finalPiecePayload = accumulated.finalPiecePayload ++ "\t" ++ pointerPayload
                    }

        outputHelper pieceList reference =
            let
                { counter, prerequisiteOps, finalPiecePayload } =
                    List.foldl perPiece { counter = inCounter, finalPiecePayload = "", prerequisiteOps = [] } pieceList
            in
            ( counter
            , { prerequisiteOps = prerequisiteOps
              , thisObjectOp = { reference = reference, payload = finalPiecePayload, reversion = False }
              }
            )
    in
    case objectChange of
        Op.NewPayload pieceList ->
            outputHelper pieceList Nothing

        Op.NewPayloadWithRef { payload, ref } ->
            outputHelper payload (Just ref)

        Op.RevertOp opIDToRevert ->
            ( inCounter
            , { prerequisiteOps = []
              , thisObjectOp = { reference = Just opIDToRevert, payload = "", reversion = True }
              }
            )


newObjectIDToPayload opID =
    "{" ++ OpID.toString opID ++ "}"


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

        Op.NewObject reducerID _ ->
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



-- getObjectLastSeenID : (Node) -> ReducerID -> ObjectID -> OpID
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


getObjectIfExists : Node -> List OpID.ObjectID -> Maybe Object
getObjectIfExists node objectIDs =
    --TODO handle multiple concurrent objects and merge
    let
        getObject id =
            Dict.get (OpID.toString id) node.objects

        foundObjects =
            List.filterMap getObject objectIDs
    in
    case foundObjects of
        [] ->
            Nothing

        [ solo ] ->
            Just solo

        first :: more ->
            Debug.todo "gotta merge multiple concurrently created objects"



-- PEER


type alias Peer =
    { identity : NodeID }


peerCodec : Codec String Peer
peerCodec =
    RS.record Peer
        |> RS.field .identity codec
        |> RS.finishRecord
