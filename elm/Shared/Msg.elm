module Shared.Msg exposing (Msg(..))

{-| -}

import Browser.Events
import Components.Odd
import Components.Replicator
import Incubator.Todoist as Todoist
import Integrations.Marvin as Marvin
import NativeScript.Notification as Notif
import Profile
import Replicated.Change as Change
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment exposing (Zone)
import SmartTime.Moment exposing (Moment)
import TaskPort


{-| Shared Messages.
Naming Convention: Use "what happened" phrasing, not "action to take" (verb) phrasing (that's for Effects).
-}
type Msg
    = NoUpdate
    | ProfileChange Profile.UserChange
    | Tick Moment
    | ReplicatorUpdate (Components.Replicator.Msg String)
    | OddUpdate Components.Odd.Msg
      --| RunEffects (List (Effect.Effect Msg))
    | WantsLogCleared
    | ViewportResized Int Int
    | VisibilityChanged Browser.Events.Visibility
    | GotNewTimeZone Zone
    | ToggledDarkTheme Bool
    | NotificationScheduled (TaskPort.Result String)
    | GotNotificationPermissionStatus (TaskPort.Result Notif.PermissionStatus)
    | GotTodoistServerResponse Todoist.Msg
    | GotMarvinServerResponse Marvin.Msg
    | SetTickEnabled Bool
