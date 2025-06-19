module Replicated.Change.PendingID exposing (..)

import List.Nonempty exposing (Nonempty(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Op.Atom exposing (Atom(..))
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)


type alias PendingID =
    { reducer : ReducerID
    , myLocation : Location
    , parentLocation : Maybe Location
    }


toComparable : PendingID -> List String
toComparable pendingID =
    Location.toComparable (toLocation pendingID)


toString : PendingID -> String
toString pendingID =
    Location.toString (toLocation pendingID)


toLocation : PendingID -> Location
toLocation { reducer, myLocation, parentLocation } =
    case parentLocation of
        Nothing ->
            Location.nestSingle myLocation (ReducerID.toString reducer)

        Just foundParentLoc ->
            Location.wrap foundParentLoc myLocation (ReducerID.toString reducer)
