module Task.AssignedAction exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import ExtraCodecs as Codec
import ID exposing (ID)
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Log
import Replicated.Change as Change exposing (Change, Changer, Context, getPointerObjectID)
import Replicated.Codec as Codec exposing (Codec, FlatCodec)
import Replicated.Op.OpID as OpID exposing (toRonPointerString)
import Replicated.Reducer.Register as Reg exposing (RW, Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Result.Extra as Result
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment, Zone)
import SmartTime.Moment exposing (..)
import SmartTime.Period as Period exposing (Period)
import Task.ActionClass exposing (ActionClass, ActionClassID, ActionClassSkel, ParentProperties, decodeTaskMoment, encodeTaskMoment)
import Task.Progress as Progress exposing (..)
import Task.Series exposing (Series, SeriesID)
import Task.SessionSkel as Session exposing (UserPlannedSession, decodeSession, encodeSession)
import ZoneHistory exposing (ZoneHistory)



-- AssignedAction Skeleton (bare minimum, non-derivative data, saved to disk) --------------------------------


{-| Definition of a single instance of a single task - one particular time that the specific thing will be done, that can be scheduled. Can be thought of as an "assignment" of a task (class). There may be zero (an unassigned task), and there may be many (a repeated task) for a given class.
-}
type alias AssignedActionSkel =
    { classID : RW ActionClassID
    , memberOfSeries : Maybe SeriesID
    , completion : RW Progress.Portion
    , externalDeadline : RW (Maybe FuzzyMoment) -- *
    , startBy : RW (Maybe FuzzyMoment) -- *
    , finishBy : RW (Maybe FuzzyMoment) -- *
    , plannedSessions : RepList UserPlannedSession
    , relevanceStarts : RW (Maybe FuzzyMoment) -- *
    , relevanceEnds : RW (Maybe FuzzyMoment) -- * (*)=An absolute FuzzyMoment if specified, otherwise generated by relative rules from class
    , extra : RepDict String String
    }


