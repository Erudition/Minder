module Replicated.Op.ObjectHeader exposing (..)

import Replicated.Op.ID as OpID exposing (OpID)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)


{-| ObjectID is OpID. Ref is implied by reducer. Cannot have payload.
-}
type alias ObjectHeader =
    { operationID : OpID
    , reducer : ReducerID
    }


toComparable : ObjectHeader -> ( ReducerID.ReducerIDString, OpID.ObjectIDString )
toComparable { reducer, operationID } =
    ( ReducerID.toString reducer, OpID.toString operationID )


toString : ObjectHeader -> String
toString { reducer, operationID } =
    ReducerID.toString reducer ++ OpID.toString operationID
