module Activity.Measure exposing (inFuzzyWords, sessions, total, totalLive)

import Activity.Activity exposing (..)
import Time
import Time.Distance exposing (..)


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


inFuzzyWords : Int -> String
inFuzzyWords ms =
    Time.Distance.inWords (Time.millisToPosix 0) (Time.millisToPosix ms)
