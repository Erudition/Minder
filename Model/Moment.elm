module Model.Moment exposing (..)

import Date
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra as Decode2 exposing (..)
import Json.Encode as Encode exposing (..)
import Time
import Time.DateTime as Moment exposing (DateTime, compare, dateTime, day, hour, millisecond, minute, month, second, year)
import Time.Iso8601 exposing (toDateTime)
import Time.Iso8601ErrorMsg exposing (renderText)
import Time.ZonedDateTime as LocalMoment exposing (ZonedDateTime)


type alias Moment =
    DateTime


decodeMoment : Decode.Decoder Moment
decodeMoment =
    let
        convert n =
            fromResult (Result.mapError Time.Iso8601ErrorMsg.renderText (Time.Iso8601.toDateTime n))

        -- Decoders must have String errors
    in
    Decode.string |> andThen convert


encodeMoment : Moment -> Encode.Value
encodeMoment moment =
    Encode.string (Time.Iso8601.fromDateTime moment)


type alias LocalMoment =
    ZonedDateTime


type MomentOrDay
    = AtExactly Moment
    | OnDayOf Moment


decodeMomentOrDay : Decoder MomentOrDay
decodeMomentOrDay =
    let
        fallthrough string =
            Result.Err ("Not valid pattern for decoder to MomentOrDay. Pattern: " ++ toString string)

        tag =
            field "tag" Decode.string
    in
    oneOf
        [ when tag ((==) "AtExactly") decodeAtExactly
        , when tag ((==) "OnDayOf") decodeOnDayOf
        , Decode.string |> andThen (fromResult << fallthrough)
        ]


encodeMomentOrDay : MomentOrDay -> Encode.Value
encodeMomentOrDay =
    toString >> Encode.string


decodeAtExactly : Decoder MomentOrDay
decodeAtExactly =
    Decode.map AtExactly (Decode.field "moment" decodeMoment)


decodeOnDayOf : Decoder MomentOrDay
decodeOnDayOf =
    Decode.map OnDayOf (Decode.field "moment" decodeMoment)


describeMomentOrDay : Time.Time -> MomentOrDay -> String
describeMomentOrDay time momentOrDay =
    case momentOrDay of
        AtExactly moment ->
            describeMoment (Moment.fromTimestamp time) moment

        OnDayOf moment ->
            describeMoment (Moment.fromTimestamp time) moment


{-| Twas hoping to delegate this function to Jacob, because it only requires basic functional programming (which he should know from Haskell) and little Elm knowledge (which I've already taught him for this purpse), yet will end up as a pretty large, powerful function. Unfortunately, I can't be sure as to his commitment level, and he won't confirm it either, so I guess I'll just have to write it myself.
-}
describeMoment : Moment -> Moment -> String
describeMoment current target =
    let
        delta =
            Moment.delta current target

        pastOrFuture =
            Moment.compare current target
    in
    case pastOrFuture of
        EQ ->
            "right now"

        GT ->
            -- moment is in the past
            "over due"

        LT ->
            -- future target
            if delta.days > 5 then
                "in less than five hours"
            else if delta.days < 5 then
                "its a 7"
            else
                "idk somewhere sometime somehow"



-- 5 hours away : in 5 hours
-- 5 minutes in the past : "5 minutes ago"
-- now : "right now"
-- later : "right later"


type alias Duration =
    Int
