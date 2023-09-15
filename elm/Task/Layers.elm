module Task.Layers exposing (..)

import Activity.Activity as Activity exposing (ActivityID)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Encode exposing (..)
import Maybe.Extra
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
import Task.Action as Action exposing (Action, ActionID)
import Task.Assignable as Assignable exposing (Assignable, AssignableID)
import Task.Assignment as Assignment exposing (Assignment, AssignmentID)
import Task.Progress as Progress exposing (Progress)
import Task.Project as Project exposing (Project, ProjectID)
import Task.ProjectSkel as ProjectSkel exposing (NestedOrAssignable(..), ProjectID, ProjectSkel)
import Task.Series exposing (Series)
import Task.SubAssignable as SubAssignable exposing (SubAssignable)
import Task.SubAssignableSkel as SubAssignable exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


type alias ProjectLayers =
    { projects : AnyDict String ProjectID Project
    , assignables : AnyDict String AssignableID Assignable
    , subAssignables : AnyDict String SubAssignableID SubAssignable
    , actions : AnyDict String ActionID Action
    }


{-| Take all the Entries and flatten them into a dict with Assignables
-}
buildLayerDatabase : RepDb (Reg ProjectSkel) -> ProjectLayers
buildLayerDatabase rootProjects =
    let
        start : ProjectLayers
        start =
            { projects = AnyDict.empty ID.toString
            , assignables = AnyDict.empty ID.toString
            , subAssignables = AnyDict.empty ID.toString
            , actions = AnyDict.empty ID.toString
            }

        traverseProject : Maybe Project -> Reg ProjectSkel -> ProjectLayers -> ProjectLayers
        traverseProject parentMaybe thisProjectSkelReg layersSoFar =
            let
                thisProjectSkel =
                    Reg.latest thisProjectSkelReg

                thisProject =
                    Project.fromSkel parentMaybe thisProjectSkelReg

                childrenToProcess : ProjectLayers
                childrenToProcess =
                    List.foldl (itemInsideProject thisProject) layersSoFar (RepList.list thisProjectSkel.children)
            in
            { childrenToProcess
                | projects =
                    AnyDict.insert (Project.id thisProject) thisProject layersSoFar.projects
                        |> AnyDict.union childrenToProcess.projects
            }

        itemInsideProject : Project -> RepList.Item NestedOrAssignable -> ProjectLayers -> ProjectLayers
        itemInsideProject parentProject child layersSoFar =
            case child.value of
                AssignableIsDeeper nestedProject ->
                    traverseProject (Just parentProject) nestedProject layersSoFar

                AssignableIsHere assignableSkelReg ->
                    let
                        assignableSkel =
                            Reg.latest assignableSkelReg

                        thisAssignable =
                            Assignable.fromSkel parentProject assignableSkelReg

                        childrenToProcess : ProjectLayers
                        childrenToProcess =
                            List.foldl (itemInsideAssignable thisAssignable) layersSoFar (RepList.listValues assignableSkel.children)
                    in
                    { childrenToProcess
                        | assignables =
                            AnyDict.insert (Assignable.id thisAssignable) thisAssignable childrenToProcess.assignables
                    }

        itemInsideAssignable : Assignable -> NestedSubAssignableOrSingleAction -> ProjectLayers -> ProjectLayers
        itemInsideAssignable parentAssignable child layersSoFar =
            case child of
                ActionIsDeeper subAssignableSkelReg ->
                    traverseAssignableLayer parentAssignable subAssignableSkelReg layersSoFar

                ActionIsHere actionSkelReg ->
                    -- we've reached the bottom
                    let
                        thisAction =
                            Action.fromSkelWithAssignableParent parentAssignable actionSkelReg
                    in
                    { layersSoFar
                        | actions =
                            AnyDict.insert (Action.id thisAction) thisAction layersSoFar.actions
                    }

        traverseAssignableLayer : Assignable -> Reg SubAssignableSkel -> ProjectLayers -> ProjectLayers
        traverseAssignableLayer parentAssignable thisSubAssignableSkelReg layersSoFar =
            let
                thisSubAssignableSkel =
                    Reg.latest thisSubAssignableSkelReg

                thisSubAssignable =
                    SubAssignable.fromSkelWithAssignableParent parentAssignable thisSubAssignableSkelReg

                childrenToProcess : ProjectLayers
                childrenToProcess =
                    List.foldl (itemInsideSubAssignable thisSubAssignable) layersSoFar (RepList.listValues thisSubAssignableSkel.children)
            in
            { childrenToProcess
                | subAssignables =
                    AnyDict.insert (SubAssignable.id thisSubAssignable) thisSubAssignable layersSoFar.subAssignables
                        |> AnyDict.union childrenToProcess.subAssignables
            }

        itemInsideSubAssignable : SubAssignable -> NestedSubAssignableOrSingleAction -> ProjectLayers -> ProjectLayers
        itemInsideSubAssignable parentSubAssignable child layersSoFar =
            case child of
                ActionIsDeeper subAssignableSkelReg ->
                    traverseSubAssignableLayer parentSubAssignable subAssignableSkelReg layersSoFar

                ActionIsHere actionSkelReg ->
                    -- we've reached the bottom
                    let
                        thisAction =
                            Action.fromSkelWithSubAssignableParent parentSubAssignable actionSkelReg
                    in
                    { layersSoFar
                        | actions =
                            AnyDict.insert (Action.id thisAction) thisAction layersSoFar.actions
                    }

        traverseSubAssignableLayer : SubAssignable -> Reg SubAssignableSkel -> ProjectLayers -> ProjectLayers
        traverseSubAssignableLayer parentSubAssignable thisSubAssignableSkelReg layersSoFar =
            let
                thisSubAssignableSkel =
                    Reg.latest thisSubAssignableSkelReg

                thisSubAssignable =
                    SubAssignable.fromSkelWithSubAssignableParent parentSubAssignable thisSubAssignableSkelReg

                childrenToProcess : ProjectLayers
                childrenToProcess =
                    List.foldl (itemInsideSubAssignable thisSubAssignable) layersSoFar (RepList.listValues thisSubAssignableSkel.children)
            in
            { childrenToProcess
                | subAssignables =
                    AnyDict.insert (SubAssignable.id thisSubAssignable) thisSubAssignable layersSoFar.subAssignables
                        |> AnyDict.union childrenToProcess.subAssignables
            }
    in
    List.foldl (traverseProject Nothing) start (RepDb.listValues rootProjects)


getAssignmentByID : ProjectLayers -> AssignmentID -> Maybe Assignment
getAssignmentByID layers assignmentID =
    AnyDict.get (Assignment.extractAssignableIDfromAssignmentID assignmentID) layers.assignables
        |> Maybe.andThen (Assignment.getByIDFromAssignable assignmentID)


getAllSavedAssignments : ProjectLayers -> List Assignment
getAllSavedAssignments layers =
    List.concatMap (Assignment.fromAssignable Assignment.AllSaved) (AnyDict.values layers.assignables)
