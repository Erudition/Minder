module Replicated.Framework exposing (Replicator, Program, browserApplication)

import Browser
import Browser.Navigation exposing (Key)
import Html
import Log
import Replicated.Change as Change exposing (Frame)
import Replicated.Codec as Codec exposing (Codec, SkelCodec, WrappedOrSkelCodec)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.Op as Op exposing (Op)
import Showstopper exposing (InitFailure(..), ShowstopperDetails)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration exposing (HumanDuration(..), dur)
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)
import Task as Job
import Url exposing (Url)


type alias Program userFlags userReplica temp userMsg =
    Platform.Program (Flags userFlags) (Model userFlags userMsg userReplica temp) (Msg userMsg)


type Msg userMsg
    = FrameworkInit Zone Moment -- Tick built in
    | UserInit
    | Tick userMsg
    | U userMsg Moment -- short name, userMsg first param, all to maximize visibility in Elm Debugger


type Model userFlags userMsg userReplica temp
    = PreInit
        { restoredNode : Maybe Node
        , warnings : List String
        , flags : Flags userFlags
        , url : Url
        , key : Key
        , userInit : UserInit userFlags userReplica temp userMsg
        }
    | FrameworkReady
        { node : Node
        , now : Moment
        , zone : Zone
        , userReplica : userReplica
        , warnings : List String
        , userFlags : userFlags
        , url : Url
        , key : Key
        , userInit : UserInit userFlags userReplica temp userMsg
        }
    | UserRunning (Replicator userReplica temp)


{-| This framework takes over Elm's "Model" and instead only gives you a `Replicator`, which is read-only. No worries, you can store your own model inside its `temp` and `replica` fields, with any types you want to model your app with, as usual.
But you also get access to a few other goodies, like the current time!
-}
type alias Replicator userReplica temp =
    { node : Node
    , now : Moment
    , zone : Zone
    , replica : userReplica
    , temp : temp
    }


type alias Flags userFlags =
    { storedRonMaybe : Maybe String
    , userFlags : userFlags
    }


browserApplication :
    { init : UserInit userFlags userReplica temp userMsg
    , view : Replicator userReplica temp -> Browser.Document userMsg
    , update : UserUpdate userMsg userReplica temp
    , subscriptions : Replicator userReplica temp -> Sub userMsg
    , onUrlRequest : Browser.UrlRequest -> userMsg
    , onUrlChange : Url -> userMsg
    , replicaCodec : SkelCodec userReplicaError userReplica -- TODO not Skel
    , portSetStorage : String -> Cmd userMsg
    }
    -> Program userFlags userReplica temp userMsg
browserApplication userApp =
    Browser.application
        { init = initWrapper userApp.init
        , view = viewWrapper userApp.view
        , update = updateWrapper userApp.replicaCodec userApp.portSetStorage userApp.update
        , subscriptions = subscriptionsWrapper userApp.subscriptions
        , onUrlChange = \url -> Tick (userApp.onUrlChange url)
        , onUrlRequest = \req -> Tick (userApp.onUrlRequest req)
        }


subscriptionsWrapper : (Replicator userReplica temp -> Sub userMsg) -> Model userFlags userMsg userReplica temp -> Sub (Msg userMsg)
subscriptionsWrapper userSubs model =
    case model of
        UserRunning replicator ->
            userSubs replicator
            -- Tick means every sub will run with an updated clock
            |> Sub.map (\userMsg -> Tick userMsg)

        _ ->
            Sub.none


viewWrapper : (Replicator userReplica temp -> Browser.Document userMsg) -> Model userFlags userMsg userReplica temp -> Browser.Document (Msg userMsg)
viewWrapper userView premodel =
    case toReplicator premodel of
        Just replicator ->
            let
                { title, body } =
                    userView replicator
            in
            { title = title
            , body = List.map (Html.map Tick) body
            }

        Nothing ->
            { title = "Replicator Failure"
            , body = [ Html.text "Replicator Failure" ]
            }


