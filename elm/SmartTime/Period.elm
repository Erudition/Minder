module SmartTime.Period exposing (Period(..), areAdjacent, between, contains, distanceBetween, divide, end, endsEarlier, endsLater, fromEnd, fromPair, fromStart, haveOverlap, isInstant, isWithin, length, midpoint, overlap, split, splitEvery, splitHalves, splitThirds, start, startsEarlier, startsLater, timeline, timelineWithEnd, timelineWithStart, toPair, toStartDurPair)

import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Moment as Moment exposing (Moment)


type Period
    = Period Moment Moment



-- CREATING PERIODS --------------------------------------------------------------NOTE


between : Moment -> Moment -> Period
between moment1 moment2 =
    if Moment.compare moment1 moment2 == Moment.Later then
        -- Second moment is earlier than first, moments are backwards!
        Period moment2 moment1

    else
        Period moment1 moment2


fromStart : Moment -> Duration -> Period
fromStart startMoment duration =
    between startMoment (Moment.future startMoment duration)


fromEnd : Moment -> Duration -> Period
fromEnd endMoment duration =
    between (Moment.past endMoment duration) endMoment


fromPair : ( Moment, Moment ) -> Period
fromPair ( moment1, moment2 ) =
    if Moment.compare moment1 moment2 == Moment.Later then
        -- Second moment is earlier than first, moments are backwards!
        Period moment2 moment1

    else
        -- they're in the correct order, or identical
        Period moment1 moment2


timeline : List Moment -> List Period
timeline momentList =
    let
        buildList momentsRemaining =
            case momentsRemaining of
                [] ->
                    []

                _ :: [] ->
                    []

                moment1 :: moment2 :: rest ->
                    Period moment1 moment2 :: buildList rest
    in
    buildList momentList


timelineWithEnd : Moment -> List Moment -> List Period
timelineWithEnd defaultEnd momentList =
    let
        buildList momentsRemaining =
            case momentsRemaining of
                [] ->
                    []

                moment1 :: moment2 :: rest ->
                    Period moment1 moment2 :: buildList rest

                danglingMoment :: [] ->
                    Period danglingMoment defaultEnd :: []
    in
    buildList momentList


timelineWithStart : Moment -> List Moment -> List Period
timelineWithStart defaultStart momentList =
    if modBy 2 (List.length momentList) == 0 then
        timeline momentList

    else
        timeline (defaultStart :: momentList)



-- PROPERTIES -----------------------------------------------------------------NOTE


start : Period -> Moment
start (Period startMoment _) =
    startMoment


end : Period -> Moment
end (Period _ endMoment) =
    endMoment


length : Period -> Duration
length (Period startMoment endMoment) =
    Moment.difference startMoment endMoment


isInstant : Period -> Bool
isInstant period =
    Duration.isZero (length period)


midpoint : Period -> Moment
midpoint givenPeriod =
    Moment.future (start givenPeriod) (Duration.scale (length givenPeriod) 0.5)



-- CONVERSION ----------------------------------------------------------------NOTE


toPair : Period -> ( Moment, Moment )
toPair (Period startMoment endMoment) =
    ( startMoment, endMoment )


toStartDurPair : Period -> ( Moment, Duration )
toStartDurPair period =
    ( start period, length period )


splitHalves : Period -> ( Period, Period )
splitHalves ((Period startMoment endMoment) as givenPeriod) =
    ( Period startMoment (midpoint givenPeriod), Period (midpoint givenPeriod) endMoment )


splitThirds : Period -> ( Period, Period, Period )
splitThirds ((Period startMoment endMoment) as givenPeriod) =
    let
        oneThirdPoint =
            Moment.future startMoment (Duration.scale (length givenPeriod) (1 / 3))

        twoThirdsPoint =
            Moment.future startMoment (Duration.scale (length givenPeriod) (2 / 3))
    in
    ( Period startMoment oneThirdPoint
    , Period oneThirdPoint twoThirdsPoint
    , Period twoThirdsPoint endMoment
    )


split : Int -> Period -> List Period
split pieces givenPeriod =
    if pieces <= 0 then
        []

    else if pieces == 1 then
        [ givenPeriod ]

    else
        let
            chunkOffset step =
                Duration.scale (length givenPeriod) (toFloat step / toFloat pieces)

            chunk step =
                Period (Moment.future (start givenPeriod) (chunkOffset step)) (Moment.future (start givenPeriod) (chunkOffset (step + 1)))
        in
        List.map chunk (List.range 0 (pieces - 1))


