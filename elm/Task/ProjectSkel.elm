module Task.ProjectSkel exposing (..)

import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Replicated.Change as Change exposing (Change, Creator)
import Replicated.Codec as Codec exposing (SkelCodec, WrappedCodec)
import Replicated.Reducer.Register as Reg exposing (RWMaybe, Reg)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Task.ActionSkel exposing (ActionSkel)
import Task.AssignableSkel as AssignableSkel exposing (AssignableSkel)
import Task.Series exposing (Series)
import Task.SubAssignableSkel as SubAssignableSkel exposing (NestedSubAssignableOrSingleAction)



--  TOPMOST LAYERS: ENTRIES & CONTAINERS OF ASSIGNABLES -------------------------------


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type alias ProjectSkel =
    { title : RWMaybe String
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
        |> Codec.variant1 ( 2, "AssignableIsHere" ) AssignableIsHere AssignableSkel.codec
        |> Codec.finishCustomType



-- create : List (Change.Creator (Reg AssignableSkel)) -> Change.Creator (Reg ProjectSkel)
-- create assignableCreatorList parentContext =
--     let
--         changeChildrenOfAssignable : RepList NestedSubAssignableOrSingleAction -> List Change
--         changeChildrenOfAssignable newChildren =
--             [ RepList.insert RepList.Last (SubAssignableSkel.ActionIsHere actionSkelReg) newChildren
--             ]
--         assignableChanger : Change.Changer (Reg AssignableSkel)
--         assignableChanger newAssignable =
--             changeChildrenOfAssignable (Reg.latest newAssignable).children
--         actionSkelReg : Reg ActionSkel
--         actionSkelReg =
--             Codec.seededNewWithChanges Task.ActionSkel.codec (Change.reuseContext "ActionIsHere" parentContext) "Untitled Action" actionSkelChanger
--         actionSkelChanger : Change.Changer (Reg ActionSkel)
--         actionSkelChanger _ =
--             []
--         justNewAssignable =
--             AssignableIsHere (Codec.seededNewWithChanges AssignableSkel.codec (Change.reuseContext "AssignableIsHere" parentContext) "Untitled Assignable" assignableChanger)
--         projectChanger : Reg ProjectSkel -> List Change
--         projectChanger projectSkel =
--             let
--                 newAssignableReg newAssignableRegCreator c =
--                     newAssignableRegCreator (Change.reuseContext "assignableWithinProject" c)
--                         |> AssignableIsHere
--                 assignablesAsChildren =
--                     List.map newAssignableReg assignableCreatorList
--             in
--             [ RepList.insertNew RepList.Last assignablesAsChildren (Reg.latest projectSkel).children
--             ]
--     in
--     Codec.newWithChanges codec parentContext projectChanger


create : Change.Changer (Reg ProjectSkel) -> Change.Creator (Reg ProjectSkel)
create projectSkelChanges parentContext =
    Codec.newWithChanges codec parentContext projectSkelChanges
