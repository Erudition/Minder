module SmartTime.TimeSegment exposing (TimeSegment(..), between, end, fromPair, length, start)

import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Moment as Moment exposing (Moment)


type TimeSegment
    = TimeSegment Moment Moment



-- CREATING PERIODS --------------------------------------------------------------NOTE


between : Moment -> Moment -> TimeSegment
between moment1 moment2 =
    if Moment.compare moment1 moment2 == Moment.Later then
        -- Second moment is earlier than first, moments are backwards!
        TimeSegment moment2 moment1

    else
        TimeSegment moment1 moment2


fromStart : Moment -> Duration -> TimeSegment
fromStart startMoment duration =
    between startMoment (Moment.future startMoment duration)


fromEnd : Moment -> Duration -> TimeSegment
fromEnd endMoment duration =
    between (Moment.past endMoment duration) endMoment


fromPair : ( Moment, Moment ) -> TimeSegment
fromPair ( moment1, moment2 ) =
    if Moment.compare moment1 moment2 == Moment.Later then
        -- Second moment is earlier than first, moments are backwards!
        TimeSegment moment2 moment1

    else
        -- they're in the correct order, or identical
        TimeSegment moment1 moment2


timeline : List Moment -> List TimeSegment
timeline momentList =
    let
        buildList momentsRemaining =
            case momentsRemaining of
                [] ->
                    []

                _ :: [] ->
                    []

                moment1 :: moment2 :: rest ->
                    TimeSegment moment1 moment2 :: buildList rest
    in
    buildList momentList


timelineWithEnd : Moment -> List Moment -> List TimeSegment
timelineWithEnd defaultEnd momentList =
    let
        buildList momentsRemaining =
            case momentsRemaining of
                [] ->
                    []

                moment1 :: moment2 :: rest ->
                    TimeSegment moment1 moment2 :: buildList rest

                danglingMoment :: [] ->
                    TimeSegment danglingMoment defaultEnd :: []
    in
    buildList momentList


timelineWithStart : Moment -> List Moment -> List TimeSegment
timelineWithStart defaultStart momentList =
    if modBy 2 (List.length momentList) == 0 then
        timeline momentList

    else
        timeline (defaultStart :: momentList)



-- PROPERTIES -----------------------------------------------------------------NOTE


start : TimeSegment -> Moment
start (TimeSegment startMoment endMoment) =
    startMoment


end : TimeSegment -> Moment
end (TimeSegment startMoment endMoment) =
    startMoment


length : TimeSegment -> Duration
length (TimeSegment startMoment endMoment) =
    Moment.difference startMoment endMoment


isInstant : TimeSegment -> Bool
isInstant period =
    Duration.isZero (length period)


midpoint : TimeSegment -> Moment
midpoint givenPeriod =
    Moment.future (start givenPeriod) (Duration.scale (length givenPeriod) 0.5)



-- CONVERSION ----------------------------------------------------------------NOTE


toPair : TimeSegment -> ( Moment, Moment )
toPair (TimeSegment startMoment endMoment) =
    ( startMoment, endMoment )


toStartDurPair : TimeSegment -> ( Moment, Duration )
toStartDurPair period =
    ( start period, length period )


splitHalves : TimeSegment -> ( TimeSegment, TimeSegment )
splitHalves ((TimeSegment startMoment endMoment) as givenPeriod) =
    ( TimeSegment startMoment (midpoint givenPeriod), TimeSegment (midpoint givenPeriod) endMoment )


splitThirds : TimeSegment -> ( TimeSegment, TimeSegment, TimeSegment )
splitThirds ((TimeSegment startMoment endMoment) as givenPeriod) =
    let
        oneThirdPoint =
            Moment.future startMoment (Duration.scale (length givenPeriod) (1 / 3))

        twoThirdsPoint =
            Moment.future startMoment (Duration.scale (length givenPeriod) (2 / 3))
    in
    ( TimeSegment startMoment oneThirdPoint
    , TimeSegment oneThirdPoint twoThirdsPoint
    , TimeSegment twoThirdsPoint endMoment
    )


