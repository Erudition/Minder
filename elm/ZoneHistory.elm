module ZoneHistory exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import List.Extra as List
import Maybe.Extra as Maybe
import Set exposing (Set)
import SmartTime.Human.Moment exposing (Zone)
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
            Moment.compare inputMoment (Moment.fromSmartInt keyMomentInt) != Earlier

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