codec : Codec String ( ActionClassID, Changer (Reg AssignedActionSkel) ) Codec.SoloObject (Reg AssignedActionSkel)
codec =
    Codec.record AssignedActionSkel
        |> Codec.coreRW ( 1, "classID" ) .classID Codec.id identity
        |> Codec.maybeR ( 2, "memberOfSeries" ) .memberOfSeries Codec.int
        |> Codec.fieldRW ( 3, "completion" ) .completion Codec.int 0
        |> Codec.maybeRW ( 4, "externalDeadline" ) .externalDeadline Codec.fuzzyMoment
        |> Codec.maybeRW ( 5, "startBy" ) .startBy Codec.fuzzyMoment
        |> Codec.maybeRW ( 6, "finishBy" ) .finishBy Codec.fuzzyMoment
        |> Codec.fieldList ( 7, "plannedSessions" ) .plannedSessions Session.codec
        |> Codec.maybeRW ( 8, "relevanceStarts" ) .relevanceStarts Codec.fuzzyMoment
        |> Codec.maybeRW ( 9, "relevanceEnds" ) .relevanceEnds Codec.fuzzyMoment
        |> Codec.fieldDict ( 10, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.finishSeededRegister


type alias AssignedActionID =
    ID (Reg AssignedActionSkel)


type alias AssignedActionDb =
    RepDb (Reg AssignedActionSkel)


initWithClass : ActionClassID -> Context (Reg AssignedActionSkel) -> Reg AssignedActionSkel
initWithClass actionClassID context =
    Codec.seededNew codec context ( actionClassID, \_ -> [] )


initWithClassAndChanges : ActionClassID -> Change.Changer (Reg AssignedActionSkel) -> Context (Reg AssignedActionSkel) -> Reg AssignedActionSkel
initWithClassAndChanges actionClassID changer context =
    Codec.seededNew codec context ( actionClassID, changer )



-- FULL Instances (augmented with Entry & ActionClass) ----------------------------------------


{-| A fully spec'ed-out version of a TaskInstance
-}
type alias AssignedAction =
    { parents : List (Reg ParentProperties)
    , class : Reg ActionClassSkel
    , instance : Reg AssignedActionSkel
    , index : Int
    , instanceID : AssignedActionID
    , classID : ActionClassID
    , remove : Change
    }


{-| Get all relevant instances of everything.

Take the skeleton data and get all relevant(within given time period) instances of every class, and return them as Full Instances.

TODO organize with IDs somehow

-}
listAllAssignedActions : List ActionClass -> AssignedActionDb -> ( ZoneHistory, Period ) -> List AssignedAction
listAllAssignedActions fullClasses instanceDb timeData =
    List.concatMap (assignedActionsOfClass timeData instanceDb) fullClasses


{-| Take a class and return all of the instances relevant within the given period - saved or generated.

Combine the saved instances with generated ones, to get the full picture within a period.

TODO: best data structure? Is Dict unnecessary here? Or should the key involve the classID for perf?

-}
assignedActionsOfClass : ( ZoneHistory, Period ) -> AssignedActionDb -> ActionClass -> List AssignedAction
assignedActionsOfClass ( zoneHistory, relevantPeriod ) instanceDb fullClass =
    let
        savedInstancesWithMatchingClass =
            List.filter (\member -> (Reg.latest member.value).classID.get == fullClass.classID) (RepDb.members instanceDb)

        savedInstancesFull =
            List.indexedMap toFull savedInstancesWithMatchingClass

        toFull : Int -> RepDb.Member (Reg AssignedActionSkel) -> AssignedAction
        toFull indexFromZero instanceSkelMember =
            { parents = fullClass.parents
            , class = fullClass.class
            , instance = instanceSkelMember.value
            , index = indexFromZero + 1
            , instanceID = instanceSkelMember.id
            , classID = fullClass.classID
            , remove = instanceSkelMember.remove
            }

        -- Filter out instances outside the window
        relevantSavedInstances =
            List.filter isRelevant savedInstancesFull

        -- TODO "If savedInstance is within period, keep"
        isRelevant savedInstance =
            True

        -- TODO Fill in based on recurrence series. Int ID = order in series.
        relevantSeriesMembers =
            fillSeries ( zoneHistory, relevantPeriod ) fullClass fullClass.recurrence
    in
    relevantSavedInstances
        ++ relevantSeriesMembers


fillSeries : ( ZoneHistory, Period ) -> ActionClass -> Maybe Series -> List AssignedAction
fillSeries ( zoneHistory, relevantPeriod ) fullClass seriesRule =
    -- TODO
    []



-- Task helper functions ---------------------------------------------


isRelevantNow : AssignedAction -> Moment -> Zone -> Bool
isRelevantNow instance now zone =
    let
        fuzzyNow =
            HumanMoment.Global now

        start =
            Maybe.withDefault fuzzyNow (Reg.latest instance.instance).relevanceStarts.get

        end =
            Maybe.withDefault fuzzyNow (Reg.latest instance.instance).relevanceEnds.get

        notBeforeStart =
            HumanMoment.compareFuzzy zone Clock.startOfDay fuzzyNow start /= Earlier

        notAfterEnd =
            HumanMoment.compareFuzzy zone Clock.endOfDay fuzzyNow end /= Later
    in
    notBeforeStart && notAfterEnd


completed : AssignedAction -> Bool
completed instance =
    isMax ( (Reg.latest instance.instance).completion.get, (Reg.latest instance.class).completionUnits.get )


partiallyCompleted : AssignedAction -> Bool
partiallyCompleted instance =
    (Reg.latest instance.instance).completion.get > 0


type alias WithSoonness t =
    { t | soonness : Duration }


prioritize : Moment -> HumanMoment.Zone -> List AssignedAction -> List AssignedAction
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
    deepSort [ compareSoonness zone, compareNewness ] taskList



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
compareSoonness : HumanMoment.Zone -> CompareFunction AssignedAction
compareSoonness zone taskA taskB =
    case ( (Reg.latest taskA.instance).externalDeadline.get, (Reg.latest taskB.instance).externalDeadline.get ) of
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


compareNewness : CompareFunction AssignedAction
compareNewness taskA taskB =
    let
        taskToIDString task =
            task.instance
                |> Reg.getPointer
                |> Change.getPointerObjectID
                |> Maybe.map OpID.toString
                |> Maybe.withDefault ""
    in
    Basics.compare (taskToIDString taskB) (taskToIDString taskA)


getID : AssignedAction -> AssignedActionID
getID ins =
    ins.instanceID


getIDString : AssignedAction -> String
getIDString ins =
    ID.toString ins.instanceID


getClassIDString : AssignedAction -> String
getClassIDString ins =
    ID.toString ins.classID


getTitle : AssignedAction -> String
getTitle instance =
    (Reg.latest instance.class).title.get


getActivityID : AssignedAction -> Maybe ActivityID
getActivityID instance =
    (Reg.latest instance.class).activity.get


getActivityIDString : AssignedAction -> Maybe String
getActivityIDString instance =
    Maybe.map Activity.idToString (Reg.latest instance.class).activity.get


getProgress : AssignedAction -> Progress
getProgress instance =
    ( (Reg.latest instance.instance).completion.get, (Reg.latest instance.class).completionUnits.get )


setCompletion : Portion -> AssignedAction -> Change
setCompletion newPortion instance =
    (Reg.latest instance.instance).completion.set newPortion


setProjectTitle : String -> AssignedAction -> Change
setProjectTitle newTitle instance =
    (Reg.latest instance.class).title.set newTitle


getProgressMaxInt : AssignedAction -> Portion
getProgressMaxInt instance =
    Progress.unitMax (Reg.latest instance.class).completionUnits.get


getCompletionInt : AssignedAction -> Int
getCompletionInt instance =
    (Reg.latest instance.instance).completion.get


getImportance : AssignedAction -> Float
getImportance instance =
    (Reg.latest instance.class).importance.get


setImportance : AssignedAction -> Float -> Change
setImportance instance =
    (Reg.latest instance.class).importance.set


getRelevanceStarts : AssignedAction -> Maybe FuzzyMoment
getRelevanceStarts instance =
    (Reg.latest instance.instance).relevanceStarts.get


getRelevanceEnds : AssignedAction -> Maybe FuzzyMoment
getRelevanceEnds instance =
    (Reg.latest instance.instance).relevanceEnds.get


getExternalDeadline : AssignedAction -> Maybe FuzzyMoment
getExternalDeadline instance =
    (Reg.latest instance.instance).externalDeadline.get


getMinEffort : AssignedAction -> Duration
getMinEffort instance =
    (Reg.latest instance.class).minEffort.get


getEstimatedEffort : AssignedAction -> Duration
getEstimatedEffort instance =
    (Reg.latest instance.class).predictedEffort.get


setEstimatedEffort : AssignedAction -> Duration -> Change
setEstimatedEffort instance =
    (Reg.latest instance.class).predictedEffort.set


getMaxEffort : AssignedAction -> Duration
getMaxEffort instance =
    (Reg.latest instance.class).maxEffort.get


getExtra : String -> AssignedAction -> Maybe String
getExtra key instance =
    RepDict.get key (Reg.latest instance.instance).extra


setExtra : String -> String -> AssignedAction -> Change
setExtra key value instance =
    RepDict.insert key value (Reg.latest instance.instance).extra