split : Int -> TimeSegment -> List TimeSegment
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
                TimeSegment (Moment.future (start givenPeriod) (chunkOffset step)) (Moment.future (start givenPeriod) (chunkOffset (step + 1)))
        in
        List.map chunk (List.range 0 (pieces - 1))


{-| Split a TimeSegment into chunks of the given size -- as many as possible, always returning a list of Periods that make up the original.

Chunks are measured from the TimeSegment's beginning. If you want to ignore any remainder of the TimeSegment that does not fit into the proper chunk size, use `divide` instead.

So if you have a TimeSegment from 12:00 to 12:35 and split it every 10 minutes, you'd get 12:00-12:10, 12:10-12:20, 12:20-12:30, and 12:30-12:35.

-}
splitEvery : Duration -> TimeSegment -> List TimeSegment
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
                    addRemaining nextEnd <| currentList ++ [ TimeSegment lastEnd nextEnd ]

                Moment.Coincident ->
                    currentList ++ [ TimeSegment lastEnd nextEnd ]

                Moment.Later ->
                    currentList ++ [ TimeSegment lastEnd finalEnd ]
    in
    addRemaining (start givenPeriod) []


{-| Split a period into periods of the desired Duration, discarding any remainder that does not perfectly fit.

If the dividend (chunk size) fits exactly, this would be equivalent to `splitEvery`.

Note that if it does not, the output Periods will not add up to the entire input TimeSegment.

So if you have a TimeSegment from 12:00 to 12:35 and split it every 10 minutes, you'd get 12:00-12:10, 12:10-12:20, and 12:20-12:30.

-}
divide : Duration -> TimeSegment -> List TimeSegment
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
                    addRemaining nextEnd <| currentList ++ [ TimeSegment lastEnd nextEnd ]

                Moment.Coincident ->
                    currentList ++ [ TimeSegment lastEnd nextEnd ]

                Moment.Later ->
                    currentList
    in
    addRemaining (start givenPeriod) []



-- COMPARISON -----------------------------------------------------------------NOTE


distanceBetween : TimeSegment -> TimeSegment -> Duration
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


areAdjacent : TimeSegment -> TimeSegment -> Bool
areAdjacent (TimeSegment startA endA) (TimeSegment startB endB) =
    startB == endA || startA == endB


overlap : TimeSegment -> TimeSegment -> Duration
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


haveOverlap : TimeSegment -> TimeSegment -> Bool
haveOverlap periodA periodB =
    not <| Duration.isZero (overlap periodA periodB)


{-| Whether the first TimeSegment is contained by the second (A fits entirely within B).
-}
contains : TimeSegment -> TimeSegment -> Bool
contains (TimeSegment startA endA) (TimeSegment startB endB) =
    Moment.compare startA startB /= Moment.Later && Moment.compare endA endB /= Moment.Earlier


startsEarlier : TimeSegment -> TimeSegment -> TimeSegment
startsEarlier periodA periodB =
    if Moment.compare (start periodA) (start periodB) /= Moment.Later then
        periodA

    else
        periodB


startsLater : TimeSegment -> TimeSegment -> TimeSegment
startsLater periodA periodB =
    if Moment.compare (start periodA) (start periodB) /= Moment.Earlier then
        periodA

    else
        periodB


endsEarlier : TimeSegment -> TimeSegment -> TimeSegment
endsEarlier periodA periodB =
    if Moment.compare (end periodA) (end periodB) /= Moment.Later then
        periodA

    else
        periodB


endsLater : TimeSegment -> TimeSegment -> TimeSegment
endsLater periodA periodB =
    if Moment.compare (end periodA) (end periodB) /= Moment.Earlier then
        periodA

    else
        periodB



-- TESTING ---------------------------------------------------------------------NOTE


isWithin : TimeSegment -> Moment -> Bool
isWithin (TimeSegment startMoment endMoment) testMoment =
    (Moment.compare testMoment startMoment /= Moment.Earlier) && (Moment.compare testMoment endMoment /= Moment.Later)
