module Activity.Timeline exposing (..)

import Activity.Activity as Activity exposing (..)
import Activity.Evidence exposing (..)
import Activity.Switch as Switch exposing (..)
import Activity.Template exposing (..)
import Date
import Dict exposing (..)
import Environment exposing (..)
import External.Commands as Commands exposing (..)
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
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Human.Moment as HumanMoment exposing (Zone, utc)
import SmartTime.Moment as Moment exposing (..)
import SmartTime.Period as Period exposing (Period)
import Svg.Styled exposing (..)
import Task.Instance exposing (Instance, InstanceID)
import Time
import Time.Distance exposing (..)
import Time.Extra exposing (..)


type alias Timeline =
    List Switch


latestSwitch : Timeline -> Switch
latestSwitch timeline =
    Maybe.withDefault (switchToActivity Moment.zero (ID.tag 0)) (List.head timeline)


currentActivityID : Timeline -> ActivityID
currentActivityID switchList =
    Switch.getActivityID (latestSwitch switchList)


currentInstanceID : Timeline -> Maybe InstanceID
currentInstanceID switchList =
    Switch.getInstanceID (latestSwitch switchList)


currentActivity : StoredActivities -> Timeline -> Activity
currentActivity storedActivities switchList =
    getActivity (currentActivityID switchList) (Activity.allActivities storedActivities)


startTask : Moment -> ActivityID -> InstanceID -> Timeline -> Timeline
startTask time newActivityID instanceID timeline =
    Switch.newSwitch time newActivityID (Just instanceID) :: timeline


startActivity : Moment -> ActivityID -> Timeline -> Timeline
startActivity time newActivityID timeline =
    Switch.newSwitch time newActivityID Nothing :: timeline


backfill : Timeline -> List ( ActivityID, Maybe InstanceID, Period ) -> Timeline
backfill timeline periodsToAdd =
    Debug.todo "List.foldl placeNewSession timeline periodsToAdd"


placeNewSession : Timeline -> ( ActivityID, Maybe InstanceID, Period ) -> Timeline
placeNewSession switchList ( candidateActivityID, candidateInstanceIDMaybe, candidatePeriod ) =
    -- NOTE: don't forget the timeline is always backwards. Later switches come
    -- first!
    let
        indexedSwitchList =
            -- add an index so we know where to insert it back later
            List.indexedMap Tuple.pair switchList

        withinBounds ( _, switch ) =
            -- we're only interested in moments that are within the candidate
            -- we also don't care if the moment is the very end of our period
            -- (because switches are start times and the next switch auto
            -- becomes the end time )
            -- thus, a switch of interest is same/later than period start
            -- but earlier than period end.
            (Moment.compare (Switch.getMoment switch) (Period.start candidatePeriod) /= Moment.Earlier)
                && (Moment.compare (Switch.getMoment switch) (Period.end candidatePeriod) == Moment.Earlier)

        areaToSearch =
            List.filter withinBounds indexedSwitchList

        alignsWithStart switch =
            Moment.isSame (Period.start candidatePeriod) (Switch.getMoment switch)

        alignsWithEnd switch =
            Moment.isSame (Period.end candidatePeriod) (Switch.getMoment switch)

        foundEndSwitchAt index =
            -- do we see a switch at the candidate end moment at the index
            Maybe.map alignsWithEnd (List.getAt index switchList) == Just True

        candidateAsSwitch =
            newSwitch (Period.start candidatePeriod) candidateActivityID candidateInstanceIDMaybe

        candidateEndAsSwitch =
            newSwitch (Period.end candidatePeriod) candidateActivityID Nothing

        isConflict switch =
            -- if tested switch has no instanceID, not a conflict. If same, not a conflict. If different, conflict!
            Switch.getInstanceID switch /= candidateInstanceIDMaybe

        reSort timeline =
            -- put a timeline back in order. TODO "stable" sort relevance?
            List.sortWith (\a b -> Moment.compareEarliness (Switch.getMoment a) (Switch.getMoment b)) timeline

        insertAt index item items =
            -- because List.Extra.insertAt PR is still not merged
            let
                ( start, end ) =
                    List.splitAt index items
            in
            start ++ [ item ] ++ end

        addEndingSwitch startIndex =
            -- same timeline with stopper added
            insertAt (startIndex - 1) candidateEndAsSwitch switchList
    in
    case areaToSearch of
        -- dealing with the list of all switches that intersect with candidate.
        [] ->
            -- Candidate period either before everything, after everything
            -- or takes up partial space in between some two. Safe to insert.
            -- TODO better way to insert?
            -- currently appending and then re-sorting the whole list
            reSort (candidateAsSwitch :: switchList)

        [ ( indexOfConcern, switchOfConcern ) ] ->
            -- only one switch during that time. was it at the same time?
            case ( isConflict switchOfConcern, alignsWithStart switchOfConcern, foundEndSwitchAt (indexOfConcern - 1) ) of
                ( False, True, True ) ->
                    -- we have a winner. we'll update that switch!
                    List.setAt indexOfConcern candidateAsSwitch switchList

                ( False, True, False ) ->
                    -- found the start switch, but period ends before next
                    -- switch. We'll have to add in our own stop switch.
                    List.setAt indexOfConcern candidateAsSwitch (addEndingSwitch indexOfConcern)

                ( True, _, _ ) ->
                    -- uh oh, that switch already has an instanceID set, and it
                    -- is not the same as our candidate... abort!
                    Log.log "Conflict when backfilling! Investigate!" switchList

        _ ->
            -- oops, we already have multiple changes going on within that
            -- period, abort
            Log.log "Found multiple events within backfill period, won't backfill this!" switchList



