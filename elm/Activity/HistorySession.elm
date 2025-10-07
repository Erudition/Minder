module Activity.HistorySession exposing (HistorySession, Timeline, activityIDMatches, activityTotalDuration, assignmentIDMatches, assignmentStartStopList, backfill, codec, current, currentActivityID, currentAssignmentID, currentlyTracking, duration, excusableLimit, excusableLimitWindow, excusedLeft, excusedUsage, getActivityID, getPeriodWithDefaultEnd, inHoursMinutes, justTodayTotal, listAsPeriods, periodsOfActivity, periodsOfAssignment, switchTracking, todayUntilNowPeriod, truncateTimeline)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import Activity.Evidence exposing (..)
import Activity.Template exposing (..)
import Dict exposing (..)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID
import IntDict
import List.Extra
import List.Nonempty exposing (..)
import Maybe.Extra
import Replicated.Change exposing (Change, Context)
import Replicated.Codec as Codec exposing ( coreR, coreRW, seededRW)
import Replicated.Reducer.Register exposing (RW, RWMaybe)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration exposing (..)
import SmartTime.Human.Moment as HumanMoment exposing (Zone)
import SmartTime.Moment as Moment exposing (..)
import SmartTime.Period as Period exposing (Period(..))
import Task.Assignment exposing (AssignmentID)
import Task.Layers exposing (ProjectLayers)
import TimeTrackable exposing (TimeTrackable)


type alias HistorySession =
    { started : RW Moment
    , endedMaybe : RWMaybe Moment
    , tracked : TimeTrackable
    }


codec :
    Codec.WrappedSeededCodec
        -- takes a HistorySessionSkel but without RWs
        { started : Moment
        , endedMaybe : Maybe Moment
        , tracked : TimeTrackable
        }
        HistorySession
codec =
    Codec.record HistorySession
        |> coreRW ( 1, "started" ) .started Codec.moment .started
        |> seededRW ( 2, "ended" ) .endedMaybe (Codec.maybe Codec.moment) Nothing .endedMaybe
        |> coreR ( 3, "tracked" ) .tracked TimeTrackable.codec .tracked
        |> Codec.finishSeededRecord


getActivityID : HistorySession -> ActivityID
getActivityID { tracked } =
    TimeTrackable.getActivityID tracked


{-| Get a session as a Period, using the given time as the cutoff for unended sessions.
-}
getPeriodWithDefaultEnd : Moment -> HistorySession -> Period
getPeriodWithDefaultEnd now session =
    Period.fromPair ( session.started.get, Maybe.withDefault now session.endedMaybe.get )


assignmentIDMatches : AssignmentID -> HistorySession -> Bool
assignmentIDMatches givenInstanceID { tracked } =
    TimeTrackable.getAssignmentID tracked
        |> Maybe.map ((==) givenInstanceID)
        |> Maybe.withDefault False


activityIDMatches : ActivityID -> HistorySession -> Bool
activityIDMatches givenID { tracked } =
    TimeTrackable.getActivityID tracked
        |> (==) givenID


duration : Moment -> HistorySession -> Duration
duration now { started, endedMaybe } =
    Moment.difference started.get (Maybe.withDefault now endedMaybe.get)


listAsPeriods sessionList =
    List.map getPeriodWithDefaultEnd sessionList



-- TIMELINE


type alias Timeline =
    List HistorySession


currentActivityID : Timeline -> ActivityID
currentActivityID timeline =
    let
        missingEndTime session =
            session.endedMaybe.get == Nothing
    in
    List.Extra.find missingEndTime timeline
        |> Maybe.map getActivityID
        |> Maybe.withDefault Activity.unknown


currentAssignmentID : Timeline -> Maybe AssignmentID
currentAssignmentID timeline =
    List.Extra.last timeline
        |> Maybe.map .tracked
        |> Maybe.andThen TimeTrackable.getAssignmentID


currentlyTracking : Timeline -> TimeTrackable
currentlyTracking timeline =
    List.Extra.last timeline
        |> Maybe.map .tracked
        |> Maybe.withDefault TimeTrackable.stub


