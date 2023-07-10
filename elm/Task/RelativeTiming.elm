module Task.RelativeTiming exposing (..)

import Dict
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID
import Json.Decode.Exploration as Decode exposing (Decoder)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra exposing (..)
import NativeScript.Notification
import Replicated.Change
import Replicated.Codec as Codec
import Replicated.Reducer.Register
import Replicated.Reducer.RepDb
import Replicated.Reducer.RepDict
import Replicated.Reducer.RepList
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment



-- Task Timing functions


{-| Need to be able to specify multiple of these, as some may not apply.
-}
type RelativeTiming
    = FromDeadline Duration
    | FromToday Duration


relativeTimingCodec : Codec.NullCodec String RelativeTiming
relativeTimingCodec =
    Codec.customType
        (\fromDeadline fromToday value ->
            case value of
                FromDeadline duration ->
                    fromDeadline duration

                FromToday duration ->
                    fromToday duration
        )
        |> Codec.variant1 ( 1, "FromDeadline" ) FromDeadline Codec.duration
        |> Codec.variant1 ( 2, "FromToday" ) FromToday Codec.duration
        |> Codec.finishCustomType


toStringPart1 relativeTiming =
    case relativeTiming of
        FromDeadline duration ->
            "FromDeadline"

        FromToday duration ->
            "FromToday"


toIntPart2 relativeTiming =
    case relativeTiming of
        FromDeadline duration ->
            Duration.inMs duration

        FromToday duration ->
            Duration.inMs duration


toRawPair relativeTiming =
    ( toStringPart1 relativeTiming, toIntPart2 relativeTiming )


fromRawPairMaybe ( part1, part2 ) =
    case part1 of
        "FromDeadline" ->
            Just <| FromDeadline (Duration.fromInt part2)

        "FromToday" ->
            Just <| FromToday (Duration.fromInt part2)

        _ ->
            Nothing