-- FROM Measure


{-| Mind if I doodle here?

    switchList: [Run @ 10,  Jog @ 8,    Walk @ 5,    Eat @4 ]
    (-1) V         (-)         (-)         (-)          X
    offsetList: [Jog @ 8,   Walk @ 5,   Eat @ 4   ]
                   (=)         (=)        (=)
    session: ...[Jog 2,     Walk 3,     Eat 1     ]

-}
allSessions : List Switch -> List ( ActivityID, Duration )
allSessions switchList =
    let
        offsetList =
            List.drop 1 switchList
    in
    List.map2 session switchList offsetList


session : Switch -> Switch -> ( ActivityID, Duration )
session newer older =
    ( Switch.getActivityID older, Moment.difference (Switch.getMoment newer) (Switch.getMoment older) )


sessions : List Switch -> ActivityID -> List Duration
sessions switchList activityId =
    let
        all =
            allSessions switchList

        isMatchingDuration : ActivityID -> ( ActivityID, Duration ) -> Maybe Duration
        isMatchingDuration targetId ( itemId, dur ) =
            if itemId == targetId then
                Just dur

            else
                Nothing
    in
    List.filterMap (isMatchingDuration activityId) all


total : List Switch -> ActivityID -> Duration
total switchList activityId =
    Duration.combine (sessions switchList activityId)


totalLive : Moment -> List Switch -> ActivityID -> Duration
totalLive now switchList activityId =
    let
        fakeSwitch =
            switchToActivity now activityId
    in
    Duration.combine (sessions (fakeSwitch :: switchList) activityId)


{-| Narrow a timeline down to a given time frame.
This function takes two Moments (now and the point in history up to which we want to keep). It will cap off the list with a fake switch at the end, set for the pastLimit, so that sessions that span the threshold still have their relevant portion counted.
-}
timelineLimit : Timeline -> Moment -> Moment -> Timeline
timelineLimit timeline now pastLimit =
    let
        switchActivityID switch =
            Switch.getActivityID switch

        recentEnough switch =
            Moment.compare (Switch.getMoment switch) pastLimit == Later

        ( pass, fail ) =
            List.partition recentEnough timeline

        justMissedId =
            Maybe.withDefault Activity.dummy <| Maybe.map switchActivityID (List.head fail)

        fakeEndSwitch =
            switchToActivity pastLimit justMissedId
    in
    pass ++ [ fakeEndSwitch ]


{-| Given a HumanDuration, how far back in time would it reach?
This returns that Moment in history.

For fixed distances, that's easy -- but variable intervals could be far back or just a millisecond ago.

-}
lookBack : Moment -> HumanDuration -> Moment
lookBack present humanDuration =
    Moment.past present (dur humanDuration)


relevantTimeline : Timeline -> Moment -> HumanDuration -> Timeline
relevantTimeline timeline now duration =
    timelineLimit timeline now (lookBack now duration)


justToday : Timeline -> ( Moment, Zone ) -> Timeline
justToday timeline ( now, zone ) =
    let
        threeAM =
            Duration.fromHours 3

        last3am =
            HumanMoment.clockTurnBack threeAM zone now
    in
    timelineLimit timeline now last3am