{-| Split a Period into chunks of the given size -- as many as possible, always returning a list of Periods that make up the original.

Chunks are measured from the Period's beginning. If you want to ignore any remainder of the Period that does not fit into the proper chunk size, use `divide` instead.

So if you have a Period from 12:00 to 12:35 and split it every 10 minutes, you'd get 12:00-12:10, 12:10-12:20, 12:20-12:30, and 12:30-12:35.

-}
splitEvery : Duration -> Period -> List Period
splitEvery chunkLength givenPeriod =
    let
        addRemaining lastEnd currentList =
            let
                nextEnd =
                    Moment.future lastEnd chunkLength

                finalEnd =
                    end givenPeriod

                nextVsFinal =
                    Moment.compare nextEnd finalEnd
            in
            case nextVsFinal of
                Moment.Earlier ->
                    addRemaining nextEnd <| currentList ++ [ Period lastEnd nextEnd ]

                Moment.Coincident ->
                    currentList ++ [ Period lastEnd nextEnd ]

                Moment.Later ->
                    currentList ++ [ Period lastEnd finalEnd ]
    in
    addRemaining (start givenPeriod) []


{-| Split a period into periods of the desired Duration, discarding any remainder that does not perfectly fit.

If the dividend (chunk size) fits exactly, this would be equivalent to `splitEvery`.

Note that if it does not, the output Periods will not add up to the entire input Period.

So if you have a Period from 12:00 to 12:35 and split it every 10 minutes, you'd get 12:00-12:10, 12:10-12:20, and 12:20-12:30.

-}
divide : Duration -> Period -> List Period
divide chunkLength givenPeriod =
    let
        addRemaining lastEnd currentList =
            let
                nextEnd =
                    Moment.future lastEnd chunkLength

                finalEnd =
                    end givenPeriod

                nextVsFinal =
                    Moment.compare nextEnd finalEnd
            in
            case nextVsFinal of
                Moment.Earlier ->
                    addRemaining nextEnd <| currentList ++ [ Period lastEnd nextEnd ]

                Moment.Coincident ->
                    currentList ++ [ Period lastEnd nextEnd ]

                Moment.Later ->
                    currentList
    in
    addRemaining (start givenPeriod) []



-- COMPARISON -----------------------------------------------------------------NOTE


distanceBetween : Period -> Period -> Duration
distanceBetween periodA periodB =
    let
        comesFirst =
            startsEarlier periodA periodB

        comesLast =
            startsLater periodA periodB
    in
    if Moment.compare (end comesFirst) (start comesLast) == Moment.Earlier then
        Moment.difference (end comesFirst) (start comesLast)

    else
        Duration.zero


areAdjacent : Period -> Period -> Bool
areAdjacent (Period startA endA) (Period startB endB) =
    startB == endA || startA == endB


overlap : Period -> Period -> Duration
overlap periodA periodB =
    let
        comesFirst =
            startsEarlier periodA periodB

        comesLast =
            startsLater periodA periodB
    in
    if Moment.compare (end comesFirst) (start comesLast) == Moment.Later then
        Moment.difference (end comesFirst) (start comesLast)

    else
        Duration.zero


haveOverlap : Period -> Period -> Bool
haveOverlap periodA periodB =
    not <| Duration.isZero (overlap periodA periodB)


{-| Whether the first Period is contained by the second (A fits entirely within B).
-}
contains : Period -> Period -> Bool
contains (Period startA endA) (Period startB endB) =
    Moment.compare startA startB /= Moment.Later && Moment.compare endA endB /= Moment.Earlier


startsEarlier : Period -> Period -> Period
startsEarlier periodA periodB =
    if Moment.compare (start periodA) (start periodB) /= Moment.Later then
        periodA

    else
        periodB


startsLater : Period -> Period -> Period
startsLater periodA periodB =
    if Moment.compare (start periodA) (start periodB) /= Moment.Earlier then
        periodA

    else
        periodB


endsEarlier : Period -> Period -> Period
endsEarlier periodA periodB =
    if Moment.compare (end periodA) (end periodB) /= Moment.Later then
        periodA

    else
        periodB


endsLater : Period -> Period -> Period
endsLater periodA periodB =
    if Moment.compare (end periodA) (end periodB) /= Moment.Earlier then
        periodA

    else
        periodB



-- TESTING ---------------------------------------------------------------------NOTE


isWithin : Period -> Moment -> Bool
isWithin (Period startMoment endMoment) testMoment =
    (Moment.compare testMoment startMoment /= Moment.Earlier) && (Moment.compare testMoment endMoment /= Moment.Later)
