module Activity.Timeline exposing (Timeline, activityTotalDuration, activityTotalDurationLive, backfill, codec, currentActivity, currentActivityID, currentAsPeriod, currentInstanceID, currentToHistory, excusableLimit, excusableLimitWindow, excusedLeft, excusedUsage, historyBackByHumanDuration, historyBackByHumanDurationLive, historyLive, inHoursMinutes, insertExternalSession, instanceUniqueMomentsList, justTodayTotal, limitedHistory, limitedHistoryLive, mostRecentHistorySessionOfActivity, onlyToday, periodsLive, periodsOfActivity, periodsOfActivityLive, periodsOfInstance, periodsOfInstanceLive, sessionsOfActivity, sessionsOfInstance, startActivity, startTask)

import Activity.Activity as Activity exposing (..)
import Activity.Evidence exposing (..)
import Activity.Session as Session exposing (..)
import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import Environment exposing (..)
import External.Commands as Commands exposing (..)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import IntDict exposing (IntDict)
import Ionicon
import Ionicon.Android as Android
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import List.Nonempty exposing (..)
import Log
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (Codec, coreR, coreRW, field, fieldRW)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepList as RepList exposing (InsertionPoint(..), RepList)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Human.Moment as HumanMoment exposing (Zone, utc)
import SmartTime.Moment as Moment exposing (..)
import SmartTime.Period as Period exposing (Period)
import Svg.Styled exposing (..)
import Task.AssignedAction exposing (AssignedAction, AssignedActionID)
import Time
import Time.Distance exposing (..)
import Time.Extra exposing (..)


type Timeline
    = Timeline TimelineSkel


type alias TimelineSkel =
    { current : RW (Maybe CurrentSession)
    , history : RepList Session
    }


codec : Codec String Codec.Skel Codec.SoloObject Timeline
codec =
    Codec.record TimelineSkel
        |> Codec.maybeRW ( 1, "current" ) .current currentSessionCodec
        |> Codec.fieldList ( 2, "history" ) .history Session.codec
        |> Codec.finishRecord
        |> Codec.makeOpaque Timeline (\(Timeline skel) -> skel)


type alias CurrentSession =
    { start : Moment
    , activity : ActivityID
    , action : Maybe AssignedActionID
    }


currentSessionCodec : Codec String CurrentSession Codec.SoloObject CurrentSession
currentSessionCodec =
    Codec.record CurrentSession
        |> coreR ( 1, "start" ) .start Codec.moment .start
        |> coreR ( 2, "activity" ) .activity Activity.idCodec .activity
        |> coreR ( 3, "action" ) .action (Codec.maybe Codec.id) .action
        |> Codec.finishSeededRecord



-- TIMELINE (OR TIMELINE SESSION) GETTERS ---------------------------------


currentActivity : Activity.Store -> Timeline -> Activity
currentActivity store timeline =
    Activity.getByID (currentActivityID timeline) store


currentActivityID : Timeline -> ActivityID
currentActivityID ((Timeline timeline) as wrappedTimeline) =
    case timeline.current.get of
        Just currentSession ->
            currentSession.activity

        Nothing ->
            Activity.unknown


historyLive : Moment -> Timeline -> List Session
historyLive now ((Timeline timeline) as wrappedTimeline) =
    case currentAsFakeHistorySession now wrappedTimeline of
        Nothing ->
            RepList.listValues timeline.history

        Just currentSesh ->
            currentSesh :: RepList.listValues timeline.history


sessionsOfActivity : Period -> Timeline -> ActivityID -> List Session
sessionsOfActivity filterPeriod ((Timeline timeline) as wrappedTimeline) activityId =
    List.filter (Session.activityMatches activityId) (limitedHistory wrappedTimeline filterPeriod)


currentInstanceID : Timeline -> Maybe AssignedActionID
currentInstanceID ((Timeline timeline) as wrappedTimeline) =
    Maybe.andThen .action timeline.current.get


sessionsOfInstance : Timeline -> AssignedActionID -> List Session
sessionsOfInstance ((Timeline timeline) as wrappedTimeline) instance =
    List.filter (Session.instanceMatches instance) (RepList.listValues timeline.history)


{-| Narrow a timeline down to a given time frame.
This function takes two Moments (now and the point in history up to which we want to keep). It will cap off the list with a fake session at the end, set for the pastLimit, so that sessions that span the threshold still have their relevant portion counted.
-}
limitedHistoryLive : Timeline -> Period -> Moment -> List Session
limitedHistoryLive ((Timeline timeline) as wrappedTimeline) filterPeriod now =
    let
        history =
            limitedHistory wrappedTimeline filterPeriod
    in
    case currentAsFakeHistorySession now wrappedTimeline of
        Nothing ->
            history

        Just currentSesh ->
            currentSesh :: history


