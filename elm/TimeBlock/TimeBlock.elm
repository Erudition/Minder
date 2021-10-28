module TimeBlock.TimeBlock exposing (..)

import Activity.Activity exposing (ActivityID)
import ID
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (decode)
import Json.Encode as Encode
import Porting
import SmartTime.Human.Moment
import SmartTime.Period exposing (Period)


type alias TimeBlock =
    { focus : ActivityID
    , range : Period
    }


decodeTimeBlock : Decode.Decoder TimeBlock
decodeTimeBlock =
    decode TimeBlock
        |> Pipeline.required "focus" ID.decode
        |> Pipeline.required "range" periodDecoder


periodDecoder : Decode.Decoder Period
periodDecoder =
    let
        momentDecoder =
            Porting.customDecoder Decode.string SmartTime.Human.Moment.fromStandardString
    in
    Decode.map SmartTime.Period.fromPair (Porting.arrayAsTuple2 momentDecoder momentDecoder)


encodeTimeBlock : TimeBlock -> Encode.Value
encodeTimeBlock timeBlock =
    Encode.object <|
        [ ( "focus", ID.encode timeBlock.focus )
        , ( "range", periodEncoder timeBlock.range )
        ]


periodEncoder : Period -> Encode.Value
periodEncoder period =
    let
        momentEncoder moment =
            Encode.string <| SmartTime.Human.Moment.toStandardString moment
    in
    Porting.homogeneousTuple2AsArray momentEncoder (SmartTime.Period.toPair period)
