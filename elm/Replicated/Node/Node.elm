module Replicated.Node.Node exposing (..)

import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Parser.Advanced as Parser
import Replicated.Change as Change exposing (Change, ComplexAtom, PendingID, Pointer(..), pendingIDToString)
import Replicated.Identifier exposing (..)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op, ReducerID, create)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, ObjectIDString, OpID, OutCounter)
import Set exposing (Set)
import SmartTime.Moment exposing (Moment)


{-| Represents this one instance in the user's network of instances, with its own ID and log of ops.
-}
type alias Node =
    { identity : NodeID
    , ops : OpDb
    , root : Maybe ObjectID
    , highestSeenClock : Int
    , peers : List Peer
    }


type alias OpDb =
    AnyDict OpID.OpIDSortable OpID Op


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
            updateWithRon { node = startNode oldNodeID, warnings = [], newObjects = [] } inputRon

        newIdentity oldNodeID =
            if sameSession then
                oldNodeID

            else
                NodeID.bumpSessionID oldNodeID

        startNode oldNodeID =
            { identity = newIdentity oldNodeID
            , peers = []
            , ops = AnyDict.empty OpID.toSortablePrimitives
            , root = Nothing
            , highestSeenClock = 0
            }
    in
    case lastIdentity of
        Just oldNodeID ->
            let
                backfilledNodeAttempt =
                    backfilledNode oldNodeID
            in
            case backfilledNodeAttempt.warnings of
                [] ->
                    Ok backfilledNodeAttempt

                foundWarnings ->
                    Err (BadRon foundWarnings)

        Nothing ->
            Err DecodingOldIdentityProblem


type InitError
    = DecodingOldIdentityProblem
    | BadRon (List OpImportWarning)


firstSessionEver : NodeID
firstSessionEver =
    NodeID.generate { agent = 0, device = 0, client = 0, session = 0 }


testNode : Node
testNode =
    { identity = firstSessionEver
    , peers = []
    , ops = AnyDict.empty OpID.toSortablePrimitives
    , root = Nothing
    , highestSeenClock = 0
    }


startNewNode : Maybe Moment -> List Change -> { newNode : Node, startFrame : List Op.ClosedChunk }
startNewNode nowMaybe givenStartChanges =
    let
        startChanges =
            []

        firstChangeFrame =
            Change.saveChanges "Node initialized" (startChanges ++ givenStartChanges)

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
        updatedNodeWithOp newOp nodeToUpdate =
            case alreadyHaveThisOp newOp of
                Nothing ->
                    { node
                        | ops = AnyDict.insert (Op.id newOp) newOp nodeToUpdate.ops
                        , highestSeenClock = max nodeToUpdate.highestSeenClock (OpID.getClock (Op.id newOp))
                    }

                Just _ ->
                    Debug.todo ("Already have op " ++ OpID.toString (Op.id newOp) ++ "as an object..")

        alreadyHaveThisOp op =
            AnyDict.get (Op.id op) node.ops
    in
    List.foldl updatedNodeWithOp node newOps


type OpImportWarning
    = ParseFail (List (Parser.DeadEnd Op.Context Op.Problem))
    | UnknownReference OpID
    | EmptyChunk


type alias RonProcessedInfo =
    { node : Node
    , warnings : List OpImportWarning
    , newObjects : List ObjectID
    }


updateWithRon : RonProcessedInfo -> String -> RonProcessedInfo
updateWithRon old inputRon =
    case Parser.run Op.ronParser inputRon of
        Ok parsedRonFrames ->
            case parsedRonFrames of
                [] ->
                    --make sure we don't pretend to succeed when we didn't actually get anything
                    { old | warnings = old.warnings ++ [ EmptyChunk ] }

                foundFrames ->
                    updateWithMultipleFrames parsedRonFrames old

        Err parseDeadEnds ->
            { old | warnings = old.warnings ++ [ ParseFail parseDeadEnds ] }


{-| When we want to update with a bunch of frames at a time. Usually we only run through one at a time for responsive performance.
-}
updateWithMultipleFrames : List Op.OpenTextRonFrame -> RonProcessedInfo -> RonProcessedInfo
updateWithMultipleFrames newFrames old =
    let
        assumeRootIfNeeded output =
            -- deduce root object, if needed. should only run on first frame processed
            case output.node.root of
                Just _ ->
                    output

                Nothing ->
                    let
                        oldNode =
                            output.node

                        newRoot =
                            -- last object created in first frame should always be the root
                            List.last output.newObjects

                        newNode =
                            { oldNode | root = newRoot }
                    in
                    { output | node = newNode }

        updateWithRootFinder frame oldInfo =
            assumeRootIfNeeded (update frame oldInfo)
    in
    List.foldl updateWithRootFinder old newFrames


