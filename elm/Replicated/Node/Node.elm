module Replicated.Node.Node exposing (..)

import Dict exposing (Dict)
import Json.Encode as JE
import List.Extra as List
import Log
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
            NodeID.fromString foundIdentity

        backfilledNode oldNodeID =
            List.foldl (\op n -> { n | objects = updateObject n.objects op }) (startNode oldNodeID) inputDatabase

        startNode oldNodeID =
            { identity = NodeID.bumpSessionID oldNodeID
            , peers = []
            , objects = Dict.empty
            , profiles = [ foundRoot ]
            , lastUsedCounter = OpID.importCounter foundCounter
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
    , profiles = []
    , lastUsedCounter = OpID.testCounter
    }


startNewNode : Maybe Moment -> Change -> { newNode : Node, newOps : List Op }
startNewNode nowMaybe rootChange =
    let
        firstChangeFrame =
            Change.saveChanges "Node initialized" [ rootChange ]

        { updatedNode, created, ops } =
            apply nowMaybe { testNode | lastUsedCounter = nodeStartCounter } firstChangeFrame

        newRoot =
            List.last created
                |> Maybe.map List.singleton
                |> Maybe.withDefault []

        nodeStartCounter =
            Maybe.withDefault OpID.testCounter (Maybe.map OpID.firstCounter nowMaybe)

        newNode =
            { updatedNode | profiles = newRoot }
    in
    { newNode = newNode, newOps = ops }


{-| Save your changes!
Always supply the current time (`Just moment`).
(Else, new Ops will be timestamped as if they occurred mere milliseconds after the previous save, which can cause them to always be considered "older" than other ops that happened between.)
If the clock is set backwards or another node loses track of time, we will never go backwards in timestamps.
-}
apply : Maybe Moment -> Node -> Change.Frame -> { ops : List Op, updatedNode : Node, created : List ObjectID }
apply timeMaybe node (Change.Frame { normalizedChanges, description }) =
    let
        fallbackCounter =
            Maybe.withDefault node.lastUsedCounter (Maybe.map OpID.firstCounter timeMaybe)

        frameStartCounter =
            OpID.highestCounter fallbackCounter node.lastUsedCounter

        ( finalCounter, listOfFinishedOpsLists ) =
            List.mapAccuml (oneChangeToOps node) frameStartCounter normalizedChanges

        finishedOps =
            List.concat listOfFinishedOpsLists

        updatedNode =
            List.foldl (\op n -> { n | objects = updateObject n.objects op }) node finishedOps

        creationOpsToObjectIDs op =
            case Op.pattern op of
                Op.CreationOp ->
                    Just (Op.object op)

                _ ->
                    Nothing
    in
    { ops = finishedOps
    , updatedNode = { updatedNode | lastUsedCounter = OpID.nextGenCounter finalCounter }
    , created = List.filterMap creationOpsToObjectIDs finishedOps
    }


{-| Testing: Drop-in replacement for `apply` which encodes the output Ops to string, and then decodes that string back to a node, to ensure it's the same
-}
applyAndReparseOps : Maybe Moment -> Node -> List Op -> Change.Frame -> Result InitError Node
applyAndReparseOps timeMaybe node existingOps changeFrame =
    let
        { ops, updatedNode } =
            apply timeMaybe node changeFrame

        outputFrameString =
            Debug.log "SERIALIZING OP FRAME: \n" (Op.toFrame ops)

        reparsedOpsResult =
            Op.fromLog outputFrameString

        rootMaybe =
            List.head updatedNode.profiles
    in
    case ( rootMaybe, reparsedOpsResult ) of
        ( Just foundRoot, Ok reparsedOps ) ->
            initFromSaved (NodeID.toString updatedNode.identity) (OpID.exportCounter updatedNode.lastUsedCounter) foundRoot (existingOps ++ reparsedOps)

        ( problemRoot, problemOpsResult ) ->
            -- Err DecodingOldIdentityProblem
            Debug.todo <| "Can't reparse node with root " ++ Debug.toString problemRoot ++ " and/or given reparsed ops " ++ Debug.toString problemOpsResult



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
oneChangeToOps : Node -> InCounter -> Change -> ( OutCounter, List Op )
oneChangeToOps node inCounter change =
    case change of
        Change.Chunk chunkRecord ->
            let
                ( ( outCounter, createdObjectMaybe ), chunkOps ) =
                    chunkToOps node ( inCounter, Nothing ) chunkRecord

                logOps =
                    List.map (\op -> Op.closedOpToString op ++ "\n") chunkOps
                        |> String.concat
            in
            ( outCounter, chunkOps )


