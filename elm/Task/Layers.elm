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
    , subassignables : AnyDict String SubAssignableID SubAssignable
    , actions : AnyDict String ActionID Action
    }


{-| Take all the Entries and flatten them into a dict with Assignables
-}
projectToAssignableLayers : RepDb (Reg ProjectSkel) -> ProjectLayers
projectToAssignableLayers rootProjects =
    let
        start : ProjectLayers
        start =
            { projects = AnyDict.empty ID.toString
            , assignables = AnyDict.empty ID.toString
            , subassignables = AnyDict.empty ID.toString
            , actions = AnyDict.empty ID.toString
            }

        traverseProject : Maybe Project -> Reg ProjectSkel -> ProjectLayers -> ProjectLayers
        traverseProject parentMaybe thisProjectSkelReg layersSoFar =
            let
                thisProjectSkel =
                    Reg.latest thisProjectSkelReg

                thisProject =
                    Project.fromSkel thisProjectSkel

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
        itemInsideProject parent child layersSoFar =
            case child.value of
                AssignableIsDeeper nestedProject ->
                    traverseProject (Just parent) nestedProject layersSoFar

                AssignableIsHere assignableSkelReg ->
                    let
                        assignableSkel =
                            Reg.latest assignableSkelReg

                        thisAssignable =
                            Assignable.fromSkel parent assignableSkelReg

                        childrenToProcess : ProjectLayers
                        childrenToProcess =
                            List.foldl (itemInsideAssignable thisAssignable) layersSoFar (RepList.listValues assignableSkel.children)
                    in
                    { childrenToProcess
                        | assignables =
                            AnyDict.insert (Assignable.id thisAssignable) thisAssignable childrenToProcess.assignables
                    }

        itemInsideAssignable : Assignable -> NestedSubAssignableOrSingleAction -> ProjectLayers -> ProjectLayers
        itemInsideAssignable parent child layersSoFar =
            case child of
                ActionIsDeeper subAssignableSkelReg ->
                    traverseAssignableLayer subAssignableSkelReg layersSoFar

                ActionIsHere actionSkelReg ->
                    -- we've reached the bottom
                    let
                        actionSkel =
                            Reg.latest actionSkelReg

                        thisAction =
                            Action.fromSkel parent actionSkel
                    in
                    { layersSoFar
                        | actions =
                            AnyDict.insert (Action.id thisAction) thisAction layersSoFar.actions
                    }

        traverseAssignableLayer : Reg SubAssignableSkel -> ProjectLayers -> ProjectLayers
        traverseAssignableLayer thisSubAssignableSkelReg layersSoFar =
            let
                thisSubAssignableSkel =
                    Reg.latest thisSubAssignableSkelReg

                passDown : InheritableFromAssignable
                passDown =
                    { layerTitles = layerTitles }

                childrenToProcess : ProjectLayers
                childrenToProcess =
                    List.foldl (itemInsideAssignable passDown) layersSoFar (RepList.listValues thisSubAssignableSkel.children)
            in
            { childrenToProcess
                | subassignables =
                    AnyDict.insert makeID metaSubAssignableToAdd layersSoFar.subassignables
                        |> AnyDict.union childrenToProcess.subassignables
            }
    in
    List.foldl (traverseProject Nothing) start (RepDb.listValues rootProjects)
