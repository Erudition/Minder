module Model.TaskMoment exposing (Duration, Moment, TaskMoment(..), decodeMoment, decodeTaskMoment, describeMoment, describeTaskMoment, encodeMoment, encodeTaskMoment)

import Json.Decode
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Extra
import Json.Encode as Encode exposing (..)
import Porting exposing (decodeTU, subValue)
import Time
import Time.Distance as Distance


type alias Moment =
    Time.Posix


decodeMoment : Decode.Decoder Moment
decodeMoment =
    Decode.map Time.millisToPosix Decode.int


encodeMoment : Moment -> Encode.Value
encodeMoment moment =
    Encode.int (Time.posixToMillis moment)


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
describeTaskMoment : Moment -> TaskMoment -> String
describeTaskMoment now target =
    case target of
        Unset ->
            ""

        DateOnly date ->
            Distance.inWords now date

        LocalMoment moment ->
            Distance.inWords now moment

        UniversalMoment moment ->
            Distance.inWords now moment


{-| Twas hoping to delegate this function to Jacob, because it only requires basic functional programming (which he should know from Haskell) and little Elm knowledge (which I've already taught him for this purpse), yet will end up as a pretty large, powerful function. Unfortunately, I can't be sure as to his commitment level, and he won't confirm it either, so I guess I'll just have to write it myself.

Update: Library function for this!

-}
describeMoment : Moment -> Moment -> String
describeMoment current target =
    ""



-- let
--     delta =
--         Distance.diff Day current target
--
--     pastOrFuture =
--         Distance.compare current target
-- in
-- case pastOrFuture of
--     EQ ->
--         "right now"
--
--     GT ->
--         -- moment is in the past
--         "over due"
--
--     LT ->
--         -- future target
--         if delta > 5 then
--             "in less than five hours"
--         else if delta < 5 then
--             "its a 7"
--         else
--             "idk somewhere sometime somehow"


type alias Duration =
    Int
