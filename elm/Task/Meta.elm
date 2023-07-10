module Task.Meta exposing (Action, Assignable, Assignment, Query(..), assignableDefaultExternalDeadline, assignableDefaultRelevanceEnds, assignableDefaultRelevanceStarts, assignableEstimatedEffort, assignableGetExtra, assignableID, assignableImportance, assignableMaxEffort, assignableMinEffort, assignableReg, assignableSetEstimatedEffort, assignableSetExtra, assignableSetImportance, assignableSetMaxEffort, assignableSetMinEffort, assignableSetTitle, assignableTitle, assignableToActions, assignableToAssignments, assignablesToAssignments, assignedActionActivityID, assignedActionActivityIDString, assignedActionCompleted, assignedActionCompletion, assignedActionEstimatedEffort, assignedActionExternalDeadline, assignedActionGetExtra, assignedActionMaxEffort, assignedActionMinEffort, assignedActionPartiallyCompleted, assignedActionProgress, assignedActionProgressMax, assignedActionRelevanceEnds, assignedActionRelevanceStarts, assignedActionSetCompletion, assignedActionSetEstimatedEffort, assignedActionSetExtra, assignedActionSetProjectTitle, assignedActionTitle, assignmentActivityID, assignmentActivityIDString, assignmentCompleted, assignmentCompletion, assignmentDelete, assignmentEstimatedEffort, assignmentExternalDeadline, assignmentGetExtra, assignmentID, assignmentIDString, assignmentMaxEffort, assignmentMinEffort, assignmentPartiallyCompleted, assignmentProgress, assignmentProgressMaxInt, assignmentReg, assignmentRelevanceEnds, assignmentRelevanceStarts, assignmentSetCompletion, assignmentSetExternalDeadline, assignmentSetExtra, assignmentSetRelevanceEnds, assignmentSetRelevanceStarts, assignmentTitle, entriesToActions, entriesToAssignables, isAssignedActionRelevantNow, listAllActions, prioritizeAssignments, setAssignableTitle, setAssignmentCompletion)

import Activity.Activity as Activity exposing (ActivityID)
import Helpers exposing (..)
import ID
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Replicated.Change as Change exposing (Change)
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
import Task.Action as Action exposing (ActionID, ActionSkel, ContainerOfActions, NestedOrAction(..), TrackableLayerProperties)
import Task.Assignable as Assignable exposing (AssignableID, AssignableSkel)
import Task.AssignedAction exposing (AssignedActionSkel)
import Task.Assignment exposing (AssignmentDb, AssignmentID, AssignmentSkel)
import Task.Progress as Progress exposing (Progress)
import Task.Project as Project exposing (ContainerOfAssignables, NestedOrAssignable(..), Project)
import Task.Series exposing (Series(..))
import ZoneHistory exposing (ZoneHistory)


type Query
    = AllSaved
    | WithinPeriod Period ZoneHistory


{-| Take all the Entries and flatten them into a list of Assignables
-}
entriesToAssignables : RepList Project -> List Assignable
entriesToAssignables entries =
    let
        traverseEntries : NestedOrAssignable -> List Assignable
        traverseEntries entry =
            insideContainerOfAssignables [] entry

        insideContainerOfAssignables : List (Reg TrackableLayerProperties) -> NestedOrAssignable -> List Assignable
        insideContainerOfAssignables accumulator child =
            case child of
                AssignableIsDeeper parent ->
                    traverseContainerOfAssignables (parent.layerProperties :: accumulator) parent

                AssignableIsHere assignable ->
                    List.singleton <| makeMetaAssignable accumulator assignable

        traverseContainerOfAssignables : List (Reg TrackableLayerProperties) -> ContainerOfAssignables -> List Assignable
        traverseContainerOfAssignables accumulator parent =
            List.concatMap (insideContainerOfAssignables accumulator) (RepList.listValues parent.children)
    in
    List.concatMap traverseEntries (RepList.listValues entries)


{-| Take all the Entries and flatten them into a list of Actions
-}
entriesToActions : RepList Project -> List Action
entriesToActions entries =
    let
        traverseEntries : NestedOrAssignable -> List Action
        traverseEntries entry =
            insideContainerOfAssignables [] entry

        insideContainerOfAssignables : List (Reg TrackableLayerProperties) -> NestedOrAssignable -> List Action
        insideContainerOfAssignables accumulator child =
            case child of
                AssignableIsDeeper parent ->
                    traverseContainerOfAssignables (parent.layerProperties :: accumulator) parent

                AssignableIsHere assignable ->
                    assignableToActions ((Reg.latest assignable).layerProperties :: accumulator) assignable

        traverseContainerOfAssignables : List (Reg TrackableLayerProperties) -> ContainerOfAssignables -> List Action
        traverseContainerOfAssignables accumulator parent =
            List.concatMap (insideContainerOfAssignables accumulator) (RepList.listValues parent.children)
    in
    List.concatMap traverseEntries (RepList.listValues entries)


