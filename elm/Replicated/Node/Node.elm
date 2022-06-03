module Replicated.Node.Node exposing (..)

import Dict exposing (Dict)
import Json.Encode as JE
import List.Extra as List
import Log
import Parser
import Replicated.Change as Change exposing (Change)
import Replicated.Identifier exposing (..)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op, ReducerID, create)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, ObjectIDString, OpID, OutCounter)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment exposing (Moment)


{-| Represents this one instance in the user's network of instances, with its own ID and log of ops.
-}
type alias Node =
    { identity : NodeID
    , objects : ObjectsByCreationDb
    , root : Maybe ObjectID
    , highestSeenClock : Int
    , peers : List Peer
    }


type alias InitArgs =
    { sameSession : Bool
    , storedNodeID : String
    }


{-| Start our program, persisting the identity we had last time.
-}
initFromSaved : InitArgs -> String -> Result InitError RonProcessedInfo
initFromSaved { sameSession, storedNodeID } inputRon =
    let
        lastIdentity =
            NodeID.fromString storedNodeID

        backfilledNode oldNodeID =
            updateWithRon { node = startNode oldNodeID, warnings = [] } inputRon

        newIdentity oldNodeID =
            if sameSession then
                oldNodeID

            else
                NodeID.bumpSessionID oldNodeID

        startNode oldNodeID =
            { identity = newIdentity oldNodeID
            , peers = []
            , objects = Dict.empty
            , root = Nothing
            , highestSeenClock = 0
            }
    in
    case lastIdentity of
        Just oldNodeID ->
            Ok (backfilledNode oldNodeID)

        Nothing ->
            Err DecodingOldIdentityProblem


type InitError
    = DecodingOldIdentityProblem


firstSessionEver : NodeID
firstSessionEver =
    NodeID.generate { primus = 0, peer = 0, client = 0, session = 0 }


testNode : Node
testNode =
    { identity = firstSessionEver
    , peers = []
    , objects = Dict.empty
    , root = Nothing
    , highestSeenClock = 0
    }


startNewNode : Maybe Moment -> Change -> { newNode : Node, startFrame : List Op.ClosedChunk }
startNewNode nowMaybe rootChange =
    let
        firstChangeFrame =
            Change.saveChanges "Node initialized" [ rootChange ]

        { updatedNode, created, outputFrame } =
            apply nowMaybe testNode firstChangeFrame

        newRoot =
            List.last created

        newNode =
            { updatedNode | root = newRoot }
    in
    { newNode = newNode, startFrame = outputFrame }


{-| Update a node with some Ops.
-}
updateWithClosedOps : Node -> List Op -> Node
updateWithClosedOps node newOps =
    let
        updatedNodeWithOp op n =
            case alreadyHaveThisOp op of
                Nothing ->
                    { node
                        | objects = updateObject n.objects op
                        , highestSeenClock = max n.highestSeenClock (OpID.toStamp (Op.id op)).clock
                    }

                Just _ ->
                    Debug.todo ("Already have op " ++ OpID.toString (Op.id op) ++ "as an object..")

        alreadyHaveThisOp op =
            Dict.get (OpID.toString (Op.id op)) node.objects
    in
    List.foldl updatedNodeWithOp node newOps


type OpImportWarning
    = ParseFail (List Parser.DeadEnd)
    | UnknownReference OpID
    | EmptyChunk


type alias RonProcessedInfo =
    { node : Node
    , warnings : List OpImportWarning
    }


updateWithRon : RonProcessedInfo -> String -> RonProcessedInfo
updateWithRon old inputRon =
    case Parser.run Op.ronParser inputRon of
        Ok parsedRonFrames ->
            updateWithMultipleFrames parsedRonFrames old

        Err parseDeadEnds ->
            { old | warnings = old.warnings ++ [ ParseFail parseDeadEnds ] }


{-| When we want to update with a bunch of frames at a time. Usually we only run through one at a time for responsive performance.
-}
updateWithMultipleFrames : List Op.OpenTextRonFrame -> RonProcessedInfo -> RonProcessedInfo
updateWithMultipleFrames newFrames old =
    List.foldl update old newFrames


{-| Update a node with some Ops in a Frame.
-}
update : Op.OpenTextRonFrame -> RonProcessedInfo -> RonProcessedInfo
update newFrame old =
    List.foldl updateNodeWithChunk old newFrame.chunks


