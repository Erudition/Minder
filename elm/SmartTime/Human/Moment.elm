module SmartTime.Human.Moment exposing (FuzzyMoment(..), Zone, clockTurnBack, clockTurnForward, dateFromFuzzy, extractDate, extractTime, fromDate, fromDateAndTime, fromFuzzy, fromStandardString, fromStandardStringLoose, fuzzyDescription, fuzzyFromString, fuzzyToString, getMillisecond, getOffset, getSecond, humanize, humanizeFuzzy, importElmMonth, localZone, makeZone, searchRemainingZoneHistory, setDate, setTime, toStandardString, today, utc)

{-| Human.Moment lets you safely comingle `Moment`s with their messy human counterparts: time zone, calendar date, and time-of-day.

The human version of a `Moment` could be a type called a `DateTime`, which would be a Date and Time combined in some way:

    type DateTime = (CalendarDate, TimeOfDay)

While you can define such a type if you really want to, this module **does not expose such a type**. Why? Because, as the `Time`-renovations of Elm 0.19 set out to encourage, you should **never store human time in your model**. Or in your database, for that matter. Human time is only for the _users_ to see and interact with -- i.e. your `view` function -- it's simply not good for machines to interact with, especially between different systems. It's just too messy! As you read the docs, you will learn why.

So, this library opts for a really great `Moment` type instead! It's pure and simple, you can move it around in a perfectly linear fashion, and not a single one of those helper functions requires you to lug a `Zone` around everywhere. Nice! Check it out in the `Moment` module.

Nevertheless, humans don't think in terms of `Moment`s, they like to push them around based on calendars and clocks. Unfortunately, they also prefer to forget that not only are these systems erratic, and subject to the whim of politicians, but they also apply only to their particular vertical slice of the globe. So, when requiring a `Zone` is unavoidable, the feature is included here, in the "human moment" library.

Are there exceptions? Yes! Like the special cases detailed in the `Clock` and `Calendar` modules, there can be a situation where it makes sense to handle human time alone, without any universal relevance or the context of a `Zone`. For example, for a "daily checklist" app it may make sense to store the due dates of tasks in human time:

    - [] Wake up (08:00)
    - [] Do Yoga (08:15)
    - [] Eat Breakfast (08:45)
    - ...
    - [] Eat Dinner (18:00)
    - [] Floss (22:00)
    - [] Go to bed (23:00)

Unlike meetings and appointments, these data really don't need to be in a fixed time zone. Sure you could store them all with respect to the zone they were created in. But what if the user crosses a few zones one day? Should they be expected to manually change all of their due-times? You could detect the zone change by comparing the current zone to the original, and compensating for the difference. But that means storing `Zones` with your data. **You should never need to do that!** So does this mean we resort to our `DateTime` type, then?

Nope! There is a better way! Check this out:

    type ScheduledMoment
        = Fixed Moment
        | Floating Moment

Then, when changing a fixed time, we do the usual: use the local zone to display the localized interface to the user, and then use the zone again to convert the given time back to Universal. But when reading the `Floating` moments, what if you skipped that first step? By short-cicuiting the zone-shifting, you effectively pretend that the UTC time is already local. So no matter where you are, that `Moment` still shows up as 9 o'clock! This clever trick allows us to once again avoid storing human time.

-}

import Parser exposing ((|.), (|=), Parser, chompWhile, getChompedString, spaces, symbol)
import ParserExtra as Parser
import Regex exposing (Regex)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Calendar.Month as Month exposing (DayOfMonth(..), Month)
import SmartTime.Human.Calendar.Year as Year exposing (Year(..))
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Moment as Moment exposing (ElmTime, Moment)
import Task as Job
import Time as ElmTime
import Time.Extra exposing (Parts, partsToPosix, toOffset)


{-| -}
type alias Zone =
    -- can't use Elm zones because they're not exposed to us
    { defaultOffset : Duration
    , name : String
    , history : List ( Moment, Duration )
    }


utc : Zone
utc =
    { defaultOffset = Duration.fromMinutes 0, name = "Universal", history = [] }


{-| Get the `Zone` where the user is!
-}
localZone : Job.Task x Zone
localZone =
    Job.map3 makeZone ElmTime.getZoneName ElmTime.here ElmTime.now


