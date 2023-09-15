module Task.Assignment exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Log
import Maybe.Extra
import Replicated.Change as Change exposing (Change, Changer, Creator)
import Replicated.Codec as Codec exposing (NullCodec)
import Replicated.Op.OpID as OpID
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
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
import Task.AssignmentSkel as AssignmentSkel exposing (AssignmentSkel)
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
        , id : AssignmentID
        , remove : Change
        }


type alias SubAssignmentID =
    ( AssignmentID, SubAssignableID )


type Query
    = AllSaved
    | WithinPeriod Period ZoneHistory


{-| For UI purposes. Not a true Pointer - can point to an instance of a series or a manual assignment, and includes the AssignableID, as we always need to know the Assignable from which an Assignment comes - though this is not serialized in the AssignmentSkel as it's already stored within the Assignable. This allows faster lookups of assignments and allows assignments to be lazy loaded if unavailable.
-}
type AssignmentID
    = ManualAssignmentID AssignableID (ID (Reg AssignmentSkel))
    | SeriesAssignmentID AssignableID SeriesMemberID


{-| Other objects may want to store a pointer to an assignment, so they need the full info to be serialized.
TODO efficient way to look up assignment without the redundant information being stored?
-}
idCodec : NullCodec String AssignmentID
idCodec =
    let
        tagSeriesAssignmentID givenAssignableID seriesID seriesIndex =
            -- for serialization, seriesMemberID doesn't need to be its own tuple object
            SeriesAssignmentID givenAssignableID ( seriesID, seriesIndex )
    in
    Codec.customType
        (\manualAssignmentID seriesAssignmentID value ->
            case value of
                ManualAssignmentID givenAssignableID regID ->
                    manualAssignmentID givenAssignableID regID

                SeriesAssignmentID givenAssignableID ( seriesID, seriesIndex ) ->
                    seriesAssignmentID givenAssignableID seriesID seriesIndex
        )
        |> Codec.variant2 ( 1, "ManualAssignmentID" ) ManualAssignmentID Codec.id Codec.id
        |> Codec.variant3 ( 2, "SeriesAssignmentID" ) tagSeriesAssignmentID Codec.id Codec.id Codec.int
        |> Codec.finishCustomType


extractAssignableIDfromAssignmentID : AssignmentID -> AssignableID
extractAssignableIDfromAssignmentID givenAssignmentID =
    case givenAssignmentID of
        ManualAssignmentID givenAssignableID _ ->
            givenAssignableID

        SeriesAssignmentID givenAssignableID _ ->
            givenAssignableID


{-| Take a assignable and return all of the assignments relevant within the given period - saved or generated.

Combine the saved assignments with generated ones, to get the full picture within a period.

TODO: best data structure? Is Dict unnecessary here? Or should the key involve the assignableID for perf?

-}
fromAssignable : Query -> Assignable -> List Assignment
fromAssignable query parent =
    let
        manualAssignments =
            RepDb.members <| Assignable.manualAssignments parent

        savedAssignmentsFull =
            List.map (fromSkelManual parent) manualAssignments

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


fromSkelManual : Assignable -> RepDb.Member (Reg AssignmentSkel) -> Assignment
fromSkelManual metaAssignable assignmentSkelMember =
    Assignment
        { assignable = metaAssignable
        , reg = assignmentSkelMember.value
        , id = ManualAssignmentID (Assignable.id metaAssignable) assignmentSkelMember.id
        , remove = assignmentSkelMember.remove
        }


fromPlaceholderSkelManual : Assignable -> Reg AssignmentSkel -> Assignment
fromPlaceholderSkelManual metaAssignable assignmentSkel =
    Assignment
        { assignable = metaAssignable
        , reg = assignmentSkel
        , id = ManualAssignmentID (Assignable.id metaAssignable) (ID.fromPointer (Reg.getPointer assignmentSkel))
        , remove = Debug.todo "tried to remove an assignment while it was still a placeholder"
        }


fromSkelSeries : Assignable -> SeriesMemberID -> RepDb.Member (Reg AssignmentSkel) -> Assignment
fromSkelSeries metaAssignable seriesMemberID assignmentSkelMember =
    Assignment
        { assignable = metaAssignable
        , reg = assignmentSkelMember.value
        , id = SeriesAssignmentID (Assignable.id metaAssignable) seriesMemberID
        , remove = assignmentSkelMember.remove
        }


getByIDFromAssignable : AssignmentID -> Assignable -> Maybe Assignment
getByIDFromAssignable idToFind containingAssignable =
    case idToFind of
        ManualAssignmentID _ assignmentSkelID ->
            Assignable.manualAssignments containingAssignable
                |> RepDb.getMember assignmentSkelID
                |> Maybe.map (fromSkelManual containingAssignable)

        SeriesAssignmentID _ seriesMemberID ->
            Log.crashInDev "Assignable.getSeriesMember seriesMemberID" Nothing



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


create : Changer Assignment -> Assignable -> Change
create assignmentChanger parentAssignable =
    let
        assignmentSkelChanger : Changer (Reg AssignmentSkel)
        assignmentSkelChanger =
            Change.mapChanger (fromPlaceholderSkelManual parentAssignable) assignmentChanger

        assignmentSkelCreator : Creator (Reg AssignmentSkel)
        assignmentSkelCreator =
            AssignmentSkel.newWithChanges assignmentSkelChanger
    in
    RepDb.addNew assignmentSkelCreator (Assignable.manualAssignments parentAssignable)


id : Assignment -> AssignmentID
id (Assignment assignment) =
    assignment.id


{-| Since AssignmentSkels have globally unique IDs, no need to keep the assignable data when stringifying for comparison purposes.
-}
idString : Assignment -> String
idString (Assignment assignment) =
    case assignment.id of
        ManualAssignmentID _ regID ->
            ID.toString regID

        SeriesAssignmentID _ seriesMemberID ->
            Task.Series.memberIDToString seriesMemberID


assignable (Assignment assignment) =
    assignment.assignable


assignableID (Assignment assignment) =
    Assignable.id assignment.assignable


assignableIDString (Assignment assignment) =
    Assignable.idString assignment.assignable


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


startBy (Assignment assignment) =
    (Reg.latest assignment.reg).startBy.get


setStartBy fuzzyMomentMaybe (Assignment assignment) =
    (Reg.latest assignment.reg).startBy.set fuzzyMomentMaybe


relevanceEnds (Assignment assignment) =
    (Reg.latest assignment.reg).relevanceEnds.get


setRelevanceEnds fuzzyMoment (Assignment assignment) =
    (Reg.latest assignment.reg).relevanceEnds.set fuzzyMoment


finishBy (Assignment assignment) =
    (Reg.latest assignment.reg).finishBy.get


setFinishBy fuzzyMomentMaybe (Assignment assignment) =
    (Reg.latest assignment.reg).finishBy.set fuzzyMomentMaybe


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


insertExtras : List ( String, String ) -> Assignment -> Change
insertExtras keyValueList (Assignment assignment) =
    RepDict.bulkInsert keyValueList (Reg.latest assignment.reg).extra


extras : Assignment -> RepDict String String
extras (Assignment assignment) =
    (Reg.latest assignment.reg).extra


delete : Assignment -> Change
delete (Assignment assignment) =
    assignment.remove


created : Assignment -> Maybe Moment
created (Assignment { reg }) =
    Reg.createdAt reg
