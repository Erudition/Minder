module Activity.Store exposing (..)

import Activity.Activity as Activity exposing (..)
import Activity.Evidence as Evidence exposing (..)
import Activity.Template as Template exposing (..)
import Date
import Dict exposing (..)
import External.Commands as Commands exposing (..)
import ExtraCodecs as Codec
import Helpers exposing (..)
import ID exposing (ID)
import IntDict exposing (IntDict)
import Ionicon
import Ionicon.Android as Android
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Nonempty exposing (..)
import Replicated.Codec as Codec exposing (Codec, coreR, coreRW, fieldDict, fieldList, fieldRW, maybeRW)
import Replicated.Reducer.Register as Register exposing (RW)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb(..))
import Replicated.Reducer.RepDict as RepDict exposing (RepDict)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Moment as Moment exposing (..)
import Svg.Styled exposing (..)
import Time
import Time.Extra exposing (..)


type alias Store =
    ( RepDict Template BuiltInActivitySkel, RepDb CustomActivitySkel )


activityStoreCodec : Codec String Store
activityStoreCodec =
    Codec.tuple
        (Codec.repDict Template.codec builtInActivitySkelCodec)
        (Codec.repDb customActivitySkelCodec)


get : ActivityID -> Store -> Activity
get activityID store =
    case activityID of
        BuiltInActivity template ->
            --TODO use dict
            defaults template

        CustomActivity template customActivitySkelID ->
            -- todo use db
            defaults template


getAll : Store -> List Activity
getAll store =
    let
        builtIns =
            List.map BuiltInActivity Template.all

        customs =
            -- TODO
            []
    in
    List.map (\a -> get a store) (builtIns ++ customs)


allUnhidden : Store -> List Activity
allUnhidden store =
    List.filter showing (getAll store)
