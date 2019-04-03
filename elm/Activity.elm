module Activity exposing (Activity, DurationPer, Excusable(..), newActivity)

import Date
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
import Time


{-| Definition of an activity.
-}
type alias Activity =
    { id : ActivityId
    , names : List String -- TODO should be Translations
    , icon : Icon -- TODO figure out best way to do this. svg file path?
    , excusable : Excusable
    , taskOptional : Bool -- technically they can all be "unplanned"
    , devices : Dict Device
    , category : Category
    , backgroundable : Bool
    , maxTime : DurationPer
    , minTime : DurationPer
    }



-- decodeTask : Decode.Decoder Activity
-- decodeTask =
--     decode Activity
--         |> Pipeline.required "title" Decode.string
--         |> Pipeline.required "completion" decodeProgress
--         |> Pipeline.required "editing" Decode.bool
--         |> Pipeline.required "id" Decode.int
--         |> Pipeline.required "predictedEffort" Decode.int
--         |> Pipeline.required "history" (Decode.list decodeHistoryEntry)
--         |> Pipeline.required "parent" (Decode.maybe Decode.int)
--         |> Pipeline.required "tags" (Decode.list Decode.string)
--         |> Pipeline.required "project" (Decode.maybe Decode.int)
--         |> Pipeline.required "deadline" decodeTaskMoment
--         |> Pipeline.required "plannedStart" decodeTaskMoment
--         |> Pipeline.required "plannedFinish" decodeTaskMoment
--         |> Pipeline.required "relevanceStarts" decodeTaskMoment
--         |> Pipeline.required "relevanceEnds" decodeTaskMoment
--
--
-- encodeTask : Activity -> Encode.Value
-- encodeTask record =
--     Encode.object
--         [ ( "title", Encode.string <| record.title )
--         , ( "completion", encodeProgress <| record.completion )
--         , ( "editing", Encode.bool <| record.editing )
--         , ( "id", Encode.int <| record.id )
--         , ( "predictedEffort", Encode.int <| record.predictedEffort )
--         , ( "history", Encode.list encodeHistoryEntry record.history )
--         , ( "parent", Encode2.maybe Encode.int record.parent )
--         , ( "tags", Encode.list Encode.string record.tags )
--         , ( "project", Encode2.maybe Encode.int record.project )
--         , ( "deadline", encodeTaskMoment record.deadline )
--         , ( "plannedStart", encodeTaskMoment record.plannedStart )
--         , ( "plannedFinish", encodeTaskMoment record.plannedFinish )
--         , ( "relevanceStarts", encodeTaskMoment record.relevanceStarts )
--         , ( "relevanceEnds", encodeTaskMoment record.relevanceEnds )
--         ]


newActivity : String -> Int -> Activity
newActivity description id =
    { title = description
    , icon = icon
    }


type Excusable
    = NeverExcused
    | TemporarilyExcused Duration
    | IndefinitelyExcused


type alias DurationPer =
    ( Duration, Duration )


type Icon
    = Icon
