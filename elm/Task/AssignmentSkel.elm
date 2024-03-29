module Task.AssignmentSkel exposing (..)

import ExtraCodecs as Codec
import ID exposing (ID)
import Json.Decode.Exploration exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode exposing (..)
import Json.Encode.Extra exposing (..)
import Replicated.Change as Change exposing (Changer, Context)
import Replicated.Codec as Codec exposing (Codec, NullCodec)
import Replicated.Reducer.Register exposing (RW, Reg)
import Replicated.Reducer.RepDb exposing (RepDb)
import Replicated.Reducer.RepDict exposing (RepDict)
import Replicated.Reducer.RepList exposing (RepList)
import Replicated.Reducer.RepStore exposing (RepStore)
import SmartTime.Human.Moment exposing (FuzzyMoment)
import SmartTime.Moment exposing (..)
import Task.ActionSkel exposing (ActionID)
import Task.AssignedActionSkel exposing (AssignedActionSkel, assignedActionCodec)
import Task.Progress as Progress exposing (..)
import Task.Series exposing (Series, SeriesIndex, SeriesMemberID)
import Task.SubAssignableSkel as SubAssignableSkel exposing (SubAssignableID, SubAssignableSkel)



-- Assignment Skeleton (bare minimum, non-derivative data, saved to disk) --------------------------------


{-| Definition of a single assignment of a single task - one particular time that the specific thing will be done, that can be scheduled. Can be thought of as an "assignment" of a task (assignable). There may be zero (an unassigned task), and there may be many (a repeated task) for a given assignable.
-}
type alias AssignmentSkel =
    { completion : RW Progress.Portion
    , externalDeadline : RW (Maybe FuzzyMoment) -- *
    , startBy : RW (Maybe FuzzyMoment) -- *
    , finishBy : RW (Maybe FuzzyMoment) -- *
    , relevanceStarts : RW (Maybe FuzzyMoment) -- *
    , relevanceEnds : RW (Maybe FuzzyMoment) -- * (*)=An absolute FuzzyMoment if specified, otherwise generated by relative rules from assignable
    , nestedAssignedActions : RepStore ActionID (Reg AssignedActionSkel) -- flattened - go straight to the AssignedActions
    , nestedLayers : RepStore SubAssignableID (Reg SubAssignableSkel)
    , extra : RepDict String String
    }


codec : Codec String (Changer (Reg AssignmentSkel)) Codec.SoloObject (Reg AssignmentSkel)
codec =
    Codec.record AssignmentSkel
        |> Codec.fieldRW ( 3, "completion" ) .completion Codec.int 0
        |> Codec.fieldRWM ( 4, "externalDeadline" ) .externalDeadline Codec.fuzzyMoment
        |> Codec.fieldRWM ( 5, "startBy" ) .startBy Codec.fuzzyMoment
        |> Codec.fieldRWM ( 6, "finishBy" ) .finishBy Codec.fuzzyMoment
        |> Codec.fieldRWM ( 8, "relevanceStarts" ) .relevanceStarts Codec.fuzzyMoment
        |> Codec.fieldRWM ( 9, "relevanceEnds" ) .relevanceEnds Codec.fuzzyMoment
        |> Codec.fieldStore ( 10, "nestedAssignedActions" ) .nestedAssignedActions ( Codec.id, assignedActionCodec )
        |> Codec.fieldStore ( 12, "nestedLayers" ) .nestedLayers ( Codec.id, SubAssignableSkel.codec )
        |> Codec.fieldDict ( 11, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.finishRegister


type alias ManualAssignmentDb =
    RepDb (Reg AssignmentSkel)


type alias SeriesAssignmentDb =
    RepStore SeriesIndex (Reg AssignmentSkel)


new : Context (Reg AssignmentSkel) -> Reg AssignmentSkel
new context =
    Codec.new codec context


newWithChanges : Change.Changer (Reg AssignmentSkel) -> Context (Reg AssignmentSkel) -> Reg AssignmentSkel
newWithChanges changer context =
    Codec.newWithChanges codec context changer