{-| Update a node with some Ops in a Frame.
-}
update : Op.OpenTextRonFrame -> RonProcessedInfo -> RonProcessedInfo
update newFrame old =
    case newFrame.chunks of
        [] ->
            { old | warnings = old.warnings ++ [ EmptyChunk ] }

        someChunks ->
            List.foldl updateNodeWithChunk old someChunks


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
            { node = updateWithClosedOps old.node closedOps
            , warnings = old.warnings
            , newObjects = old.newObjects ++ creationOpsToObjectIDs closedOps
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
    case AnyDict.get opIDToFind node.ops of
        -- will even find objects by middle ops (version references)
        Just foundOp ->
            Ok ( Op.reducer foundOp, Op.object foundOp )

        Nothing ->
            Err (UnknownReference opIDToFind)


{-| Quick way to see how many recognized objects are in the Node.
-}
objectCount : Node -> Int
objectCount node =
    List.map (Op.object >> OpID.toSortablePrimitives) (AnyDict.values node.ops)
        |> Set.fromList
        |> Set.size


{-| Quick way to see how many recognized objects are in the Node.
-}
objects : Node -> List ObjectID
objects node =
    List.map Op.object (AnyDict.values node.ops)
        |> List.uniqueBy OpID.toSortablePrimitives


{-| Save your changes!
Always supply the current time (`Just moment`).
(Else, new Ops will be timestamped as if they occurred mere milliseconds after the previous save, which can cause them to always be considered "older" than other ops that happened between.)
If the clock is set backwards or another node loses track of time, we will never go backwards in timestamps.
-}
apply : Maybe Moment -> Node -> Change.Frame -> { outputFrame : List Op.ClosedChunk, updatedNode : Node, created : List ObjectID }
apply timeMaybe node (Change.Frame { changes, description }) =
    let
        nextUnseenCounter =
            OpID.importCounter (node.highestSeenClock + 1)

        fallbackCounter =
            Maybe.withDefault nextUnseenCounter (Maybe.map OpID.firstCounterOfFrame timeMaybe)

        -- the frame shall start with this counter.
        frameStartCounter =
            OpID.highestCounter fallbackCounter nextUnseenCounter

        frameStartMapping : UpdatesSoFar
        frameStartMapping =
            { assignedIDs = AnyDict.empty Change.pendingIDToComparable
            , lastSeen = AnyDict.empty OpID.toString
            }

        changesToOps givenChanges inCounter inMapping alreadyDoneChunks inNode =
            let
                ( ( finalCounter, finalMapping ), generatedOutputsList ) =
                    List.mapAccuml (oneChangeToOpChunks inNode) ( inCounter, inMapping ) givenChanges

                finishedOpChunks =
                    alreadyDoneChunks ++ List.concat generatedOutputsList
            in
            finishedOpChunks

        allGeneratedChunks =
            changesToOps changes frameStartCounter frameStartMapping [] node

        allGeneratedOps =
            List.concat allGeneratedChunks

        updatedNode =
            let
                opsAdded =
                    updateWithClosedOps node allGeneratedOps
            in
            if node.root == Nothing then
                { opsAdded | root = List.last newObjectsCreated }

            else
                opsAdded

        newObjectsCreated =
            creationOpsToObjectIDs allGeneratedOps

        logApplyResults =
            Log.proseToString
                [ [ "Node.apply:" ]
                , [ "Created", Log.lengthWithBad 0 newObjectsCreated, "new objects:" ]
                , [ List.map OpID.toString newObjectsCreated |> String.join ", " ]
                , [ "Output Frame:" ]
                , [ Op.closedChunksToFrameText allGeneratedChunks ]
                ]
    in
    -- Log.logMessageOnly logApplyResults
    { outputFrame = allGeneratedChunks
    , updatedNode = updatedNode
    , created = newObjectsCreated
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


{-| Collects info on what ObjectIDs map back to what placeholder IDs from before they were initialized. In case we want to reference the new object same-frame.
Use with Change.pendingIDToString
-}
type alias UpdatesSoFar =
    { assignedIDs : AnyDict (List String) Change.PendingID ObjectID
    , lastSeen : AnyDict OpID.OpIDString ObjectID OpID
    }


{-| Passed to mapAccuml, so must have accumulator and change as last params
-}
oneChangeToOpChunks :
    Node
    -> ( InCounter, UpdatesSoFar ) -- the accumulator
    -> Change
    ->
        ( ( OutCounter, UpdatesSoFar ) -- the accumulator
        , List Op.ClosedChunk
        )
oneChangeToOpChunks node ( inCounter, inMapping ) (Change.Change changeSet) =
    let
        -- Step 1. Create pending objects
        ( postObjectsCreatedCounter, postObjectsCreatedMapping, objectsCreatedChunks ) =
            AnyDict.foldl
                singlePendingChunkToOps
                ( inCounter, inMapping, [] )
                changeSet.objectsToCreate

        singlePendingChunkToOps pendingID objectChanges ( counter, mapping, chunksSoFar ) =
            objectChangeChunkToOps node (PlaceholderPointer pendingID Nothing) objectChanges ( counter, mapping, chunksSoFar )

        -- Step 2. Change existing objects
        ( outCounter, outMapping, generatedChunks ) =
            AnyDict.foldl
                singleExistingChunkToOps
                ( postObjectsCreatedCounter, postObjectsCreatedMapping, objectsCreatedChunks )
                changeSet.existingObjectChanges

        singleExistingChunkToOps existingID objectChanges ( counter, mapping, chunksSoFar ) =
            objectChangeChunkToOps node (ExistingObjectPointer existingID) objectChanges ( counter, mapping, chunksSoFar )

        -- TODO Step 3. collect ops to repeat
        --
        -- logOps =
        --     List.map (\op -> Op.closedOpToString Op.OpenOps op ++ "\n") (List.concat generatedChunks)
        --         |> String.concat
    in
    ( ( outCounter, outMapping )
    , generatedChunks
    )


{-| Turns a change Chunk (same-object changes) into finalized ops.
-}
objectChangeChunkToOps :
    Node
    -> Pointer
    -> List Change.ObjectChange
    -> ( InCounter, UpdatesSoFar, List Op.ClosedChunk ) -- accumulator when used in foldl for batching
    -> ( OutCounter, UpdatesSoFar, List Op.ClosedChunk )
objectChangeChunkToOps node pointer objectChanges ( inCounter, inMapping, inChunks ) =
    let
        -- I'm pretty proud of this concotion, it took me DAYS to figure a concise way to get the prereqs all stamped BEFORE the object initialization op and the object changes (the prereqs are nested in the object that doesn't exist yet).
        --
        -- Step 1. Turn all objectChanges into Unstamped Ops, get nested prereq Ops stamped
        ( ( postUnstampedOpCounter, postUnstampedOpMapping ), subChangesOutput ) =
            List.mapAccuml (objectChangeToUnstampedOp node) ( inCounter, inMapping ) objectChanges

        ---------- collect prereq chunks of pre-stamped ops
        allPrereqChunks =
            List.concatMap .prerequisiteChunks subChangesOutput

        ---------- collect all the objectChanges turned unstamped-ops
        allUnstampedChunkOps =
            List.map .thisUnstampedOp subChangesOutput

        -- Step 2. Header Op: initialize the object, if it wasn't created already
        { objectID, reducerID, initOpMaybe, postInitCounter, postInitMapping } =
            case pointer of
                Change.ExistingObjectPointer { reducer, object } ->
                    -- Existed at start of frame, so no-op.
                    { objectID = object, reducerID = reducer, initOpMaybe = Nothing, postInitCounter = postUnstampedOpCounter, postInitMapping = postUnstampedOpMapping }

                Change.PlaceholderPointer pendingID _ ->
                    -- May need creating, check mapping first, then create
                    createPendingObject node postUnstampedOpCounter postUnstampedOpMapping pendingID

        --------- find out when this object was last seen, for stamping
        lastOpSeen =
            AnyDict.get objectID postUnstampedOpMapping.lastSeen
                |> Maybe.withDefault (getLastSeen node objectID)

        -- Step 3. Stamp all ops with an incremental ID
        ( ( counterAfterObjectChanges3, newLastOpSeen ), objectChangeOps ) =
            List.mapAccuml stampChunkOps ( postInitCounter, lastOpSeen ) allUnstampedChunkOps

        stampChunkOps : ( InCounter, OpID ) -> UnstampedChunkOp -> ( ( OutCounter, OpID ), Op )
        stampChunkOps ( stampInCounter, opIDToReference ) givenUCO =
            let
                ( newID, stampOutCounter ) =
                    OpID.generate stampInCounter node.identity givenUCO.reversion

                stampedOp =
                    Op.create reducerID objectID newID (Op.OpReference <| Maybe.withDefault opIDToReference givenUCO.reference) givenUCO.payload
            in
            ( ( stampOutCounter, newID ), stampedOp )

        -- ObjectsCreated Mapping: be sure to update the lastOpSeen for this object
        finalMapping =
            { postInitMapping | lastSeen = AnyDict.insert objectID newLastOpSeen postInitMapping.lastSeen }

        logOps prefix ops =
            String.concat (List.intersperse "\n" (List.map (\op -> prefix ++ ":\t" ++ Op.closedOpToString Op.ClosedOps op ++ "\t") ops))

        allOpsInDependencyOrder =
            allPrereqChunks ++ [ Maybe.Extra.toList initOpMaybe ++ objectChangeOps ]
    in
    ( counterAfterObjectChanges3
    , finalMapping
    , inChunks ++ allOpsInDependencyOrder
    )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Op.OpPayloadAtoms, reversion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> ( InCounter, UpdatesSoFar ) -> Change.ObjectChange -> ( ( OutCounter, UpdatesSoFar ), { prerequisiteChunks : List Op.ClosedChunk, thisUnstampedOp : UnstampedChunkOp } )
objectChangeToUnstampedOp node ( inCounter, inMapping ) objectChange =
    let
        perPiece :
            ComplexAtom
            -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List Op.OpPayloadAtom, mapping : UpdatesSoFar }
            -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List Op.OpPayloadAtom, mapping : UpdatesSoFar }
        perPiece piece accumulated =
            case piece of
                Change.FromPrimitiveAtom primitiveAtom ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ Change.primitiveAtomToRonAtom primitiveAtom ]
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.ExistingObjectReferenceAtom objectID ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ Op.IDPointerAtom objectID ]
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.PendingObjectReferenceAtom pendingID ->
                    let
                        foundNewObjectID =
                            AnyDict.get pendingID accumulated.mapping.assignedIDs

                        atomInList =
                            case foundNewObjectID of
                                Just objectID ->
                                    [ Op.IDPointerAtom objectID ]

                                Nothing ->
                                    Log.logSeparate
                                        (Console.bgRed <|
                                            "Node.objectChangeToUnstampedOp: Unknown PendingObjectReferenceAtom reference to a pending object: "
                                                ++ pendingIDToString pendingID
                                                ++ " when processing the objectChange "
                                                ++ Debug.toString objectChange
                                                ++ "with this in the mapping so far"
                                        )
                                        (AnyDict.toList accumulated.mapping.assignedIDs)
                                        [ Op.NakedStringAtom <| pendingIDToString pendingID ]
                    in
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ atomInList
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.QuoteNestedObject soloObject ->
                    let
                        ( ( postPrereqCounter, outMapping ), newPrereqChunks ) =
                            oneChangeToOpChunks node ( accumulated.counter, accumulated.mapping ) soloObject.change

                        pointerPayloadAsList =
                            case soloObject.toReference of
                                Change.ExistingObjectPointer existingID ->
                                    [ Op.IDPointerAtom existingID.object ]

                                Change.PlaceholderPointer pendingID _ ->
                                    case AnyDict.get pendingID outMapping.assignedIDs of
                                        Just outputObject ->
                                            [ Op.IDPointerAtom outputObject ]

                                        Nothing ->
                                            Log.crashInDev ("QuoteNestedObject not sure what the ObjectID was of this nested object. " ++ Log.dump soloObject.change) []
                    in
                    { counter = postPrereqCounter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ newPrereqChunks
                    , piecesSoFar = accumulated.piecesSoFar ++ pointerPayloadAsList
                    , mapping = outMapping
                    }

                Change.NestedAtoms nestedChangeAtoms ->
                    let
                        outputAtoms =
                            Nonempty.foldl perPiece
                                { counter = accumulated.counter
                                , piecesSoFar = []
                                , prerequisiteChunks = []
                                , mapping = accumulated.mapping
                                }
                                nestedChangeAtoms

                        finalNestedPayloadAsString =
                            outputAtoms.piecesSoFar
                    in
                    { counter = outputAtoms.counter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ outputAtoms.prerequisiteChunks

                    -- TODO below may get multi-atom values confused with multiple values
                    , piecesSoFar = accumulated.piecesSoFar ++ finalNestedPayloadAsString
                    , mapping = accumulated.mapping
                    }

        outputHelper pieceList reference =
            let
                { counter, prerequisiteChunks, piecesSoFar, mapping } =
                    Nonempty.foldl perPiece { counter = inCounter, piecesSoFar = [], prerequisiteChunks = [], mapping = inMapping } pieceList
            in
            ( ( counter, mapping )
            , { prerequisiteChunks = prerequisiteChunks
              , thisUnstampedOp =
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
            ( ( inCounter, inMapping )
            , { prerequisiteChunks = []
              , thisUnstampedOp = { reference = Just opIDToRevert, payload = [], reversion = True }
              }
            )


{-| Generates a single Op: an object creation header, but only if this object wasn't already created in this frame.
-}
createPendingObject :
    Node
    -> InCounter
    -> UpdatesSoFar
    -> PendingID
    ->
        { objectID : ObjectID
        , reducerID : Op.ReducerID
        , initOpMaybe : Maybe Op
        , postInitCounter : OutCounter
        , postInitMapping : UpdatesSoFar
        }
createPendingObject node inCounter inMapping pendingID =
    case AnyDict.get pendingID inMapping.assignedIDs of
        Just assigned ->
            -- oops, we created this object already
            { objectID = assigned
            , reducerID = pendingID.reducer
            , initOpMaybe = Nothing
            , postInitCounter = inCounter
            , postInitMapping = inMapping
            }

        Nothing ->
            let
                ( newID, outCounter ) =
                    OpID.generate inCounter node.identity False
            in
            { objectID = newID
            , reducerID = pendingID.reducer
            , initOpMaybe = Just <| Op.initObject pendingID.reducer newID
            , postInitCounter = outCounter
            , postInitMapping = { inMapping | assignedIDs = AnyDict.insert pendingID newID inMapping.assignedIDs }
            }


{-| Build an object out of the matching ops in the replica - or a placeholder.
-}
getObject :
    { node : Node
    , cutoff : Maybe Moment
    , foundIDs : List OpID.ObjectID
    , parent : Change.Parent
    , reducer : ReducerID
    , position : Nonempty Change.SiblingIndex
    }
    -> Object
getObject { node, cutoff, foundIDs, parent, reducer, position } =
    let
        uninitializedObject =
            Object.Unsaved { reducer = reducer, parent = parent, position = position }
    in
    case foundIDs of
        [] ->
            uninitializedObject

        foundSome ->
            let
                matchingOp opID op =
                    case ( beforeCutoff opID && correctObject op, Op.reducer op == reducer ) of
                        ( False, _ ) ->
                            False

                        ( True, True ) ->
                            True

                        ( True, False ) ->
                            Log.crashInDev
                                ("Node.getObject: I was told [" ++ String.join ", " (List.map OpID.toString foundIDs) ++ "] were aliases to look for when building " ++ Log.dump reducer ++ " at location " ++ String.join " " (Nonempty.toList position) ++ ". Problem is, " ++ OpID.toString opID ++ " is actually a " ++ Log.dump (Op.reducer op))
                                False

                beforeCutoff opID =
                    case cutoff of
                        Nothing ->
                            True

                        Just cutoffMoment ->
                            SmartTime.Moment.toSmartInt cutoffMoment > OpID.toInt opID

                correctObject op =
                    List.member (Op.object op) foundSome

                findMatchingOps =
                    AnyDict.filter matchingOp node.ops
            in
            case Object.buildSavedObject findMatchingOps of
                ( Just finalObject, [] ) ->
                    Object.Saved finalObject

                ( Just finalObject, warnings ) ->
                    Log.crashInDev "object builder produced warnings!" <| Object.Saved finalObject

                ( Nothing, warnings ) ->
                    Log.crashInDevProse
                        [ [ "Node.getObject:" ]
                        , [ "object builder was tasked with building an object that should exist but found nothing. The existing object(s) supposedly had ID(s):" ]
                        , [ Log.dump foundSome ]
                        , [ "Matched", Log.int (AnyDict.size findMatchingOps), "out of", Log.int (AnyDict.size node.ops), "total ops (correct object and pre-cutoff)." ]
                        , [ "The builder produced these warnings:" ]
                        , [ Log.dump warnings ]
                        ]
                        uninitializedObject


{-| Get the last seen op from a given object.
It does not have to be stamped by the local replica.
Usually used to reference the object by new ops.
-}
getLastSeen : Node -> ObjectID -> OpID
getLastSeen node objectIDToFind =
    let
        correctObject op =
            if Op.object op == objectIDToFind then
                Just (Op.id op)

            else
                Nothing

        findMatchingOps =
            List.filterMap correctObject (AnyDict.values node.ops)
    in
    List.last findMatchingOps
        |> Maybe.withDefault objectIDToFind



-- PEER


type alias Peer =
    { identity : NodeID }