{-| Internal helper to get the Model the user expects when everything initialized correctly.
-}
toReplicator : Model userFlags userMsg userReplica temp -> Maybe (Replicator userReplica temp)
toReplicator premodel =
    case premodel of
        UserRunning replicator ->
            Just replicator

        _ ->
            Nothing


type alias UserInit userFlags userReplica temp userMsg =
    userFlags -> Url -> Key -> userReplica -> ( List Frame, temp, Cmd userMsg )



--    startingModel =
--         case maybeRon of
--             Just foundRon ->
--                 case Node.initFromSaved { sameSession = False, storedNodeID = "myNode" } foundRon of
--                     Ok { node, warnings } ->
--                         case (Codec.decodeFromNode userReplica.codec node, warnings) of
--                             (Ok userReplica, []) ->
--                                 { viewState = viewUrl url
--                                 , userReplica = userReplica
--                                 , environment = Environment.preInit maybeKey
--                                 , node = node
--                                 }
--                             (Ok _, warningsFound) ->
--                                 initShowstopper
--                                     { savedRon = foundRon
--                                     , problem =  ImportFail warningsFound
--                                     , url = url
--                                     }
--                             (Err problem, _) ->
--                                 initShowstopper
--                                     { savedRon = foundRon
--                                     , problem = DecodeNodeFail problem
--                                     , url = url
--                                     }
--                     Err initError ->
--                         initShowstopper
--                             { savedRon = foundRon
--                             , problem = OtherFail initError
--                             , url = url
--                             }
--             -- no ron stored at all
--             Nothing ->
--                 let
--                     { newNode, startOps } =
--                         Node.startNewNode Nothing
--                 in
--                 case decodeFromNode userReplica.codec newNode of
--                     Ok userReplica ->
--                         { viewState = viewUrl url
--                         , userReplica = userReplica
--                         , environment = Environment.preInit maybeKey
--                         , node = newNode
--                         }
--                     Err problem ->
--                         initShowstopper
--                             { savedRon = "No Stored RON."
--                             , problem = DecodeNodeFail problem
--                             , url = url
--                             }


initWrapper : UserInit userFlags userReplica temp userMsg -> Flags userFlags -> Url -> Key -> ( Model userFlags userMsg userReplica temp, Cmd (Msg userMsg) )
initWrapper userInit  wrappedFlags url key =
    let
        { storedNodeMaybe, startWarnings } =
            case wrappedFlags.storedRonMaybe of
                Just foundRon ->
                    case Node.initFromSaved { sameSession = False, storedNodeID = "myNode" } foundRon of
                        Ok { node, warnings } ->
                            { storedNodeMaybe = Just node, startWarnings = warnings }

                        Err initError ->
                            -- TODO pass initError as warning
                            Log.crashInDev ("TODO pass initError as warning: " ++ Log.dump initError) { storedNodeMaybe = Nothing, startWarnings = [] }

                Nothing ->
                    { storedNodeMaybe = Nothing, startWarnings = [] }

        startupCmd =
            Job.perform identity (Job.map2 FrameworkInit HumanMoment.localZone Moment.now)
    in
    ( PreInit 
        { restoredNode = storedNodeMaybe
        , warnings = [] -- TODO
        , flags = wrappedFlags
        , url = url
        , key = key
        , userInit = userInit
        }
    , Cmd.batch [ startupCmd ]
    )


type alias UserUpdate userMsg userReplica temp =
    userMsg -> Replicator userReplica temp -> ( List Frame, temp, Cmd userMsg )


