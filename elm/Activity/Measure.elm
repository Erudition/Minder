module Activity.Measure exposing (exportActivityUsage, exportLastSession, inFuzzyWords, inHoursMinutes, justToday, justTodayTotal, relevantTimeline, sessions, timelineLimit, total, totalLive)

import Activity.Activity as Activity exposing (..)
import AppData exposing (AppData)
import Environment exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.HumanDuration exposing (..)
import Time exposing (..)
import Time.Distance exposing (..)
import Time.Extra


{-| Mind if I doodle here?

    switchList: [Run @ 10,  Jog @ 8,    Walk @ 5,    Eat @4 ]
    (-1) V         (-)         (-)         (-)          X
    offsetList: [Jog @ 8,   Walk @ 5,   Eat @ 4   ]
                   (=)         (=)        (=)
    session: ...[Jog 2,     Walk 3,     Eat 1     ]

-}
allSessions : List Switch -> List ( ActivityId, Duration )
allSessions switchList =
    let
        offsetList =
            List.drop 1 switchList
    in
    List.map2 session switchList offsetList


session : Switch -> Switch -> ( ActivityId, Duration )
session (Switch newer _) (Switch older activityId) =
    ( activityId, Duration.fromInt (Time.posixToMillis newer - Time.posixToMillis older) )


sessions : List Switch -> ActivityId -> List Duration
sessions switchList activityId =
    let
        all =
            allSessions switchList
    in
    List.filterMap (isMatchingDuration activityId) all


isMatchingDuration : ActivityId -> ( ActivityId, Duration ) -> Maybe Duration
isMatchingDuration targetId ( itemId, dur ) =
    if itemId == targetId then
        Just dur

    else
        Nothing


total : List Switch -> ActivityId -> Duration
total switchList activityId =
    Duration.combine (sessions switchList activityId)


totalLive : Moment -> List Switch -> ActivityId -> Duration
totalLive now switchList activityId =
    let
        fakeSwitch =
            Switch now activityId
    in
    Duration.combine (sessions (fakeSwitch :: switchList) activityId)


{-| Narrow a timeline down to a given time frame.
This function takes two Moments (now and the point in history up to which we want to keep). It will cap off the list with a fake switch at the end, set for the pastLimit, so that sessions that span the threshold still have their relevant portion counted.
-}
timelineLimit : Timeline -> Moment -> Moment -> Timeline
timelineLimit timeline now pastLimit =
    let
        switchActivityId (Switch _ id) =
            id

        recentEnough (Switch moment _) =
            Time.posixToMillis moment > Time.posixToMillis pastLimit

        ( pass, fail ) =
            List.partition recentEnough timeline

        justMissedId =
            Maybe.withDefault Activity.dummy <| Maybe.map switchActivityId (List.head fail)

        fakeEndSwitch =
            Switch pastLimit justMissedId
    in
    pass ++ [ fakeEndSwitch ]


{-| Given a HumanDuration, how far back in time would it reach?
This returns that Moment in history.

For fixed distances, that's easy, but variable intervals could be far back or just a millisecond ago.

-}
lookBack : ( Moment, Time.Zone ) -> HumanDuration -> Moment
lookBack ( present, zone ) humanDuration =
    Time.Extra.add Time.Extra.Millisecond -(Duration.inMs (toDuration humanDuration)) zone present


relevantTimeline : Timeline -> ( Moment, Zone ) -> HumanDuration -> Timeline
relevantTimeline timeline ( now, zone ) duration =
    timelineLimit timeline now (lookBack ( now, zone ) duration)


justToday : Timeline -> ( Moment, Zone ) -> Timeline
justToday timeline ( now, zone ) =
    let
        lastMidnight =
            Time.Extra.floor Time.Extra.Day zone now

        -- TODO: what if between midnight and 3am
        last3am =
            Time.Extra.add Time.Extra.Hour 3 zone lastMidnight
    in
    timelineLimit timeline now lastMidnight


justTodayTotal : Timeline -> Environment -> Activity -> Duration
justTodayTotal timeline env activity =
    let
        lastPeriod =
            justToday timeline ( env.time, env.timeZone )
    in
    totalLive env.time lastPeriod activity.id


inFuzzyWords : Duration -> String
inFuzzyWords duration =
    Time.Distance.inWords (Time.millisToPosix 0) (Time.millisToPosix (Duration.inMs duration))


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


exportActivityUsage : AppData -> Environment -> Activity -> String
exportActivityUsage app env activity =
    let
        lastPeriod =
            relevantTimeline app.timeline ( env.time, env.timeZone ) (Tuple.second excusableLimit)

        excusableLimit =
            Activity.excusableFor activity

        totalMs =
            totalLive env.time lastPeriod activity.id

        totalSeconds =
            Duration.inSecondsRounded totalMs
    in
    String.fromInt totalSeconds


exportLastSession : AppData -> Activity -> String
exportLastSession app old =
    let
        timeSpent =
            Maybe.withDefault Duration.zero (List.head (sessions app.timeline old.id))
    in
    String.fromInt <| Duration.inMinutesRounded timeSpent



-- TODO use SmartTime instead
