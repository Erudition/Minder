module Replicated.Node.Node exposing (..)

import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Element.Region exposing (description)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Parser.Advanced as Parser
import Replicated.Change as Change exposing (Change, ChangeSet(..), ComplexAtom, Pointer(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Change.PendingID as PendingID exposing (PendingID)
import Replicated.Change.Primitive as ChangePrimitive
import Replicated.Collection as Collection exposing (Collection)
import Replicated.Identifier exposing (..)
import Replicated.Node.AncestorDb as AncestorDb exposing (AncestorDb)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Op.Atom as Atom exposing (Atom)
import Replicated.Op.Db as OpDb exposing (OpDb)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, ObjectIDString, OpID, OpIDSortable, OutCounter)
import Replicated.Op.ObjectHeader as ObjectHeader exposing (ObjectHeader)
import Replicated.Op.Op as Op exposing (Op, Reference(..))
import Replicated.Op.Payload as Payload exposing (Payload)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import Replicated.Op.RonOutput as RonOutput
import Replicated.Op.RonParser as RonParser exposing (FrameChunk, OpenOp, OpenTextRonFrame, RonParser)
import Set exposing (Set)
import Set.Any as AnySet exposing (AnySet)
import SmartTime.Moment exposing (Moment)


{-| Represents this one instance in the user's network of instances, with its own ID and log of ops.
-}
type alias Node =
    { identity : NodeID
    , ops : OpDb
    , ancestors : AncestorDb
    , root : Maybe ObjectHeader
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
            updateWithRon { node = startNode oldNodeID, warnings = [], newObjects = [] } inputRon

        newIdentity oldNodeID =
            if sameSession then
                oldNodeID

            else
                NodeID.bumpSessionID oldNodeID

        startNode oldNodeID =
            { identity = newIdentity oldNodeID
            , peers = []
            , ops = OpDb.empty
            , ancestors = AncestorDb.empty
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
    , ops = OpDb.empty
    , ancestors = AncestorDb.empty
    , root = Nothing
    , highestSeenClock = 0
    }


startNewNode : Maybe Moment -> Bool -> List Change -> { newNode : Node, startFrame : List Op.ClosedChunk }
startNewNode nowMaybe testMode givenStartChanges =
    let
        startChanges =
            []

        firstChangeFrame =
            Change.saveUserChanges "Node initialized" (givenStartChanges ++ startChanges)

        startNode =
            { identity = firstSessionEver
            , peers = []
            , ops = OpDb.empty
            , ancestors = AncestorDb.empty
            , root = Nothing
            , highestSeenClock = 0
            }

        { updatedNode, created, outputFrame } =
            applyChanges nowMaybe testMode startNode firstChangeFrame
    in
    { newNode = updatedNode, startFrame = outputFrame }


{-| Update a node with some Ops. All changes, internal and external, pass through this function.
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

                        -- , recentlyTouchedObjects = AnySet.insert (Op.object newOp) nodeToUpdate.recentlyTouchedObjects
                    }

                Just _ ->
                    -- TODO error if op is different despite same ID
                    Debug.log ("Already have op " ++ OpID.toString (Op.id newOp) ++ "as an object..")
                        { node
                            | ops = AnyDict.insert (Op.id newOp) newOp nodeToUpdate.ops
                            , highestSeenClock = max nodeToUpdate.highestSeenClock (OpID.getClock (Op.id newOp))
                        }

        alreadyHaveThisOp op =
            AnyDict.get (Op.id op) node.ops
    in
    List.foldl updatedNodeWithOp node newOps


type OpImportWarning
    = ParseFail (List RonParser.DeadEnd)
    | UnknownReference OpID
    | EmptyChunk
    | NoSuccessfulOps String


opImportWarningToString : OpImportWarning -> String
opImportWarningToString opImportWarning =
    case opImportWarning of
        ParseFail deadEndList ->
            List.map RonParser.deadEndToString deadEndList
                |> String.concat

        UnknownReference opID ->
            "Unknown reference, OpID: " ++ OpID.toString opID

        EmptyChunk ->
            "Got an empty chunk"

        NoSuccessfulOps frame ->
            "Did not successfully import any ops from this frame: " ++ frame


type alias RonProcessedInfo =
    { node : Node
    , warnings : List OpImportWarning
    , newObjects : List ObjectHeader
    }


updateWithRon : RonProcessedInfo -> String -> RonProcessedInfo
updateWithRon old inputRon =
    case Parser.run RonParser.ronParser inputRon of
        Ok parsedRonFrames ->
            case parsedRonFrames of
                [] ->
                    Log.logMessageOnly ("parsed 0 frames from input ron: '" ++ inputRon ++ "'")
                        old

                foundFrames ->
                    let
                        output =
                            updateWithMultipleFrames parsedRonFrames old
                    in
                    if True then
                        -- AnyDict.size old.node.ops == AnyDict.size output.node.ops
                        output

                    else
                        { output | warnings = output.warnings ++ [ NoSuccessfulOps inputRon ] }

        Err parseDeadEnds ->
            { old | warnings = old.warnings ++ [ ParseFail parseDeadEnds ] }


{-| When we want to update with a bunch of frames at a time. Usually we only run through one at a time for responsive performance.
-}
updateWithMultipleFrames : List OpenTextRonFrame -> RonProcessedInfo -> RonProcessedInfo
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
update : OpenTextRonFrame -> RonProcessedInfo -> RonProcessedInfo
update newFrame old =
    case newFrame.chunks of
        [] ->
            Log.log "Node.update: got an OpenTextRonFrame with no Chunks!"
                { old | warnings = old.warnings ++ [ EmptyChunk ] }

        someChunks ->
            List.foldl updateNodeWithChunk old someChunks


{-| Add a single object Chunk to the node.
-}
updateNodeWithChunk : FrameChunk -> RonProcessedInfo -> RonProcessedInfo
updateNodeWithChunk chunk old =
    let
        deduceChunkReducerAndObject : Result OpImportWarning ObjectHeader
        deduceChunkReducerAndObject =
            case chunk.ops of
                [] ->
                    Err EmptyChunk

                firstOpenOp :: moreOpenOps ->
                    case ( firstOpenOp.objectSpecified, firstOpenOp.reducerSpecified, firstOpenOp.reference ) of
                        ( Just explicitObjectID, Just explicitReducer, _ ) ->
                            -- closed ops - reducer and objectID are explicit
                            case lookupObject old.node explicitObjectID of
                                Just foundObject ->
                                    Ok foundObject

                                Nothing ->
                                    Err (UnknownReference explicitObjectID)

                        ( _, _, RonParser.UnresolvedReducerReference reducerID ) ->
                            -- It's a header / creation op
                            case lookupObject old.node firstOpenOp.opID of
                                Just foundObject ->
                                    Ok foundObject

                                Nothing ->
                                    Err (UnknownReference firstOpenOp.opID)

                        ( _, _, RonParser.UnresolvedOpReference referencedOpID ) ->
                            case lookupObject old.node referencedOpID of
                                Just foundBoth ->
                                    Ok foundBoth

                                Nothing ->
                                    Err (UnknownReference referencedOpID)

        resolveReference : OpenOp -> Maybe Reference
        resolveReference openTextOp =
            case openTextOp.reference of
                RonParser.UnresolvedReducerReference reducer ->
                    Just (ReducerReference reducer)

                RonParser.UnresolvedOpReference opIDToFind ->
                    AnyDict.get opIDToFind old.node.ops
                        |> Maybe.map OpReference

        closeOp : ObjectHeader -> OpenOp -> Maybe Op
        closeOp deducedObject openOp =
            case resolveReference openOp of
                Just foundRef ->
                    case
                        Op.create
                            (openOp.reducerSpecified |> Maybe.withDefault deducedObject.reducer)
                            (openOp.objectSpecified |> Maybe.withDefault deducedObject.operationID)
                            openOp.opID
                            foundRef
                            openOp.payload
                    of
                        Ok good ->
                            Just good

                        Err bad ->
                            Nothing

                Nothing ->
                    Nothing

        closedOpListResult =
            case deduceChunkReducerAndObject of
                Ok foundObject ->
                    -- TODO propogate errors instead of Nothing
                    Ok <| List.filterMap (closeOp foundObject) chunk.ops

                Err newErrs ->
                    Err newErrs
    in
    case closedOpListResult of
        Ok closedOps ->
            { node = updateWithClosedOps old.node closedOps
            , warnings = old.warnings
            , newObjects = old.newObjects ++ filterObjectHeaders closedOps
            }

        Err newErr ->
            -- withhold the whole chunk
            { old | warnings = old.warnings ++ [ newErr ] }


{-| Find the opID referenced so we know what object an op belongs to.

First we compare against object creation IDs, then the stored "last seen" IDs, since it will usually be that. Finally, we check all other op IDs.

-}
lookupObject : Node -> OpID -> Maybe ObjectHeader
lookupObject node opIDToFind =
    case AnyDict.get opIDToFind node.ops of
        -- will even find objects by middle ops (version references)
        Just foundOp ->
            Just (Op.objectHeader foundOp)

        Nothing ->
            Nothing


{-| Quick way to see how many recognized objects are in the Node.
-}
objectCount : Node -> Int
objectCount node =
    List.map (Op.objectID >> OpID.toSortablePrimitives) (AnyDict.values node.ops)
        |> Set.fromList
        |> Set.size


{-| Quick way to see how many recognized objects are in the Node.
-}
objects : Node -> List ObjectID
objects node =
    List.map Op.objectID (AnyDict.values node.ops)
        |> List.uniqueBy OpID.toSortablePrimitives


{-| Save your changes!
Always supply the current time (`Just moment`).
(Else, new Ops will be timestamped as if they occurred mere milliseconds after the previous save, which can cause them to always be considered "older" than other ops that happened between.)
If the clock is set backwards or another node loses track of time, we will never go backwards in timestamps.
-}
applyChanges :
    Maybe Moment
    -> Bool
    -> Node
    -> Change.Frame desc
    ->
        { outputFrame : List Op.ClosedChunk
        , updatedNode : Node
        , created : List ObjectHeader
        }
applyChanges timeMaybe testMode node (Change.Frame { changes, description }) =
    let
        nextUnseenCounter =
            OpID.importCounter (node.highestSeenClock + 1)

        fallbackCounter =
            Maybe.withDefault nextUnseenCounter (Maybe.map OpID.firstCounterOfFrame timeMaybe)

        -- the frame shall start with this counter.
        frameStartCounter =
            OpID.highestCounter fallbackCounter nextUnseenCounter

        -- create the object passed in -header only!!
        frameStartMapping : UpdatesSoFar
        frameStartMapping =
            { assignedIDs = AnyDict.empty PendingID.toComparable
            , lastSeen = AnyDict.empty OpID.toString
            , delayed = []
            }

        -- STEP 1. Process this ChangeSet
        ( ( step1OutCounter, step1OutMapping ), step1OutChunks ) =
            oneChangeSetToOpChunks node ( frameStartCounter, frameStartMapping ) changes

        delayedChangeSets =
            let
                asChangeSetList =
                    Change.delayedChangesToSets step1OutMapping.delayed
                        -- TODO why must we reverse
                        |> List.reverse
            in
            asChangeSetList

        -- STEP 2. Process delayed changes
        ( ( step2OutCounter, step2OutMapping ), step2OutChunks ) =
            List.mapAccuml (oneChangeSetToOpChunks node) ( step1OutCounter, { step1OutMapping | delayed = [] } ) delayedChangeSets

        -- -- Step 3. Process User Undo/Redo ops
        -- ( step3OutCounter, _) =
        --     List.mapAccuml createReversionOp step2OutCounter reversions
        outChunks =
            step1OutChunks ++ List.concat step2OutChunks

        allGeneratedOps =
            List.concat outChunks

        updatedNode =
            updateWithClosedOps node allGeneratedOps

        newObjectsCreated =
            filterObjectHeaders allGeneratedOps

        -- For Tests : use last output as root object
        finalNode =
            if updatedNode.root == Nothing && testMode then
                { updatedNode | root = List.last newObjectsCreated }

            else
                updatedNode

        logApplyResults =
            Log.proseToString
                [ [ "Node.apply:" ]
                , [ "Main ChangeSet:" ]
                , [ Change.changeSetDebug 0 changes ]
                , [ "Delayed ChangeSets (", String.fromInt (List.length delayedChangeSets), "):" ]
                , [ List.map (Change.changeSetDebug 0) delayedChangeSets |> String.join "\n" ]
                , [ "Created", Log.lengthWithBad 0 newObjectsCreated, "new objects:" ]
                , [ List.map ObjectHeader.idString newObjectsCreated |> String.join ", " ]
                , [ "Output Frame:" ]
                , [ RonOutput.closedChunksToFrameText step1OutChunks ]
                , [ "Delayed Updates:" ]
                , [ RonOutput.closedChunksToFrameText (List.concat step2OutChunks) ]
                ]
    in
    Log.logMessageOnly logApplyResults
        { outputFrame = outChunks
        , updatedNode = finalNode
        , created = newObjectsCreated
        }


filterObjectHeaders : List Op -> List ObjectHeader
filterObjectHeaders ops =
    let
        getCreationIDs op =
            case op of
                Op.CreationOp header ->
                    Just header

                _ ->
                    Nothing
    in
    List.filterMap getCreationIDs ops


{-| Get the IDs of the ops that are reversible
-}
getReversibleOps : List Op -> List Op
getReversibleOps ops =
    let
        getCreationIDs op =
            case op of
                Op.NormalOp _ ->
                    Just op

                Op.DeletionOp _ ->
                    Just op

                Op.UnDeletionOp _ ->
                    Just op

                Op.CreationOp _ ->
                    Nothing
    in
    List.filterMap getCreationIDs ops



-- {-| Find all Ops that use the given Op as a reference.
-- TODO just index the OpDb by reference
-- -}
-- findAllReferencesToOp : Node -> OpID -> List Op
-- findAllReferencesToOp node opID =
--     AnyDict.filter (\_ op -> Op.opIDFromReference (Op.reference op) == Just opID) node.ops
--         |> AnyDict.values
-- {-| Given a list of OpIDs representing the original change, find the Ops of their latest reversion.
-- TODO: once OpDb is indexed by object and reference, eliminate the recursive search.
-- -}
-- findFinalOpsToRevert : Node -> Change.UndoData -> List Op
-- findFinalOpsToRevert node opIDsToRevert =
--     let
--         findFinalReversionOp earlierOpID =
--             let
--                 earlierOpMaybe =
--                     -- TODO ideally we don't have to fetch the op itself for this.
--                     AnyDict.get earlierOpID node.ops
--                 earlierOpPatternMaybe =
--                     Maybe.map Op.pattern earlierOpMaybe
--                 -- if the op is normal, the next reversion will be a deletion op.
--                 -- if the op is a deletion already, the next reversion (undeletion) will look like a normal opID.
--                 opPatternToLookFor =
--                     case earlierOpPatternMaybe of
--                         Just Op.DeletionOp ->
--                             Op.UnDeletionOp
--                         Just Op.UnDeletionOp ->
--                             Op.DeletionOp
--                         _ ->
--                             Op.NormalOp
--                 allOpsReferringToEarlierOp =
--                     findAllReferencesToOp node earlierOpID
--             in
--             case List.filter (\op -> Op.pattern op == opPatternToLookFor) allOpsReferringToEarlierOp of
--                 [] ->
--                     -- Looks like this op was never reverted, so it's the final op
--                     earlierOpMaybe
--                 [ foundReversionOp ] ->
--                     -- the earlier op has been reverted, repeat the process with the newfound reversion
--                     findFinalReversionOp (Op.id foundReversionOp)
--                 firstOpFound :: moreFound ->
--                     Log.crashInDev "When trying to find reversions of an op, I found multiple..." (Just firstOpFound)
--     in
--     List.filterMap findFinalReversionOp (AnySet.toList opIDsToRevert)


{-| Collects info on what ObjectIDs map back to what placeholder IDs from before they were initialized. In case we want to reference the new object same-frame.
Use with Change.pendingIDToString
-}
type alias UpdatesSoFar =
    { assignedIDs : AnyDict (List String) PendingID ObjectID
    , lastSeen : AnyDict OpID.OpIDString ObjectID OpID
    , delayed : List Change.DelayedChange
    }


keepChangeSetIfNonempty changeSetMaybe =
    Maybe.Extra.filter (not << Change.isEmptyChangeSet) changeSetMaybe


{-| Passed to mapAccuml, so must have accumulator and change as last params
-}
oneChangeSetToOpChunks :
    Node
    -> ( InCounter, UpdatesSoFar ) -- the accumulator
    -> ChangeSet
    ->
        ( ( OutCounter, UpdatesSoFar ) -- the accumulator
        , List Op.ClosedChunk
        )
oneChangeSetToOpChunks node ( inCounter, inMapping ) (ChangeSet changeSet) =
    let
        -- Step 1. Create pending objects
        ( postObjectsCreatedCounter, postObjectsCreatedMapping, objectsCreatedChunks ) =
            AnyDict.foldl
                singlePendingChunkToOps
                ( inCounter, inMapping, [] )
                changeSet.objectsToCreate

        singlePendingChunkToOps pendingID objectChanges ( counter, mapping, chunksSoFar ) =
            let
                asPointer =
                    PlaceholderPointer pendingID []
            in
            objectChangeChunkToOps node asPointer objectChanges ( counter, mapping, chunksSoFar )

        -- Step 2. Change existing objects
        ( outCounter, postExistingMapping, generatedChunks ) =
            AnyDict.foldl
                singleExistingChunkToOps
                ( postObjectsCreatedCounter, postObjectsCreatedMapping, objectsCreatedChunks )
                changeSet.existingObjectChanges

        singleExistingChunkToOps existingID objectChanges ( counter, mapping, chunksSoFar ) =
            let
                asPointer =
                    ExistingObjectPointer existingID
            in
            objectChangeChunkToOps node asPointer objectChanges ( counter, mapping, chunksSoFar )

        outMapping =
            { postExistingMapping | delayed = postExistingMapping.delayed ++ changeSet.delayed }

        -- logOps =
        --     List.map (\op -> Op.closedOpToString Op.OpenOps op ++ "\n") (List.concat generatedChunks)
        --         |> String.concat
    in
    ( ( outCounter, outMapping )
    , generatedChunks
    )


processDelayedInMapping : Change.Pointer -> List Change.ObjectChange -> UpdatesSoFar -> { safeToDoNow : List Change.ObjectChange, processedMapping : UpdatesSoFar }
processDelayedInMapping inPointer inObjectChanges inMapping =
    let
        { doNow, keep } =
            List.foldl processDelayedChange
                { doNow = [], keep = [] }
                inMapping.delayed

        processDelayedChange : Change.DelayedChange -> { doNow : List Change.ObjectChange, keep : List Change.DelayedChange } -> { doNow : List Change.ObjectChange, keep : List Change.DelayedChange }
        processDelayedChange (( delayedPointer, delayedObjectChange ) as delayedChange) acc =
            if Change.equalPointers inPointer delayedPointer then
                let
                    foundSame =
                        List.find (Change.redundantObjectChange delayedObjectChange) inObjectChanges
                in
                if Maybe.Extra.isJust foundSame || List.member delayedChange acc.keep then
                    -- we're already doing this now, or did previously, remove it from delayed
                    { doNow = acc.doNow, keep = acc.keep }

                else if canDoNow delayedObjectChange then
                    -- we made sure this has no unresolved refs, do it now!
                    Log.logSeparate "Doing a delayed change early, nice!" delayedObjectChange { doNow = acc.doNow ++ [ delayedObjectChange ], keep = acc.keep }

                else
                    --not ready to do now, keep delayed
                    Log.logSeparate "Not ready to do this objectChange" delayedChange { doNow = acc.doNow, keep = acc.keep ++ [ delayedChange ] }

            else
                -- irrelevant to this object, move along
                { doNow = acc.doNow, keep = acc.keep ++ [ delayedChange ] }

        canDoNow delayedObjectChange =
            let
                objectChangeAsPayload =
                    case delayedObjectChange of
                        Change.NewPayload complexPayload ->
                            Nonempty.toList complexPayload

                        Change.NewPayloadWithRef { payload } ->
                            Nonempty.toList payload

                        Change.RevertOp _ ->
                            []

                checkComplexAtom complexAtom =
                    -- check eack atom for unresolvable references
                    case complexAtom of
                        Change.PendingObjectReferenceAtom pendingID ->
                            -- see if it's already been assigned
                            AnyDict.member pendingID inMapping.assignedIDs

                        Change.QuoteNestedObject _ ->
                            Log.crashInDev "ew! there was a QuoteNestedObject in a delayed object change somehow?" False

                        Change.NestedAtoms complexPayload ->
                            List.all checkComplexAtom (Nonempty.toList complexPayload)

                        _ ->
                            True
            in
            List.all checkComplexAtom objectChangeAsPayload
    in
    { safeToDoNow = doNow, processedMapping = { inMapping | delayed = keep } }


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
        -- Step 1a. Turn all objectChanges into Unstamped Ops, get nested prereq Ops stamped
        ( ( postUnstampedOpCounter1a, postUnstampedOpMapping1a ), subChanges1aOutput ) =
            List.mapAccuml (objectChangeToUnstampedOp node) ( inCounter, inMapping ) objectChanges

        { safeToDoNow, processedMapping } =
            processDelayedInMapping pointer objectChanges postUnstampedOpMapping1a

        -- -- Step 1b. Do the same for delayed changes that we can do now instead - if any
        ( ( postUnstampedOpCounter1b, postUnstampedOpMapping1b ), subChanges1bOutput ) =
            List.mapAccuml (objectChangeToUnstampedOp node) ( postUnstampedOpCounter1a, processedMapping ) safeToDoNow

        ---------- collect prereq chunks of pre-stamped ops
        allPrereqChunks =
            List.concatMap .prerequisiteChunks subChanges1aOutput ++ List.concatMap .prerequisiteChunks subChanges1bOutput

        ---------- collect all the objectChanges turned unstamped-ops
        allUnstampedChunkOps =
            List.map .thisUnstampedOp subChanges1aOutput ++ List.map .thisUnstampedOp subChanges1bOutput

        -- Step 2. Header Op: initialize the object, if it wasn't created already
        { objectID, reducerID, initOps, postInitCounter, postInitMapping } =
            case pointer of
                Change.ExistingObjectPointer { reducer, operationID } ->
                    -- Existed at start of frame, so no-op.
                    { objectID = operationID, reducerID = reducer, initOps = [], postInitCounter = postUnstampedOpCounter1b, postInitMapping = postUnstampedOpMapping1b }

                Change.PlaceholderPointer pendingID _ ->
                    -- May need creating, check mapping first, then create
                    createPendingObject node postUnstampedOpCounter1b postUnstampedOpMapping1b pendingID

        --------- find out when this object was last seen, for stamping
        objectLastOpSeenInNode =
            getLastSeenOp node objectID

        objectLastOpIDSeen =
            Maybe.Extra.or
                -- check newest ops first
                (AnyDict.get objectID postInitMapping.lastSeen)
                -- then check old ops
                (Maybe.map Op.id objectLastOpSeenInNode)
                -- fall back to assuming this is the first op of object (creation)
                |> Maybe.withDefault objectID

        -- Step 3. Stamp all ops with an incremental ID
        ( ( counterAfterObjectChanges3, newLastOpSeen ), objectChangeOps ) =
            List.mapAccuml stampChunkOps ( postInitCounter, objectLastOpIDSeen ) allUnstampedChunkOps

        stampChunkOps : ( InCounter, OpID ) -> UnstampedChunkOp -> ( ( OutCounter, OpID ), Op )
        stampChunkOps ( stampInCounter, opIDToReference ) givenUCO =
            let
                ( newID, stampOutCounter ) =
                    OpID.generate stampInCounter node.identity givenUCO.deletion

                stampedOp =
                    Op.create reducerID objectID newID (Op.OpReference <| Maybe.withDefault opIDToReference givenUCO.reference) givenUCO.payload
            in
            ( ( stampOutCounter, newID ), stampedOp )

        -- ObjectsCreated Mapping: be sure to update the lastOpSeen for this object
        finalMapping =
            { postInitMapping | lastSeen = AnyDict.insert objectID newLastOpSeen postInitMapping.lastSeen }

        -- logOps prefix ops =
        --     String.concat (List.intersperse "\n" (List.map (\op -> prefix ++ ":\t" ++ RonOutput.opToString op ++ "\t") ops))
        allOpsInDependencyOrder =
            allPrereqChunks ++ [ initOps ++ objectChangeOps ]
    in
    ( counterAfterObjectChanges3
    , finalMapping
    , inChunks ++ allOpsInDependencyOrder
    )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Payload, deletion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> ( InCounter, UpdatesSoFar ) -> Change.ObjectChange -> ( ( OutCounter, UpdatesSoFar ), { prerequisiteChunks : List Op.ClosedChunk, thisUnstampedOp : UnstampedChunkOp } )
objectChangeToUnstampedOp node ( inCounter, inMapping ) objectChange =
    let
        perPiece :
            ComplexAtom
            -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List Atom, mapping : UpdatesSoFar }
            -> { counter : OutCounter, prerequisiteChunks : List Op.ClosedChunk, piecesSoFar : List Atom, mapping : UpdatesSoFar }
        perPiece piece accumulated =
            case piece of
                Change.FromPrimitiveAtom primitiveAtom ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ ChangePrimitive.toRonAtom primitiveAtom ]
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.ExistingObjectReferenceAtom objectID ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ Atom.IDPointerAtom objectID ]
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
                                    [ Atom.IDPointerAtom objectID ]

                                Nothing ->
                                    Log.logSeparate
                                        (Console.bgRed <|
                                            "Node.objectChangeToUnstampedOp: Unknown PendingObjectReferenceAtom reference to a pending object: "
                                                ++ PendingID.toString pendingID
                                                ++ " when processing the objectChange "
                                                ++ Debug.toString objectChange
                                                ++ "with this in the mapping so far"
                                        )
                                        (AnyDict.toList accumulated.mapping.assignedIDs)
                                        [ Atom.StringAtom <| PendingID.toString pendingID ]
                    in
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ atomInList
                    , prerequisiteChunks = accumulated.prerequisiteChunks
                    , mapping = accumulated.mapping
                    }

                Change.QuoteNestedObject soloObject ->
                    let
                        ( ( postPrereqCounter, outMapping ), newPrereqChunks ) =
                            oneChangeSetToOpChunks node ( accumulated.counter, accumulated.mapping ) soloObject.changeSet

                        pointerPayloadAsList =
                            case soloObject.toReference of
                                Change.ExistingObjectPointer existingID ->
                                    [ Atom.IDPointerAtom existingID.operationID ]

                                Change.PlaceholderPointer pendingID nestedInstallers ->
                                    case AnyDict.get pendingID outMapping.assignedIDs of
                                        Just outputObject ->
                                            [ Atom.IDPointerAtom outputObject ]

                                        Nothing ->
                                            Log.crashInDev ("QuoteNestedObject not sure what the ObjectID was of this nested object. " ++ Log.dump soloObject.changeSet) []
                    in
                    { counter = postPrereqCounter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ newPrereqChunks
                    , piecesSoFar = accumulated.piecesSoFar ++ pointerPayloadAsList
                    , mapping = outMapping
                    }

                Change.NestedAtoms nestedChangeAtoms ->
                    let
                        nestedOutputAtoms =
                            Nonempty.foldl perPiece
                                { counter = accumulated.counter
                                , piecesSoFar = []
                                , prerequisiteChunks = []
                                , mapping = accumulated.mapping
                                }
                                nestedChangeAtoms

                        finalNestedPayloadAsString =
                            Atom.NakedStringAtom "(" :: nestedOutputAtoms.piecesSoFar ++ [ Atom.NakedStringAtom ")" ]
                    in
                    { counter = nestedOutputAtoms.counter
                    , prerequisiteChunks = accumulated.prerequisiteChunks ++ nestedOutputAtoms.prerequisiteChunks

                    -- TODO below may get multi-atom values confused with multiple values
                    , piecesSoFar = accumulated.piecesSoFar ++ finalNestedPayloadAsString
                    , mapping = nestedOutputAtoms.mapping
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
                    , deletion = False
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
              , thisUnstampedOp = { reference = Just opIDToRevert, payload = [], deletion = not (OpID.isDeletion opIDToRevert) }
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
        , reducerID : ReducerID
        , initOps : List Op
        , postInitCounter : OutCounter
        , postInitMapping : UpdatesSoFar
        }