updateWrapper : SkelCodec userReplicaError userReplica -> (String -> Cmd userMsg) -> UserUpdate userMsg userReplica temp -> Msg userMsg -> Model userFlags userMsg userReplica temp -> ( Model userFlags userMsg userReplica temp, Cmd (Msg userMsg) )
updateWrapper userReplicaCodec setStorage userUpdate wrappedMsg wrappedModel =
    case wrappedMsg of
        -- first get the current time
        Tick userMsg ->
            ( wrappedModel
            , Job.perform (U userMsg) Moment.now
            )

        -- then do the update
        U userMsg newTime ->
            case toReplicator wrappedModel of
                Nothing ->
                    -- TODO handle unhappy-path better
                    (wrappedModel, Cmd.none)

                Just oldReplicator ->
                    let
                        replicator =
                            {oldReplicator | now = newTime}
                    in
                    case (userUpdate userMsg replicator) of
                        ( [], temp, newCmds ) ->
                            ( UserRunning { replicator | temp = temp }, Cmd.map (\m -> U m newTime) newCmds )

                        ( framesToApply, temp, newCmds ) ->
                            let
                                modelWithTimeTemp =
                                    { replicator | temp = temp }

                                ( replicatorWithUpdates, finalOutputFrame ) =
                                    List.foldl applyFrame ( modelWithTimeTemp, [] ) framesToApply

                                applyFrame givenFrame ( givenModel, outputsSoFar ) =
                                    let
                                        { outputFrame, updatedNode } =
                                            Node.apply (Just newTime) givenModel.node (Log.log "Changes to save" givenFrame)
                                    in
                                    ( { givenModel | node = updatedNode }, outputsSoFar ++ outputFrame )
                            in
                            case Codec.decodeFromNode userReplicaCodec replicatorWithUpdates.node of
                                Ok updatedUserReplica ->
                                    ( UserRunning { replicatorWithUpdates | replica = updatedUserReplica }
                                    , Log.logSeparate "Saving with new frame" finalOutputFrame <| Cmd.batch [ Cmd.map (\m -> U m newTime) <| setStorage (Op.closedChunksToFrameText finalOutputFrame), Cmd.map (\m -> U m newTime) newCmds ]
                                    )

                                Err problem ->
                                    -- TODO error handling. ops are still added to node of model even if decode fails. Revert temp changes?
                                    ( Log.logSeparate "Failed to decodeFromNode! Reverting update!" problem (UserRunning replicatorWithUpdates)
                                    , Cmd.map (\m -> U m newTime) newCmds
                                    )

        FrameworkInit zone now ->
            case wrappedModel of
                PreInit {restoredNode, warnings, key, url, flags, userInit} ->
                    let
                        startNode =
                            Maybe.withDefault (Node.startNewNode (Just now)).newNode restoredNode


                        ( startuserReplica, userReplicaDecodeWarnings ) =
                            Codec.forceDecodeFromNode userReplicaCodec startNode

                        userStartupCmd =
                            Job.perform (\_ -> UserInit) (Job.succeed ())
                    in
                    ( FrameworkReady
                        { node = startNode
                        , now = now
                        , zone = zone
                        , userReplica = startuserReplica
                        , warnings = warnings
                        , key = key
                        , url = url
                        , userFlags = flags.userFlags
                        , userInit = userInit
                        }
                    , userStartupCmd
                    )

                _ ->
                    -- never possible
                    (Log.crashInDev "FrameworkInit when model wasn't PreInit" wrappedModel, Cmd.none)

        UserInit ->
            case wrappedModel of
                FrameworkReady {userInit, userFlags, url, key, userReplica, node, now, zone} ->
                    let
                        ( userInitFrames, temp, userInitCmds ) =
                            userInit userFlags url key userReplica
                    in
                    ( UserRunning
                        { node = node
                        , now = now
                        , zone = zone
                        , replica = userReplica
                        , temp = temp
                        }
                    , Cmd.map (\cmds -> U cmds now) userInitCmds
                    )
                
                _ ->
                    -- never possible
                    (Log.crashInDev "UserInit when model wasn't FrameworkReady" wrappedModel, Cmd.none)
