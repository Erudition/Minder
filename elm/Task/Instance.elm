module Task.Instance exposing (..)

import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Result.Extra as Result
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import SmartTime.Moment exposing (..)
import SmartTime.Period exposing (Period)
import Task.Class exposing (Class, ClassID, ClassSkel, ParentProperties, decodeClassID, decodeTaskMoment, encodeTaskMoment)
import Task.Entry exposing (Entry, getClassesFromEntries)
import Task.Progress as Progress exposing (..)
import Task.Series exposing (RecurrenceRule, SeriesID)
import Task.SessionSkel exposing (UserPlannedSession, decodeSession, encodeSession)
import ZoneHistory exposing (ZoneHistory)



-- Instance Skeleton (bare minimum, non-derivative data, saved to disk) --------------------------------


{-| Definition of a single instance of a single task - one particular time that the specific thing will be done, that can be scheduled. Can be thought of as an "assignment" of a task (class). There may be zero (an unassigned task), and there may be many (a repeated task) for a given class.
-}
type alias InstanceSkel =
    { class : ClassID
    , id : InstanceID
    , memberOfSeries : Maybe SeriesID
    , completion : Progress.Portion
    , externalDeadline : Maybe FuzzyMoment -- *
    , startBy : Maybe FuzzyMoment -- *
    , finishBy : Maybe FuzzyMoment -- *
    , plannedSessions : List UserPlannedSession
    , relevanceStarts : Maybe FuzzyMoment -- *
    , relevanceEnds : Maybe FuzzyMoment -- * (*)=An absolute FuzzyMoment if specified, otherwise generated by relative rules from class
    }


decodeInstance : Decode.Decoder InstanceSkel
decodeInstance =
    decode InstanceSkel
        |> Pipeline.required "class" decodeClassID
        |> Pipeline.required "id" decodeInstanceID
        |> Pipeline.optional "memberOfSeries" (Decode.nullable Decode.int) Nothing
        |> Pipeline.required "completion" Decode.int
        |> Pipeline.required "externalDeadline" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "startBy" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "finishBy" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "plannedSessions" (Decode.list decodeSession)
        |> Pipeline.required "relevanceStarts" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "relevanceEnds" (Decode.nullable decodeTaskMoment)


encodeInstance : InstanceSkel -> Encode.Value
encodeInstance taskInstance =
    Encode.object <|
        [ ( "class", Encode.int taskInstance.class )
        , ( "id", Encode.int taskInstance.id )
        , ( "memberOfSeries", Encode2.maybe Encode.int taskInstance.memberOfSeries )
        , ( "completion", Encode.int taskInstance.completion )
        , ( "externalDeadline", Encode2.maybe encodeTaskMoment taskInstance.externalDeadline )
        , ( "startBy", Encode2.maybe encodeTaskMoment taskInstance.startBy )
        , ( "finishBy", Encode2.maybe encodeTaskMoment taskInstance.finishBy )
        , ( "plannedSessions", Encode.list encodeSession taskInstance.plannedSessions )
        , ( "relevanceStarts", Encode2.maybe encodeTaskMoment taskInstance.relevanceStarts )
        , ( "relevanceEnds", Encode2.maybe encodeTaskMoment taskInstance.relevanceEnds )
        ]


newInstanceSkel : Int -> ClassSkel -> InstanceSkel
newInstanceSkel newID class =
    { class = class.id
    , id = newID
    , memberOfSeries = Nothing
    , completion = 0
    , externalDeadline = Nothing
    , startBy = Nothing
    , finishBy = Nothing
    , plannedSessions = []
    , relevanceStarts = Nothing
    , relevanceEnds = Nothing
    }


type alias InstanceID =
    Int


decodeInstanceID : Decoder InstanceID
decodeInstanceID =
    Decode.int


encodeInstanceID : InstanceID -> Encode.Value
encodeInstanceID taskInstanceID =
    Encode.int taskInstanceID



-- FULL Instances (augmented with Entry & Class) ----------------------------------------


{-| A fully spec'ed-out version of a TaskInstance
-}
type alias Instance =
    { parents : List ParentProperties
    , class : ClassSkel
    , instance : InstanceSkel
    }


