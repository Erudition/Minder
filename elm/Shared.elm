module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    , profileChangeToString
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Activity.HistorySession exposing (HistorySession)
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Components.Odd as Odd
import Components.Replicator
import Effect exposing (Effect, incomingRon)
import Element exposing (..)
import Html exposing (Html)
import Integrations.Marvin as Marvin
import Integrations.Todoist as Todoist
import Json.Decode
import List.Nonempty exposing (Nonempty(..))
import Log
import NativeScript.Notification as Notif
import Profile exposing (Profile)
import Replicated.Change as Change exposing (Change, Parent)
import Replicated.Codec as Codec exposing (Codec, SkelCodec, WrappedOrSkelCodec)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg exposing (Msg(..))
import Shared.PopupType exposing (PopupType(..))
import SmartTime.Duration as Duration
import SmartTime.Human.Calendar
import SmartTime.Human.Clock
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment as HumanMoment exposing (Zone, utc)
import SmartTime.Moment as Moment exposing (Moment, zero)
import SmartTime.Period as Period exposing (Period)
import Task.ActionSkel as Action
import Task.Assignable as Assignable exposing (Assignable, AssignableID)
import Task.Assignment as Assignment exposing (Assignment, AssignmentID)
import Task.Layers
import Task.Progress
import Task.Project as Project exposing (Project)
import Task.ProjectSkel as ProjectSkel
import Task.SubAssignableSkel as SubAssignableSkel exposing (SubAssignableSkel)



-- FLAGS


type alias Flags =
    { darkTheme : Bool
    , launchTime : Moment
    , notifPermission : Notif.PermissionStatus
    }