assignableToActions : List (Reg TrackableLayerProperties) -> Reg AssignableSkel -> List Action
assignableToActions acc assignable =
    let
        traverseContainerOfActions : List (Reg TrackableLayerProperties) -> ContainerOfActions -> List Action
        traverseContainerOfActions accumulator class =
            -- TODO do we need to collect props here
            List.concatMap (insideContainerOfActions accumulator) (RepList.listValues class.children)

        insideContainerOfActions : List (Reg TrackableLayerProperties) -> NestedOrAction -> List Action
        insideContainerOfActions accumulator child =
            case child of
                ActionIsHere action ->
                    -- we've reached the bottom
                    List.singleton <| makeMetaAction accumulator action

                ActionIsDeeper followerParent ->
                    traverseContainerOfActions (followerParent.layerProperties :: accumulator) followerParent
    in
    List.concatMap (insideContainerOfActions acc) (RepList.listValues (Reg.latest assignable).children)



-- addActionToClass : ActionClassID -> ContainerOfActions -> Change
-- addActionToClass actionClassID classToModify =
--     let
--         taskClassChild =
--             ActionIsHere actionClassID
--     in
--     RepList.insert RepList.Last taskClassChild classToModify.children
-- FULL Task Classes (augmented with entry data) --------------------------


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type Assignable
    = Assignable
        { parents : List (Reg TrackableLayerProperties)
        , assignableReg : Reg AssignableSkel
        , assignableID : AssignableID
        }


makeMetaAssignable : List (Reg TrackableLayerProperties) -> Reg AssignableSkel -> Assignable
makeMetaAssignable parentPropsRegList assignableSkelReg =
    Assignable
        { parents = parentPropsRegList
        , assignableReg = assignableSkelReg -- Reg because we may need earlier versions
        , assignableID = ID.fromPointer (Reg.getPointer assignableSkelReg)
        }



-- METAACTIONS --------------------------------


type Action
    = Action
        { parents : List (Reg TrackableLayerProperties)
        , actionReg : Reg ActionSkel
        , actionID : ActionID
        }


makeMetaAction : List (Reg TrackableLayerProperties) -> Reg ActionSkel -> Action
makeMetaAction parentPropsRegList actionSkelReg =
    Action
        { parents = parentPropsRegList
        , actionReg = actionSkelReg
        , actionID = ID.fromPointer (Reg.getPointer actionSkelReg)
        }



-- MetaAssignments ----------------------------------------


{-| Assignment with metadata
-}
type Assignment
    = Assignment
        { parents : List (Reg TrackableLayerProperties)
        , assignableReg : Reg AssignableSkel
        , assignmentReg : Reg AssignmentSkel
        , index : Int
        , assignmentID : AssignmentID
        , assignableID : AssignableID
        , remove : Change
        }


{-| Get all relevant assignments of everything.

Take the skeleton data and get all relevant(within given time period) assignments of every assignable, and return them as Full Instances.

TODO organize with IDs somehow

-}
assignablesToAssignments : List Assignable -> Query -> List Assignment
assignablesToAssignments fullClasses query =
    List.concatMap (assignableToAssignments query) fullClasses


{-| Take a assignable and return all of the assignments relevant within the given period - saved or generated.

Combine the saved assignments with generated ones, to get the full picture within a period.

TODO: best data structure? Is Dict unnecessary here? Or should the key involve the assignableID for perf?

-}
assignableToAssignments : Query -> Assignable -> List Assignment
assignableToAssignments relevance ((Assignable metaAssignable) as wrappedAssignable) =
    let
        manualAssignments =
            RepDb.members (Reg.latest metaAssignable.assignableReg).manualAssignments

        savedInstancesFull =
            List.indexedMap (makeMetaAssignment wrappedAssignable) manualAssignments

        -- Filter out assignments outside the window
        relevantSavedInstances =
            List.filter isRelevant savedInstancesFull

        -- TODO "If savedInstance is within period, keep"
        isRelevant _ =
            True

        -- TODO Fill in based on recurrence series. Int ID = order in series.
        _ =
            fillSeries relevance wrappedAssignable
    in
    relevantSavedInstances


