module Replicated.Framework exposing (Program, Replicator, browserApplication)

import Browser
import Browser.Navigation exposing (Key)
import Console
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


testMode =
    True


type alias Program userFlags userReplica temp userMsg =
    Platform.Program (Flags userFlags) (Model userFlags userMsg userReplica temp) (Msg userMsg)


type Msg userMsg
    = FrameworkInit (List String) Zone Moment -- Tick built in
    | LoadMoreData (List String)
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
    let
        objectsImportedString node =
            "Objects imported: " ++ String.fromInt (Node.objectCount node)
    in
    case premodel of
        PreInit { restoredNode, warnings, flags, url, key, userInit } ->
            { title = "Crashed."
            , body =
                [ Html.text "PreInit Replicator Failure"
                , Html.text <| Maybe.withDefault "No stored RON." flags.storedRonMaybe
                , Html.text <| Maybe.withDefault "No ops imported." (Maybe.map objectsImportedString restoredNode)
                ]
                    ++ List.map Html.text warnings
            }

        FrameworkReady { node, now, zone, userReplica, warnings, userFlags, url } ->
            { title = "Crashed."
            , body =
                [ Html.text "FrameworkReady Replicator Failure"
                ]
                    ++ List.map Html.text warnings
            }

        UserRunning replicator ->
            let
                { title, body } =
                    userView replicator
            in
            { title = title
            , body = List.map (Html.map Tick) body
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
initWrapper userInit wrappedFlags url key =
    let
        { storedNodeMaybe, startWarnings, loadAfter } =
            case wrappedFlags.storedRonMaybe of
                Just foundRon ->
                    -- case [ String.dropRight 1 foundRon ] of
                    case String.split "❃" foundRon of
                        [] ->
                            { storedNodeMaybe = Nothing, startWarnings = [], loadAfter = [] }

                        firstFrame :: moreFrames ->
                            case Node.initFromSaved { sameSession = False, storedNodeID = "myNode" } firstFrame of
                                Ok { node, warnings } ->
                                    { storedNodeMaybe = Just node, startWarnings = warnings, loadAfter = moreFrames }

                                Err initError ->
                                    -- TODO pass initError as warning
                                    Log.crashInDev ("TODO pass initError as warning: " ++ Log.dump initError ++ "\n InitError was from ron:\n" ++ firstFrame) { storedNodeMaybe = Nothing, startWarnings = [], loadAfter = moreFrames }

                Nothing ->
                    { storedNodeMaybe = Nothing, startWarnings = [], loadAfter = [] }

        userInitNext =
            Job.perform identity (Job.map2 (FrameworkInit loadAfter) HumanMoment.localZone Moment.now)
    in
    ( PreInit
        { restoredNode = storedNodeMaybe
        , warnings = [] -- TODO
        , flags = wrappedFlags
        , url = url
        , key = key
        , userInit = userInit
        }
    , userInitNext
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
                    ( wrappedModel, Cmd.none )

                Just oldReplicator ->
                    let
                        replicator =
                            { oldReplicator | now = newTime }

                        ( framesToApply, temp, cmds ) =
                            userUpdate userMsg replicator
                    in
                    case ( Change.nonEmptyFrames framesToApply, temp, cmds ) of
                        ( [], newTemp, newCmds ) ->
                            ( UserRunning { replicator | temp = newTemp }, Cmd.map (\m -> U m newTime) newCmds )

                        ( filledFramesToApply, newTemp, newCmds ) ->
                            let
                                modelWithTimeTemp =
                                    { replicator | temp = newTemp }

                                ( replicatorWithUpdates, finalOutputFrame ) =
                                    List.foldl applyFrame ( modelWithTimeTemp, [] ) filledFramesToApply

                                maybeTime =
                                    if testMode then
                                        Nothing

                                    else
                                        Just newTime

                                applyFrame givenFrame ( givenModel, outputsSoFar ) =
                                    let
                                        { outputFrame, updatedNode } =
                                            Node.apply maybeTime False givenModel.node givenFrame
                                    in
                                    ( { givenModel | node = updatedNode }, outputsSoFar ++ outputFrame )
                            in
                            case Codec.decodeFromNode userReplicaCodec replicatorWithUpdates.node of
                                Ok updatedUserReplica ->
                                    ( UserRunning { replicatorWithUpdates | replica = updatedUserReplica }
                                    , Cmd.batch [ Cmd.map (\m -> U m newTime) <| setStorage (Op.closedChunksToFrameText finalOutputFrame), Cmd.map (\m -> U m newTime) newCmds ]
                                    )

                                Err problem ->
                                    ( Log.logSeparate (Console.bgRed "Failed to decodeFromNode! Reverting update! Ops:\n" ++ Console.colorsInverted (Op.closedChunksToFrameText finalOutputFrame) ++ "\nProblem: ") problem wrappedModel
                                    , Cmd.map (\m -> U m newTime) newCmds
                                    )

        FrameworkInit remainingRon zone now ->
            case wrappedModel of
                PreInit { restoredNode, warnings, key, url, flags, userInit } ->
                    let
                        ( startNode, startCmds ) =
                            case restoredNode of
                                Just restoredNodeFound ->
                                    ( restoredNodeFound
                                    , [ Job.perform (\_ -> LoadMoreData remainingRon) (Job.succeed ()) ]
                                    )

                                Nothing ->
                                    let
                                        maybeTime =
                                            if testMode then
                                                Nothing

                                            else
                                                Just now

                                        ( newNode, startChunks ) =
                                            -- Node.startNewNode (Just now) []
                                            Codec.startNodeFromRoot maybeTime userReplicaCodec

                                        --tempDefaultChanges
                                        saveNodeCmd =
                                            setStorage (Op.closedChunksToFrameText startChunks)
                                                |> Cmd.map (\m -> U m now)

                                        userStartupCmd =
                                            Job.perform (\_ -> UserInit) (Job.succeed ())
                                    in
                                    ( newNode, [ saveNodeCmd, userStartupCmd ] )

                        ( startuserReplica, userReplicaDecodeWarnings ) =
                            Codec.forceDecodeFromNode userReplicaCodec startNode
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
                    , Cmd.batch startCmds
                    )

                _ ->
                    -- never possible
                    ( Log.crashInDev "FrameworkInit when model wasn't PreInit" wrappedModel, Cmd.none )

        LoadMoreData remainingRonFrames ->
            case ( wrappedModel, remainingRonFrames ) of
                ( FrameworkReady ({ userReplica, node } as frameworkReady), [] ) ->
                    -- no more RON frames to process
                    let
                        ( startuserReplica, userReplicaDecodeWarnings ) =
                            Codec.forceDecodeFromNode userReplicaCodec node
                    in
                    ( FrameworkReady { frameworkReady | userReplica = startuserReplica }
                    , Job.perform (\_ -> UserInit) (Job.succeed ())
                    )

                ( FrameworkReady ({ node } as frameworkReady), nextRonFrame :: moreRonFrames ) ->
                    let
                        updated =
                            Node.updateWithRon { node = node, warnings = [], newObjects = [] } nextRonFrame
                    in
                    ( FrameworkReady { frameworkReady | node = updated.node }
                    , Job.perform (\_ -> LoadMoreData moreRonFrames) (Job.succeed ())
                    )

                ( UserRunning replicator, [] ) ->
                    ( wrappedModel, Cmd.none )

                ( UserRunning ({ node } as replicator), nextRonFrame :: moreRonFrames ) ->
                    let
                        updated =
                            Node.updateWithRon { node = node, warnings = [], newObjects = [] } (nextRonFrame ++ ".")
                    in
                    ( UserRunning { replicator | node = updated.node }
                    , Job.perform (\_ -> LoadMoreData moreRonFrames) (Job.succeed ())
                    )

                ( PreInit _, _ ) ->
                    ( Log.crashInDev "LoadMoreData when model was PreInit" wrappedModel, Cmd.none )

        UserInit ->
            case wrappedModel of
                FrameworkReady { userInit, userFlags, url, key, userReplica, node, now, zone } ->
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
                    ( Log.crashInDev "UserInit when model wasn't FrameworkReady" wrappedModel, Cmd.none )
