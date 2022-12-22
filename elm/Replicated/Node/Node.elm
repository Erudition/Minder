module Replicated.Node.Node exposing (..)

import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Parser.Advanced as Parser
import Replicated.Change as Change exposing (Change)
import Replicated.Identifier exposing (..)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op, ReducerID, create)
import Replicated.Op.OpID as OpID exposing (InCounter, ObjectID, ObjectIDString, OpID, OutCounter)
import Set exposing (Set)
import SmartTime.Moment exposing (Moment)
import Svg.Styled.Attributes exposing (accumulate)


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
    NodeID.generate { primus = 0, peer = 0, client = 0, session = 0 }


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
                    updateWithMultipleFrames (Debug.log "PARSED FRAMES:" <| parsedRonFrames) old

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
                            List.last (Log.log (Console.bgYellow "new objects") output.newObjects)

                        newNode =
                            { oldNode | root = newRoot }
                    in
                    { output | node = newNode }

        updateWithRootFinder frame oldInfo =
            assumeRootIfNeeded (update frame oldInfo)
    in
    List.foldl updateWithRootFinder old (Log.logSeparate (Console.green "newFrames ") (List.length newFrames |> String.fromInt) newFrames)


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
apply timeMaybe node (Change.Frame { normalizedChanges, description }) =
    let
        nextUnseenCounter =
            OpID.importCounter (node.highestSeenClock + 1)

        fallbackCounter =
            Maybe.withDefault nextUnseenCounter (Maybe.map OpID.firstCounterOfFrame timeMaybe)

        frameStartCounter =
            OpID.highestCounter fallbackCounter nextUnseenCounter

        ( finalCounter, listOfFinishedOpChunks ) =
            List.mapAccuml (oneChangeToOpChunks node Dict.empty) frameStartCounter normalizedChanges

        finishedOpChunks =
            List.concat listOfFinishedOpChunks

        finishedOps =
            List.concat finishedOpChunks

        updatedNode =
            updateWithClosedOps node finishedOps

        newObjectsCreated =
            creationOpsToObjectIDs finishedOps

        logApplyResults =
            Log.proseToString
                [ [ "Node.apply:" ]
                , [ "Created", Log.lengthWithBad 0 newObjectsCreated, "new objects:" ]
                , [ List.map OpID.toString newObjectsCreated |> String.join ", " ]
                , [ "Output Frame:" ]
                , [ Op.closedChunksToFrameText finishedOpChunks ]
                ]
    in
    -- Log.logMessageOnly logApplyResults
    { outputFrame = finishedOpChunks
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
type alias ObjectMapping =
    Dict ( Op.ReducerID, String ) ObjectID


{-| Passed to mapAccuml, so must have accumulator and change as last params
-}
oneChangeToOpChunks : Node -> ObjectMapping -> InCounter -> Change -> ( OutCounter, List Op.ClosedChunk )
oneChangeToOpChunks node inMapping inCounter change =
    case change of
        Change.Chunk (chunkDetails) ->
            let
                -- TODO let outputMapping escape to caller for deeply nested mappings
                ( ( outCounter, ( outputMapping, createdObjectMaybe ) ), generatedChunks ) =
                    chunkToOps node
                        ( inCounter, ( inMapping, Nothing ) )
                        chunkDetails


                logOps =
                    List.map (\op -> Op.closedOpToString Op.OpenOps op ++ "\n") (List.concat generatedChunks)
                        |> String.concat
            in
            ( outCounter, generatedChunks )


{-| Turns a change Chunk (same-object changes) into finalized ops.
in mapAccuml form
-}
chunkToOps : Node -> ( InCounter, ( ObjectMapping, Maybe ObjectID ) ) -> { target : Change.Pointer, objectChanges : List Change.ObjectChange, externalUpdates : List Change } -> ( ( OutCounter, ( ObjectMapping, Maybe ObjectID ) ), List Op.ClosedChunk )
chunkToOps node ( inCounter0, ( inMapping0, _ ) ) { target, objectChanges, externalUpdates } =
    let
        -- I'm pretty proud of this concotion, it took me DAYS to figure a concise way to get the prereqs all stamped BEFORE the object initialization op and the object changes (the prereqs are nested in the object that doesn't exist yet).
        ( postPrereqCounter1, processedChanges ) =
            List.mapAccuml (objectChangeToUnstampedOp node inMapping0) inCounter0 objectChanges

        allPrereqChunks =
            List.concatMap .prerequisiteChunks processedChanges

        postPrereqMapping1 =
            List.foldl Dict.union inMapping0 (List.map .mapping processedChanges)

        allUnstampedChunkOps =
            List.map .thisObjectOp processedChanges

        { reducerID, objectID, lastSeen, initOps, postInitCounter2 } =
            getOrInitObject node postPrereqCounter1 target

        postInitMapping2 =
            case target of
                Change.ExistingObjectPointer _ _ ->
                    -- we did not initialize anything
                    postPrereqMapping1

                Change.PlaceholderPointer _ pendingID _ ->
                    -- we initialized an object, add it to the mapping!
                    Dict.insert ( reducerID, Change.pendingIDToString pendingID ) objectID postPrereqMapping1


        stampChunkOps : ( InCounter, OpID ) -> UnstampedChunkOp -> ( ( OutCounter, OpID ), Op )
        stampChunkOps ( stampInCounter, opIDToReference ) givenUCO =
            let
                ( newID, stampOutCounter ) =
                    OpID.generate stampInCounter node.identity givenUCO.reversion

                stampedOp =
                    Op.create reducerID objectID newID (Op.OpReference <| Maybe.withDefault opIDToReference givenUCO.reference) givenUCO.payload
            in
            ( ( stampOutCounter, newID ), stampedOp )

        ( ( counterAfterObjectChanges3, newLastSeen ), objectChangeOps ) =
            List.mapAccuml stampChunkOps ( postInitCounter2, lastSeen ) allUnstampedChunkOps

        logOps prefix ops =
            String.concat (List.intersperse "\n" (List.map (\op -> prefix ++ ":\t" ++ Op.closedOpToString Op.ClosedOps op ++ "\t") ops))


        ( counterAfterExternalChanges4, generatedExternalChunksList ) =
            if List.isEmpty externalUpdates then
                -- TODO any good reason to capture the mapping output? (postExternalMapping3)
                Debug.log "no external changes" <| List.mapAccuml (oneChangeToOpChunks node postInitMapping2) counterAfterObjectChanges3 externalUpdates

            else
                Debug.log "yes external changes!" <| List.mapAccuml (oneChangeToOpChunks node postInitMapping2) counterAfterObjectChanges3 externalUpdates

        externalChunks =
            List.concat generatedExternalChunksList

        prereqLogMsg =
            case List.length allPrereqChunks of
                0 ->
                    "----\tchunk"

                n ->
                    "----\t^^last " ++ String.fromInt n ++ " chunks are prereqs for chunk"

        thisObjectChunk =
            [ Log.logMessageOnly (logOps "init" initOps) initOps ++ Log.logMessageOnly (logOps "change" objectChangeOps) objectChangeOps ]

        allOpsInDependencyOrder =
            Log.logMessageOnly prereqLogMsg allPrereqChunks
                ++ thisObjectChunk ++  externalChunks
    in
    ( ( counterAfterExternalChanges4, ( postInitMapping2, Just objectID ) )
    , allOpsInDependencyOrder
    )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Op.OpPayloadAtoms, reversion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> ObjectMapping -> InCounter -> Change.ObjectChange -> ( OutCounter, { prerequisiteChunks : List Op.ClosedChunk, thisObjectOp : UnstampedChunkOp, mapping : ObjectMapping } )
