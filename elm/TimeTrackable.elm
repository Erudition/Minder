module TimeTrackable exposing (TimeTrackable, codec, getActivityID, getAssignmentID, stub)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import Dict.Any exposing (AnyDict)
import ID exposing (ID)
import Replicated.Codec as Codec exposing (NullCodec)
import Replicated.Reducer.RepList exposing (RepList)
import Task.Action as Action exposing (Action, ActionID)
import Task.ActionSkel exposing (ActionSkel)
import Task.Assignable as Assignable exposing (Assignable, AssignableID)
import Task.AssignableSkel exposing (AssignableID, AssignableSkel)
import Task.AssignedAction as AssignedAction exposing (AssignedAction)
import Task.AssignedActionSkel exposing (AssignedActionID, AssignedActionSkel)
import Task.Assignment as Assignment exposing (Assignment, AssignmentID(..))
import Task.AssignmentSkel as Assignment exposing (AssignmentSkel, ManualAssignmentDb)
import Task.Progress as Progress exposing (Progress)
import Task.ProjectSkel as Project exposing (NestedOrAssignable(..), ProjectID, ProjectSkel)
import Task.Series exposing (Series)
import Task.SubAssignable as SubAssignable exposing (SubAssignable, SubAssignableID)
import Task.SubAssignableSkel exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


{-| Any timetrackable item. Can be a raw activity, or any layer of an assignment, but it must have an activity to be trackable, so the activity is required to be included.
-}
type TimeTrackable
    = TrackedActivityID ActivityID
    | TrackedAssignmentID AssignmentID ActivityID
    | TrackedSubAssignmentID AssignmentID SubAssignableID ActivityID
    | TrackedAssignedActionID AssignedActionID ActivityID


codec : NullCodec String TimeTrackable
codec =
    Codec.customType
        (\trackedActivityID trackedAssignableID trackedSubAssignableID trackedAssignedActionID value ->
            case value of
                TrackedActivityID activityID ->
                    trackedActivityID activityID

                TrackedAssignmentID assignmentID activityID ->
                    trackedAssignableID assignmentID activityID

                TrackedSubAssignmentID assignmentID subAssignableID activityID ->
                    trackedSubAssignableID assignmentID subAssignableID activityID

                TrackedAssignedActionID assignedActionID activityID ->
                    trackedAssignedActionID assignedActionID activityID
        )
        |> Codec.variant1 ( 1, "TrackedActivityID" ) TrackedActivityID Activity.idCodec
        |> Codec.variant2 ( 2, "TrackedAssignmentID" ) TrackedAssignmentID Assignment.idCodec Activity.idCodec
        |> Codec.variant3 ( 3, "TrackedSubAssignmentID" ) TrackedSubAssignmentID Assignment.idCodec Codec.id Activity.idCodec
        |> Codec.variant2 ( 4, "TrackedAssignedActionID" ) TrackedAssignedActionID Codec.id Activity.idCodec
        |> Codec.finishCustomType


getActivityID : TimeTrackable -> ActivityID
getActivityID trackable =
    case trackable of
        TrackedActivityID activity ->
            activity

        TrackedAssignmentID _ activity ->
            activity

        TrackedSubAssignmentID _ _ activity ->
            activity

        TrackedAssignedActionID _ activity ->
            activity


getAssignmentID : TimeTrackable -> Maybe AssignmentID
getAssignmentID trackable =
    case trackable of
        TrackedActivityID activity ->
            Nothing

        TrackedAssignmentID assignment activity ->
            Just assignment

        TrackedSubAssignmentID sub _ activity ->
            Debug.todo "getAssignment from SubAssignment"

        TrackedAssignedActionID assignedAction activity ->
            Debug.todo "getAssignment from TrackAssignedAction"


stub : TimeTrackable
stub =
    TrackedActivityID Activity.unknown
