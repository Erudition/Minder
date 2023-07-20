module TimeTrackable exposing (TimeTrackable, TimeTrackableID, fromID, getActivity, idCodec)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import ID exposing (ID)
import Replicated.Codec as Codec exposing (NullCodec)
import Replicated.Reducer.RepList exposing (RepList)
import Task.Action exposing (ContainerOfActionsID, SubAssignable)
import Task.Assignable exposing (AssignableID)
import Task.AssignedAction exposing (AssignedActionID)
import Task.Assignment exposing (AssignmentID)
import Task.Meta exposing (Assignable, AssignedAction, Assignment)
import Task.Project exposing (ProjectSkel)


{-| Any timetrackable item. Can be a raw activity, or any layer of an assignment, but it must have an activity to be trackable, so the activity is required to be included.
-}
type TimeTrackable
    = TrackActivity Activity
    | TrackAssignment Assignment Activity
    | TrackSubAssignment SubAssignable Activity -- TODO
    | TrackAssignedAction AssignedAction Activity


{-| still need to save activityIDs because tasks return a Maybe ActivityID.
-}
type TimeTrackableID
    = TrackedActivityID ActivityID
    | TrackedAssignmentID AssignmentID ActivityID
    | TrackedSubAssignmentID AssignmentID ContainerOfActionsID ActivityID
    | TrackedAssignedActionID AssignedActionID ActivityID


idCodec : NullCodec String TimeTrackableID
idCodec =
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
        |> Codec.variant2 ( 2, "TrackedAssignableID" ) TrackedAssignmentID Codec.id Activity.idCodec
        |> Codec.variant3 ( 3, "TrackedSubAssignableID" ) TrackedSubAssignmentID Codec.id Codec.id Activity.idCodec
        |> Codec.variant2 ( 4, "TrackedAssignedActionID" ) TrackedAssignedActionID Codec.id Activity.idCodec
        |> Codec.finishCustomType


fromID : Activity.Store -> RepList ProjectSkel -> TimeTrackableID -> TimeTrackable
fromID activities projects timeTrackableID =
    let
        activityFromID activityID =
            Activity.getByID activityID activities

        assignmentFromID assignableID =
            Task.Meta.assignableFromID assignableID

        subAssignableFromID assignmentID subAssignableID =
            Debug.todo "subAssignableFromID"

        assignedActionFromID assignedActionID =
            Debug.todo "assignedActionID"
    in
    case timeTrackableID of
        TrackedActivityID activityID ->
            TrackActivity <| activityFromID activityID

        TrackedAssignmentID assignableID activityID ->
            TrackAssignment (assignmentFromID assignableID) (activityFromID activityID)

        TrackedSubAssignmentID assignmentID subAssignableID activityID ->
            TrackSubAssignment (subAssignableFromID assignmentID subAssignableID) (activityFromID activityID)

        TrackedAssignedActionID assignedActionID activityID ->
            TrackAssignedAction (assignedActionFromID assignedActionID) (activityFromID activityID)


getActivity : TimeTrackable -> Activity
getActivity trackable =
    case trackable of
        TrackActivity activity ->
            activity

        TrackAssignment _ activity ->
            activity

        TrackSubAssignment _ activity ->
            activity

        TrackAssignedAction _ activity ->
            activity
