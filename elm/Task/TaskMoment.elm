module Task.TaskMoment exposing (Duration, Moment, TaskMoment(..), decodeMoment, decodeTaskMoment, describeTaskMoment, encodeMoment, encodeTaskMoment)

import Date exposing (Date)
import Json.Decode
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Extra
import Json.Encode as Encode exposing (..)
import Porting exposing (decodeCustom, sub)
import Time exposing (posixToMillis, utc)
import Time.Distance as Distance
import Time.Extra exposing (Parts, partsToPosix, posixToParts)


{-| A Posix-Time Integer represents an exact, universal, single Date and Time. You could almost say it's simply a MOMENT in time.... Hey wait a second... that's a way better name!
Silly Elm.
-}
type alias Moment =
    Time.Posix


{-| This is a bit of a clever hack: Parts is not an export-friendly datatype (being a large record), but Posix is (being a single Int); we take advantage of Posix's compact form by giving it a fake timezone. Unfortunately the resulting JSON is technically a lie and wouldn't be super intuitive to an outsider.
-}
encodeParts : Parts -> Encode.Value
encodeParts parts =
    Encode.int <| posixToMillis <| partsToPosix zoneless parts


decodeParts : Decode.Decoder Parts
decodeParts =
    Decode.map (posixToParts zoneless) decodeMoment


{-| The timezone we arbitrarily choose to temporarily use for encoding Parts. Factored out as an extra reminder that we're not dealing with utc for real.
-}
zoneless =
    utc


encodeMoment : Moment -> Encode.Value
encodeMoment moment =
    Encode.int (Time.posixToMillis moment)


decodeMoment : Decode.Decoder Moment
decodeMoment =
    Decode.map Time.millisToPosix Decode.int


{-| Rata Die is cool! And just so perfect for this task. (It turns any calendar day into a unique integer: 1 = 1 January 0001.)
-}
encodeDate : Date -> Encode.Value
encodeDate date =
    Encode.int (Date.toRataDie date)


decodeDate : Decode.Decoder Date
decodeDate =
    Decode.map Date.fromRataDie Decode.int


{-| Unlike calendar entries, todo-list items tend to have lots of timeless Dates. Our app needs to be handle dates both with times (Moment) and without times (Date) in a consistent way, so we have the TaskMoment type.

With Elm 0.19, everything is a Posix (Moment) - we can't represent Dates without times, so we use a library to restore that functionality for now.

For full flexibility, we want the user to be able to set times that are always the same (e.g. 9am) regardless of time zone, like you might want with an alarm clock. Storing that is even harder in Posix-only land where you're forced to have a time zone. The time's zone information would always have to change with the local clocks as the user moves - no bueno.

An important design principle is Make Invalid States Unrepresentable. So how do we store these "Localized" times with no zone? With a clever (ab)use of the 'Parts' type from a Time-extra library, meant for constructing a Posix/Moment out of human-friendly bits like Year,Month,Hour before applying a time zone. We simply neglect to add a time zone, storing it as-is.

Note there is a 'Universal' time (same everywhere) and a Local one, but no fourth option for 'Universal Date'. This is because the notion of a 'Universal Date' does not make sense. Yes, sadly, you cannot tell what day it is without a time zone...

-}
type TaskMoment
    = Unset
    | LocalDate Date
    | Localized Parts
    | Universal Moment


decodeTaskMoment : Decoder TaskMoment
decodeTaskMoment =
    decodeCustom
        [ ( "Unset", succeed Unset )
        , ( "LocalDate", sub LocalDate "Date" decodeDate )
        , ( "Localized", sub Localized "Parts" decodeParts )
        , ( "Universal", sub Universal "Moment" decodeMoment )
        ]


{-| TODO make encoder
-}
encodeTaskMoment : TaskMoment -> Encode.Value
encodeTaskMoment taskmoment =
    Encode.object
        []


{-| Brief human-friendly description of due dates relative to now.
TODO implement custom wordings
-}
describeTaskMoment : Moment -> TaskMoment -> String
describeTaskMoment now target =
    case target of
        Unset ->
            ""

        -- TODO, obviously
        LocalDate date ->
            "in " ++ String.fromInt (Date.diff Date.Days date (Date.fromPosix userTimeZonePlaceholder now)) ++ " days"

        Localized moment ->
            Distance.inWords now (partsToPosix userTimeZonePlaceholder moment)

        Universal moment ->
            Distance.inWords now moment


userTimeZonePlaceholder =
    utc


type alias Duration =
    Int
