module Replicated.Framework exposing (browserApplication, Program, Model)
import Replicated.Node.Node exposing (Node)
import SmartTime.Moment exposing (Moment)
import SmartTime.Human.Moment exposing (Zone)
import Replicated.Codec as Codec exposing (Codec, SkelCodec, WrappedOrSkelCodec)
import Log
import Html
import Replicated.Change as Change exposing (Frame)
import Replicated.Node.Node as Node exposing (Node)
import Url exposing (Url)
import Browser.Navigation exposing (Key)
import Browser
import Replicated.Op.Op as Op exposing (Op)
import Task as Job
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration exposing (HumanDuration(..), dur)
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (Moment)

type alias Program flags profile temp msg =
    Platform.Program (Flags flags) (Model profile temp) (Msg msg)

type Msg userMsg
    = Initialize (Cmd userMsg) Zone Moment -- Tick built in
    | Tick userMsg
    | U userMsg Moment -- short name, userMsg first param, all to maximize visibility in Elm Debugger

type alias Model profile temp =
    { profile : profile
    , temp : temp
    , now : Moment
    , zone : Zone
    , node : Node
    }

type alias Flags userFlags =
    { storedRonMaybe : Maybe String
    , userFlags : userFlags
    }

browserApplication : 
    { init : UserInit userFlags profile temp userMsg
    , view : (Model profile temp) -> Browser.Document userMsg
    , update : UserUpdate userMsg profile temp
    , subscriptions : Model profile temp -> Sub userMsg
    , onUrlRequest : Browser.UrlRequest -> userMsg
    , onUrlChange : Url -> userMsg
    , profileCodec : SkelCodec e profile -- TODO not Skel
    , portSetStorage : String -> Cmd userMsg
    }
    -> Program userFlags profile temp userMsg
browserApplication userApp =
    Browser.application
        { init = initWrapper userApp.init userApp.profileCodec
        , view = viewWrapper userApp.view
        , update = updateWrapper userApp.profileCodec userApp.portSetStorage userApp.update
        , subscriptions = 
            \model -> Sub.map Tick (userApp.subscriptions model) -- Tick needed?
        , onUrlChange = \url -> Tick (userApp.onUrlChange url)
        , onUrlRequest = \req -> Tick (userApp.onUrlRequest req)
        }

viewWrapper : (Model profile temp -> Browser.Document userMsg) -> Model profile temp -> Browser.Document (Msg userMsg)
viewWrapper userView model =
    let
        {title, body} = 
            userView model
    in
    { title = title
    , body = List.map (Html.map Tick) body
    }


type alias UserInit userFlags profile temp userMsg =
    userFlags -> Url -> Key -> profile -> ( List Frame, temp, Cmd userMsg )


initWrapper : UserInit userFlags profile temp userMsg -> SkelCodec e profile -> (Flags userFlags) -> Url -> Key -> ( Model profile temp, Cmd (Msg userMsg) )
initWrapper userInit profileCodec wrappedFlags url key =
    let
        {startNode, startWarnings } =
            case wrappedFlags.storedRonMaybe of
                Just foundRon ->
                    case Node.initFromSaved { sameSession = False, storedNodeID = "myNode" } foundRon of
                        Ok { node, warnings } ->
                            {startNode = node, startWarnings = warnings }

                        Err initError ->
                            -- TODO pass initError as warning
                            Log.crashInDev ("TODO pass initError as warning: " ++ Log.dump initError) {startFresh | startWarnings = [] }

                Nothing ->
                    startFresh

        startFresh =
            let
                { newNode } =
                    -- TODO pass in start time?
                    Node.startNewNode Nothing
            in
            {startNode = newNode , startWarnings = [] }

        (startProfile, profileDecodeWarnings) =
            Codec.forceDecodeFromNode profileCodec startNode
                    
        (userInitFrames, temp, userInitCmds) =
            userInit wrappedFlags.userFlags url key startProfile

        startWith : Model profile temp
        startWith =
            { profile = startProfile
            , temp = temp
            , now = Moment.fromSmartInt 0 -- TODO improve
            , zone = HumanMoment.utc -- TODO improve
            , node = startNode
            }

        startupCmd =
            Job.perform identity (Job.map3 Initialize (Job.succeed userInitCmds) HumanMoment.localZone Moment.now) -- reduces initial calls to update
    in
    ( startWith
    , Cmd.batch [startupCmd]
    )
    
    


type alias UserUpdate userMsg profile temp =
    userMsg -> Model profile temp -> ( List Frame, temp, Cmd userMsg )


updateWrapper : WrappedOrSkelCodec e s profile -> (String -> Cmd userMsg) -> UserUpdate userMsg profile temp -> (Msg userMsg) -> (Model profile temp) -> ( (Model profile temp), Cmd (Msg userMsg) )
updateWrapper profileCodec setStorage userUpdate wrappedMsg wrappedModel =
    case wrappedMsg of
        -- first get the current time
        Tick userMsg ->
            ( wrappedModel
            , Job.perform (U userMsg) Moment.now
            )

        -- then do the update
        U userMsg newTime ->
            let
                modelWithTime =
                    {wrappedModel | now = newTime }
            in
            case userUpdate userMsg modelWithTime of
                ([], temp, newCmds ) ->
                    ( {modelWithTime | temp = temp}, Cmd.map (\m -> U m newTime) newCmds )

                ( framesToApply, temp, newCmds ) ->
                    let
                        modelWithTimeTemp =
                            {modelWithTime | temp = temp}

                        ( modelWithTimeTempChanges, finalOutputFrame ) =
                            List.foldl applyFrame ( modelWithTimeTemp, [] ) framesToApply

                        applyFrame givenFrame ( givenModel, outputsSoFar ) =
                            let
                                { outputFrame, updatedNode } =
                                    Node.apply (Just newTime) givenModel.node (Log.log "Changes to save" givenFrame)
                            in
                            ( { givenModel | node = updatedNode }, outputsSoFar ++ outputFrame )
                    in
                    case Codec.decodeFromNode profileCodec modelWithTimeTempChanges.node of
                        Ok updatedProfile ->
                            ( { modelWithTimeTempChanges | profile = updatedProfile }
                            , Log.logSeparate "Saving with new frame" finalOutputFrame <| Cmd.batch [ Cmd.map (\m -> U m newTime) <| setStorage (Op.closedChunksToFrameText finalOutputFrame), Cmd.map (\m -> U m newTime) newCmds ]
                            )

                        Err problem ->
                            -- TODO error handling. ops are still added to node of model even if decode fails. Revert temp changes?
                            ( Log.logSeparate "Failed to decodeFromNode! Reverting update!" problem modelWithTimeTempChanges
                            , Cmd.map (\m -> U m newTime) newCmds
                            )

        Initialize userInitCmds zone time ->
            -- The only time we ever need to fetch the zone is at the start, and that's also when we need the time, so we combine them to reduce initial updates - this saves us one
            ( { wrappedModel | now = time, zone = zone }
            , Cmd.map (\cmds -> U cmds time) userInitCmds
            )


