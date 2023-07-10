module Task.AssignedAction exposing (..)

import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode exposing (..)
import Json.Encode.Extra exposing (..)
import Replicated.Codec as Codec exposing (WrappedCodec)
import Replicated.Reducer.Register exposing (RW, Reg)
import Replicated.Reducer.RepDict exposing (RepDict)
import Replicated.Reducer.RepList exposing (RepList)
import SmartTime.Human.Moment exposing (FuzzyMoment)
import Task.Action exposing (NestedOrAction(..))
import Task.Progress as Progress exposing (..)
import Task.RelativeTiming exposing (RelativeTiming(..))



-- AssignedAction Skeleton (bare minimum, non-derivative data, saved to disk) --------------------------------


{-| Definition of a single action of a single assignment of a single task
-}
type alias AssignedActionSkel =
    { completion : RW Progress.Portion
    , externalDeadline : RW (Maybe FuzzyMoment)
    , startBy : RW (Maybe FuzzyMoment)
    , finishBy : RW (Maybe FuzzyMoment)
    , relevanceStarts : RW (Maybe FuzzyMoment)
    , relevanceEnds : RW (Maybe FuzzyMoment)
    , extra : RepDict String String
    }


assignedActionCodec : WrappedCodec String (Reg AssignedActionSkel)
assignedActionCodec =
    Codec.record AssignedActionSkel
        |> Codec.fieldRW ( 3, "completion" ) .completion Codec.int 0
        |> Codec.maybeRW ( 4, "externalDeadline" ) .externalDeadline Codec.fuzzyMoment
        |> Codec.maybeRW ( 5, "startBy" ) .startBy Codec.fuzzyMoment
        |> Codec.maybeRW ( 6, "finishBy" ) .finishBy Codec.fuzzyMoment
        |> Codec.maybeRW ( 8, "relevanceStarts" ) .relevanceStarts Codec.fuzzyMoment
        |> Codec.maybeRW ( 9, "relevanceEnds" ) .relevanceEnds Codec.fuzzyMoment
        |> Codec.fieldDict ( 10, "extra" ) .extra ( Codec.string, Codec.string )
        |> Codec.finishRegister


type alias AssignedActionID =
    ID (Reg AssignedActionSkel)
