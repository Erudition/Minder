module Task.ActionClass exposing (..)

import Activity.Activity exposing (ActivityID)
import Dict exposing (Dict)
import Helpers exposing (..)
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (Decoder)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Replicated.Codec as Codec exposing (Codec)
import Replicated.Reducer.Register as Register exposing (RW)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Progress as Progress exposing (..)
import Task.Series


{-| A TaskClass is an exact specific task, in general, without a time. If you took a shower yesterday, and you take a shower tomorrow, those are two separate TaskInstances - but they are instances of the same TaskClass ("take a shower").
This way, the same task can be assigned multiple times in life (either automatic recurrence, or by manually adding a new instance) and the program is aware they are the same thing.

Tasks that are only similar, e.g. "take a bath", should be separate TaskClasses.

-}
type alias ActionClassSkel =
    { title : String -- ActionClass
    , id : ActionClassID -- ActionClass and Instance
    , activity : Maybe ActivityID

    --, template : TaskTemplate
    , completionUnits : Progress.Unit
    , minEffort : Duration -- Class. can always revise
    , predictedEffort : Duration -- Class. can always revise
    , maxEffort : Duration -- Class. can always revise

    --, tags : List TagId -- ActionClass
    , defaultExternalDeadline : List RelativeTiming
    , defaultStartBy : List RelativeTiming --  THESE ARE NORMALLY SPECIFIED AT THE INSTANCE LEVEL
    , defaultFinishBy : List RelativeTiming
    , defaultRelevanceStarts : List RelativeTiming
    , defaultRelevanceEnds : List RelativeTiming
    , importance : Float -- ActionClass
    , extra : Dict String String

    -- future: default Session strategy
    }


decodeActionClassSkel : Decode.Decoder ActionClassSkel
decodeActionClassSkel =
    decode ActionClassSkel
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "id" decodeActionClassID
        |> Pipeline.required "activity" (Decode.nullable <| ID.decode)
        |> Pipeline.required "completionUnits" Progress.decodeUnit
        |> Pipeline.required "minEffort" decodeDuration
        |> Pipeline.required "predictedEffort" decodeDuration
        |> Pipeline.required "maxEffort" decodeDuration
        |> Pipeline.required "defaultExternalDeadline" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultStartBy" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultFinishBy" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultRelevanceStarts" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultRelevanceEnds" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "importance" Decode.float
        |> Pipeline.optional "extra" (Decode.dict Decode.string) Dict.empty


encodeActionClassSkell : ActionClassSkel -> Encode.Value
encodeActionClassSkell taskClass =
    object <|
        [ ( "title", Encode.string taskClass.title )
        , ( "id", Encode.int taskClass.id )
        , ( "activity", Encode2.maybe ID.encode taskClass.activity )
        , ( "completionUnits", Progress.encodeUnit taskClass.completionUnits )
        , ( "minEffort", encodeDuration taskClass.minEffort )
        , ( "predictedEffort", encodeDuration taskClass.predictedEffort )
        , ( "maxEffort", encodeDuration taskClass.maxEffort )
        , ( "defaultExternalDeadline", Encode.list encodeRelativeTiming taskClass.defaultExternalDeadline )
        , ( "defaultStartBy", Encode.list encodeRelativeTiming taskClass.defaultStartBy )
        , ( "defaultFinishBy", Encode.list encodeRelativeTiming taskClass.defaultFinishBy )
        , ( "defaultRelevanceStarts", Encode.list encodeRelativeTiming taskClass.defaultRelevanceStarts )
        , ( "defaultRelevanceEnds", Encode.list encodeRelativeTiming taskClass.defaultRelevanceEnds )
        , ( "importance", Encode.float taskClass.importance )
        , ( "extra", Encode.dict identity Encode.string taskClass.extra )
        ]


newActionClassSkel : String -> Int -> ActionClassSkel
newActionClassSkel givenTitle newID =
    { title = givenTitle
    , id = newID
    , activity = Nothing
    , completionUnits = Progress.Percent
    , minEffort = Duration.zero
    , predictedEffort = Duration.zero
    , maxEffort = Duration.zero
    , defaultExternalDeadline = []
    , defaultStartBy = []
    , defaultFinishBy = []
    , defaultRelevanceStarts = []
    , defaultRelevanceEnds = []
    , importance = 1
    , extra = Dict.empty
    }


type alias ActionClassID =
    Int


decodeActionClassID : Decode.Decoder ActionClassID
decodeActionClassID =
    Decode.int


encodeActionClassID : ActionClassID -> Encode.Value
encodeActionClassID taskClassID =
    Encode.int taskClassID



-- FULL Task Classes (augmented with entry data) --------------------------


type alias ParentProperties =
    { title : RW (Maybe String) -- Can have no title if it's just a singleton task
    }


parentPropertiesCodec : Codec String ParentProperties
parentPropertiesCodec =
    Codec.record ParentProperties
        |> Codec.fieldRW ( 1, "title" ) .title (Codec.maybe Codec.string) Nothing
        |> Codec.finishRecord


{-| A fully spec'ed-out version of a ActionClass
-}
type alias ActionClass =
    { parents : List ParentProperties
    , recurrence : Maybe Task.Series.Series
    , class : ActionClassSkel
    }


makeFullActionClass : List ParentProperties -> Maybe Task.Series.Series -> ActionClassSkel -> ActionClass
makeFullActionClass parentList recurrenceRules class =
    { parents = parentList
    , recurrence = recurrenceRules
    , class = class
    }



-- Task Moments ------------------------------------------------------------


decodeTaskMoment : Decode.Decoder FuzzyMoment
decodeTaskMoment =
    customDecoder Decode.string HumanMoment.fuzzyFromString


{-| TODO make encoder
-}
encodeTaskMoment : FuzzyMoment -> Encode.Value
encodeTaskMoment fuzzy =
    Encode.string <| HumanMoment.fuzzyToString fuzzy


type alias TagId =
    Int



-- Task Timing functions


{-| Need to be able to specify multiple of these, as some may not apply.
-}
type RelativeTiming
    = FromDeadline Duration
    | FromToday Duration


decodeRelativeTiming : Decoder RelativeTiming
decodeRelativeTiming =
    Decode.map FromDeadline decodeDuration


encodeRelativeTiming : RelativeTiming -> Encode.Value
encodeRelativeTiming relativeTaskTiming =
    case relativeTaskTiming of
        FromDeadline duration ->
            encodeDuration duration

        FromToday duration ->
            encodeDuration duration



-- Task helper functions -------------------------------------------------------


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle
