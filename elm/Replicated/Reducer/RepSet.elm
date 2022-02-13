module Replicated.Reducer.RepSet exposing (..)

import Dict exposing (Dict)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.OpID as OpID exposing (ObjectID)
import SmartTime.Moment as Moment exposing (Moment)


type RepSet a
    = RepSet
        { id : ObjectID
        , adds : GrowArray a
        , removes : GrowArray OpID.EventStamp
        , included : Object.InclusionInfo
        }


type alias GrowArray a =
    -- TODO use Array?
    List (NewMember a)


type NewMember a
    = NewMember
        { stamp : OpID.EventStamp
        , value : a
        }


fromReplicaDb : Object -> RepSet a
fromReplicaDb object =
    RepSet
        { id = object.creation
        , changes = eventsToSet object.events
        , included = object.included
        }


eventsToSet : Dict OpIDString Event -> GrowArray a
eventsToSet events =
    []


{-| Get your RepSet as a List.
The List will always be in chronological order, with the newest addition at the top (accessing the head is the most performant way to use Lists anyway) but you can always List.reverse or List.sort it.
-}
list : RepSet a -> List a
list aRepSet =
    []


rwList : RepSet a -> List a
rwList aRepSet =
    []


listAsOf : Moment -> RepSet a -> List a
listAsOf moment aRepSet =
    []