{-| Add a single object Chunk to the node.
-}
updateNodeWithChunk : Op.FrameChunk -> RonProcessedInfo -> RonProcessedInfo
updateNodeWithChunk chunk old =
    let
        deduceChunkReducerAndObject =
            case List.head chunk.ops of
                Nothing ->
                    Err EmptyChunk

                Just firstOpenOp ->
                    case ( firstOpenOp.objectSpecified, firstOpenOp.reducerSpecified, firstOpenOp.reference ) of
                        ( Just explicitReducer, Just explicitObject, _ ) ->
                            -- closed ops - reducer and objectID are explicit
                            Ok ( explicitObject, explicitReducer )

                        ( _, _, Op.ReducerReference reducerID ) ->
                            -- It's a header / creation op, no need to lookup
                            Ok ( reducerID, firstOpenOp.opID )

                        ( _, _, Op.OpReference referencedOpID ) ->
                            lookupObject old.node referencedOpID

        closedOpListResult =
            case deduceChunkReducerAndObject of
                Ok ( foundReducerID, foundObjectID ) ->
                    Ok <| List.map (closeOp foundReducerID foundObjectID) chunk.ops

                Err newErrs ->
                    Err newErrs
    in
    case closedOpListResult of
        Ok closedOps ->
            let
                nodeWithRoot givenNode =
                    -- deduce root object, if needed
                    case givenNode.root of
                        Just _ ->
                            givenNode

                        Nothing ->
                            { givenNode | root = List.last <| creationOpsToObjectIDs closedOps }
            in
            { node = updateWithClosedOps (nodeWithRoot old.node) closedOps
            , warnings = old.warnings
            }

        Err newErr ->
            -- withhold the whole chunk
            { old | warnings = old.warnings ++ [ newErr ] }


closeOp : ReducerID -> ObjectID -> Op.OpenTextOp -> Op
closeOp deducedReducer deducedObject openOp =
    Op.Op <|
        { reducerID = openOp.reducerSpecified |> Maybe.withDefault deducedReducer
        , objectID = openOp.objectSpecified |> Maybe.withDefault deducedObject
        , operationID = openOp.opID
        , reference = openOp.reference
        , payload = openOp.payload
        }


{-| Find the opID referenced so we know what object an op belongs to.

First we compare against object creation IDs, then the stored "last seen" IDs, since it will usually be that. Finally, we check all other op IDs.

-}
lookupObject : Node -> OpID -> Result OpImportWarning ( ReducerID, ObjectID )
lookupObject node opIDToFind =
    case Dict.get (OpID.toString opIDToFind) node.objects of
        -- ^first, quickly check only the object IDs
        Just foundObject ->
            Ok ( foundObject.reducer, foundObject.creation )

        Nothing ->
            case List.head <| Dict.toList <| Dict.filter (\k v -> v.lastSeen == opIDToFind) node.objects of
                -- ^next, check only the last seen opIDs of each object
                Just ( _, foundObject ) ->
                    Ok ( foundObject.reducer, foundObject.creation )

                Nothing ->
                    -- ^ last resort, check all other ops
                    let
                        allOtherOpIDsLookup =
                            List.concatMap pairOpsWithObject (Dict.values node.objects)

                        pairOpsWithObject givenObject =
                            List.map (\opID -> ( opID, Object.getReducer givenObject, Object.getID givenObject )) (Object.allOtherOpIDs givenObject)

                        matchMaybe =
                            List.find (\( eachOpID, _, _ ) -> eachOpID == opIDToFind) allOtherOpIDsLookup
                    in
                    case matchMaybe of
                        Just ( _, foundObjectReducer, foundObjectID ) ->
                            Ok ( foundObjectReducer, foundObjectID )

                        Nothing ->
                            Err (UnknownReference opIDToFind)


{-| Save your changes!
Always supply the current time (`Just moment`).
(Else, new Ops will be timestamped as if they occurred mere milliseconds after the previous save, which can cause them to always be considered "older" than other ops that happened between.)
If the clock is set backwards or another node loses track of time, we will never go backwards in timestamps.
-}
apply : Maybe Moment -> Node -> Change.Frame -> { outputFrame : List Op.ClosedChunk, updatedNode : Node, created : List ObjectID }
apply timeMaybe node (Change.Frame { normalizedChanges, description }) =
    let
        nextUnseenCounter =
            OpID.importCounter (node.highestSeenClock + 1)

        fallbackCounter =
            Maybe.withDefault nextUnseenCounter (Maybe.map OpID.firstCounterOfFrame timeMaybe)

        frameStartCounter =
            OpID.highestCounter fallbackCounter nextUnseenCounter

        ( finalCounter, listOfFinishedOpChunks ) =
            List.mapAccuml (oneChangeToOpChunks node) frameStartCounter normalizedChanges

        finishedOpChunks =
            List.concat listOfFinishedOpChunks

        finishedOps =
            List.concat finishedOpChunks

        updatedNode =
            updateWithClosedOps node finishedOps
    in
    { outputFrame = finishedOpChunks
    , updatedNode = updatedNode
    , created = creationOpsToObjectIDs finishedOps
    }