{-| Turns a change Chunk (same-object changes) into finalized ops.
in mapAccuml form
-}
chunkToOps : Node -> ( InCounter, Maybe ObjectID ) -> { target : Change.Pointer, objectChanges : List Change.ObjectChange } -> ( ( OutCounter, Maybe ObjectID ), List Op )
chunkToOps node ( inCounter, _ ) { target, objectChanges } =
    let
        -- I'm pretty proud of this concotion, it took me DAYS to figure a concise way to get the prereqs all stamped BEFORE the object initialization op and the object changes (the prereqs are nested in the object that doesn't exist yet).
        ( postPrereqCounter, processedChanges ) =
            List.mapAccuml (objectChangeToUnstampedOp node) inCounter objectChanges

        allPrereqOps =
            List.concatMap .prerequisiteOps processedChanges

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
            String.concat (List.intersperse "\n" (List.map (\op -> prefix ++ ":\t" ++ Op.closedOpToString op ++ "\t") ops))

        prereqLogMsg =
            case List.length allPrereqOps of
                0 ->
                    "----\tchunk"

                n ->
                    "----\t^^last " ++ String.fromInt n ++ " are prereqs for chunk"

        allOpsInDependencyOrder =
            Log.logMessage prereqLogMsg allPrereqOps
                ++ Log.logMessage (logOps "init" initOps) initOps
                ++ Log.logMessage (logOps "change" objectChangeOps) objectChangeOps
    in
    ( ( counterAfterObjectChanges, Just objectID )
    , allOpsInDependencyOrder
    )


type alias UnstampedChunkOp =
    { reference : Maybe OpID, payload : Op.OpPayloadAtoms, reversion : Bool }


{-| Get prerequisite ops for an (existing object) change if needed, then process the change into an UnstampedChunkOp, leaving out the other op fields to be added by the caller
-}
objectChangeToUnstampedOp : Node -> InCounter -> Change.ObjectChange -> ( OutCounter, { prerequisiteOps : List Op, thisObjectOp : UnstampedChunkOp } )
objectChangeToUnstampedOp node inCounter objectChange =
    let
        perPiece : Change.Atom -> { counter : OutCounter, prerequisiteOps : List Op, piecesSoFar : List JE.Value } -> { counter : OutCounter, prerequisiteOps : List Op, piecesSoFar : List JE.Value }
        perPiece piece accumulated =
            case piece of
                Change.ValueAtom value ->
                    { counter = accumulated.counter
                    , piecesSoFar = accumulated.piecesSoFar ++ [ value ]
                    , prerequisiteOps = accumulated.prerequisiteOps
                    }

                Change.QuoteNestedObject (Change.Chunk chunkDetails) ->
                    let
                        ( ( postPrereqCounter, subObjectIDMaybe ), newPrereqOps ) =
                            chunkToOps node ( accumulated.counter, Nothing ) chunkDetails

                        pointerPayload =
                            Maybe.map newObjectIDToPayload subObjectIDMaybe
                                |> Maybe.withDefault "ERROR no pointer, unreachable"
                    in
                    { counter = postPrereqCounter
                    , prerequisiteOps = accumulated.prerequisiteOps ++ newPrereqOps
                    , piecesSoFar = accumulated.piecesSoFar ++ [ JE.string pointerPayload ]
                    }

                Change.NestedAtoms nestedChangeAtoms ->
                    let
                        outputAtoms =
                            List.foldl perPiece
                                { counter = accumulated.counter
                                , piecesSoFar = []
                                , prerequisiteOps = []
                                }
                                nestedChangeAtoms

                        finalNestedPayloadAsString =
                            JE.list identity outputAtoms.piecesSoFar
                    in
                    { counter = outputAtoms.counter
                    , prerequisiteOps = accumulated.prerequisiteOps ++ outputAtoms.prerequisiteOps
                    , piecesSoFar = accumulated.piecesSoFar ++ [ finalNestedPayloadAsString ]
                    }

        outputHelper pieceList reference =
            let
                { counter, prerequisiteOps, piecesSoFar } =
                    List.foldl perPiece { counter = inCounter, piecesSoFar = [], prerequisiteOps = [] } pieceList
            in
            ( counter
            , { prerequisiteOps = prerequisiteOps
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
            , { prerequisiteOps = []
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