objectChangeToUnstampedOp node inMapping inCounter objectChange =
    let
        perPiece : Change.Atom -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List Op.OpPayloadAtom, mapping : ObjectMapping } -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List Op.OpPayloadAtom, mapping : ObjectMapping }
        perPiece piece accumulated =
            case piece of
                Change.JsonValueAtom value ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ Op.StringAtom (JE.encode 0 value) ]
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.RonAtom atom ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ atom ]
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.ReferenceObjectAtom reducerID pendingID ->
                    let
                        foundNewObjectID =
                            Dict.get ( reducerID, Change.pendingIDToString pendingID ) accumulated.mapping

                        atomInList =
                            case foundNewObjectID of
                                Just objectID ->
                                    [ Op.IDPointerAtom objectID ]

                                Nothing ->
                                    []
                    in
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ atomInList
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.QuoteNestedObject (Change.Chunk chunkDetails) ->
                    let
                        ( ( postPrereqCounter, ( newMapping, subObjectIDMaybe ) ), newPrereqChunks ) =
                            chunkToOps node
                                ( accumulated.counter, ( accumulated.mapping, Nothing ) )
                                chunkDetails

                        pointerPayload =
                            Maybe.map Op.IDPointerAtom subObjectIDMaybe

                        pointerPayloadAsList =
                            List.filterMap identity [ pointerPayload ]
                    in
                    { counter = postPrereqCounter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ newPrereqChunks
                    , piecesSoFar = accumulated.piecesSoFar ++ pointerPayloadAsList
                    , mapping = newMapping
                    }

                Change.NestedAtoms nestedChangeAtoms ->
                    let
                        outputAtoms =
                            List.foldl perPiece
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
                    List.foldl perPiece { counter = inCounter, piecesSoFar = [], prerequisiteChunks = [], mapping = inMapping } pieceList
            in
            ( counter
            , { prerequisiteChunks = prerequisiteChunks
              , thisObjectOp =
                    { reference = reference
                    , payload = piecesSoFar
                    , reversion = False
                    }
              , mapping = mapping
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
              , mapping = inMapping
              }
            )


{-| Internal helper used when converting Changes into final Ops, that must reference a real object or generate one.
-}
getOrInitObject :
    Node
    -> InCounter
    -> Change.Pointer
    ->
        { reducerID : ReducerID
        , objectID : ObjectID
        , lastSeen : OpID
        , initOps : List Op
        , postInitCounter2 : OutCounter
        }
getOrInitObject node inCounter targetObject =
    case targetObject of
        Change.ExistingObjectPointer objectID _ ->
            case AnyDict.filter (\_ op -> Op.object op == objectID) node.ops |> AnyDict.values of
                [] ->
                    Debug.todo ("object was supposed to pre-exist but couldn't find it: " ++ OpID.toString objectID)

                firstOp :: moreOps ->
                    { reducerID = Op.reducer firstOp
                    , objectID = objectID
                    , lastSeen = Op.id (Maybe.withDefault firstOp <| List.last moreOps)
                    , initOps = []
                    , postInitCounter2 = inCounter
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
            , postInitCounter2 = outCounter
            }


{-| Build an object out of the matching ops in the replica - or a placeholder.
-}
getObject : { node : Node, cutoff : Maybe Moment, foundIDs : List OpID.ObjectID, parent : Change.Pointer, reducer : ReducerID, position : Nonempty Change.SiblingIndex } -> Object
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
                    beforeCutoff opID && correctObject op

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



-- PEER


type alias Peer =
    { identity : NodeID }
