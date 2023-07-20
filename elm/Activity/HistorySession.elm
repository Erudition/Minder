module Activity.HistorySession exposing (HistorySession, activityMatches, codec, duration, getActivityID, getEnd, getPeriod, getStart, getTrackable, instanceMatches, listAsPeriods, makeMetaHistorySession)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import Activity.Evidence exposing (..)
import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import IntDict exposing (IntDict)
import Ionicon
import Ionicon.Android as Android
import List.Nonempty exposing (..)
import Replicated.Codec as Codec exposing (Codec, SelfSeededCodec, coreR, coreRW, field, fieldDict, fieldList, fieldRW, seededRW)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import SmartTime.Period exposing (Period)
import Task.Assignment exposing (AssignmentID)
import Task.Project exposing (ProjectSkel)
import TimeTrackable exposing (TimeTrackable, TimeTrackableID)


type HistorySession
    = HistorySession
        { started : RW Moment
        , ended : RW Moment
        , tracked : TimeTrackable
        }


type alias HistorySessionSkel =
    { started : RW Moment
    , ended : RW (Maybe Moment)
    , tracked : TimeTrackableID
    }


codec :
    Codec
        String
        -- takes a HistorySessionSkel but without RWs
        { started : Moment
        , ended : Maybe Moment
        , tracked : TimeTrackableID
        }
        Codec.SoloObject
        HistorySessionSkel
codec =
    Codec.record HistorySessionSkel
        |> coreRW ( 1, "started" ) .started Codec.moment .started
        |> seededRW ( 2, "ended" ) .ended (Codec.maybe Codec.moment) Nothing .ended
        |> coreR ( 3, "tracked" ) .tracked TimeTrackable.idCodec .tracked
        |> Codec.finishSeededRecord


makeMetaHistorySession :
    HistorySessionSkel
    -> Activity.Store
    -> RepList ProjectSkel
    -> HistorySession
makeMetaHistorySession { started, ended, tracked } activities projects =
    let
        timeTrackable =
            TimeTrackable.fromID activities projects tracked

        fallbackEndMoment =
            -- temporary solution, should use task goals and such
            Activity.getMaxTimePortion (TimeTrackable.getActivity timeTrackable)
                |> Tuple.first
                -- get the max duration numerator, denominator not considered for now, so this will be generous
                |> Moment.future started.get

        -- that long after the start, is the default end time
    in
    HistorySession started { ended | get = Maybe.withDefault fallbackEndMoment ended.get } timeTrackable


getActivityID : HistorySession -> ActivityID
getActivityID (HistorySession { activity }) =
    activity


getStart : HistorySession -> Moment
getStart (HistorySession { started }) =
    started.get


getEnd : HistorySession -> Moment
getEnd (HistorySession { ended }) =
    ended.get


getTrackable : HistorySession -> TimeTrackable
getTrackable (HistorySession { tracked }) =
    tracked


getPeriod : HistorySession -> Period
getPeriod (HistorySession session) =
    SmartTime.Period.fromPair ( session.started, session.ended )


instanceMatches : AssignmentID -> HistorySession -> Bool
instanceMatches givenInstanceID (HistorySession givenSession) =
    case givenSession.action of
        Just foundInstance ->
            foundInstance == givenInstanceID

        Nothing ->
            False


activityMatches : ActivityID -> HistorySession -> Bool
activityMatches givenActivity (HistorySession givenSession) =
    givenActivity == givenSession.activity


duration : HistorySession -> Duration
duration (HistorySession session) =
    Moment.difference session.started.get session.ended.get


listAsPeriods sessionList =
    List.map getPeriod sessionList