makeMetaAssignment : Assignable -> Int -> RepDb.Member (Reg AssignmentSkel) -> Assignment
makeMetaAssignment (Assignable metaAssignable) indexFromZero assignmentSkelMember =
    Assignment
        { parents = metaAssignable.parents
        , assignableReg = metaAssignable.assignableReg
        , assignmentReg = assignmentSkelMember.value
        , index = indexFromZero + 1
        , assignmentID = assignmentSkelMember.id
        , assignableID = metaAssignable.assignableID
        , remove = assignmentSkelMember.remove
        }


{-| Get all relevant actions of all assignments.
-}
listAllActions : List Assignable -> Query -> List AssignedAction
listAllActions assignables timeData =
    let
        allAssignments =
            assignablesToAssignments assignables timeData
    in
    List.concatMap (actionsOfAssignment timeData) allAssignments


{-| -}
actionsOfAssignment : Query -> Assignment -> List AssignedAction
actionsOfAssignment query (Assignment metaAssignment) =
    let
        actions =
            assignableToActions metaAssignment.parents metaAssignment.assignableReg

        assignedActionsWithClassID =
            (Reg.latest metaAssignment.assignmentReg).children

        fullAssignmentFromAction : Action -> AssignedAction
        fullAssignmentFromAction (Action metaAction) =
            let
                assignedActionReg =
                    RepStore.get metaAction.actionID assignedActionsWithClassID

                _ =
                    Reg.latest assignedActionReg
            in
            AssignedAction
                { parents = metaAction.parents
                , actionReg = metaAction.actionReg
                , actionID = metaAction.actionID
                , assignableReg = metaAssignment.assignableReg
                , assignmentReg = metaAssignment.assignmentReg
                , assignmentID = metaAssignment.assignmentID
                , assignableID = metaAssignment.assignableID
                , assignedActionReg = assignedActionReg
                }

        fullAssignmentsFromActions : List AssignedAction
        fullAssignmentsFromActions =
            List.map fullAssignmentFromAction actions

        -- Filter out assignments outside the window
        relevantSavedActionAssignments =
            List.filter isRelevant fullAssignmentsFromActions

        -- TODO "If savedInstance is within period, keep"
        isRelevant _ =
            True
    in
    relevantSavedActionAssignments


fillSeries : Query -> Assignable -> List Assignment
fillSeries relevance _ =
    -- TODO
    []



-- Meta Assigned Actions (augmented with Project and Assignment) ----------------------------------------


{-| Assignment Action with metadata
-}
type AssignedAction
    = AssignedAction
        { parents : List (Reg TrackableLayerProperties)
        , actionReg : Reg ActionSkel
        , assignedActionReg : Reg AssignedActionSkel
        , assignableReg : Reg AssignableSkel
        , assignmentReg : Reg AssignmentSkel
        , assignmentID : AssignmentID
        , assignableID : AssignableID
        , actionID : ActionID
        }



-- Task helper functions -------------------------------------------------------


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle


isAssignmentRelevantNow : Moment -> Zone -> Assignment -> Bool
isAssignmentRelevantNow now zone (Assignment metaAssignment) =
    let
        fuzzyNow =
            HumanMoment.Global now

        start =
            Maybe.withDefault fuzzyNow (Reg.latest metaAssignment.assignmentReg).relevanceStarts.get

        end =
            Maybe.withDefault fuzzyNow (Reg.latest metaAssignment.assignmentReg).relevanceEnds.get

        notBeforeStart =
            HumanMoment.compareFuzzy zone Clock.startOfDay fuzzyNow start /= Earlier

        notAfterEnd =
            HumanMoment.compareFuzzy zone Clock.endOfDay fuzzyNow end /= Later
    in
    notBeforeStart && notAfterEnd


assignmentCompleted : Assignment -> Bool
assignmentCompleted (Assignment metaAssignment) =
    Progress.isMax ( (Reg.latest metaAssignment.assignmentReg).completion.get, (Reg.latest metaAssignment.assignableReg).completionUnits.get )


assignmentPartiallyCompleted : Assignment -> Bool
assignmentPartiallyCompleted (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).completion.get > 0


type alias WithSoonness t =
    { t | soonness : Duration }


