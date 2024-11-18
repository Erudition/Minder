module Replicated.Op.Db exposing (..)

import Dict.Any exposing (AnyDict)
import List.Nonempty exposing (Nonempty(..))
import Replicated.Change exposing (ChangeSet(..), Pointer(..))
import Replicated.Identifier exposing (..)
import Replicated.Op.ID exposing (OpID, OpIDSortable)
import Replicated.Op.Op exposing (Op)


type alias OpDb =
    AnyDict OpIDSortable OpID Op