makeZone : ElmTime.ZoneName -> ElmTime.Zone -> ElmTime -> Zone
makeZone elmZoneName elmZone now =
    let
        deducedOffset =
            deduceZoneOffset elmZone now
    in
    case elmZoneName of
        ElmTime.Name zoneName ->
            { defaultOffset = deducedOffset
            , name = zoneName
            , history = [] -- should be supported one day
            }

        ElmTime.Offset offsetMinutes ->
            { defaultOffset = Duration.fromMinutes (toFloat offsetMinutes)
            , name = "Unsupported"
            , history = []
            }


{-| Get just the date where the user is. Useful if you are working only with dates.
-}
today : Job.Task x CalendarDate
today =
    Job.map2 extractDate localZone Moment.now


{-| What is the offset from UTC, in minutes, for this `Zone` at this
`Posix` time?
import Time exposing (Month(..))
import Time.Extra exposing (Parts, partsToPosix, toOffset)
toOffset nyc
(partsToPosix nyc (Parts 2018 Sep 26 10 30 0 0))
== -240
-- assuming `nyc` is a `Zone` for America/New\_York
**Note:** It's possible to verify the example above by using time zone data
from the package [justinmimbs/timezone-data][tzdata] to define `nyc`:
import TimeZone
nyc =
TimeZone.america\__new_york ()
[tzdata]: <https://package.elm-lang.org/packages/justinmimbs/timezone-data/latest/>
-}
deduceZoneOffset : ElmTime.Zone -> ElmTime -> Duration
deduceZoneOffset zone elmTime =
    let
        zonedDate =
            Calendar.fromPartsForced
                { year = Year (ElmTime.toYear zone elmTime)
                , month = importElmMonth (ElmTime.toMonth zone elmTime)
                , day = DayOfMonth (ElmTime.toDay zone elmTime)
                }

        zonedTime =
            Clock.clock (ElmTime.toHour zone elmTime) (ElmTime.toMinute zone elmTime) (ElmTime.toSecond zone elmTime) (ElmTime.toMillis zone elmTime)

        combinedMoment =
            -- pretend the date is utc so we can see the difference
            fromDateAndTime utc zonedDate zonedTime

        localTime =
            -- Debug.log ("local: " ++ toStandardString combinedMoment) <| combinedMoment
            combinedMoment

        utcTime =
            Moment.fromElmTime elmTime

        offset =
            Moment.toSmartInt localTime - Moment.toSmartInt utcTime
    in
    Duration.fromMs (toFloat offset)


importElmMonth : ElmTime.Month -> Month
importElmMonth elmMonth =
    case elmMonth of
        ElmTime.Jan ->
            Month.Jan

        ElmTime.Feb ->
            Month.Feb

        ElmTime.Mar ->
            Month.Mar

        ElmTime.Apr ->
            Month.Apr

        ElmTime.May ->
            Month.May

        ElmTime.Jun ->
            Month.Jun

        ElmTime.Jul ->
            Month.Jul

        ElmTime.Aug ->
            Month.Aug

        ElmTime.Sep ->
            Month.Sep

        ElmTime.Oct ->
            Month.Oct

        ElmTime.Nov ->
            Month.Nov

        ElmTime.Dec ->
            Month.Dec



-- posixFromDateTime : Zone -> Date -> Int -> Posix
-- posixFromDateTime zone date time =
--     -- find the local offset
--     let
--         millis =
--             (date |> dateToMillis) + time
--
--         offset0 =
--             millis |> millisToPosix |> toOffset zone
--
--         posix1 =
--             (millis - offset0 * 60000) |> millisToPosix
--
--         offset1 =
--             posix1 |> toOffset zone
--     in
--     if offset0 == offset1 then
--         posix1
--
--     else
--         -- local offset has changed within `offset0` time period (e.g. DST switch)
--         let
--             posix2 =
--                 (millis - offset1 * 60000) |> millisToPosix
--
--             offset2 =
--                 posix2 |> toOffset zone
--         in
--         if offset1 == offset2 then
--             posix2
--
--         else
--             -- `millis` is within the lost hour of a local switch
--             posix1


{-| Create a `Moment` from only a `CalendarDate`, using midnight as the time of day.
-}
fromDate : Zone -> CalendarDate -> Moment
fromDate zone date =
    fromDateAndTime zone date Clock.midnight



--- From DateTime


