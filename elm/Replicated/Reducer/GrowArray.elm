module Replicated.Reducer.GrowArray exposing (..)

import Replicated.Identifier exposing (ObjectID)


type GrowArray
    = GrowArray
        { id : ObjectID
        , changes : List FieldChange -- can be truncated by timestamp for a historical snapshot
        , included : Object.InclusionInfo
        }


fromReplicaDb : ObjectID -> ObjectEvents -> GrowArray
fromReplicaDb id eventlist =
    GrowArray
        { id = id
        , changes = eventlist
        , included = All
        }
