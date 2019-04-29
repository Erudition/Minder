module Activity.Measure exposing (inFuzzyWords, relevantTimeline, sessions, timelineLimit, total, totalLive)

import Activity.Activity as Activity exposing (..)
import Time exposing (..)
import Time.Distance exposing (..)
import Time.Extra exposing (..)


{-| Mind if I doodle here?

    switchList: [Run @ 10,  Jog @ 8,    Walk @ 5,    Eat @4 ]
    (-1) V         (-)         (-)         (-)          X
    offsetList: [Jog @ 8,   Walk @ 5,   Eat @ 4   ]
                   (=)         (=)        (=)
    session: ...[Jog 2,     Walk 3,     Eat 1     ]

-}
allSessions : List Switch -> List ( ActivityId, Int )
allSessions switchList =
    let
        offsetList =
            List.drop 1 switchList
    in
    List.map2 session switchList offsetList


session : Switch -> Switch -> ( ActivityId, Int )
session (Switch newer _) (Switch older activityId) =
    ( activityId, Time.posixToMillis newer - Time.posixToMillis older )


sessions : List Switch -> ActivityId -> List Int
sessions switchList activityId =
    let
        all =
            allSessions switchList
    in
    List.filterMap (getMatchingDurations activityId) all


getMatchingDurations : ActivityId -> ( ActivityId, Int ) -> Maybe Int
getMatchingDurations targetId ( itemId, dur ) =
    if itemId == targetId then
        Just dur

    else
        Nothing


total : List Switch -> ActivityId -> Int
total switchList activityId =
    List.sum (sessions switchList activityId)


totalLive : Moment -> List Switch -> ActivityId -> Int
totalLive now switchList activityId =
    let
        fakeSwitch =
            Switch now activityId
    in
    List.sum (sessions (fakeSwitch :: switchList) activityId)


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


{-| Given a Duration, how far back in time would it reach?
This returns that Moment in history.

For fixed distances, that's easy, but variable intervals could be far back or just a millisecond ago.

-}
lookBack : ( Moment, Time.Zone ) -> Duration -> Moment
lookBack ( present, zone ) ( count, interval ) =
    let
        fixedDistance =
            add interval -count zone present

        variableDistance =
            Time.Extra.floor interval zone ifMoreThanOne

        ifMoreThanOne =
            add interval (1 - count) zone present
    in
    case interval of
        Year ->
            variableDistance

        Quarter ->
            variableDistance

        Month ->
            variableDistance

        Week ->
            variableDistance

        Monday ->
            variableDistance

        Tuesday ->
            variableDistance

        Wednesday ->
            variableDistance

        Thursday ->
            variableDistance

        Friday ->
            variableDistance

        Saturday ->
            variableDistance

        Sunday ->
            variableDistance

        Day ->
            variableDistance

        Hour ->
            fixedDistance

        Minute ->
            fixedDistance

        Second ->
            fixedDistance

        Millisecond ->
            fixedDistance


relevantTimeline : Timeline -> ( Moment, Zone ) -> Duration -> Timeline
relevantTimeline timeline ( now, zone ) duration =
    timelineLimit timeline now (lookBack ( now, zone ) duration)


inFuzzyWords : Int -> String
inFuzzyWords ms =
    Time.Distance.inWords (Time.millisToPosix 0) (Time.millisToPosix ms)