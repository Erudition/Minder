module SmartTime.Human.Clock exposing (Clock, Clock12Hr, NoonBasedHour(..), Zone, every, localZone, toClock, toClock12Hr, utc)

import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Moment as Moment exposing (..)
import Task as Job
import Time as ElmTime exposing (toHour, toMillis, toMinute, toSecond)


type alias Clock =
    { hour : Int
    , minute : Int
    , second : Int
    , ms : Int
    }


type alias Clock12Hr =
    { hour : NoonBasedHour
    , minute : Int
    , second : Int
    , ms : Int
    , bareHour : Int
    , pm : Bool
    }


type NoonBasedHour
    = AM Int
    | PM Int


hourToString : NoonBasedHour -> String
hourToString noonBasedHour =
    case noonBasedHour of
        AM hr ->
            String.fromInt hr ++ " AM"

        PM hr ->
            String.fromInt hr ++ " PM"


hourToShortString : NoonBasedHour -> String
hourToShortString noonBasedHour =
    case noonBasedHour of
        AM hr ->
            String.fromInt hr ++ "a"

        PM hr ->
            String.fromInt hr ++ "p"


toClock : Zone -> Moment -> Clock
toClock zone moment =
    let
        civil =
            toElmTime moment
    in
    { hour = toHour zone civil
    , minute = toMinute zone civil
    , second = toSecond zone civil
    , ms = toMillis zone civil
    }


toClock12Hr : Zone -> Moment -> Clock12Hr
toClock12Hr zone moment =
    let
        civil =
            toElmTime moment

        hour =
            toHour zone civil

        postMeridiem =
            hour > 12

        hourOf12HrDay =
            hour - 12
    in
    { hour =
        if postMeridiem then
            PM hourOf12HrDay

        else
            AM hour
    , minute = toMinute zone civil
    , second = toSecond zone civil
    , ms = toMillis zone civil
    , bareHour = hourOf12HrDay
    , pm = postMeridiem
    }


type alias Zone =
    ElmTime.Zone


utc : ElmTime.Zone
utc =
    ElmTime.utc


{-| Get the current Time Zone, based on the the UTC offset given to us by Javascript. Provided here so you can ditch your `Time` imports entirely if you want.
-}
localZone : Job.Task x Zone
localZone =
    ElmTime.here


{-| Get the current time periodically. How often though? Well, you provide a `HumanDuration` and that is how often you get a new time!

This is a convenient replacement for `Moment.every` that directly accepts HumanDurations, so you can cleanly hardcode a value like:

`Clock.every [ Minutes 1 ] MyUpdateMsg`

(Not for efficient animation. Use the [`elm/animation-frame`][af]
package instead.)
[af]: /packages/elm/animation-frame/latest

-}
every : HumanDuration -> (Moment -> msg) -> Sub msg
every interval tagger =
    Moment.every (HumanDuration.toDuration interval) tagger