creationOpsToObjectIDs : List Op -> List OpID
creationOpsToObjectIDs ops =
    let
        getCreationIDs op =
            case Op.pattern op of
                Op.CreationOp ->
                    Just (Op.object op)

                _ ->
                    Nothing
    in
    List.filterMap getCreationIDs ops



-- combineSameObjectChunks : List Change -> List Change
-- combineSameObjectChunks changes =
--     let
--         sameObjectID change1 change2 =
--             case ( change1, change2 ) of
--                 ( Op.Chunk chunk1, Op.Chunk chunk2 ) ->
--                     case ( chunk1.object, chunk2.object ) of
--                         ( Op.ExistingObjectPointer objectID1, Op.ExistingObjectPointer objectID2 ) ->
--                             objectID1 == objectID2
--
--                         ( Op.PlaceholderPointer reducerID1 pendingID1, Op.PlaceholderPointer reducerID2 pendingID2 ) ->
--                             pendingID1 == pendingID2 && reducerID1 == reducerID2
--
--                         _ ->
--                             False
--
--         sameObjectGroups =
--             List.gatherWith sameObjectID changes
--
--         combineGroupedItems group =
--             case group of
--                 ( singleItem, [] ) ->
--                     [ singleItem ]
--
--                 ( Op.Chunk { object, objectChanges }, rest ) ->
--                     [ Op.Chunk { object = object, objectChanges = objectChanges ++ List.concatMap extractChanges rest } ]
--
--         extractChanges (Op.Chunk { objectChanges }) =
--             objectChanges
--     in
--     List.concatMap combineGroupedItems sameObjectGroups


{-| Passed to mapAccuml, so must have accumulator and change as last params
-}
oneChangeToOpChunks : Node -> InCounter -> Change -> ( OutCounter, List Op.ClosedChunk )
oneChangeToOpChunks node inCounter change =
    case change of
        Change.Chunk chunkRecord ->
            let
                ( ( outCounter, createdobjectSpecified ), generatedChunks ) =
                    chunkToOps node ( inCounter, Nothing ) chunkRecord

                logOps =
                    List.map (\op -> Op.closedOpToString Op.OpenOps op ++ "\n") (List.concat generatedChunks)
                        |> String.concat
            in
            ( outCounter, generatedChunks )


{-| Turns a change Chunk (same-object changes) into finalized ops.
in mapAccuml form
-}
chunkToOps : Node -> ( InCounter, Maybe ObjectID ) -> { target : Change.Pointer, objectChanges : List Change.ObjectChange } -> ( ( OutCounter, Maybe ObjectID ), List Op.ClosedChunk )
chunkToOps node ( inCounter, _ ) { target, objectChanges } =
    let
        -- I'm pretty proud of this concotion, it took me DAYS to figure a concise way to get the prereqs all stamped BEFORE the object initialization op and the object changes (the prereqs are nested in the object that doesn't exist yet).
        ( postPrereqCounter, processedChanges ) =
            List.mapAccuml (objectChangeToUnstampedOp node) inCounter objectChanges

        allPrereqChunks =
            List.concatMap .prerequisiteChunks processedChanges

        allUnstampedChunkOps =
            List.map .thisObjectOp processedChanges

        { reducerID, objectID, lastSeen, initOps, postInitCounter } =
            getOrInitObject node postPrereqCounter target

        stampChunkOps : ( InCounter, OpID ) -> UnstampedChunkOp -> ( ( OutCounter, OpID ), Op )
        stampChunkOps ( stampInCounter, opIDToReference ) givenUCO =
            let
                ( newID, stampOutCounter ) =
                    OpID.generate stampInCounter node.identity givenUCO.reversion

                stampedOp =
                    Op.create reducerID objectID newID (Op.OpReference <| Maybe.withDefault opIDToReference givenUCO.reference) givenUCO.payload
            in
            ( ( stampOutCounter, newID ), stampedOp )

        ( ( counterAfterObjectChanges, newLastSeen ), objectChangeOps ) =
            List.mapAccuml stampChunkOps ( postInitCounter, lastSeen ) allUnstampedChunkOps

        logOps prefix ops =
            String.concat (List.intersperse "\n" (List.map (\op -> prefix ++ ":\t" ++ Op.closedOpToString Op.ClosedOps op ++ "\t") ops))

        prereqLogMsg =
            case List.length allPrereqChunks of
                0 ->
                    "----\tchunk"

                n ->
                    "----\t^^last " ++ String.fromInt n ++ " chunks are prereqs for chunk"

        allOpsInDependencyOrder =
            Log.logMessage prereqLogMsg allPrereqChunks
                ++ [ Log.logMessage (logOps "init" initOps) initOps
                        ++ Log.logMessage (logOps "change" objectChangeOps) objectChangeOps
                   ]
    in
    ( ( counterAfterObjectChanges, Just objectID )
    , allOpsInDependencyOrder
    )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Op.OpPayloadAtoms, reversion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> InCounter -> Change.ObjectChange -> ( OutCounter, { prerequisiteChunks : List Op.ClosedChunk, thisObjectOp : UnstampedChunkOp } )
