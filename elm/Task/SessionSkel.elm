module Task.SessionSkel exposing (..)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Maybe.Extra
import Porting exposing (..)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Class exposing (ClassSkel, ParentProperties)



-- Session skeletons (bare minimum data, saved to disk) -----------------------------------------


{-| One time chunk during which a task is scheduled. Most tasks are done in one session, but this allows for breaking up longer tasks into sessions and scheduling those individually.

(when it starts, how long it lasts)

-}
type alias UserPlannedSession =
    ( FuzzyMoment, Duration )


decodeSession : Decoder UserPlannedSession
decodeSession =
    let
        decodeFuzzyMoment =
            Porting.customDecoder Decode.string HumanMoment.fuzzyFromString
    in
    Porting.arrayAsTuple2 decodeFuzzyMoment decodeDuration


encodeSession : UserPlannedSession -> Encode.Value
encodeSession plannedSession =
    Debug.todo "encode plannedSessions"