limitedHistory : Timeline -> Period -> List Session
limitedHistory (Timeline timeline) filterPeriod =
    let
        withinFilter givenMoment =
            Period.isWithin filterPeriod givenMoment

        keepWithinLimits : Session -> Maybe Session
        keepWithinLimits sesh =
            case ( withinFilter (Session.getStart sesh), withinFilter (Session.getEnd sesh) ) of
                ( True, True ) ->
                    -- totally within our horizon
                    Just sesh

                ( True, False ) ->
                    -- session starts within filter, but ends after it.
                    -- cut off from the end
                    Session.new
                        { start = Session.getStart sesh
                        , end = Period.end filterPeriod
                        , activity = Session.getActivityID sesh
                        , action = Session.getInstanceID sesh
                        }
                        |> Just

                ( False, True ) ->
                    -- session ends within filter, but starts before it.
                    -- cut off from the beginning
                    Session.new
                        { start = Period.start filterPeriod
                        , end = Session.getEnd sesh
                        , activity = Session.getActivityID sesh
                        , action = Session.getInstanceID sesh
                        }
                        |> Just

                ( False, False ) ->
                    -- out of bounds
                    Nothing
    in
    List.filterMap keepWithinLimits (RepList.listValues timeline.history)


historyBackByHumanDuration : Timeline -> Moment -> HumanDuration -> List Session
historyBackByHumanDuration ((Timeline timeline) as wrappedTimeline) now duration =
    limitedHistory wrappedTimeline (Period.fromEnd now (dur duration))


historyBackByHumanDurationLive : Timeline -> Moment -> HumanDuration -> List Session
historyBackByHumanDurationLive ((Timeline timeline) as wrappedTimeline) now duration =
    limitedHistoryLive wrappedTimeline (Period.fromEnd now (dur duration)) now


onlyToday : ( Moment, Zone ) -> Period
onlyToday ( now, zone ) =
    let
        threeAM =
            Duration.fromHours 3

        last3am =
            HumanMoment.clockTurnBack threeAM zone now
    in
    Period.between now last3am


mostRecentHistorySessionOfActivity : Period -> Timeline -> ActivityID -> Maybe Session
mostRecentHistorySessionOfActivity filterPeriod ((Timeline timeline) as wrappedTimeline) activity =
    List.head (sessionsOfActivity filterPeriod wrappedTimeline activity)


{-| internal only
-}
currentAsFakeHistorySession : Moment -> Timeline -> Maybe Session
currentAsFakeHistorySession now ((Timeline timeline) as wrappedTimeline) =
    let
        fake currentSesh =
            Session.new
                { start = currentSesh.start
                , end = now
                , activity = currentSesh.activity
                , action = currentSesh.action
                }
    in
    Maybe.map fake timeline.current.get



-- TIMELINE SETTERS ---------------------------------


currentToHistory : Timeline -> Moment -> List Change
currentToHistory ((Timeline timeline) as wrappedTimeline) now =
    case currentAsFakeHistorySession now wrappedTimeline of
        Nothing ->
            []

        Just currentSesh ->
            [ RepList.insert RepList.Last currentSesh timeline.history ]


startTask : Moment -> ActivityID -> AssignedActionID -> Timeline -> List Change
startTask now newActivityID instanceID ((Timeline timeline) as wrappedTimeline) =
    let
        newCurrent : CurrentSession
        newCurrent =
            { start = now
            , activity = newActivityID
            , action = Just instanceID
            }
    in
    timeline.current.set (Just newCurrent) :: currentToHistory wrappedTimeline now


startActivity : Moment -> ActivityID -> Timeline -> List Change
startActivity now newActivityID ((Timeline timeline) as wrappedTimeline) =
    let
        newCurrent : CurrentSession
        newCurrent =
            { start = now
            , activity = newActivityID
            , action = Nothing
            }
    in
    timeline.current.set (Just newCurrent) :: currentToHistory wrappedTimeline now


backfill : Timeline -> List ( ActivityID, Maybe AssignedActionID, Period ) -> List Change
backfill ((Timeline timeline) as wrappedTimeline) periodsToAdd =
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


insertExternalSession : Timeline -> ( ActivityID, Maybe AssignedActionID, Period ) -> List Change
insertExternalSession ((Timeline timeline) as wrappedTimeline) ( candidateActivityID, candidateInstanceIDMaybe, candidatePeriod ) =
    let
        newSession : Session
        newSession =
            Session.new
                { start = Period.start candidatePeriod
                , end = Period.end candidatePeriod
                , activity = candidateActivityID
                , action = candidateInstanceIDMaybe
                }
    in
    -- TODO check if it's there already
    [ RepList.insert RepList.Last newSession timeline.history ]