objectChangeToUnstampedOp node inCounter objectChange =
    let
        perPiece : Change.Atom -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List JE.Value } -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List JE.Value }
        perPiece piece accumulated =
            case piece of
                Change.ValueAtom value ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ value ]
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    }

                Change.QuoteNestedObject (Change.Chunk chunkDetails) ->
                    let
                        ( ( postPrereqCounter, subObjectIDMaybe ), newPrereqChunks ) =
                            chunkToOps node ( accumulated.counter, Nothing ) chunkDetails

                        pointerPayload =
                            Maybe.map newObjectIDToPayload subObjectIDMaybe
                                |> Maybe.withDefault "ERROR no pointer, unreachable"
                    in
                    { counter = postPrereqCounter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ newPrereqChunks
                    , piecesSoFar = accumulated.piecesSoFar ++ [ JE.string pointerPayload ]
                    }

                Change.NestedAtoms nestedChangeAtoms ->
                    let
                        outputAtoms =
                            List.foldl perPiece
                                { counter = accumulated.counter
                                , piecesSoFar = []
                                , prerequisiteChunks = []
                                }
                                nestedChangeAtoms

                        finalNestedPayloadAsString =
                            JE.list identity outputAtoms.piecesSoFar
                    in
                    { counter = outputAtoms.counter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ outputAtoms.prerequisiteChunks
                    , piecesSoFar = accumulated.piecesSoFar ++ [ finalNestedPayloadAsString ]
                    }

        outputHelper pieceList reference =
            let
                { counter, prerequisiteChunks, piecesSoFar } =
                    List.foldl perPiece { counter = inCounter, piecesSoFar = [], prerequisiteChunks = [] } pieceList
            in
            ( counter
            , { prerequisiteChunks = prerequisiteChunks
              , thisObjectOp =
                    { reference = reference
                    , payload = piecesSoFar
                    , reversion = False
                    }
              }
            )
    in
    case objectChange of
        Change.NewPayload pieceList ->
            outputHelper pieceList Nothing

        Change.NewPayloadWithRef { payload, ref } ->
            outputHelper payload (Just ref)

        Change.RevertOp opIDToRevert ->
            ( inCounter
            , { prerequisiteChunks = []
              , thisObjectOp = { reference = Just opIDToRevert, payload = [], reversion = True }
              }
            )


newObjectIDToPayload opID =
    "❰" ++ OpID.toString opID ++ "❱"


getOrInitObject :
    Node
    -> InCounter
    -> Change.Pointer
    ->
        { reducerID : ReducerID
        , objectID : ObjectID
        , lastSeen : OpID
        , initOps : List Op
        , postInitCounter : OutCounter
        }
getOrInitObject node inCounter targetObject =
    case targetObject of
        Change.ExistingObjectPointer objectID ->
            case Dict.get (OpID.toString objectID) node.objects of
                Nothing ->
                    Debug.todo ("object was supposed to pre-exist but couldn't find it: " ++ OpID.toString objectID)

                Just foundObject ->
                    { reducerID = foundObject.reducer
                    , objectID = foundObject.creation
                    , lastSeen = foundObject.lastSeen
                    , initOps = []
                    , postInitCounter = inCounter
                    }

        Change.PlaceholderPointer reducerID _ _ ->
            let
                ( newID, outCounter ) =
                    OpID.generate inCounter node.identity False
            in
            { reducerID = reducerID
            , objectID = newID
            , lastSeen = newID
            , initOps = [ Op.initObject reducerID newID ]
            , postInitCounter = outCounter
            }



-- getObjectLastSeenID : (Node) -> ReducerID -> ObjectID -> OpID
-- getObjectLastSeenID node reducer objectID =
--     let
--         relevantObject =
--             Dict.get (OpID.toString objectID) node.objects
--     in
--     Maybe.withDefault objectID <| Maybe.map .lastSeen relevantObject


updateObject : ObjectsByCreationDb -> Op -> ObjectsByCreationDb
updateObject oBCDict newOp =
    let
        opIDStringToUpdate =
            OpID.toString (Op.object newOp)
    in
    -- we have an object objects. Do work inside it, and return it
    Dict.update opIDStringToUpdate (Object.applyOp newOp) oBCDict


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
        |> RS.field .identity NodeID.codec
        |> RS.finishRecord
