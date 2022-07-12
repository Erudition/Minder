module Task.Session exposing (..)

import Helpers exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Maybe.Extra
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.ActionClass exposing (ActionClassSkel, ParentProperties)
import Task.AssignedAction exposing (AssignedAction, AssignedActionSkel)
import Task.SessionSkel exposing (..)



-- FULL Sessions (augmented) -----------------------------------------------------------------


{-| A fully spec'ed-out version of a PlannedSession
-}
type alias FullSession =
    { parents : List ParentProperties
    , class : ActionClassSkel
    , instance : AssignedActionSkel
    , session : UserPlannedSession
    }



-- TODO replace this?


makeFullSession : AssignedAction -> UserPlannedSession -> FullSession
makeFullSession inherited justSession =
    { parents = inherited.parents
    , class = inherited.class
    , instance = inherited.instance
    , session = justSession
    }


{-| Get planned sessions for a FullInstance and build a FullSession list.
-}
getFullSessions : AssignedAction -> List FullSession
getFullSessions fullInstance =
    let
        ins =
            fullInstance.instance

        providedSessions =
            RepList.listValues ins.plannedSessions

        generatedSessions =
            let
                sessionStart =
                    -- TODO these are end, not start
                    Maybe.Extra.or ins.finishBy.get ins.externalDeadline.get

                taskDuration =
                    fullInstance.class.maxEffort.get
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
