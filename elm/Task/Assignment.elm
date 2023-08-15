module Task.Assignment exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Maybe.Extra
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (NullCodec)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment, Zone)
import SmartTime.Moment exposing (Moment, TimelineOrder(..))
import SmartTime.Period exposing (Period)
import Task.ActionSkel as Action exposing (ActionID, ActionSkel)
import Task.Assignable as Assignable exposing (Assignable, AssignableID)
import Task.AssignedActionSkel exposing (AssignedActionSkel)
import Task.AssignmentSkel exposing (AssignmentSkel)
import Task.Progress as Progress exposing (Progress)
import Task.ProjectSkel as Project exposing (NestedOrAssignable(..), ProjectID, ProjectSkel)
import Task.Series exposing (Series, SeriesIndex, SeriesMemberID)
import Task.SubAssignableSkel as SubAssignable exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


{-| Assignment with metadata
-}
type Assignment
    = Assignment
        { assignable : Assignable
        , reg : Reg AssignmentSkel
        , index : Int
        , id : AssignmentID
        , remove : Change
        }


type alias SubAssignmentID =
    ( AssignmentID, SubAssignableID )


type Query
    = AllSaved
    | WithinPeriod Period ZoneHistory


type AssignmentID
    = ManualAssignmentID (ID (Reg AssignmentSkel))
    | SeriesAssignmentID (ID Series) SeriesIndex


idCodec : NullCodec String AssignmentID
idCodec =
    Codec.customType
        (\manualAssignmentID seriesAssignmentID value ->
            case value of
                ManualAssignmentID regID ->
                    manualAssignmentID regID

                SeriesAssignmentID seriesID seriesIndex ->
                    seriesAssignmentID seriesID seriesIndex
        )
        |> Codec.variant1 ( 1, "ManualAssignmentID" ) ManualAssignmentID Codec.id
        |> Codec.variant2 ( 2, "SeriesAssignmentID" ) SeriesAssignmentID Codec.id Codec.int
        |> Codec.finishCustomType


{-| Take a assignable and return all of the assignments relevant within the given period - saved or generated.

Combine the saved assignments with generated ones, to get the full picture within a period.

TODO: best data structure? Is Dict unnecessary here? Or should the key involve the assignableID for perf?

-}
fromAssignables : Query -> Assignable -> List Assignment
fromAssignables query parent =
    let
        manualAssignments =
            RepDb.members <| Assignable.manualAssignments parent

        savedAssignmentsFull =
            List.indexedMap (fromSkel parent) manualAssignments

        -- Filter out assignments outside the window
        relevantSavedInstances =
            List.filter isRelevant savedAssignmentsFull

        -- TODO "If savedInstance is within period, keep"
        isRelevant _ =
            True

        -- TODO Fill in based on recurrence series. Int ID = order in series.
        _ =
            fillSeries query parent
    in
    relevantSavedInstances


fromSkel : Assignable -> Int -> RepDb.Member (Reg AssignmentSkel) -> Assignment
fromSkel metaAssignable indexFromZero assignmentSkelMember =
    Assignment
        { assignable = metaAssignable
        , reg = assignmentSkelMember.value
        , index = indexFromZero + 1
        , id = ManualAssignmentID assignmentSkelMember.id
        , remove = assignmentSkelMember.remove
        }



-- {-| Get all relevant actions of all assignments.
-- -}
-- listAllActions : List Assignable -> Query -> List AssignedAction
-- listAllActions assignables timeData =
--     let
--         allAssignments =
--             assignablesToAssignments assignables timeData
--     in
--     List.concatMap (actionsOfAssignment timeData) allAssignments
-- {-| -}
-- actionsOfAssignment : Query -> Assignment -> List AssignedAction
-- actionsOfAssignment query (Assignment assignment) =
--     let
--         actions =
--             assignableToActions assignment.parents assignment.assignableReg
--         assignedActionsWithClassID =
--             (Reg.latest assignment.reg).nestedAssignedActions
--         fullAssignmentFromAction : Action -> AssignedAction
--         fullAssignmentFromAction (Action metaAction) =
--             let
--                 assignedActionReg =
--                     RepStore.get metaAction.actionID assignedActionsWithClassID
--                 _ =
--                     Reg.latest assignedActionReg
--             in
--             AssignedAction
--                 { parents = metaAction.parents
--                 , actionReg = metaAction.actionReg
--                 , actionID = metaAction.actionID
--                 , assignableReg = assignment.assignableReg
--                 , assignmentReg = assignment.reg
--                 , assignmentID = assignment.assignmentID
--                 , assignableID = assignment.assignableID
--                 , assignedActionReg = assignedActionReg
--                 }
--         fullAssignmentsFromActions : List AssignedAction
--         fullAssignmentsFromActions =
--             List.map fullAssignmentFromAction actions
--         -- Filter out assignments outside the window
--         relevantSavedActionAssignments =
--             List.filter isRelevant fullAssignmentsFromActions
--         -- TODO "If savedInstance is within period, keep"
--         isRelevant _ =
--             True
--     in
--     relevantSavedActionAssignments