current : Timeline -> Maybe HistorySession
current timeline =
    List.Extra.last timeline


{-| Narrow a timeline down to a given time frame.
This function takes two Moments (now and the point in history up to which we want to keep). It will cap off the list with a fake session at the end, set for the pastLimit, so that sessions that span the threshold still have their relevant portion counted.
-}
truncateTimeline : Timeline -> Period -> TruncatedTimeline
truncateTimeline timeline filterPeriod =
    let
        withinFilter givenMoment =
            Period.isWithin filterPeriod givenMoment

        keepWithinLimits : HistorySession -> Maybe TruncatedHistorySession
        keepWithinLimits sesh =
            let
                ended =
                    Maybe.withDefault (Period.end filterPeriod) sesh.endedMaybe.get
            in
            case ( withinFilter sesh.started.get, withinFilter ended ) of
                ( True, True ) ->
                    -- totally within our horizon
                    { period = Period sesh.started.get ended
                    , tracked = sesh.tracked
                    }
                        |> Just

                ( True, False ) ->
                    -- session starts within filter, but ends after it.
                    -- cut off from the end
                    { period = Period sesh.started.get (Period.end filterPeriod)
                    , tracked = sesh.tracked
                    }
                        |> Just

                ( False, True ) ->
                    -- session ends within filter, but starts before it.
                    -- cut off from the beginning
                    { period = Period (Period.start filterPeriod) ended
                    , tracked = sesh.tracked
                    }
                        |> Just

                ( False, False ) ->
                    -- out of bounds
                    Nothing
    in
    List.filterMap keepWithinLimits timeline


todayUntilNowPeriod : ( Moment, Zone ) -> Period
todayUntilNowPeriod ( now, zone ) =
    let
        threeAM =
            Duration.fromHours 3

        last3am =
            HumanMoment.clockTurnBack threeAM zone now
    in
    Period.between now last3am



-- mostRecentHistorySessionOfActivity : Period -> RawTimeline -> ActivityID -> Maybe HistorySession
-- mostRecentHistorySessionOfActivity filterPeriod timeline activity =
--     List.head (sessionsOfActivity filterPeriod wrappedTimeline activity)
-- TIMELINE SETTERS ---------------------------------


switchTracking : Moment -> TimeTrackable -> RepList HistorySession -> List Change
switchTracking now trackable timelineRepList =
    let
        newSession context =
            Codec.newWithSeed codec
                context
                { started = now
                , endedMaybe = Nothing
                , tracked = trackable
                }

        oldSessionMaybe =
            current (RepList.listValues timelineRepList)

        endOldSession =
            Maybe.map (\s -> s.endedMaybe.set (Just now)) oldSessionMaybe
                |> Maybe.Extra.toList
    in
    RepList.insertNew RepList.Last [ newSession ] timelineRepList
        :: endOldSession


backfill : RepList HistorySession -> List ( ActivityID, Maybe AssignmentID, Period ) -> List Change
backfill _ _ =
    -- case periodsToAdd of
    --     [] ->
    --         Log.logMessageOnly "nothing to backfill!" timeline
    --
    --     [ singlePeriod ] ->
    --         placeNewSession timeline singlePeriod
    --
    --     singlePeriod :: rest ->
    --         placeNewSession (backfill timeline rest) singlePeriod
    Debug.todo "fix backfill"



-- insertExternalSession : RawTimeline -> ( ActivityID, Maybe AssignmentID, Period ) -> List Change
-- insertExternalSession timeline ( candidateActivityID, candidateInstanceIDMaybe, candidatePeriod ) =
--     let
--         newSession : HistorySession
--         newSession =
--             HistorySession
--                 { start = Period.start candidatePeriod
--                 , end = Period.end candidatePeriod
--                 , tracked = candidateInstanceIDMaybe
--                 }
--     in
--     -- TODO check if it's there already
--     [ RepList.insert RepList.Last newSession timeline ]
-- PERIODS ----------------------------------------------------


type alias TruncatedTimeline =
    List TruncatedHistorySession