createPendingObject node inCounter inMapping pendingID =
    case AnyDict.get pendingID inMapping.assignedIDs of
        Just assigned ->
            -- oops, we created this object already
            { objectID = assigned
            , reducerID = pendingID.reducer
            , initOps = []
            , postInitCounter = inCounter
            , postInitMapping = inMapping
            }

        Nothing ->
            let
                ( newID, postInitCounter ) =
                    OpID.generate inCounter node.identity False

                postInitMapping =
                    { inMapping | assignedIDs = AnyDict.insert pendingID newID inMapping.assignedIDs }
            in
            { objectID = newID
            , reducerID = pendingID.reducer
            , initOps = [ Op.initObject pendingID.reducer newID ]
            , postInitCounter = postInitCounter
            , postInitMapping = postInitMapping
            }


{-| Build a Collection out of the matching Objects in the replica. If none exist yet, create a placeholder Collection.
-}
initializeCollection :
    { node : Node
    , cutoff : Maybe Moment
    , foundIDs : List OpID.ObjectID
    , parent : Change.Parent
    , reducer : ReducerID
    , position : Location
    }
    -> Collection event
initializeCollection { node, cutoff, foundIDs, parent, reducer, position } =
    let
        uninitializedObject =
            Collection.Unsaved { reducer = reducer, parent = parent, position = position }
    in
    case foundIDs of
        [] ->
            uninitializedObject

        foundSome ->
            let
                matchingOp opID op =
                    case ( beforeCutoff opID && correctObject op, Op.reducerID op == reducer ) of
                        ( False, _ ) ->
                            False

                        ( True, True ) ->
                            True

                        ( True, False ) ->
                            Log.crashInDev
                                ("Node.initializeCollection: I was told [" ++ String.join ", " (List.map OpID.toString foundIDs) ++ "] were aliases to look for when building " ++ Log.dump reducer ++ " at location " ++ Location.toString position ++ ". Problem is, " ++ OpID.toString opID ++ " is actually a " ++ Log.dump (Op.reducerID op))
                                False

                beforeCutoff opID =
                    case cutoff of
                        Nothing ->
                            True

                        Just cutoffMoment ->
                            SmartTime.Moment.toSmartInt cutoffMoment > OpID.toInt opID

                correctObject op =
                    List.member (Op.objectID op) foundSome

                findMatchingOps =
                    AnyDict.filter matchingOp node.ops
            in
            case Collection.buildSaved findMatchingOps of
                ( Just finalCollection, [] ) ->
                    Collection.Saved finalCollection

                ( Just finalCollection, warnings ) ->
                    Log.crashInDev "collection builder produced warnings!" <| Collection.Saved finalCollection

                ( Nothing, warnings ) ->
                    Log.crashInDevProse
                        [ [ "Node.initializeCollection:" ]
                        , [ "collection builder was tasked with building an collection that should exist but found nothing. The existing object(s) supposedly had ID(s):" ]
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
getLastSeenOp : Node -> ObjectID -> Maybe Op
getLastSeenOp node objectIDToFind =
    let
        correctObject op =
            Op.objectID op == objectIDToFind

        findMatchingOps =
            List.filter correctObject (AnyDict.values node.ops)
    in
    List.last findMatchingOps


lastUpdate : Node -> Moment
lastUpdate node =
    SmartTime.Moment.fromSmartInt node.highestSeenClock



-- PEER


type alias Peer =
    { identity : NodeID }
