module Activity.Session exposing (Session, activityMatches, codec, duration, getActivityID, getEnd, getInstanceID, getPeriod, getStart, instanceMatches, listAsPeriods, new)

import Activity.Activity exposing (Activity, ActivityID)
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
import Replicated.Codec as Codec exposing (Codec, SelfSeededCodec, coreR, coreRW, field, fieldDict, fieldList, fieldRW)
import Replicated.Reducer.Register as Register exposing (RW)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import SmartTime.Period exposing (Period)
import Task.Assignment exposing (AssignmentID)


type Session
    = Session SessionSkel


type alias SessionSkel =
    { start : Moment
    , end : Moment
    , activity : ActivityID
    , action : Maybe AssignmentID
    }


codec : Codec String Session Codec.SoloObject Session
codec =
    Codec.record SessionSkel
        |> coreR ( 1, "start" ) .start Codec.moment .start
        |> coreR ( 2, "end" ) .end Codec.moment .end
        |> coreR ( 3, "activity" ) .activity Activity.Activity.idCodec .activity
        |> Codec.seededR ( 4, "action" ) .action (Codec.maybe Codec.id) Nothing .action
        |> Codec.finishSeededRecord
        |> Codec.map Session (\(Session skel) -> skel)


new :
    { start : Moment
    , end : Moment
    , activity : ActivityID
    , action : Maybe AssignmentID
    }
    -> Session
new sessionDetails =
    Session sessionDetails


getActivityID : Session -> ActivityID
getActivityID (Session { activity }) =
    activity


getStart : Session -> Moment
getStart (Session { start }) =
    start


getEnd : Session -> Moment
getEnd (Session { end }) =
    end


getInstanceID : Session -> Maybe AssignmentID
getInstanceID (Session { action }) =
    action


getPeriod : Session -> Period
getPeriod (Session session) =
    SmartTime.Period.fromPair ( session.start, session.end )


instanceMatches : AssignmentID -> Session -> Bool
instanceMatches givenInstanceID (Session givenSession) =
    case givenSession.action of
        Just foundInstance ->
            foundInstance == givenInstanceID

        Nothing ->
            False


activityMatches : ActivityID -> Session -> Bool
activityMatches givenActivity (Session givenSession) =
    givenActivity == givenSession.activity


duration : Session -> Duration
duration (Session session) =
    Moment.difference session.start session.end


listAsPeriods sessionList =
    List.map getPeriod sessionList