justTodayTotal : Timeline -> Environment -> ActivityID -> Duration
justTodayTotal timeline env activityID =
    let
        lastPeriod =
            justToday timeline ( env.time, env.timeZone )
    in
    totalLive env.time lastPeriod activityID


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


{-| Total time used within the excused window.
-}
excusedUsage : Timeline -> Moment -> ( ActivityID, Activity ) -> Duration
excusedUsage timeline now ( activityID, activity ) =
    let
        lastPeriod =
            relevantTimeline timeline now (Tuple.first (Activity.excusableFor activity))
    in
    totalLive now lastPeriod activityID


{-| Amount of time allowed to be Excused (within window)
-}
excusableLimit : Activity -> Duration
excusableLimit activity =
    dur (Tuple.first (Activity.excusableFor activity))


{-| Length of the the window in which excused time is limited.
-}
excusableLimitWindow : Activity -> Duration
excusableLimitWindow activity =
    dur (Tuple.second (Activity.excusableFor activity))


{-| Total time NOT used within the excused window.
-}
excusedLeft : Timeline -> Moment -> ( ActivityID, Activity ) -> Duration
excusedLeft timeline now ( activityID, activity ) =
    Duration.difference (excusableLimit activity) (excusedUsage timeline now ( activityID, activity ))


lastSession : Timeline -> ActivityID -> Maybe Duration
lastSession timeline old =
    List.head (sessions timeline old)



-- ------------------------------------------------------------------------------------------------
-- Below: Migrating to use SmartTime instead


switchListLiveToPeriods : Moment -> List Switch -> List ( ActivityID, Period )
switchListLiveToPeriods now switchList =
    let
        fakeSwitch =
            switchToActivity now (Maybe.withDefault dummy latestActivityID)

        latestActivityID =
            Maybe.map Switch.getActivityID (List.head switchList)
    in
    switchListToPeriods (fakeSwitch :: switchList)


periodFromSwitchPair : Switch -> Switch -> ( ActivityID, Period )
periodFromSwitchPair newerSwitch olderSwitch =
    ( Switch.getActivityID olderSwitch, Period.fromPair ( Switch.getMoment newerSwitch, Switch.getMoment olderSwitch ) )


instancePeriodFromSwitchPair : Switch -> Switch -> ( Maybe InstanceID, Period )
instancePeriodFromSwitchPair newerSwitch olderSwitch =
    ( Switch.getInstanceID olderSwitch, Period.fromPair ( Switch.getMoment newerSwitch, Switch.getMoment olderSwitch ) )


switchListToPeriods : List Switch -> List ( ActivityID, Period )
switchListToPeriods switchList =
    let
        offsetList =
            List.drop 1 switchList
    in
    List.map2 periodFromSwitchPair switchList offsetList


switchListToInstancePeriods : List Switch -> List ( Task.Instance.InstanceID, Period )
switchListToInstancePeriods switchList =
    let
        offsetList =
            List.drop 1 switchList

        listWithBlanks =
            List.map2 instancePeriodFromSwitchPair switchList offsetList

        maybeInstanceToMaybePair ( maybeInstanceID, period ) =
            case maybeInstanceID of
                Just instanceID ->
                    Just ( instanceID, period )

                Nothing ->
                    Nothing
    in
    List.filterMap maybeInstanceToMaybePair listWithBlanks


toPeriods : Timeline -> List ( ActivityID, Maybe Task.Instance.InstanceID, Period )
toPeriods switchList =
    let
        offsetList =
            List.drop 1 switchList

        listWithBlanks =
            List.map2 instancePeriodFromSwitchPair switchList offsetList

        maybeInstanceToMaybePair ( maybeInstanceID, period ) =
            case maybeInstanceID of
                Just instanceID ->
                    Just ( instanceID, period )

                Nothing ->
                    Nothing
    in
    List.filterMap maybeInstanceToMaybePair listWithBlanks


getInstancePeriods : Timeline -> InstanceID -> List Period
getInstancePeriods timeline instanceID =
    List.map Tuple.second <| List.filter (\( i, p ) -> i == instanceID) (switchListToInstancePeriods timeline)


getInstanceTimes : Timeline -> InstanceID -> List Moment
getInstanceTimes timeline instanceID =
    let
        periods =
            List.map Period.toPair <| getInstancePeriods timeline instanceID

        timesList =
            List.concatMap (\( a, b ) -> [ a, b ]) periods
    in
    List.uniqueBy Moment.toSmartInt timesList
