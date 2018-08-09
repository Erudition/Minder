module Model.Moment exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra as Decode2 exposing (..)
import Json.Encode as Encode exposing (..)
import Time.DateTime as Moment exposing (DateTime, dateTime, day, hour, millisecond, minute, month, second, year)
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


type alias Duration =
    Int