prioritizeAssignments : Moment -> HumanMoment.Zone -> List Assignment -> List Assignment
prioritizeAssignments _ zone taskList =
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
compareSoonness zone (Assignment metaA) (Assignment metaB) =
    case ( (Reg.latest metaA.assignmentReg).externalDeadline.get, (Reg.latest metaB.assignmentReg).externalDeadline.get ) of
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
compareNewness (Assignment metaA) (Assignment metaB) =
    let
        taskToIDString task =
            task.assignmentReg
                |> Reg.getPointer
                |> Change.getPointerObjectID
                |> Maybe.map OpID.toString
                |> Maybe.withDefault ""
    in
    -- B before A since it's about soonness
    Basics.compare (taskToIDString metaB) (taskToIDString metaA)



-- GETTERS AND SETTERS - be sure to put the object last -----------------


assignmentID : Assignment -> AssignmentID
assignmentID (Assignment metaAssignment) =
    metaAssignment.assignmentID


assignableID : Assignable -> AssignableID
assignableID (Assignable metaAssignable) =
    metaAssignable.assignableID


assignmentIDString : Assignment -> String
assignmentIDString (Assignment metaAssignment) =
    ID.toString metaAssignment.assignmentID


assignmentTitle (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignableReg).title.get


assignableTitle (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).title.get


assignableSetTitle newTitle (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).title.set newTitle


assignableImportance (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).importance.get


assignableSetImportance newImportance (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).importance.set newImportance


assignmentActivityID (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignableReg).activity.get


assignmentActivityIDString (Assignment metaAssignment) =
    Maybe.map Activity.idToString (Reg.latest metaAssignment.assignableReg).activity.get


assignmentProgress (Assignment metaAssignment) =
    ( (Reg.latest metaAssignment.assignmentReg).completion.get, (Reg.latest metaAssignment.assignableReg).completionUnits.get )


setAssignmentCompletion newPortion (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).completion.set newPortion


setAssignableTitle newTitle (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).title.set newTitle


assignmentProgressMaxInt (Assignment metaAssignment) =
    Progress.unitMax (Reg.latest metaAssignment.assignableReg).completionUnits.get


assignmentCompletion (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).completion.get


assignmentSetCompletion portion (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).completion.set portion


assignmentRelevanceStarts (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).relevanceStarts.get


assignableDefaultRelevanceStarts (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).defaultRelevanceStarts


assignmentSetRelevanceStarts fuzzyMoment (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).relevanceStarts.set fuzzyMoment


assignmentRelevanceEnds (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).relevanceEnds.get


assignableDefaultRelevanceEnds (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).defaultRelevanceEnds


assignmentSetRelevanceEnds fuzzyMoment (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).relevanceEnds.set fuzzyMoment


assignmentExternalDeadline (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).externalDeadline.get


assignableDefaultExternalDeadline (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).defaultExternalDeadline


assignmentSetExternalDeadline fuzzyMoment (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignmentReg).externalDeadline.set fuzzyMoment


assignmentMinEffort (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignableReg).minEffort.get


assignableMinEffort (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).minEffort.get


assignableSetMinEffort newDur (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).minEffort.set newDur


assignmentEstimatedEffort (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignableReg).predictedEffort.get


assignableSetEstimatedEffort newDur (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).predictedEffort.set newDur


assignableEstimatedEffort (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).predictedEffort.get


assignmentMaxEffort (Assignment metaAssignment) =
    (Reg.latest metaAssignment.assignableReg).maxEffort.get


assignableMaxEffort (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).maxEffort.get


assignableSetMaxEffort newDur (Assignable metaAssignable) =
    (Reg.latest metaAssignable.assignableReg).maxEffort.set newDur



-- assignableSetProgressMax newMax (Assignable metaAssignable) =
--     (Reg.latest metaAssignable.assignableReg).progressMax.set newMax


assignmentGetExtra key (Assignment metaAssignment) =
    RepDict.get key (Reg.latest metaAssignment.assignmentReg).extra


assignableGetExtra key (Assignable metaAssignable) =
    RepDict.get key (Reg.latest metaAssignable.assignableReg).extra


assignableSetExtra key value (Assignable metaAssignable) =
    RepDict.insert key value (Reg.latest metaAssignable.assignableReg).extra


assignmentSetExtra : String -> String -> Assignment -> Change
assignmentSetExtra key value (Assignment metaAssignment) =
    RepDict.insert key value (Reg.latest metaAssignment.assignmentReg).extra


assignmentDelete : Assignment -> Change
assignmentDelete (Assignment metaAssignment) =
    metaAssignment.remove


