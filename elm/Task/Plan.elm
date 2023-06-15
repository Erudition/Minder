module Task.Plan exposing (..)

import Environment exposing (Environment)
import List.Extra as List
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Duration exposing (HumanDuration(..), dur)
import SmartTime.Period exposing (Period)
import Task.Assignable as Class
import Task.Assignment as Instance exposing (Assignment)
import Task.Entry as Entry


{-| Current Idea: Go through list of To-Be-Planned in this order

1.  Lay down all fixed sessions. If conflicts found, work around but generate warnings:
    a) external events (can't be moved anyway)
    b) user-preplanned sessions (may move slightly due to fuzziness)
    c) tasks with a suggested timeslot
2.  In importance order, lay down remaining CONSTRAINED sessions in as-late-as-possible position
      - Break down chunked tasks into minimum # of sessions
      - Calculate acceptable time window for each session, push to very end
      - If conflict, shift <-SOONER until it fits

-}
type alias PlannedSession =
    { source : GenerationSource
    , mustBeOutOfPreferredTimeslot : Bool
    , mustBeLate : Bool
    , seriesOrder : ( Int, Int )
    }


type GenerationSource
    = User
    | Auto


type alias SessionConstraints =
    { instance : Assignment
    , allowedWindow : Period
    , duration : Duration
    , chunkMaximum : Duration
    , chunkMinimum : Duration
    , chunkIdeal : Duration
    }



--autoPlan : List FullSession ->


{-| Step 1. Get potential sessions out of the task list.

Tasks with pre-planned timeslots start out constrained
all other tasks start out unconstrained

For efficiency, we filter out :

  - Completed tasks
  - Expired tasks
  - The currently-in-progress task (start from after it's done)
  - Unready tasks IF they will not become ready at any point within the current window
  - TODO what else?

Conflicts that can arise already at this level:

  - A task has a prerequisite task which we cannot fit before it (prereq window is all later than task window)
  - Two tasks that require the same timeslot
  - A task that does not fit into its timeslot, when spillover is disallowed
  - A task is already late from the get-go (unacknowledged) - just a warning
  - TODO what else?

Extra constraints to consider besides start-end window:

  - Preferred timeslots, of course
  - Saturation of day
  - Buffer before/after/between tasks
  - TODO what else?

Problem: How do we prevent trying to plan infinitely into the future? The further out we go, the more instances we'll have to consider (considering e.g. infinite daily tasks) when planning closer tasks, so we have to plan those future instances as well ad infinitum.
Idea: What if we fill and sample tasks ONLY from a time window with a hard start and end moment - BUT it's a growing window where we start small - ex. try only planning today - then when you need more time for those tasks you grow the window, ex. new end time tomorrow - and for all the new time added you sample the task list again to make sure it's filled with the next day's tasks as well. Keep growing until everything is planned

Problem: How do we guess the best starting size, for efficiency?
Idea: The sum of all task durations is the least amount of time the user will need to complete everything, so let's go at least that far out! But wait, how do we choose the period to sample tasks from. Just one day?

Problem: There are theoretical race conditions. For example, every future day is completely booked with recurring task(s). We'd keep growing the window, never to find room for our session.
Idea: If the sum of all task durations only continues to grow, and never shrink (due to solutions found), we can give up. The algorithm can quit with a special Conflict. Should not happen in practice?

Order in which to make compromises to current plan in order to fit something in?

  - ?
  - Push later a task with higher importance but later due date
  - Ignore a condition on a task's preferred conditions list
  - Change a task's chunking plan
  - ?

And only if that fails (after applying to all possible tasks!), resort to:

  - Let a task be late
  - Miss a task entirely

Idea: Step through list, attempt planning without compromises, if fail, start again with one compromise, then another, and so on incrementally until success or until last resort conditions should be tried
Problem: What if that takes forever

-}
buildConstraintsList : Environment -> List Assignment -> Period -> ( List SessionConstraints, List Conflict )
buildConstraintsList env instances growingSearchWindow =
    let
        makePreplannedSession =
            []

        generated =
            List.mapAccuml (constraintsFromInstance env) instances

        combinedList =
            preplanned ++ generated
    in
    ( combinedList, conflicts )



-- take an instance, generate sessionConstraints, attempt to add it to list


constraintsFromInstance : ( List SessionConstraints, List Conflict ) -> Period -> Assignment -> ( List SessionConstraints, List Conflict )
constraintsFromInstance ( existingSCs, existingConflicts ) searchWindow instance =
    let
        instances =
            Debug.todo "instances"

        newSessionConstraints =
            { instance = instance
            , allowedWindow = decideAllowedWindow env instance
            , duration = instance.class.predictedEffort
            , chunkMaximum = dur (Hours 6)
            , chunkMinimum = dur (Minutes 20)
            , chunkIdeal = dur (Minutes 90)
            }
    in
    case conflictFound of
        Just conflict ->
            ( existingSCs, existingConflicts ++ conflict )

        Nothing ->
            ( existingSCs ++ newSessionConstraints, existingConflicts )


type alias Conflict =
    { instance : Assignment
    , resolutions : List Resolution
    }


type alias Resolution =
    List ResolutionAction


type ResolutionAction
    = MissOrEliminate Assignment
    | FinishLate Assignment
