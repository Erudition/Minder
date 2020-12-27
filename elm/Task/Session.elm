module Task.Session exposing (..)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Maybe.Extra
import Porting exposing (..)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Class exposing (ClassSkel, ParentProperties)
import Task.Instance exposing (Instance, InstanceSkel)
import Task.SessionSkel exposing (..)



-- FULL Sessions (augmented) -----------------------------------------------------------------


{-| A fully spec'ed-out version of a PlannedSession
-}
type alias FullSession =
    { parents : List ParentProperties
    , class : ClassSkel
    , instance : InstanceSkel
    , session : UserPlannedSession
    }



-- TODO replace this?


makeFullSession : Instance -> UserPlannedSession -> FullSession
makeFullSession inherited justSession =
    { parents = inherited.parents
    , class = inherited.class
    , instance = inherited.instance
    , session = justSession
    }


{-| Get planned sessions for a FullInstance and build a FullSession list.
-}
getFullSessions : Instance -> List FullSession
getFullSessions fullInstance =
    let
        ins =
            fullInstance.instance

        providedSessions =
            ins.plannedSessions

        generatedSessions =
            let
                sessionStart =
                    Maybe.Extra.or ins.finishBy ins.externalDeadline

                taskDuration =
                    fullInstance.class.maxEffort
            in
            case sessionStart of
                Just foundStart ->
                    [ ( foundStart, taskDuration ) ]

                Nothing ->
                    Debug.log "No sessionStart found" []

        attachSession =
            makeFullSession fullInstance
    in
    List.map attachSession providedSessions
        ++ List.map attachSession generatedSessions
