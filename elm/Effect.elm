port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    , PromptOptions, cancelNotification, clearPreferences, closePopup, dialogPrompt, incomingRon, mlPredict, requestNotificationPermission, saveChanges, saveFrame, saveFrames, sendNotifications, setStorage, syncMarvin, syncTodoist, toast
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs map, toCmd

-}

import Browser.Navigation
import Components.Replicator
import Dict exposing (Dict)
import Http
import Integrations.Marvin as Marvin
import Integrations.Todoist as Todoist
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as JE exposing (Value)
import Json.Encode.Extra as JE
import ML.OnlineChat
import NativeScript.Notification as Notif
import Process
import Profile exposing (Profile)
import Replicated.Change as Change
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg
import Task
import TaskPort
import Url exposing (Url)


{-| Effects that can be run from anywhere within the program.
Naming Convention: Use "action to take" phrasing (command verbs), not "what happened" phrasing (that's for Msg).
-}
type Effect msg
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
      -- REPLICATOR
    | Save (List Change.Frame)
      -- EXTERNAL APP
    | ClearPreferences
    | RequestNotificationPermission
    | SendNotifications (List Notif.Notification)
    | CancelNotification Notif.NotificationID
    | Toast String
    | DialogPrompt (Result TaskPort.Error String -> msg) PromptOptions
      -- INTEGRATIONS
    | SyncTodoist
    | SyncMarvin
      -- Ion
    | ClosePopup
    | FocusIonInput String
      -- Internet
    | MLPredict (Result String ML.OnlineChat.Prediction -> msg) ML.OnlineChat.Prediction



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or `Random.generate`.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


{-| Set the new route, but replace the previous one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


{-| Redirect users to a new URL, somewhere external your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl


clearPreferences =
    ClearPreferences


type alias PromptOptions =
    { title : Maybe String
    , message : String
    , okButtonTitle : Maybe String
    , cancelButtonTitle : Maybe String
    , inputPlaceholder : Maybe String
    , inputText : Maybe String
    }


dialogPrompt :
    (Result TaskPort.Error String -> msg)
    -> PromptOptions
    -> Effect msg
dialogPrompt toMsg promptOptions =
    DialogPrompt toMsg promptOptions


closePopup =
    ClosePopup


toast : String -> Effect msg
toast toastMsg =
    Toast toastMsg


saveFrame : Change.Frame -> Effect msg
saveFrame changeFrame =
    Save [ changeFrame ]


saveFrames : List Change.Frame -> Effect msg
saveFrames changeFrames =
    Save changeFrames


saveChanges : String -> List Change.Change -> Effect msg
saveChanges frameTitle changes =
    saveFrame (Change.saveChanges frameTitle changes)


sendNotifications : List Notif.Notification -> Effect msg
sendNotifications notifList =
    SendNotifications notifList


cancelNotification : Notif.NotificationID -> Effect msg
cancelNotification notifID =
    CancelNotification notifID


mlPredict =
    MLPredict



-- {- The goal here is to get (mouse x / window width) on each mouse event. So if
--    the mouse is at 500px and the screen is 1000px wide, we should get 0.5 from this.
--    Getting the mouse x is not too hard, but getting window width is a bit tricky.
--    We want the window.innerWidth value, which happens to be available at:
--        event.currentTarget.defaultView.innerWidth
--    The value at event.currentTarget is the document in these cases, but this will
--    not work if you have a <section> or a <div> with a normal elm/html event handler.
--    So if currentTarget is NOT the document, you should instead get the value at:
--        event.currentTarget.ownerDocument.defaultView.innerWidth
--                            ^^^^^^^^^^^^^
-- -}
-- decodeFraction : JD.Decoder Float
-- decodeFraction =
--     JD.map2 (/)
--         (JD.field "pageX" JD.float)
--         (JD.at [ "currentTarget", "defaultView", "innerWidth" ] JD.float)
-- {- What happens when the user is dragging, but the "mouse up" occurs outside
--    the browser window? We need to stop listening for mouse movement and end the
--    drag. We use MouseEvent.buttons to detect this:
--        https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/buttons
--    The "buttons" value is 1 when "left-click" is pressed, so we use that to
--    detect zombie drags.
-- -}
-- decodeButtons : JD.Decoder Bool
-- decodeButtons =
--     JD.field "buttons" (JD.map (\buttons -> buttons == 1) JD.int)


syncTodoist : Effect Shared.Msg.Msg
syncTodoist =
    batch
        [ toast "Reached out to Todoist server for sync..."
        , SyncTodoist
        ]


syncMarvin : Effect Shared.Msg.Msg
syncMarvin =
    batch
        [ toast "Reached out to Marvin server for sync..."
        , SyncMarvin
        ]


requestNotificationPermission =
    RequestNotificationPermission



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into the overall app.
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg

        ClearPreferences ->
            ClearPreferences

        RequestNotificationPermission ->
            RequestNotificationPermission

        SyncTodoist ->
            SyncTodoist

        SyncMarvin ->
            SyncMarvin

        SendNotifications list ->
            SendNotifications list

        CancelNotification notifID ->
            CancelNotification notifID

        Save frame ->
            Save frame

        ClosePopup ->
            ClosePopup

        MLPredict toMsg prompt ->
            MLPredict (fn << toMsg) prompt

        Toast toastMsg ->
            Toast toastMsg

        DialogPrompt toMsg prompt ->
            DialogPrompt (fn << toMsg) prompt

        FocusIonInput inputID ->
            FocusIonInput inputID


{-| Final conversion of Effects to raw Cmds.
Elm Land depends on this function to perform our effects.
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    let
        sharedMsgTaskAttempt : (Result error value -> Shared.Msg.Msg) -> Task.Task error value -> Cmd msg
        sharedMsgTaskAttempt resultHandler theTask =
            Task.attempt (options.fromSharedMsg << resultHandler) theTask
    in
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            Task.succeed sharedMsg
                |> Task.perform options.fromSharedMsg

        ClearPreferences ->
            let
                clearPreferencesTaskPort : TaskPort.Task ()
                clearPreferencesTaskPort =
                    TaskPort.callNoArgs
                        { function = "changePassphrase"
                        , valueDecoder = TaskPort.ignoreValue
                        }
            in
            sharedMsgTaskAttempt (\_ -> Shared.Msg.NoUpdate) clearPreferencesTaskPort

        RequestNotificationPermission ->
            sharedMsgTaskAttempt Shared.Msg.GotNotificationPermissionStatus Notif.requestPermisson

        SyncTodoist ->
            Cmd.map (options.fromSharedMsg << Shared.Msg.GotTodoistServerResponse) <|
                Todoist.fetchUpdates options.shared.replica.todoist

        SyncMarvin ->
            Cmd.map (options.fromSharedMsg << Shared.Msg.GotMarvinServerResponse) <|
                Marvin.getLabelsCmd

        SendNotifications notifList ->
            ns_notify (JE.list Notif.encode notifList)

        CancelNotification id ->
            ns_notify_cancel (JE.int id)

        Save frames ->
            Cmd.map (options.fromSharedMsg << Shared.Msg.ReplicatorUpdate) <|
                Components.Replicator.saveEffect frames

        ClosePopup ->
            Debug.todo "close popup port/taskport"

        MLPredict toMsg prompt ->
            ML.OnlineChat.predict toMsg prompt

        Toast toastMsg ->
            toastPort toastMsg

        DialogPrompt toMsg promptOptions ->
            Task.attempt toMsg (dialogPromptTaskPort promptOptions)

        FocusIonInput inputToFocus ->
            Process.sleep 100
                |> Task.andThen (\_ -> ionInputSetFocus inputToFocus)
                |> Task.attempt (\_ -> Shared.Msg.NoUpdate)
                |> Cmd.map options.fromSharedMsg



-- PORTS --------------------------------------------------------


port incomingRon : (String -> msg) -> Sub msg


port ns_notify : JE.Value -> Cmd msg


port ns_notify_cancel : JE.Value -> Cmd msg


port ns_toast : JE.Value -> Cmd msg


port toastPort : String -> Cmd msg


port setStorage : String -> Cmd msg



-- TASKPORTS ------------------------------------------


dialogPromptTaskPort : PromptOptions -> TaskPort.Task String
dialogPromptTaskPort inOptions =
    let
        optionsEncoder : PromptOptions -> JE.Value
        optionsEncoder promptOptions =
            JE.object
                [ ( "title"
                  , case promptOptions.title of
                        Just title ->
                            JE.string title

                        Nothing ->
                            JE.null
                  )
                , ( "message"
                  , JE.string promptOptions.message
                  )
                , ( "okButtonTitle"
                  , case promptOptions.okButtonTitle of
                        Just okButtonTitle ->
                            JE.string okButtonTitle

                        Nothing ->
                            JE.null
                  )
                , ( "cancelButtonTitle"
                  , case promptOptions.cancelButtonTitle of
                        Just cancelButtonTitle ->
                            JE.string cancelButtonTitle

                        Nothing ->
                            JE.null
                  )
                , ( "inputPlaceholder"
                  , case promptOptions.inputPlaceholder of
                        Just inputPlaceholder ->
                            JE.string inputPlaceholder

                        Nothing ->
                            JE.null
                  )
                , ( "inputText"
                  , case promptOptions.inputText of
                        Just inputText ->
                            JE.string inputText

                        Nothing ->
                            JE.null
                  )
                ]
    in
    TaskPort.call
        { function = "dialogPrompt"
        , valueDecoder = JD.at [ "value" ] JD.string
        , argsEncoder = optionsEncoder
        }
        inOptions


ionInputSetFocus : String -> TaskPort.Task ()
ionInputSetFocus ionInputIDToFocus =
    TaskPort.call
        { function = "ionInputSetFocus"
        , valueDecoder = TaskPort.ignoreValue
        , argsEncoder = JE.string
        }
        ionInputIDToFocus
