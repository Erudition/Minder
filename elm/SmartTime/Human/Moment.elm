module SmartTime.Human.Moment exposing (Zone, clockTurnBack, clockTurnForward, extractDate, extractTime, fromDate, fromDateAndTime, getMillisecond, getOffsetMinutes, getSecond, humanize, importElmMonth, localZone, localize, makeZone, setDate, setTime, today, utc)

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

import Parser exposing (getOffset)
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
    case elmZoneName of
        ElmTime.Name zoneName ->
            { defaultOffset = Duration.fromMinutes (toFloat (getOffsetMinutes elmZone now))
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
getOffsetMinutes : ElmTime.Zone -> ElmTime -> Int
getOffsetMinutes zone elmTime =
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
            fromDateAndTime utc zonedDate zonedTime

        localMillis =
            ElmTime.posixToMillis (Moment.toElmTime combinedMoment)

        utcMillis =
            ElmTime.posixToMillis elmTime
    in
    (localMillis - utcMillis) // 60000


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


{-| Create a [CalendarDate](CalendarDate#CalendarDate) by combining a [Date](Calendar#Date) and [Time](Clock#Time).

    -- date == 26 Aug 2019
    -- time == 12:30:45.000

    fromDateAndTime date time
    -- CalendarDate { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 } } : CalendarDate

-}
fromDateAndTime : Zone -> CalendarDate -> TimeOfDay -> Moment
fromDateAndTime zone date timeOfDay =
    let
        woleDaysBefore =
            Duration.scale Duration.aDay (toFloat (Calendar.toRataDie date))

        total =
            Duration.add timeOfDay woleDaysBefore
    in
    unlocalize zone total



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
            localize zone moment

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
localize : Zone -> Moment -> Duration
localize zone moment =
    let
        momentAsDur =
            Moment.toDuration moment Moment.commonEraStart
    in
    Duration.add momentAsDur (getOffset moment zone)


unlocalize : Zone -> Duration -> Moment
unlocalize zone localMomentDur =
    let
        zoneOffset =
            getOffset (toMoment localMomentDur) zone

        toMoment duration =
            Moment.moment Moment.TAI Moment.commonEraStart duration
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
