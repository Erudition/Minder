module Task.Project exposing (..)

import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Replicated.Change as Change exposing (Change)
import Replicated.Codec as Codec exposing (SkelCodec, WrappedCodec)
import Replicated.Reducer.Register as Reg exposing (RWM, Reg)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Task.Action as Action exposing (ActionSkel, NestedOrAction(..))
import Task.Assignable as Assignable exposing (AssignableSkel)
import Task.Series exposing (Series(..))



--  TOPMOST LAYERS: ENTRIES & CONTAINERS OF ASSIGNABLES -------------------------------


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type alias ProjectSkel =
    { title : RWM String
    , children : RepList NestedOrAssignable
    }


codec =
    projectCodec


type alias ProjectID =
    ID (Reg ProjectSkel)


projectCodec : WrappedCodec String (Reg ProjectSkel)
projectCodec =
    Codec.record ProjectSkel
        |> Codec.fieldRWM ( 3, "title" ) .title Codec.string
        |> Codec.fieldList ( 2, "children" ) .children nestedOrAssignableCodec
        |> Codec.finishRegister


type NestedOrAssignable
    = AssignableIsDeeper (Reg ProjectSkel)
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
        |> Codec.variant1 ( 1, "AssignableIsDeeper" ) AssignableIsDeeper (Codec.lazy (\_ -> projectCodec))
        |> Codec.variant1 ( 2, "AssignableIsHere" ) AssignableIsHere Assignable.codec
        |> Codec.finishCustomType



--  TRAVERSE & FLATTEN LAYERS --------------------------------------
-- initProjectWithAssignable : Reg AssignableSkel -> Change.Creator (Reg ProjectSkel)
-- initProjectWithAssignable givenAssignableReg parentContext =
--     let
--         changeChildrenOfAssignable : RepList NestedOrAction -> List Change
--         changeChildrenOfAssignable newChildren =
--             [ RepList.insert RepList.Last (ActionIsHere actionSkelReg) newChildren
--             ]
--         assignableChanger : Change.Changer (Reg AssignableSkel)
--         assignableChanger newAssignable =
--             changeChildrenOfAssignable (Reg.latest newAssignable).children
--         actionSkelReg : Reg ActionSkel
--         actionSkelReg =
--             Codec.seededNewWithChanges Action.codec (Change.reuseContext "ActionIsHere" parentContext) "Untitled Action" actionSkelChanger
--         actionSkelChanger : Change.Changer (Reg ActionSkel)
--         actionSkelChanger _ =
--             []
--         projectChanger : Reg ProjectSkel -> List Change
--         projectChanger projectSkel =
--             [ RepList.insert RepList.Last (AssignableIsHere givenAssignableReg) (Reg.latest projectSkel).children
--             ]
--         justNewAssignable =
--             AssignableIsHere (Codec.seededNewWithChanges Assignable.codec (Change.reuseContext "AssignableIsHere" parentContext) "Untitled Assignable" assignableChanger)
--     in
--     Codec.newWithChanges codec parentContext projectChanger
