module Task.Session exposing (..)

import Helpers exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Maybe.Extra
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Action exposing (TrackableLayerProperties)
import Task.Assignable
import Task.Assignment exposing (AssignmentSkel)
import Task.Meta exposing (..)
import Task.SessionSkel exposing (..)



-- FULL Sessions (augmented) -----------------------------------------------------------------


{-| A fully spec'ed-out version of a PlannedSession
-}
type alias FullSession =
    { parents : List (Reg TrackableLayerProperties)
    , assignable : Reg Task.Assignable.AssignableSkel
    , assignment : Reg AssignmentSkel
    , session : UserPlannedSession
    }



-- TODO replace this?


makeFullSession : Assignment -> UserPlannedSession -> FullSession
makeFullSession inherited justSession =
    { parents = inherited.parents
    , assignable = inherited.assignable
    , assignment = inherited.assignment
    , session = justSession
    }


{-| Get planned sessions for a FullInstance and build a FullSession list.
-}
getFullSessions : Assignment -> List FullSession
getFullSessions fullInstance =
    let
        ins =
            Reg.latest fullInstance.assignment

        class =
            Reg.latest fullInstance.assignable

        providedSessions =
            RepList.listValues ins.plannedSessions

        generatedSessions =
            let
                sessionStart =
                    -- TODO these are end, not start
                    Maybe.Extra.or ins.finishBy.get ins.externalDeadline.get

                taskDuration =
                    class.maxEffort.get
            in
            case sessionStart of
                Just foundStart ->
                    [ ( foundStart, taskDuration ) ]

                Nothing ->
                    []

        attachSession =
            makeFullSession fullInstance
    in
    List.map attachSession providedSessions
        ++ List.map attachSession generatedSessions


duration : FullSession -> Duration
duration fullSession =
    Tuple.second fullSession.session


start fullSession =
    Tuple.first fullSession.session
