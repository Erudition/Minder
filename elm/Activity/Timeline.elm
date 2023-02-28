module Activity.Timeline exposing (..)

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


type alias Timeline =
    { current : RW (Maybe CurrentSession)
    , history : RepList Session
    }


codec : Codec.SkelCodec String Timeline
codec =
    Codec.record Timeline
        |> Codec.maybeRW ( 1, "current" ) .current currentSessionCodec
        |> Codec.fieldList ( 2, "history" ) .history Session.codec
        |> Codec.finishRecord


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
currentActivityID timeline =
    case timeline.current.get of
        Just currentSession ->
            currentSession.activity

        Nothing ->
            Activity.unknown


historyLive : Moment -> Timeline -> List Session
historyLive now timeline =
    case currentAsFakeHistorySession now timeline of
        Nothing ->
            RepList.listValues timeline.history

        Just currentSesh ->
            currentSesh :: RepList.listValues timeline.history


sessionsOfActivity : Timeline -> ActivityID -> List Session
sessionsOfActivity timeline activityId =
    List.filter (Session.activityMatches activityId) (RepList.listValues timeline.history)


currentInstanceID : Timeline -> Maybe AssignedActionID
currentInstanceID timeline =
    Maybe.andThen .action timeline.current.get


sessionsOfInstance : Timeline -> AssignedActionID -> List Session
sessionsOfInstance timeline instance =
    List.filter (Session.instanceMatches instance) (RepList.listValues timeline.history)


{-| Narrow a timeline down to a given time frame.
This function takes two Moments (now and the point in history up to which we want to keep). It will cap off the list with a fake session at the end, set for the pastLimit, so that sessions that span the threshold still have their relevant portion counted.
-}
limitedTimeline : Timeline -> Moment -> Moment -> Timeline
limitedTimeline timeline now pastLimit =
    -- let
    --     sessionActivityID session =
    --         Session.getActivityID session
    --
    --     recentEnough session =
    --         Moment.compare (Session.getMoment session) pastLimit == Later
    --
    --     ( pass, fail ) =
    --         List.partition recentEnough timeline
    --
    --     justMissedId =
    --         Maybe.withDefault Activity.unknown <| Maybe.map sessionActivityID (List.head fail)
    --
    --     fakeEndSession =
    --         sessionToActivity pastLimit justMissedId
    -- in
    -- pass ++ [ fakeEndSession ]
    Debug.todo "timeline limit"


relevantTimeline : Timeline -> Moment -> HumanDuration -> Timeline
relevantTimeline timeline now duration =
    limitedTimeline timeline now (Moment.past now (dur duration))


onlyToday : Timeline -> ( Moment, Zone ) -> Timeline
onlyToday timeline ( now, zone ) =
    let
        threeAM =
            Duration.fromHours 3

        last3am =
            HumanMoment.clockTurnBack threeAM zone now
    in
    limitedTimeline timeline now last3am


mostRecentHistorySessionOfActivity : Timeline -> ActivityID -> Maybe Session
mostRecentHistorySessionOfActivity timeline activity =
    List.head (sessionsOfActivity timeline activity)


{-| internal only
-}
currentAsFakeHistorySession : Moment -> Timeline -> Maybe Session
currentAsFakeHistorySession now timeline =
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
currentToHistory timeline now =
    case currentAsFakeHistorySession now timeline of
        Nothing ->
            []

        Just currentSesh ->
            [ RepList.insert RepList.Last currentSesh timeline.history ]


startTask : Moment -> ActivityID -> AssignedActionID -> Timeline -> List Change
startTask now newActivityID instanceID timeline =
    let
        newCurrent : CurrentSession
        newCurrent =
            { start = now
            , activity = newActivityID
            , action = Just instanceID
            }
    in
    timeline.current.set (Just newCurrent) :: currentToHistory timeline now


startActivity : Moment -> ActivityID -> Timeline -> List Change
startActivity now newActivityID timeline =
    let
        newCurrent : CurrentSession
        newCurrent =
            { start = now
            , activity = newActivityID
            , action = Nothing
            }
    in
    timeline.current.set (Just newCurrent) :: currentToHistory timeline now


backfill : Timeline -> List ( ActivityID, Maybe AssignedActionID, Period ) -> List Change
backfill timeline periodsToAdd =
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
insertExternalSession timeline ( candidateActivityID, candidateInstanceIDMaybe, candidatePeriod ) =
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
currentAsPeriod now timeline =
    let
        currentSessionStarted =
            Maybe.map .start timeline.current.get
                |> Maybe.withDefault now
    in
    Period.fromPair ( currentSessionStarted, now )


periodsOfInstance : Timeline -> AssignedActionID -> List Period
periodsOfInstance timeline givenInstanceID =
    sessionsOfInstance timeline givenInstanceID
        |> Session.listAsPeriods


periodsOfInstanceLive : Moment -> Timeline -> AssignedActionID -> List Period
periodsOfInstanceLive now timeline givenInstanceID =
    let
        historyPeriods =
            periodsOfInstance timeline givenInstanceID
    in
    if Maybe.andThen .action timeline.current.get == Just givenInstanceID then
        currentAsPeriod now timeline :: historyPeriods

    else
        historyPeriods


periodsOfActivity : Timeline -> ActivityID -> List Period
periodsOfActivity timeline activityID =
    sessionsOfActivity timeline activityID
        |> Session.listAsPeriods


periodsOfActivityLive : Moment -> Timeline -> ActivityID -> List Period
periodsOfActivityLive now timeline activityID =
    let
        historyPeriods =
            periodsOfActivity timeline activityID
    in
    if Maybe.map .activity timeline.current.get == Just activityID then
        currentAsPeriod now timeline :: historyPeriods

    else
        historyPeriods


periodsLive : Moment -> Timeline -> List Period
periodsLive now timeline =
    currentAsPeriod now timeline :: Session.listAsPeriods (RepList.listValues timeline.history)



-- DURATIONS --------------------------------------------------
-- rely on Period functions first


activityTotalDuration : Timeline -> ActivityID -> Duration
activityTotalDuration timeline activityId =
    Duration.combine (List.map Period.length (periodsOfActivity timeline activityId))


activityTotalDurationLive : Moment -> Timeline -> ActivityID -> Duration
activityTotalDurationLive now timeline activityID =
    Duration.combine (List.map Period.length (periodsOfActivityLive now timeline activityID))


{-| Total time used within the excused window.
-}
excusedUsage : Timeline -> Moment -> ( ActivityID, Activity ) -> Duration
excusedUsage timeline now ( activityID, activity ) =
    let
        lastExcusablePeriodTimeline =
            relevantTimeline timeline now (Tuple.first (Activity.excusableRatio activity))
    in
    activityTotalDurationLive now lastExcusablePeriodTimeline activityID


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
excusedLeft timeline now ( activityID, activity ) =
    Duration.difference (excusableLimit activity) (excusedUsage timeline now ( activityID, activity ))


justTodayTotal : Timeline -> Environment -> ActivityID -> Duration
justTodayTotal timeline env activityID =
    let
        onlyTodayTimeline =
            onlyToday timeline ( env.time, env.timeZone )
    in
    activityTotalDurationLive env.time onlyTodayTimeline activityID



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
instanceUniqueMomentsList timeline instanceID =
    let
        periods =
            periodsOfInstance timeline instanceID

        timesList =
            List.concatMap (\p -> [ Period.start p, Period.end p ]) periods
    in
    List.uniqueBy Moment.toSmartInt timesList