{-| Get all relevant instances of everything.

Take the skeleton data and get all relevant(within given time period) instances of every class, and return them as Full Instances.

TODO organize with IDs somehow

-}
listAllInstances : List Class -> IntDict.IntDict InstanceSkel -> ( ZoneHistory, Period ) -> List Instance
listAllInstances fullClasses savedInstanceSkeletons timeData =
    List.concatMap (singleClassToActiveInstances timeData savedInstanceSkeletons) fullClasses


{-| Take a class and return all of the instances relevant within the given period - saved or generated.

Combine the saved instances with generated ones, to get the full picture within a period.

TODO: best data structure? Is Dict unnecessary here? Or should the key involve the classID for perf?

-}
singleClassToActiveInstances : ( ZoneHistory, Period ) -> IntDict InstanceSkel -> Class -> List Instance
singleClassToActiveInstances ( zoneHistory, relevantPeriod ) allSavedInstances fullClass =
    let
        -- Any & all saved instances that match this taskclass
        -- TODO more efficient way to filter?
        savedInstancesWithMatchingClass =
            List.filter (\instance -> instance.class == fullClass.class.id) (IntDict.values allSavedInstances)

        savedInstancesFull =
            List.map toFull savedInstancesWithMatchingClass

        toFull : InstanceSkel -> Instance
        toFull instanceSkel =
            { parents = fullClass.parents
            , class = fullClass.class
            , instance = instanceSkel
            }

        -- Filter out instances outside the window
        relevantSavedInstances =
            List.filter isRelevant savedInstancesFull

        -- TODO "If savedInstance is within period, keep"
        isRelevant savedInstance =
            True

        -- TODO Fill in based on recurrence series. Int ID = order in series.
        relevantSeriesMembers =
            List.concatMap (fillSeries ( zoneHistory, relevantPeriod ) fullClass) fullClass.recurrence
    in
    relevantSavedInstances
        ++ relevantSeriesMembers


fillSeries : ( ZoneHistory, Period ) -> Class -> RecurrenceRule -> List Instance
fillSeries ( zoneHistory, relevantPeriod ) fullClass seriesRule =
    -- TODO
    []


instanceProgress : Instance -> Progress
instanceProgress fullInstance =
    ( fullInstance.instance.completion, fullInstance.class.completionUnits )



-- Task helper functions ---------------------------------------------


completed : Instance -> Bool
completed spec =
    isMax ( spec.instance.completion, spec.class.completionUnits )


type alias WithSoonness t =
    { t | soonness : Duration }


prioritize : Moment -> HumanMoment.Zone -> List Instance -> List Instance
prioritize now zone taskList =
    let
        -- lowest values first
        compareProp prop a b =
            Basics.compare (prop a) (prop b)

        -- highest values first
        comparePropInverted prop a b =
            Basics.compare (prop b) (prop a)
    in
    -- deepSort [ compareSoonness zone, comparePropInverted .importance ] taskList
    deepSort [ compareSoonness zone ] taskList



-- List.sortWith (compareSoonness zone) <| List.sortBy .importance taskList


type alias CompareFunction a =
    a -> a -> Basics.Order


deepSort : List (CompareFunction a) -> List a -> List a
deepSort compareFuncs listToSort =
    let
        deepCompare funcs a b =
            case funcs of
                [] ->
                    -- No more comparisons to make, give up and say they're equal
                    EQ

                nextCompareFunc :: laterCompareFuncs ->
                    let
                        -- run next comparison
                        check =
                            nextCompareFunc a b
                    in
                    if check == EQ then
                        -- they still look equal, dig deeper
                        deepCompare laterCompareFuncs a b

                    else
                        -- we have a winner, we can stop digging
                        check
    in
    List.sortWith (deepCompare compareFuncs) listToSort


{-| TODO this could be a Moment.Fuzzy function
-}
compareSoonness : HumanMoment.Zone -> CompareFunction Instance
compareSoonness zone taskA taskB =
    case ( taskA.instance.externalDeadline, taskB.instance.externalDeadline ) of
        ( Just fuzzyMomentA, Just fuzzyMomentB ) ->
            HumanMoment.compareFuzzyLateness zone Clock.endOfDay fuzzyMomentA fuzzyMomentB

        ( Nothing, Nothing ) ->
            -- whenevers can't be compared
            EQ

        ( Just _, Nothing ) ->
            -- actual times always come before whenevers
            LT

        ( Nothing, Just _ ) ->
            -- whenevers always come after actual times
            GT
