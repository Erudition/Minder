module Task.Project exposing (..)

import ExtraCodecs as Codec
import Helpers exposing (..)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (SkelCodec)
import Replicated.Reducer.Register as Reg exposing (Reg)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Task.Action as Action exposing (ActionSkel, NestedOrAction(..), TrackableLayerProperties, trackableLayerPropertiesCodec)
import Task.Assignable as Assignable exposing (AssignableSkel)
import Task.Series exposing (Series(..))



--  TOPMOST LAYERS: ENTRIES & CONTAINERS OF ASSIGNABLES -------------------------------


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type alias Project =
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


initProjectWithAssignable : Reg AssignableSkel -> Change.Creator Project
initProjectWithAssignable _ entryListParent =
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
        actionSkelChanger _ =
            []

        layerPropertiesChanger : Reg TrackableLayerProperties -> List Change
        layerPropertiesChanger newParentProperties =
            [ (Reg.latest newParentProperties).title.set <| Just "Entry title"
            ]
    in
    AssignableIsHere (Codec.seededNewWithChanges Assignable.codec (Change.reuseContext "AssignableIsHere" entryListParent) "Untitled Assignable" assignableChanger)
