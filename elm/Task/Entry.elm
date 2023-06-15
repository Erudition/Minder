module Task.Entry exposing (..)

import Date exposing (Date)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Nonempty as Nonempty exposing (Nonempty)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (Codec, FlatCodec, NullCodec, SkelCodec, WrappedCodec)
import Replicated.Reducer.Register as Reg exposing (RW, Reg)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Result.Extra as Result
import SmartTime.Duration exposing (Duration)
import SmartTime.Human.Calendar.Month exposing (DayOfMonth)
import SmartTime.Human.Calendar.Week exposing (DayOfWeek)
import SmartTime.Moment exposing (Moment)
import Task.Action as Action exposing (Action, ActionSkel, ContainerOfActions, NestedOrAction(..), TrackableLayerProperties, trackableLayerPropertiesCodec)
import Task.Assignable as Assignable exposing (Assignable, AssignableDb, AssignableID, AssignableSkel)
import Task.Assignment exposing (Assignment, AssignmentSkel)
import Task.Series exposing (Series(..))



--  TOPMOST LAYERS: ENTRIES & CONTAINERS OF ASSIGNABLES -------------------------------


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type alias RootEntry =
    NestedOrAssignable


codec =
    nestedOrAssignableCodec


{-| An "Unconstrained" group of tasks has no recurrence rules, but one or more of its children may be containers that do (RecurringParents). UnconstrainedParents may contain infinitely nested UnconstrainedParents, until the level at which a RecurringParent appears.
-}
type alias ContainerOfAssignables =
    { layerProperties : Reg TrackableLayerProperties
    , children : RepList NestedOrAssignable
    }


containerOfAssignablesCodec : SkelCodec String ContainerOfAssignables
containerOfAssignablesCodec =
    Codec.record ContainerOfAssignables
        |> Codec.fieldReg ( 1, "layerProperties" ) .layerProperties trackableLayerPropertiesCodec
        |> Codec.fieldList ( 2, "children" ) .children nestedOrAssignableCodec
        |> Codec.finishRecord


type NestedOrAssignable
    = AssignableIsDeeper ContainerOfAssignables
    | AssignableIsHere (Reg AssignableSkel)


nestedOrAssignableCodec : Codec.NullCodec String NestedOrAssignable
nestedOrAssignableCodec =
    Codec.customType
        (\leaderIsDeeper leaderIsHere value ->
            case value of
                AssignableIsDeeper wrapperParent ->
                    leaderIsDeeper wrapperParent

                AssignableIsHere leaderParent ->
                    leaderIsHere leaderParent
        )
        |> Codec.variant1 ( 1, "AssignableIsDeeper" ) AssignableIsDeeper (Codec.lazy (\_ -> containerOfAssignablesCodec))
        |> Codec.variant1 ( 2, "AssignableIsHere" ) AssignableIsHere Assignable.codec
        |> Codec.finishCustomType



--  TRAVERSE & FLATTEN LAYERS --------------------------------------


{-| Take all the Entries and flatten them into a list of Actions
-}
flattenEntriesToActions : RepList RootEntry -> List Action
flattenEntriesToActions entries =
    List.concatMap traverseEntries (RepList.listValues entries)


traverseEntries : NestedOrAssignable -> List Action
traverseEntries entry =
    insideContainerOfAssignables [] entry


traverseContainerOfAssignables : List (Reg TrackableLayerProperties) -> ContainerOfAssignables -> List Action
traverseContainerOfAssignables accumulator parent =
    List.concatMap (insideContainerOfAssignables accumulator) (RepList.listValues parent.children)


insideContainerOfAssignables : List (Reg TrackableLayerProperties) -> NestedOrAssignable -> List Action
insideContainerOfAssignables accumulator child =
    case child of
        AssignableIsDeeper parent ->
            traverseContainerOfAssignables (parent.layerProperties :: accumulator) parent

        AssignableIsHere assignable ->
            traverseAssignable ((Reg.latest assignable).layerProperties :: accumulator) assignable


traverseAssignable : List (Reg TrackableLayerProperties) -> Reg AssignableSkel -> List Action
traverseAssignable accumulator assignable =
    List.concatMap (insideContainerOfActions accumulator) (RepList.listValues (Reg.latest assignable).children)


traverseContainerOfActions : List (Reg TrackableLayerProperties) -> ContainerOfActions -> List Action
traverseContainerOfActions accumulator class =
    -- TODO do we need to collect props here
    List.concatMap (insideContainerOfActions accumulator) (RepList.listValues class.children)


insideContainerOfActions : List (Reg TrackableLayerProperties) -> NestedOrAction -> List Action
insideContainerOfActions accumulator child =
    case child of
        ActionIsHere action ->
            -- we've reached the bottom
            List.singleton <| Action.makeFull accumulator action

        ActionIsDeeper followerParent ->
            traverseContainerOfActions (followerParent.layerProperties :: accumulator) followerParent



-- addActionToClass : ActionClassID -> ContainerOfActions -> Change
-- addActionToClass actionClassID classToModify =
--     let
--         taskClassChild =
--             ActionIsHere actionClassID
--     in
--     RepList.insert RepList.Last taskClassChild classToModify.children


initProjectWithAssignable : Reg AssignableSkel -> Change.Creator RootEntry
initProjectWithAssignable assignableSkelReg entryListParent =
    let
        -- initContainerOfActions : Change.Creator ContainerOfActions
        -- initContainerOfActions container =
        --     { layerProperties = Codec.new parentPropertiesCodec container
        --     , children = Codec.newWithChanges (Codec.repList nestedOrActionCodec) container taskClassChildrenChanger
        --     }
        changeChildrenOfAssignable : RepList NestedOrAction -> List Change
        changeChildrenOfAssignable newChildren =
            [ RepList.insert RepList.Last (ActionIsHere actionSkelReg) newChildren
            ]

        assignableChanger : Change.Changer (Reg AssignableSkel)
        assignableChanger newAssignable =
            changeChildrenOfAssignable (Reg.latest newAssignable).children

        actionSkelReg : Reg ActionSkel
        actionSkelReg =
            Codec.seededNewWithChanges Action.codec (Change.reuseContext "ActionIsHere" entryListParent) "Untitled Action" actionSkelChanger

        actionSkelChanger : Change.Changer (Reg ActionSkel)
        actionSkelChanger newActionSkel =
            []

        layerPropertiesChanger : Reg TrackableLayerProperties -> List Change
        layerPropertiesChanger newParentProperties =
            [ (Reg.latest newParentProperties).title.set <| Just "Entry title"
            ]
    in
    AssignableIsHere (Codec.seededNewWithChanges Assignable.codec (Change.reuseContext "AssignableIsHere" entryListParent) "Untitled Assignable" assignableChanger)



-- Todo list left off:
-- - how do I add a new Custom Type value to a RepList when the variant takes a nested type?
-- - how do I refer to the ID of an object that's being created in the same frame I want the reference made? update IDs to be pointers?
