module ZoneHistory exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import List.Extra as List
import List.Nonempty exposing (Nonempty(..))
import Maybe.Extra as Maybe
import Set exposing (Set)
import SmartTime.Duration as Duration
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment as HumanMoment exposing (Zone, utc)
import SmartTime.Moment as Moment exposing (Moment, TimelineOrder(..))



-- TODO optimize choice of data structure


type ZoneHistory
    = ZoneHistory Zone (Dict Int Zone)


init now nowZone =
    ZoneHistory nowZone (Dict.singleton (Moment.toSmartInt now) nowZone)


sample : ZoneHistory -> Moment -> Zone
sample (ZoneHistory fallback historyDict) inputMoment =
    case nearestPriorZoneChange inputMoment historyDict of
        Just ( _, zone ) ->
            zone

        Nothing ->
            case isOlderThanOldestZoneChange inputMoment historyDict of
                Nothing ->
                    fallback

                Just ( _, oldestZone ) ->
                    oldestZone


add : ( Moment, Zone ) -> ZoneHistory -> ZoneHistory
add ( newEntryMoment, newEntryZone ) (ZoneHistory fallback historyDict) =
    let
        isRedundant =
            case nearestPriorZoneChange newEntryMoment historyDict of
                Nothing ->
                    False

                Just zoneChange ->
                    Tuple.second zoneChange == newEntryZone
    in
    if isRedundant then
        -- don't add anything, we already knew we were in that time zone at that moment
        ZoneHistory fallback historyDict

    else
        ZoneHistory fallback (Dict.insert (Moment.toSmartInt newEntryMoment) newEntryZone historyDict)



-- Private Helpers


nearestPriorZoneChange : Moment -> Dict Int Zone -> Maybe ( Int, Zone )
nearestPriorZoneChange inputMoment historyDict =
    let
        keyIsPrior keyMomentInt _ =
            -- Input moment can be equal or Later to key moment
            Moment.compare inputMoment (Moment.fromSmartInt keyMomentInt) /= Earlier

        everythingOlder =
            Dict.filter keyIsPrior historyDict
    in
    List.head (Dict.toList everythingOlder)


{-| If the requested Moment is older than the oldest zone-change entry we have, return the oldest entry.

This way it can be used for assuming the zone at that time, since for "ancient history", the oldest known zone is usually a better guess than the most current zone.

-}
isOlderThanOldestZoneChange : Moment -> Dict Int Zone -> Maybe ( Int, Zone )
isOlderThanOldestZoneChange inputMoment historyDict =
    let
        oldestZoneChange =
            List.last (Dict.toList historyDict)

        isOlder ( keyMomentInt, _ ) =
            Moment.toSmartInt inputMoment <= keyMomentInt
    in
    Maybe.filter isOlder oldestZoneChange



-- Personal Days - Get Moments from dates while taking into account moves


{-| What moment did a given date start, from the user's perspective?
May not be "on the hour", e.g. if the user relocated into a timezone that was already in the next day.
Moving back into the previous day is not currently considered. You can go forward in date, never back.

Wow, I'm pretty proud of this one. It was a lot to engineer.
I have no idea if it works as intended though.
TODO test the hell out of this

-}
userDayStart : ZoneHistory -> CalendarDate -> Moment
userDayStart zoneHistory date =
    let
        offsetOfWorldsFurthestAheadTimeZone =
            -- Stupidly +14 hours instead of +12
            Duration.fromHours 14

        -- The earliest Moment the date could possibly start, i.e. in the earliest time zone
        earliestTheDateCouldStart =
            Moment.past (HumanMoment.fromDate utc date) offsetOfWorldsFurthestAheadTimeZone

        -- What time zone were we in at that point? It could be the same or later
        userZoneAtEarliestStartTime =
            sample zoneHistory earliestTheDateCouldStart

        -- When would the day have started in that user time zone?
        dateStartMomentFirstGuess =
            HumanMoment.fromDate userZoneAtEarliestStartTime date

        -- Between earliest possible start and first guess start, were there any more zone changes?
        zoneChangesBeforeThen =
            changesBetween zoneHistory earliestTheDateCouldStart dateStartMomentFirstGuess

        zoneChangesBeforeThenList =
            -- Turn that Int Dict back into a (Moment, Zone) list
            List.map (Tuple.mapFirst Moment.fromSmartInt) <| Dict.toList zoneChangesBeforeThen

        finalDateStart =
            case List.Nonempty.fromList <| zoneChangesBeforeThenList of
                -- No zone changes in that window. Should be 99%+ of the time.
                Nothing ->
                    -- phew, first guess is all we need
                    dateStartMomentFirstGuess

                Just otherChanges ->
                    -- uh oh, there was some zone-hopping that day. (or was it the day before?)
                    let
                        -- Here are the zone changes, paired with when the day would have started in that zone
                        changesWithDateStarts =
                            List.Nonempty.map (\( m, z ) -> ( m, HumanMoment.fromDate z date )) otherChanges

                        -- With any of these zone changes, did we immediately move into a new day?
                        didDateAlreadyStart ( changeMoment, dateStartMoment ) =
                            Moment.isSameOrEarlier dateStartMoment changeMoment

                        changesWithAlreadyStartedDate =
                            List.filter didDateAlreadyStart (List.Nonempty.toList changesWithDateStarts)
                    in
                    case List.Nonempty.fromList changesWithAlreadyStartedDate of
                        -- In at least one of these zone changes, we instantly moved into a new day
                        Just someImmediateDateChanges ->
                            let
                                stripdownToDateStartTimeAsInt ( _, dateStart ) =
                                    Moment.toSmartInt dateStart

                                changesAsDateStartTimes =
                                    List.Nonempty.map stripdownToDateStartTimeAsInt someImmediateDateChanges

                                listEarliestDateStartsFirst =
                                    List.Nonempty.sort changesAsDateStartTimes

                                earliestDateStartInt =
                                    List.Nonempty.head listEarliestDateStartsFirst
                            in
                            -- The earliest zone switch that immediately moved us into a new day, wins.
                            Moment.fromSmartInt earliestDateStartInt

                        -- We changed zones, but never instantly triggering a new day
                        Nothing ->
                            let
                                -- Just use the latest zone for date start
                                latestZone =
                                    Tuple.second <| List.Nonempty.head otherChanges
                            in
                            HumanMoment.fromDate latestZone date
    in
    finalDateStart


changesBetween : ZoneHistory -> Moment -> Moment -> Dict Int Zone
changesBetween (ZoneHistory _ historyDict) start end =
    let
        isBetween momentInt _ =
            Moment.isSameOrLater (Moment.fromSmartInt momentInt) start
                && Moment.isSameOrEarlier (Moment.fromSmartInt momentInt) end
    in
    Dict.filter isBetween historyDict
