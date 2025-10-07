module Components.Replicator exposing (Replicator, ReplicatorConfig, init, IncomingFramesPort, subscriptions, saveEffect, update)

import Console
import Dict.Any as AnyDict exposing (AnyDict)
import Log
import Maybe.Extra
import Platform exposing (Task)
import Replicated.Change as Change
import Replicated.Codec as Codec exposing (SkelCodec)
import Replicated.Codec.Error
import Replicated.Node.Node as Node exposing (Node, OpImportWarning)
import Replicated.Op.ID as OpID
import Replicated.Op.RonOutput as RonOutput
import SmartTime.Moment as Moment exposing (Moment)
import Task


{-| Internal Model of the replicator component.
-}
type Replicator replica frameDesc
    = ReplicatorModel
        { node : Node
        , replicaCodec : WrappedOrSkelCodecWithoutSeed replica
        , replica : replica
        , outPort : String -> Cmd (Msg frameDesc)
        }

{-| Internal reminder what this is: We want to allow replicas created from skels and wrapped types, but not force everyone to have another type variable in their Replicator (for the seed).
This means no startup changes via seed, but the user could do anyway in their own first loop, and startup changes are dis-recommended because there should be a time "before the replica exists" for the app to make sure the user doesn't actually have one (rather than creating a new one, potentially confusing when blank app appears, or even overwriting the old replica when it comes back)
-}
type alias WrappedOrSkelCodecWithoutSeed replica = Codec.WrappedOrSkelCodec (Change.Changer ()) replica



{-| Data required to initialize the replicator.
-}
type alias ReplicatorConfig replica seed yourFrameDesc =
    { launchTime : Maybe Moment
    , replicaCodec : WrappedOrSkelCodecWithoutSeed replica
    , outPort : String -> Cmd (Msg yourFrameDesc)
    }


init : ReplicatorConfig replica seed desc -> ( Replicator replica desc, replica )
init { launchTime, replicaCodec, outPort } =
    let
        ( startNode, initChanges ) =
            Codec.startNodeFromRoot launchTime replicaCodec

        ( startReplica, replicaDecodeWarnings ) =
            Codec.decodeFromNode replicaCodec startNode Nothing
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
                    Codec.decodeFromNode oldReplicator.replicaCodec oldReplicator.node (Just oldReplicator.replica)

                problemAsWarning =
                    case problemMaybe of
                        Just codecErr ->
                            -- TODO convert to warning
                            Log.crashInDev (Replicated.Codec.Error.toString codecErr) []

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
                            Node.applyChanges (Just newTime) False inNode givenFrame
                    in
                    ( updatedNode, outputsSoFar ++ outputFrame )

                (updatedUserReplica, problemMaybe) =
                    Codec.decodeFromNode oldReplicator.replicaCodec nodeWithUpdates (Just oldReplicator.replica)

                warnings =
                    case problemMaybe of
                    -- TODO organize and report decode problems vs import problems
                        Nothing -> []
                        Just problem ->
                            Log.logSeparate (Console.bgRed "Failed to decodeFromNode! Reverting update! Ops:\n" ++ Console.colorsInverted (RonOutput.closedChunksToFrameText finalOutputFrame) ++ "\nProblem: ")
                            problem
                            []

            in
                { newReplicator = ReplicatorModel { oldReplicator | node = nodeWithUpdates, replica = updatedUserReplica }
                , newReplica = updatedUserReplica
                , warnings = warnings
                , cmd = Cmd.batch [ oldReplicator.outPort (RonOutput.closedChunksToFrameText finalOutputFrame) ]
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