{-| Create a Moment by combining a [CalendarDate](Calendar#CalendarDate) and [TimeOfDay](Clock#TimeOfDay).
-}
fromDateAndTime : Zone -> CalendarDate -> TimeOfDay -> Moment
fromDateAndTime zone date timeOfDay =
    let
        woleDaysBefore =
            Duration.scale Duration.aDay (toFloat (Calendar.toRataDie date))

        total =
            Duration.add timeOfDay woleDaysBefore
    in
    toTAIAndUnlocalize zone total


toStandardString : Moment -> String
toStandardString moment =
    let
        ( date, time ) =
            humanize utc moment
    in
    Calendar.toStandardString date ++ "T" ++ Clock.toStandardString time ++ "Z"


fromStandardString : String -> Result String Moment
fromStandardString input =
    let
        combinedParser =
            Parser.succeed Tuple.pair
                |= Calendar.separatedYMD "-"
                |. symbol "T"
                |= Clock.parseHMS
                |. symbol "Z"
                -- TODO allow offset 0 as well
                |. Parser.end
    in
    fromStringHelper combinedParser input


fromStandardStringLoose : String -> Result String Moment
fromStandardStringLoose input =
    let
        combinedParser =
            Parser.succeed Tuple.pair
                |= Calendar.separatedYMD "-"
                |. symbol "T"
                |= Clock.parseHMS
    in
    fromStringHelper combinedParser input


fromStringHelper : Parser ( Calendar.Parts, TimeOfDay ) -> String -> Result String Moment
fromStringHelper givenParser input =
    -- Internal
    let
        parserResult =
            Parser.run givenParser input

        withNiceErrors =
            Result.mapError Parser.realDeadEndsToString parserResult

        -- TODO handle in-built zones
        combiner d t =
            fromDateAndTime utc d t

        fromAll : ( Calendar.Parts, Clock.TimeOfDay ) -> Result String Moment
        fromAll ( dateparts, time ) =
            Result.map (\d -> combiner d time) (Calendar.fromParts dateparts)
    in
    withNiceErrors |> Result.andThen fromAll



-- Accessors


{-| Extract the local date and time from a `Moment`.
Feel free to ditch the part you don't need:

    -- moment == 25 Dec 2019 16:45:30.000



    ( date, _ ) =
        humanize moment

    -- date == 25 Dec 2019 : CalendarDate

But if you really only need the Date or the Time, consider just using the `fromMoment` functions in `Clock` or `Calendar`, respectively.

-}
humanize : Zone -> Moment -> ( CalendarDate, TimeOfDay )
humanize zone moment =
    let
        localMomentDur =
            toUTCAndLocalize zone moment

        daysSinceEpoch =
            Duration.inWholeDays localMomentDur

        remaining =
            Duration.subtract localMomentDur (Duration.fromDays (toFloat daysSinceEpoch))
    in
    ( Calendar.fromRataDie daysSinceEpoch, remaining )


extractDate : Zone -> Moment -> CalendarDate
extractDate zone moment =
    Tuple.first (humanize zone moment)


extractTime : Zone -> Moment -> TimeOfDay
extractTime zone moment =
    Tuple.second (humanize zone moment)


{-| Internal function to turn a Moment into a duration that represents this moment AFTER being adjusted for zone - which is thus NOT a true Moment and should be treated as a mere Duration.

Use this function as late as possible.

-}
toUTCAndLocalize : Zone -> Moment -> Duration
toUTCAndLocalize zone moment =
    let
        momentAsDur =
            Duration.fromInt <| Moment.toInt moment Moment.UTC Moment.commonEraStart
    in
    Duration.add momentAsDur (getOffset moment zone)


toTAIAndUnlocalize : Zone -> Duration -> Moment
toTAIAndUnlocalize zone localMomentDur =
    let
        zoneOffset =
            getOffset (toMoment localMomentDur) zone

        toMoment duration =
            Moment.moment Moment.UTC Moment.commonEraStart duration
    in
    toMoment <| Duration.subtract localMomentDur zoneOffset


{-| What offset from `utc` does this time zone describe?

Since many time zones have changed over time, you'll need to provide a `Moment`, too. It serves as a point of reference: if the offset was different back then, this function will return that offset instead of the current one.

-}
getOffset : Moment -> Zone -> Duration
getOffset referencePoint zone =
    searchRemainingZoneHistory referencePoint zone.defaultOffset zone.history


{-| Uses tail-call recursion to step back through the time periods described by a Zone.
NOTE ignore in docs

TODO use time period type instead

-}
searchRemainingZoneHistory : Moment -> Duration -> List ( Moment, Duration ) -> Duration
searchRemainingZoneHistory moment fallback history =
    case history of
        -- nothing left in the list, guess this moment is too old for our data.
        [] ->
            -- use default
            fallback

        ( zoneChange, offsetAtThatTime ) :: remainingHistory ->
            -- if the time is the same or later, it's in this period!
            if Moment.compare moment zoneChange /= Moment.Earlier then
                offsetAtThatTime

            else
                -- sets fallback to most recently checked change instead of default
                searchRemainingZoneHistory moment offsetAtThatTime remainingHistory



-- NO ZONE REQUIRED


{-| Extracts a moment's `TimeOfDay` and runs `Clock.second`, but with _no need for a time zone_! Equivalent to:

    Clock.second (extractTime anyZoneHere moment)

This is possible because time zone offsets only affect the moment's local date/time interpetation at the _minute level or higher_. Without the `Zone` we may not know if it's 5:02 or 8:02 or even 12:47 on the local clocks, but the second hand is always the same globally.

Of course, if you're working with the other `Clock` parts too, it's clearer to stick with the normal `Clock.second`.

-}
getSecond : Moment -> Int
getSecond =
    Clock.second << extractTime utc


{-| Extracts a moment's `TimeOfDay` and runs `Clock.millisecond`, but with no need for a time zone! Equivalent to:

    Clock.millisecond (extractTime anyZoneHere moment)

This is possible because time zone offsets only affect the interpetation of `Moment`s as date/time at the _minute level or higher_. Without the `Zone` we may not know if it's 5:02 or 8:02 or even 12:47 on the local clocks, but the second hand is always the same globally (and likewise it's fractional position, like the millisecond).

Of course, if you're working with the other `Clock` parts too, it's clearer to stick with the normal `Clock.millisecond`.

This could be used to build quick Random Number Generator, but you may want to use the `Random` library instead.

-}
getMillisecond : Moment -> Int
getMillisecond =
    Clock.milliseconds << extractTime utc



