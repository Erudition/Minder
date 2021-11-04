module TimeBlock.TimeBlock exposing (..)

import Activity.Activity exposing (ActivityID)
import ID
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (decode)
import Json.Encode as Encode
import Porting exposing (customDecoder)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar exposing (CalendarDate)
import SmartTime.Human.Clock exposing (TimeOfDay)


type alias TimeBlock =
    { focus : ActivityID
    , date : CalendarDate
    , startTime : TimeOfDay
    , duration : Duration
    }


decodeTimeBlock : Decode.Decoder TimeBlock
decodeTimeBlock =
    decode TimeBlock
        |> Pipeline.required "focus" ID.decode
        |> Pipeline.required "date" (Decode.map SmartTime.Human.Calendar.fromRataDie Decode.int)
        |> Pipeline.required "startTime" (customDecoder Decode.string SmartTime.Human.Clock.fromStandardString)
        |> Pipeline.required "duration" (Decode.map Duration.fromInt Decode.int)


encodeTimeBlock : TimeBlock -> Encode.Value
encodeTimeBlock timeBlock =
    Encode.object <|
        [ ( "focus", ID.encode timeBlock.focus )
        , ( "date", Encode.int <| SmartTime.Human.Calendar.toRataDie timeBlock.date )
        , ( "startTime", Encode.string <| SmartTime.Human.Clock.toStandardString timeBlock.startTime )
        , ( "duration", Encode.int <| Duration.inMs timeBlock.startTime )
        ]