-- PERIODS ----------------------------------------------------


currentAsPeriod : Moment -> Timeline -> Period
currentAsPeriod now ((Timeline timeline) as wrappedTimeline) =
    let
        currentSessionStarted =
            Maybe.map .start timeline.current.get
                |> Maybe.withDefault now
    in
    Period.fromPair ( currentSessionStarted, now )


periodsOfInstance : Timeline -> AssignedActionID -> List Period
periodsOfInstance ((Timeline timeline) as wrappedTimeline) givenInstanceID =
    sessionsOfInstance wrappedTimeline givenInstanceID
        |> Session.listAsPeriods


periodsOfInstanceLive : Moment -> Timeline -> AssignedActionID -> List Period
periodsOfInstanceLive now ((Timeline timeline) as wrappedTimeline) givenInstanceID =
    let
        historyPeriods =
            periodsOfInstance wrappedTimeline givenInstanceID
    in
    if Maybe.andThen .action timeline.current.get == Just givenInstanceID then
        currentAsPeriod now wrappedTimeline :: historyPeriods

    else
        historyPeriods


periodsOfActivity : Period -> Timeline -> ActivityID -> List Period
periodsOfActivity filterPeriod ((Timeline timeline) as wrappedTimeline) activityID =
    sessionsOfActivity filterPeriod wrappedTimeline activityID
        |> Session.listAsPeriods


periodsOfActivityLive : Period -> Moment -> Timeline -> ActivityID -> List Period
periodsOfActivityLive filterPeriod now ((Timeline timeline) as wrappedTimeline) activityID =
    let
        historyPeriods =
            periodsOfActivity filterPeriod wrappedTimeline activityID
    in
    if Maybe.map .activity timeline.current.get == Just activityID then
        currentAsPeriod now wrappedTimeline :: historyPeriods

    else
        historyPeriods


periodsLive : Moment -> Timeline -> List Period
periodsLive now ((Timeline timeline) as wrappedTimeline) =
    currentAsPeriod now wrappedTimeline :: Session.listAsPeriods (RepList.listValues timeline.history)



-- DURATIONS --------------------------------------------------
-- rely on Period functions first


activityTotalDuration : Period -> Timeline -> ActivityID -> Duration
activityTotalDuration filterPeriod ((Timeline timeline) as wrappedTimeline) activityId =
    Duration.combine (List.map Period.length (periodsOfActivity filterPeriod wrappedTimeline activityId))


activityTotalDurationLive : Period -> Moment -> Timeline -> ActivityID -> Duration
activityTotalDurationLive filterPeriod now ((Timeline timeline) as wrappedTimeline) activityID =
    Duration.combine (List.map Period.length (periodsOfActivityLive filterPeriod now wrappedTimeline activityID))


activityTotalDurationLimitedLive : Period -> Moment -> Timeline -> ActivityID -> Duration
activityTotalDurationLimitedLive period now ((Timeline timeline) as wrappedTimeline) activityID =
    Duration.combine (List.map Period.length (periodsOfActivityLive period now wrappedTimeline activityID))


{-| Total time used within the excused window.
-}
excusedUsage : Timeline -> Moment -> ( ActivityID, Activity ) -> Duration
excusedUsage ((Timeline timeline) as wrappedTimeline) now ( activityID, activity ) =
    activityTotalDurationLive (Period.fromEnd now (dur (Tuple.first (Activity.excusableRatio activity)))) now wrappedTimeline activityID


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
excusedLeft : Timeline -> Moment -> ( ActivityID, Activity ) -> Duration
excusedLeft ((Timeline timeline) as wrappedTimeline) now ( activityID, activity ) =
    Duration.difference (excusableLimit activity) (excusedUsage wrappedTimeline now ( activityID, activity ))


justTodayTotal : Timeline -> ( Moment, HumanMoment.Zone ) -> ActivityID -> Duration
justTodayTotal ((Timeline timeline) as wrappedTimeline) ( time, timeZone ) activityID =
    activityTotalDurationLive (onlyToday ( time, timeZone )) time wrappedTimeline activityID



-- HELPERS ------------------------------------------------------


{-| TODO replace with smarttime library functions
-}
inHoursMinutes : Duration -> String
inHoursMinutes duration =
    let
        durationInMs =
            Duration.inMs duration

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
instanceUniqueMomentsList : Timeline -> AssignedActionID -> List Moment
instanceUniqueMomentsList ((Timeline timeline) as wrappedTimeline) instanceID =
    let
        periods =
            periodsOfInstance wrappedTimeline instanceID

        timesList =
            List.concatMap (\p -> [ Period.start p, Period.end p ]) periods
    in
    List.uniqueBy Moment.toSmartInt timesList
