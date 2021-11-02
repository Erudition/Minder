module Activity.Measure exposing (excusableLimit, excusedLeft, excusedUsage, exportExcusedUsageSeconds, inHoursMinutes, justToday, justTodayTotal, lastSession, relevantTimeline, sessions, switchListLiveToPeriods, timelineLimit, total, totalLive)

import Activity.Activity as Activity exposing (..)
import Activity.Switch as Switch exposing (..)
import Activity.Timeline as Timeline exposing (..)
import Environment exposing (..)
import ID
import Profile exposing (Profile)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Human.Moment as HumanMoment exposing (Zone, utc)
import SmartTime.Moment as Moment exposing (..)
import SmartTime.Period as Period exposing (Period)
import Time.Distance exposing (..)
import Time.Extra


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


exportExcusedUsageSeconds : Profile -> Moment -> ( ActivityID, Activity ) -> String
exportExcusedUsageSeconds app now ( activityID, activity ) =
    String.fromInt <| Duration.inSecondsRounded (excusedUsage app.timeline now ( activityID, activity ))


exportExcusedLeftSeconds : Profile -> Moment -> ( ActivityID, Activity ) -> String
exportExcusedLeftSeconds app now ( activityID, activity ) =
    String.fromInt <| Duration.inSecondsRounded (excusedLeft app.timeline now ( activityID, activity ))


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


switchListToPeriods : List Switch -> List ( ActivityID, Period )
switchListToPeriods switchList =
    let
        offsetList =
            List.drop 1 switchList
    in
    List.map2 periodFromSwitchPair switchList offsetList
