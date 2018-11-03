module Model.TaskMoment exposing (Duration, Moment, TaskMoment(..), decodeMoment, decodeTaskMoment, describeMoment, describeTaskMoment, encodeMoment, encodeTaskMoment)

import Date as Moment
import Date.Distance as Distance
import Date.Extra as Moment2 exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra as Decode2 exposing (..)
import Json.Encode as Encode exposing (..)
import Porting exposing (decodeTU, subValue, valueC)
import Time


type alias Moment =
    Moment.Date


decodeMoment : Decode.Decoder Moment
decodeMoment =
    Decode2.date


encodeMoment : Moment -> Encode.Value
encodeMoment moment =
    Encode.string (Moment2.toIsoString moment)


type TaskMoment
    = Unset
    | DateOnly Moment
    | LocalMoment Moment
    | UniversalMoment Moment


decodeTaskMoment : Decoder TaskMoment
decodeTaskMoment =
    decodeTU "TaskMoment"
        [ valueC "Unset" (succeed Unset)
        , valueC "DateOnly" (subValue DateOnly "moment" decodeMoment)
        , valueC "LocalMoment" (subValue LocalMoment "moment" decodeMoment)
        , valueC "UniversalMoment" (subValue UniversalMoment "moment" decodeMoment)
        ]


encodeTaskMoment : TaskMoment -> Encode.Value
encodeTaskMoment taskmoment =
    Encode.object
        []


{-| Brief human-friendly description of due dates relative to now.
TODO implement custom wordings
-}
describeTaskMoment : Time.Time -> TaskMoment -> String
describeTaskMoment now target =
    case target of
        Unset ->
            ""

        DateOnly date ->
            Distance.inWords (Moment.fromTime now) date

        LocalMoment moment ->
            Distance.inWords (Moment.fromTime now) moment

        UniversalMoment moment ->
            Distance.inWords (Moment.fromTime now) moment


{-| Twas hoping to delegate this function to Jacob, because it only requires basic functional programming (which he should know from Haskell) and little Elm knowledge (which I've already taught him for this purpse), yet will end up as a pretty large, powerful function. Unfortunately, I can't be sure as to his commitment level, and he won't confirm it either, so I guess I'll just have to write it myself.

Update: Library function for this!

-}
describeMoment : Moment -> Moment -> String
describeMoment current target =
    let
        delta =
            Moment2.diff Day current target

        pastOrFuture =
            Moment2.compare current target
    in
    case pastOrFuture of
        EQ ->
            "right now"

        GT ->
            -- moment is in the past
            "over due"

        LT ->
            -- future target
            if delta > 5 then
                "in less than five hours"

            else if delta < 5 then
                "its a 7"

            else
                "idk somewhere sometime somehow"


type alias Duration =
    Int