fillSeries : Query -> Assignable -> List Assignment
fillSeries relevance _ =
    -- TODO
    []


isRelevantNow : Moment -> Zone -> Assignment -> Bool
isRelevantNow now zone assignment =
    let
        fuzzyNow =
            HumanMoment.Global now

        start =
            Maybe.withDefault fuzzyNow <| relevanceStarts assignment

        end =
            Maybe.withDefault fuzzyNow <| relevanceEnds assignment

        notBeforeStart =
            HumanMoment.compareFuzzy zone Clock.startOfDay fuzzyNow start /= Earlier

        notAfterEnd =
            HumanMoment.compareFuzzy zone Clock.endOfDay fuzzyNow end /= Later
    in
    notBeforeStart && notAfterEnd


isCompleted : Assignment -> Bool
isCompleted assignment =
    Progress.isMax ( completion assignment, assignable assignment |> Assignable.completionUnits )


isPartiallyCompleted : Assignment -> Bool
isPartiallyCompleted assignment =
    completion assignment > 0


type alias WithSoonness t =
    { t | soonness : Duration }


prioritize : Moment -> HumanMoment.Zone -> List Assignment -> List Assignment
prioritize _ zone taskList =
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
compareSoonness : HumanMoment.Zone -> CompareFunction Assignment
compareSoonness zone assignmentA assignmentB =
    case ( externalDeadline assignmentA, externalDeadline assignmentB ) of
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


compareNewness : CompareFunction Assignment
compareNewness a b =
    -- B before A since it's about soonness
    Basics.compare (idString a) (idString b)


id : Assignment -> AssignmentID
id (Assignment assignment) =
    assignment.id


idString : Assignment -> String
idString (Assignment assignment) =
    case assignment.id of
        ManualAssignmentID regID ->
            ID.toString regID

        SeriesAssignmentID seriesID seriesIndex ->
            Task.Series.memberIDToString ( seriesID, seriesIndex )


assignable (Assignment assignment) =
    assignment.assignable


title (Assignment assignment) =
    Assignable.title assignment.assignable


activityID (Assignment assignment) =
    Assignable.activityID assignment.assignable


activityIDString (Assignment assignment) =
    Assignable.activityIDString assignment.assignable


progress metaAssignment =
    ( completion metaAssignment, Assignable.completionUnits <| assignable metaAssignment )


setCompletion newPortion (Assignment assignment) =
    (Reg.latest assignment.reg).completion.set newPortion


progressMaxInt assignment =
    assignable assignment
        |> Assignable.completionUnits
        |> Progress.unitMax


completion (Assignment assignment) =
    (Reg.latest assignment.reg).completion.get


relevanceStarts (Assignment assignment) =
    (Reg.latest assignment.reg).relevanceStarts.get


setRelevanceStarts fuzzyMoment (Assignment assignment) =
    (Reg.latest assignment.reg).relevanceStarts.set fuzzyMoment


relevanceEnds (Assignment assignment) =
    (Reg.latest assignment.reg).relevanceEnds.get


setRelevanceEnds fuzzyMoment (Assignment assignment) =
    (Reg.latest assignment.reg).relevanceEnds.set fuzzyMoment


externalDeadline (Assignment assignment) =
    (Reg.latest assignment.reg).externalDeadline.get


setExternalDeadline fuzzyMoment (Assignment assignment) =
    (Reg.latest assignment.reg).externalDeadline.set fuzzyMoment


minEffort assignment =
    assignable assignment
        |> Assignable.minEffort


estimatedEffort assignment =
    assignable assignment
        |> Assignable.estimatedEffort


maxEffort assignment =
    assignable assignment
        |> Assignable.maxEffort


getExtra key (Assignment assignment) =
    RepDict.get key (Reg.latest assignment.reg).extra


setExtra : String -> String -> Assignment -> Change
setExtra key value (Assignment assignment) =
    RepDict.insert key value (Reg.latest assignment.reg).extra


delete : Assignment -> Change
delete (Assignment assignment) =
    assignment.remove


{-| only use if you need to make bulk changes
-}
reg (Assignment assignment) =
    assignment.reg
