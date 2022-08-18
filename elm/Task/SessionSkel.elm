module Task.SessionSkel exposing (..)

import ExtraCodecs as Codec
import Helpers exposing (..)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Maybe.Extra
import Replicated.Codec as Codec exposing (Codec, fieldDict, coreR, coreRW, fieldR, fieldList, fieldRW)
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.ActionClass exposing (ActionClassSkel, ParentProperties)



-- Session skeletons (bare minimum data, saved to disk) -----------------------------------------


{-| One time chunk during which a task is scheduled. Most tasks are done in one session, but this allows for breaking up longer tasks into sessions and scheduling those individually.

(when it starts, how long it lasts)

-}
type alias UserPlannedSession =
    ( FuzzyMoment, Duration )


codec : Codec String UserPlannedSession
codec =
    Codec.pair Codec.fuzzyMoment Codec.duration


decodeSession : Decoder UserPlannedSession
decodeSession =
    Helpers.arrayAsTuple2 decodeFuzzyMoment decodeDuration


encodeSession : UserPlannedSession -> Encode.Value
encodeSession plannedSession =
    Helpers.encodeTuple2 Helpers.encodeFuzzyMoment Helpers.encodeDuration plannedSession