-- Setters


{-| Extract the local TimeOfDay from a Moment, and associate it with the given `CalendarDate` to create a new `Moment` with `fromDateAndTime`.

    -- date == 26 Aug 2019
    -- dateTime == 25 Dec 2019 16:45:30.000
    setDate date dateTime -- 26 Aug 2019 16:45:30.000

-}
setDate : CalendarDate -> Zone -> Moment -> Moment
setDate newDate zone moment =
    let
        ( _, oldTime ) =
            humanize zone moment
    in
    fromDateAndTime zone newDate oldTime


{-| Sets the `Time` part of a [DateTime#DateTime].

    -- dateTime == 25 Dec 2019 16:45:30.000
    setTime Clock.midnight dateTime -- 25 Dec 2019 00:00:00.000

-}
setTime : TimeOfDay -> Zone -> Moment -> Moment
setTime newTime zone moment =
    let
        ( oldDate, _ ) =
            humanize zone moment
    in
    fromDateAndTime zone oldDate newTime


clockTurnBack : TimeOfDay -> Zone -> Moment -> Moment
clockTurnBack timeOfDay zone moment =
    let
        newMoment =
            setTime timeOfDay zone moment
    in
    if Moment.compare newMoment moment == Moment.Earlier then
        newMoment

    else
        -- if the new time is not earlier than the old one, force it to be
        Moment.past newMoment Duration.aDay


clockTurnForward : TimeOfDay -> Zone -> Moment -> Moment
clockTurnForward timeOfDay zone moment =
    let
        newMoment =
            setTime timeOfDay zone moment
    in
    if Moment.compare newMoment moment == Moment.Later then
        newMoment

    else
        -- if the new time is not later than the old one, force it to be
        Moment.future newMoment Duration.aDay


{-| A convenience type for a much more human kind of `Moment`: the `Zone` and `TimeOfDay` are optional! Why? Imagine you have a schedule that looks something like this:

    type alias Event =
        { what : String, when : String }

    schedule =
        [ { what = "Meeting with Greg", when = "tomorrow at 4 EST" }
        , { what = "Call Donna", when = "tomorrow at 4 EST" }
        , { what = "The Simpsons is on", when = "Thursday at 9" }
        ]

Note: For something like a to-do list, this is best wrapped with a `Maybe` so you can have todos with no due moments!

Note: As you can see, there no Floating/Universal distinction for the `DateOnly` option. That's because dates, unlike `Moment`s, are inherently `Floating` - they're pretty much always local! You never see a date with a time zone (like "2022/03/12 EST" (!?) or something) because anyone collaborating across timezones will need more precision than just a Date anyway. Anything meaningfully assigned to a Date - like holidays or birthday - is always attributed to the start of that date _in your local zone_. That's why the New Year always starts at midnight wherever you are, not midnight in Greenwhich!

-}
type FuzzyMoment
    = Global Moment
    | Floating ( CalendarDate, TimeOfDay )
    | DateOnly CalendarDate


fromFuzzy : Zone -> FuzzyMoment -> Moment
fromFuzzy zone fuzzy =
    case fuzzy of
        DateOnly date ->
            fromDate zone date

        Floating ( date, time ) ->
            -- de-humanize as if it was written for this time zone
            fromDateAndTime zone date time

        Global moment ->
            moment


humanizeFuzzy : Zone -> FuzzyMoment -> ( CalendarDate, Maybe TimeOfDay )
humanizeFuzzy zone fuzzy =
    let
        wrapTimeWithJust ( date, time ) =
            ( date, Just time )
    in
    case fuzzy of
        DateOnly date ->
            ( date, Nothing )

        Floating ( date, time ) ->
            ( date, Just time )

        Global moment ->
            wrapTimeWithJust (humanize zone moment)


fromFuzzyWithDefaultTime : Zone -> TimeOfDay -> FuzzyMoment -> Moment
fromFuzzyWithDefaultTime zone defaultTime fuzzy =
    case fuzzy of
        DateOnly date ->
            fromDateAndTime zone date defaultTime

        Floating ( date, time ) ->
            -- de-humanize as if it was written for this time zone
            fromDateAndTime zone date time

        Global moment ->
            moment


humanizeFuzzyWithDefaultTime : Zone -> TimeOfDay -> FuzzyMoment -> ( CalendarDate, TimeOfDay )
humanizeFuzzyWithDefaultTime zone defaultTime fuzzy =
    let
        wrapTimeWithJust ( date, time ) =
            ( date, Just time )
    in
    case fuzzy of
        DateOnly date ->
            ( date, defaultTime )

        Floating ( date, time ) ->
            ( date, time )

        Global moment ->
            humanize zone moment


fuzzyDescription : Moment -> Zone -> FuzzyMoment -> String
fuzzyDescription now zone fuzzyMoment =
    case humanizeFuzzy zone fuzzyMoment of
        ( date, Nothing ) ->
            Calendar.describeVsToday (extractDate zone now) date

        ( date, Just time ) ->
            Calendar.describeVsToday (extractDate zone now) date ++ " at " ++ Clock.toShortString time


{-| One thing all `FuzzyMoment`s have in common is they hold a `CalendarDate`. This extracts that directly!
-}
dateFromFuzzy : Zone -> FuzzyMoment -> CalendarDate
dateFromFuzzy zone fuzzy =
    Tuple.first (humanizeFuzzy zone fuzzy)


{-| If a `TimeOfDay` was specified in this `FuzzyMoment`, you can extract `Just` that time without using `humanizeFuzzy`. If not, you get `Nothing`.
-}
timeFromFuzzy : Zone -> FuzzyMoment -> Maybe TimeOfDay
timeFromFuzzy zone fuzzy =
    Tuple.second (humanizeFuzzy zone fuzzy)


fuzzyToString : FuzzyMoment -> String
fuzzyToString fuzzyMoment =
    case fuzzyMoment of
        Global moment ->
            toStandardString moment

        Floating _ ->
            -- Remove the "Z" from the end to indicate this is not in any particular zone
            String.dropRight 1 (toStandardString (fromFuzzy utc fuzzyMoment))

        DateOnly date ->
            Calendar.toStandardString date


fuzzyFromString : String -> Result String FuzzyMoment
fuzzyFromString givenString =
    -- follows "T and "Z" convention
    if String.endsWith "Z" givenString then
        -- TODO may not necessarily end with Z!
        Result.map Global (fromStandardString givenString)

    else if String.contains "T" givenString then
        -- Doesn't end with "Z", but still has a "T"
        Result.map (Floating << humanize utc) (fromStandardStringLoose givenString)

    else
        Result.map DateOnly (Calendar.fromNumberString givenString)
