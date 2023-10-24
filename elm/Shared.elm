module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Activity.HistorySession exposing (HistorySession)
import Browser.Events
import Browser.Navigation as Nav exposing (..)
import Effect exposing (Effect)
import Element exposing (..)
import External.Commands exposing (..)
import Html exposing (Html)
import Integrations.Marvin as Marvin
import Integrations.Todoist as Todoist
import Json.Decode
import List.Nonempty exposing (Nonempty(..))
import Log
import NativeScript.Commands exposing (..)
import NativeScript.Notification as Notif
import Profile exposing (Profile)
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



-- FLAGS


type alias Flags =
    { darkTheme : Bool }


{-| TODO can we get away without decoding?
-}
decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "darkTheme" Json.Decode.bool)



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
                    value

                Err reason ->
                    { darkTheme = True
                    }
    in
    ( { time = zero -- temporary placeholder

      --, navkey = maybeKey -- passed from init
      , timeZone = utc -- temporary placeholder
      , launchTime = zero -- temporary placeholder
      , notifPermission = Notif.Denied
      , viewportSize = { width = 0, height = 0 }
      , viewportSizeClass = Element.Phone
      , windowVisibility = Browser.Events.Visible
      , darkThemeActive = flags.darkTheme
      , modal = Nothing
      , replica = Debug.todo "init replica"
      }
    , Effect.none
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

        Save frame ->
            -- TODO
            ( shared
            , Effect.none
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
            , Effect.none
            )

        ToggledDarkTheme isDark ->
            ( { shared | darkThemeActive = isDark }
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
                , Effect.saveChanges "Log it temporarily" [ Profile.saveError shared.replica ("Synced with Marvin: \n" ++ whatHappened) ]
                ]
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    let
        -- Old for reference:
        -- , storageChangedElsewhere NewAppData
        --, Browser.Events.onMouseMove <| JD.map2 MouseMoved decodeButtons decodeFraction
        --, SmartTime.Human.Moment.everySecondOnTheSecond model.time (\_ -> NoOp)
        alwaysSubscriptions =
            Sub.batch <|
                [ Browser.Events.onVisibilityChange VisibilityChanged ]

        visibleOnlySubscriptions =
            if model.windowVisibility == Browser.Events.Visible then
                Sub.batch <|
                    [ HumanMoment.everyMinuteOnTheMinute model.time (\_ -> NoUpdate)
                    , Browser.Events.onResize (\width height -> ViewportResized width height)
                    ]

            else
                Sub.none
    in
    Sub.batch [ alwaysSubscriptions, visibleOnlySubscriptions ]