{-| TODO can we get away without decoding?
-}
decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map3 Flags
        (Json.Decode.field "darkTheme" Json.Decode.bool)
        (Json.Decode.field "launchTime" (Json.Decode.map Moment.fromElmInt Json.Decode.int))
        (Json.Decode.field "notifPermission" Notif.permissonStatusDecoder)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            case flagsResult of
                Ok value ->
                    Debug.log "flags" value

                Err reason ->
                    Log.crashInDev ("Failed to decode startup flags. " ++ Json.Decode.errorToString reason)
                        { darkTheme = True
                        , launchTime = zero
                        , notifPermission = Notif.Prompt
                        }

        ( replicator, replica ) =
            Components.Replicator.init
                { launchTime = Just flags.launchTime
                , replicaCodec = Profile.codec
                , outPort = Effect.setStorage

                --, outPort = \stuffToWrite -> Effect.sendMsg (OddUpdate <| Odd.WriteFileContents stuffToWrite)
                }

        ( oddModel, oddInit ) =
            Odd.init
    in
    ( { time = zero -- temporary placeholder
      , replicator = replicator
      , timeZone = utc -- temporary placeholder
      , launchTime = flags.launchTime
      , notifPermission = flags.notifPermission
      , viewportSize = { width = 0, height = 0 }
      , viewportSizeClass = Element.Phone
      , windowVisibility = Browser.Events.Visible
      , systemSaysDarkTheme = flags.darkTheme
      , darkThemeOn = flags.darkTheme
      , modal = Nothing
      , replica = replica
      , tickEnabled = False
      , oddModel = oddModel
      }
    , Effect.none
      -- DISABLED FOR NOW -- Effect.sendCmd (Cmd.map OddUpdate oddInit)
      -- TODO Effect.saveChanges "init" initChanges
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg shared =
    case msg of
        NoUpdate ->
            ( shared
            , Effect.none
            )

        ProfileChange profileChange ->
            let
                ( afterHandlerShared, afterHandlerEffects ) =
                    profileUpdate Nothing profileChange shared
            in
            ( afterHandlerShared, afterHandlerEffects )

        Tick newTime ->
            ( { shared | time = newTime }, Effect.none )

        SetTickEnabled newSetting ->
            ( { shared | tickEnabled = newSetting }, Effect.none )

        ReplicatorUpdate replicatorMsg ->
            let
                { newReplicator, newReplica, cmd } =
                    Components.Replicator.update replicatorMsg shared.replicator
            in
            ( { shared | replicator = newReplicator, replica = newReplica }
            , Effect.sendCmd (Cmd.map ReplicatorUpdate cmd)
            )

        OddUpdate oddMsg ->
            let
                ( newOddModel, oddCmds ) =
                    Odd.update oddMsg shared.oddModel
            in
            ( { shared | oddModel = newOddModel }
            , Effect.sendCmd (Cmd.map OddUpdate oddCmds)
            )

        NotificationScheduled response ->
            -- TODO add to Shared notification tracker
            ( shared
            , Effect.none
            )

        GotNewTimeZone zone ->
            ( { shared | timeZone = zone, launchTime = shared.time }
              -- TODO^ only set zone, launchTime should be set at launch
            , Effect.none
            )

        ViewportResized newWidth newHeight ->
            ( { shared
                | viewportSize = { height = newHeight, width = newWidth }
                , viewportSizeClass = (Element.classifyDevice { height = newHeight, width = newWidth }).class
              }
            , Effect.none
            )

        VisibilityChanged newVisibility ->
            ( { shared | windowVisibility = newVisibility }
            , Effect.updateTime
            )

        ToggledDarkTheme isDark ->
            ( { shared | darkThemeOn = isDark }
            , Effect.none
            )

        WantsLogCleared ->
            -- TODO save changes to log replist
            ( shared, Effect.none )

        GotNotificationPermissionStatus result ->
            case result of
                Ok status ->
                    ( { shared | notifPermission = status }
                    , Effect.none
                    )

                Err taskPortErr ->
                    Log.logSeparate "taskport error"
                        taskPortErr
                        ( { shared | notifPermission = Notif.Denied }
                        , Effect.toast ("Failed to get permission for notifications. " ++ Debug.toString taskPortErr)
                        )

        GotTodoistServerResponse response ->
            let
                ( todoistChangeFrame, whatHappened ) =
                    Todoist.handle response shared.replica

                syncStatusChannel =
                    Notif.basicChannel "Sync Status"
                        |> Notif.setChannelDescription "Lets you know what happened the last time we tried to sync with online servers."
                        |> Notif.setChannelImportance Notif.High

                notification =
                    Notif.build syncStatusChannel
                        |> Notif.setID 23
                        |> Notif.setExpiresAfter (Duration.fromMinutes 1)
                        |> Notif.setTitle "Todoist Response"
                        |> Notif.setSubtitle "Sync Status"
                        |> Notif.setBody whatHappened
                        |> Notif.setBigTextStyle True
            in
            ( shared
            , Effect.batch
                [ Effect.sendNotifications [ notification ]
                , Effect.toast whatHappened
                , Effect.saveFrame todoistChangeFrame
                ]
            )

        GotMarvinServerResponse response ->
            let
                ( marvinChanges, whatHappened, nextStep ) =
                    Marvin.handle shared.replica ( shared.time, shared.timeZone ) response

                _ =
                    Profile.saveError shared.replica ("Synced with Marvin: \n" ++ whatHappened)

                syncStatusChannel =
                    Notif.basicChannel "Sync Status"
                        |> Notif.setChannelDescription "Lets you know what happened the last time we tried to sync with online servers."
                        |> Notif.setChannelImportance Notif.Min
                        |> Notif.setChannelGroup "Status"

                notification =
                    Notif.build syncStatusChannel
                        |> Notif.setExpiresAfter (Duration.fromMinutes 1)
                        |> Notif.setTitle "Marvin Response"
                        |> Notif.setSubtitle "Sync Status"
                        |> Notif.setBody whatHappened
                        |> Notif.setBigTextStyle True
                        |> Notif.setAccentColor "green"
                        |> Notif.setGroup (Notif.GroupKey "marvin")
            in
            ( shared
            , Effect.batch
                [ Effect.sendCmd (Cmd.map GotMarvinServerResponse <| nextStep)
                , Effect.sendNotifications [ notification ]
                , Effect.toast whatHappened
                , Effect.saveFrame marvinChanges
                , Effect.saveUserChanges "Log it temporarily" [ Profile.saveError shared.replica ("Synced with Marvin: \n" ++ whatHappened) ]
                ]
            )


profileUpdate : Maybe Moment -> Profile.UserChange -> Model -> ( Model, Effect Msg )
profileUpdate happenedMaybe profileChange shared =
    let
        frameDescription =
            profileChangeToString profileChange
    in
    case profileChange of
        Profile.AddProject newProjectTitle ->
            let
                newProjectSkel =
                    Project.createTopLevelSkel projectChanger

                projectChanger project =
                    [ Project.setTitle (Just newProjectTitle) project ]

                finalChanges =
                    [ RepDb.addNew newProjectSkel shared.replica.projects
                    ]
            in
            ( shared
            , Effect.saveUserChanges frameDescription finalChanges
            )


profileChangeToString : Profile.UserChange -> String
profileChangeToString profileChange =
    case profileChange of
        Profile.AddProject newProjectTitle ->
            "Created new project \"" ++ newProjectTitle ++ "\""



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route shared =
    let
        -- Old for reference:
        -- , storageChangedElsewhere NewAppData
        --, Browser.Events.onMouseMove <| JD.map2 MouseMoved decodeButtons decodeFraction
        --, SmartTime.Human.Moment.everySecondOnTheSecond model.time (\_ -> NoOp)
        tickSubscriptionMaybe =
            if shared.windowVisibility == Browser.Events.Visible && shared.tickEnabled then
                Just <| HumanMoment.everySecondOnTheSecond shared.time Tick

            else
                Nothing
    in
    Sub.batch <|
        List.filterMap identity
            [ Just <| Browser.Events.onVisibilityChange VisibilityChanged
            , Just <| Browser.Events.onResize (\width height -> ViewportResized width height)
            , tickSubscriptionMaybe
            , Just <| Sub.map ReplicatorUpdate (Components.Replicator.subscriptions incomingRon)
            ]
