module Task.SubAssignable exposing (..)

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
import Task.Assignable exposing (Assignable)
import Task.Progress as Progress exposing (Progress)
import Task.Series exposing (Series)
import Task.SubAssignableSkel as SubAssignable exposing (NestedSubAssignableOrSingleAction(..), SubAssignableID, SubAssignableSkel)
import ZoneHistory exposing (ZoneHistory)


{-| Meta SubAssignable
-}
type SubAssignable
    = SubAssignable
        { parent : SubAssignableParent
        , reg : Reg SubAssignableSkel
        , id : SubAssignableID
        }


type alias SubAssignableID =
    ID SubAssignableSkel


type SubAssignableParent
    = AssignableParent Assignable
    | SubAssignableParent SubAssignable


id : SubAssignable -> SubAssignableID
id (SubAssignable sub) =
    sub.id


fromSkelWithAssignableParent : Assignable -> Reg SubAssignableSkel -> SubAssignable
fromSkelWithAssignableParent parent skelReg =
    SubAssignable
        { reg = skelReg
        , id = ID.fromPointer (Reg.getPointer skelReg)
        , parent = AssignableParent parent
        }


fromSkelWithSubAssignableParent : SubAssignable -> Reg SubAssignableSkel -> SubAssignable
fromSkelWithSubAssignableParent parent skelReg =
    SubAssignable
        { reg = skelReg
        , id = ID.fromPointer (Reg.getPointer skelReg)
        , parent = SubAssignableParent parent
        }