type alias TruncatedHistorySession =
    { period : Period
    , tracked : TimeTrackable
    }


periodsOfActivity : Period -> Timeline -> ActivityID -> List Period
periodsOfActivity filterPeriod timeline activityId =
    let
        getPeriodIfMatches sesh =
            if TimeTrackable.getActivityID sesh.tracked == activityId then
                Just sesh.period

            else
                Nothing
    in
    List.filterMap getPeriodIfMatches (truncateTimeline timeline filterPeriod)


periodsOfAssignment : Period -> Timeline -> AssignmentID -> List Period
periodsOfAssignment filterPeriod timeline givenAssignmentID =
    let
        getPeriodIfMatches sesh =
            if
                TimeTrackable.getAssignmentID sesh.tracked
                    |> Maybe.map ((==) givenAssignmentID)
                    |> Maybe.withDefault False
            then
                Just sesh.period

            else
                Nothing
    in
    List.filterMap getPeriodIfMatches (truncateTimeline timeline filterPeriod)



-- DURATIONS --------------------------------------------------
-- rely on Period functions first


activityTotalDuration : Period -> Timeline -> ActivityID -> Duration
activityTotalDuration filterPeriod rawTimeline activityId =
    Duration.combine (List.map Period.length (periodsOfActivity filterPeriod rawTimeline activityId))


{-| Total time used within the excused window.
-}
excusedUsage : Timeline -> Moment -> Activity -> Duration
excusedUsage timeline now activity =
    activityTotalDuration (Period.fromEnd now (dur (Tuple.first (Activity.excusableRatio activity)))) timeline (Activity.getID activity)


{-| Amount of time allowed to be Excused (within window)
-}
excusableLimit : Activity -> Duration
excusableLimit activity =
    dur (Tuple.first (Activity.excusableRatio activity))


{-| Length of the window in which excused time is limited.
-}
excusableLimitWindow : Activity -> Duration
excusableLimitWindow activity =
    dur (Tuple.second (Activity.excusableRatio activity))


{-| Total time NOT used within the excused window.
-}
excusedLeft : Timeline -> Moment -> Activity -> Duration
excusedLeft rawTimeline now activity =
    Duration.difference (excusableLimit activity) (excusedUsage rawTimeline now activity)


justTodayTotal : Timeline -> ( Moment, HumanMoment.Zone ) -> ActivityID -> Duration
justTodayTotal rawTimeline ( time, timeZone ) activityID =
    activityTotalDuration (todayUntilNowPeriod ( time, timeZone )) rawTimeline activityID



-- HELPERS ------------------------------------------------------


{-| TODO replace with smarttime library functions
-}
inHoursMinutes : Duration -> String
inHoursMinutes givenDuration =
    let
        durationInMs =
            Duration.inMs givenDuration

        hour =
            3600000

        wholeHours =
            durationInMs // hour

        wholeMinutes =
            (durationInMs - (wholeHours * hour)) // 60000

        hoursString =
            String.fromInt wholeHours ++ "h"

        minutesString =
            String.fromInt wholeMinutes ++ "m"
    in
    case ( wholeHours, wholeMinutes ) of
        ( 0, 0 ) ->
            minutesString

        ( _, 0 ) ->
            hoursString

        ( 0, _ ) ->
            minutesString

        ( _, _ ) ->
            hoursString ++ " " ++ minutesString


{-| Marvin needs a flat list of start/stop moments.
-}
assignmentStartStopList : Timeline -> AssignmentID -> List Moment
assignmentStartStopList rawTimeline givenAssignmentID =
    let
        getStartStopIfMatches sesh =
            if
                TimeTrackable.getAssignmentID sesh.tracked
                    |> Maybe.map ((==) givenAssignmentID)
                    |> Maybe.withDefault False
            then
                [ Just sesh.started.get, sesh.endedMaybe.get ]

            else
                []

        timesList : List Moment
        timesList =
            List.concatMap getStartStopIfMatches rawTimeline
                |> List.filterMap identity
    in
    -- TODO - what if there are multiple sessions without end times.
    List.Extra.uniqueBy Moment.toSmartInt timesList
