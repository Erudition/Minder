module Components.Replicator exposing (..)

import Console
import Log
import Maybe.Extra
import Platform exposing (Task)
import Replicated.Change as Change
import Replicated.Codec as Codec exposing (SkelCodec)
import Replicated.Node.Node as Node exposing (Node, OpImportWarning)
import Replicated.Op.Op as Op
import SmartTime.Moment as Moment exposing (Moment)
import Task


{-| Internal Model of the replicator component.
-}
type Replicator replica frameDesc
    = ReplicatorModel
        { node : Node
        , replicaCodec : SkelCodec ReplicaError replica
        , replica : replica
        , outPort : String -> Cmd (Msg frameDesc)
        }


type alias ReplicaError =
    String


{-| Data required to initialize the replicator.
-}
type alias ReplicatorConfig replica yourFrameDesc =
    { launchTime : Maybe Moment
    , replicaCodec : SkelCodec ReplicaError replica
    , outPort : String -> Cmd (Msg yourFrameDesc)
    }


init : ReplicatorConfig replica desc -> ( Replicator replica desc, replica )
init { launchTime, replicaCodec, outPort } =
    let
        ( startNode, initChanges ) =
            Codec.startNodeFromRoot launchTime replicaCodec

        ( startReplica, replicaDecodeWarnings ) =
            Codec.forceDecodeFromNode replicaCodec startNode
    in
    -- TODO return warnings?
    ( ReplicatorModel
        { node = startNode
        , replicaCodec = replicaCodec
        , replica = startReplica
        , outPort = outPort
        }
    , startReplica
    )


{-| This component's internal Msg type.
-}
type Msg desc
    = LoadRon Int (List String)
    | ApplyFrames (List (Change.Frame desc)) Moment


update :
    Msg desc
    -> Replicator replica desc
    -> { newReplicator : Replicator replica desc, newReplica : replica, warnings : List OpImportWarning, cmd : Cmd (Msg desc) }
update msg (ReplicatorModel oldReplicator) =
    case msg of
        LoadRon originalFrameCount [] ->
            let
                ( newReplica, problemMaybe ) =
                    Codec.forceDecodeFromNode oldReplicator.replicaCodec oldReplicator.node

                problemAsWarning =
                    case problemMaybe of
                        Just codecErr ->
                            -- TODO convert to warning
                            Log.crashInDev (Codec.errorToString codecErr) []

                        Nothing ->
                            []

                newReplicator =
                    ReplicatorModel
                        { oldReplicator | replica = newReplica }
            in
            { newReplicator = newReplicator
            , newReplica = newReplica
            , warnings = problemAsWarning
            , cmd = Cmd.none
            }

        LoadRon originalFrameCount (nextRonFrame :: moreRonFrames) ->
            let
                { node, warnings, newObjects } =
                    Node.updateWithRon { node = oldReplicator.node, warnings = [], newObjects = [] } (Log.logMessageOnly ("Importing RON frame: \n" ++ nextRonFrame) nextRonFrame)

                progress =
                    originalFrameCount - List.length moreRonFrames

                newReplicator =
                    ReplicatorModel
                        { oldReplicator | node = node }
            in
            { newReplicator = newReplicator
            , newReplica = oldReplicator.replica
            , warnings = warnings
            , cmd = Task.perform (\_ -> LoadRon originalFrameCount moreRonFrames) (Task.succeed ())
            }

        ApplyFrames newFrames newTime ->
            let
                ( nodeWithUpdates, finalOutputFrame ) =
                    List.foldl applyFrame ( oldReplicator.node, [] ) newFrames

                applyFrame givenFrame ( inNode, outputsSoFar ) =
                    let
                        { outputFrame, updatedNode } =
                            Node.apply (Just newTime) False inNode givenFrame
                    in
                    ( updatedNode, outputsSoFar ++ outputFrame )
            in
            case Codec.decodeFromNode oldReplicator.replicaCodec nodeWithUpdates of
                Ok updatedUserReplica ->
                    { newReplicator = ReplicatorModel { oldReplicator | node = nodeWithUpdates, replica = updatedUserReplica }
                    , newReplica = updatedUserReplica
                    , warnings = []
                    , cmd = Cmd.batch [ oldReplicator.outPort (Op.closedChunksToFrameText finalOutputFrame) ]
                    }

                Err problem ->
                    { newReplicator =
                        Log.logSeparate (Console.bgRed "Failed to decodeFromNode! Reverting update! Ops:\n" ++ Console.colorsInverted (Op.closedChunksToFrameText finalOutputFrame) ++ "\nProblem: ")
                            problem
                            (ReplicatorModel oldReplicator)
                    , newReplica = oldReplicator.replica
                    , warnings = [] -- TODO warn if fail to apply
                    , cmd = Cmd.none
                    }


{-| Type for your "incoming frames" port. Use this on your JS port which is called when you receive new changeframes from elsewhere. The RON data (as a string) will be processed into the replicator.
-}
type alias IncomingFramesPort desc =
    (String -> Msg desc) -> Sub (Msg desc)


{-| Wire this component's subscriptions up into your `Shared.subscriptions`, using `Sub.map` to convert it to your message type, like:

    subscriptions =
        Sub.batch
            [   ...
            ,   Sub.map ReplicatorUpdate (Components.Replicator.subscriptions incomingRon)
            ]

`incomingRon` is a port you create (you can put it in the `Effect` module if you like) that receives a String, and has the type `IncomingFramesPort`.

-}
subscriptions : IncomingFramesPort desc -> Sub (Msg desc)
subscriptions incomingFramesPort =
    let
        splitIncomingFrames inRon =
            let
                frames =
                    String.split "❃" inRon
            in
            LoadRon (List.length frames) frames
    in
    incomingFramesPort splitIncomingFrames


saveEffect : List (Change.Frame desc) -> Cmd (Msg desc)
saveEffect framesToSave =
    case Change.nonEmptyFrames framesToSave of
        [] ->
            Cmd.none

        _ ->
            Task.perform (ApplyFrames framesToSave) Moment.now