isAssignedActionRelevantNow : Moment -> Zone -> AssignedAction -> Bool
isAssignedActionRelevantNow now zone (AssignedAction metaAssignedAction) =
    let
        fuzzyNow =
            HumanMoment.Global now

        start =
            Maybe.withDefault fuzzyNow (Reg.latest metaAssignedAction.assignedActionReg).relevanceStarts.get

        end =
            Maybe.withDefault fuzzyNow (Reg.latest metaAssignedAction.assignedActionReg).relevanceEnds.get

        notBeforeStart =
            HumanMoment.compareFuzzy zone Clock.startOfDay fuzzyNow start /= Earlier

        notAfterEnd =
            HumanMoment.compareFuzzy zone Clock.endOfDay fuzzyNow end /= Later
    in
    notBeforeStart && notAfterEnd


assignedActionCompleted : AssignedAction -> Bool
assignedActionCompleted (AssignedAction metaAssignedAction) =
    Progress.isMax ( (Reg.latest metaAssignedAction.assignedActionReg).completion.get, (Reg.latest metaAssignedAction.actionReg).completionUnits.get )


assignedActionPartiallyCompleted : AssignedAction -> Bool
assignedActionPartiallyCompleted (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.assignedActionReg).completion.get > 0


assignedActionTitle : AssignedAction -> String
assignedActionTitle (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).title.get


assignedActionActivityID : AssignedAction -> Maybe ActivityID
assignedActionActivityID (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).activity.get


assignedActionActivityIDString : AssignedAction -> Maybe String
assignedActionActivityIDString (AssignedAction metaAssignedAction) =
    Maybe.map Activity.idToString (Reg.latest metaAssignedAction.actionReg).activity.get


assignedActionProgress : AssignedAction -> Progress
assignedActionProgress (AssignedAction metaAssignedAction) =
    ( (Reg.latest metaAssignedAction.assignedActionReg).completion.get, (Reg.latest metaAssignedAction.actionReg).completionUnits.get )


assignedActionSetCompletion : Progress.Portion -> AssignedAction -> Change
assignedActionSetCompletion newPortion (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.assignedActionReg).completion.set newPortion


assignedActionSetProjectTitle : String -> AssignedAction -> Change
assignedActionSetProjectTitle newTitle (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).title.set newTitle


assignedActionProgressMax : AssignedAction -> Progress.Portion
assignedActionProgressMax (AssignedAction metaAssignedAction) =
    Progress.unitMax (Reg.latest metaAssignedAction.actionReg).completionUnits.get


assignedActionCompletion : AssignedAction -> Int
assignedActionCompletion (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.assignedActionReg).completion.get


assignedActionRelevanceStarts : AssignedAction -> Maybe FuzzyMoment
assignedActionRelevanceStarts (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.assignedActionReg).relevanceStarts.get


assignedActionRelevanceEnds : AssignedAction -> Maybe FuzzyMoment
assignedActionRelevanceEnds (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.assignedActionReg).relevanceEnds.get


assignedActionExternalDeadline : AssignedAction -> Maybe FuzzyMoment
assignedActionExternalDeadline (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.assignedActionReg).externalDeadline.get


assignedActionMinEffort : AssignedAction -> Duration
assignedActionMinEffort (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).minEffort.get


assignedActionEstimatedEffort : AssignedAction -> Duration
assignedActionEstimatedEffort (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).predictedEffort.get


assignedActionSetEstimatedEffort : Duration -> AssignedAction -> Change
assignedActionSetEstimatedEffort newDur (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).predictedEffort.set newDur


assignedActionMaxEffort : AssignedAction -> Duration
assignedActionMaxEffort (AssignedAction metaAssignedAction) =
    (Reg.latest metaAssignedAction.actionReg).maxEffort.get


assignedActionGetExtra : String -> AssignedAction -> Maybe String
assignedActionGetExtra key (AssignedAction metaAssignedAction) =
    RepDict.get key (Reg.latest metaAssignedAction.assignedActionReg).extra


assignedActionSetExtra : String -> String -> AssignedAction -> Change
assignedActionSetExtra key value (AssignedAction metaAssignedAction) =
    RepDict.insert key value (Reg.latest metaAssignedAction.assignedActionReg).extra


{-| only use if you need to make bulk changes
-}
assignmentReg (Assignment metaAssignment) =
    metaAssignment.assignmentReg


{-| only use if you need to make bulk changes
-}
assignableReg (Assignable metaAssignable) =
    metaAssignable.assignableReg
