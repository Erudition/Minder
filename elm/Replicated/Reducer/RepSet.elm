module Replicated.Reducer.RepSet exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Replicated.Object as Object exposing (Object)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated Set.
Does not have order
-}
type RepSet a
    = RepSet
        { id : ObjectID
        , members : Array (Member a)
        , included : Object.InclusionInfo
        }


type Member a
    = Member
        { stamp : OpID.EventStamp
        , value : a
        }


fromReplicaDb : Object -> (String -> a) -> RepSet a
fromReplicaDb object unstringifier =
    RepSet
        { id = object.creation
        , members = eventsToMembers object.events unstringifier
        , included = object.included
        }


eventsToMembers : Dict OpIDString Object.KeptEvent -> (String -> a) -> Array (Member a)
eventsToMembers events unstringifier =
    -- This is the simplest way I could think to do this but definitely needs an eventual performance upgrade.
    -- Use grouping instead of maintaining a tree.
    let
        eventsList =
            Dict.values events

        eventsHaveSameNode event1 event2 =
            -- This should group events with the later events that reference them.
            -- TODO is it necessary to include || Object.eventID event2 == Object.eventReference event1 ?
            Object.eventReference event1 == Object.eventReference event2 || Object.eventID event1 == Object.eventReference event2

        concurrentGroups =
            List.gatherEqualsBy Object.eventReference eventsList
                |> List.map toNormalList

        toNormalList ( head, tail ) =
            head :: tail

        toMember event =
            Member
                { stamp = OpID.getEventStamp (Object.eventID event)
                , value = unstringifier (Object.eventPayload event)
                }
    in
    List.concat concurrentGroups
        |> List.map toMember
        |> Array.fromList


{-| Get your RepSet as a List.
The List will always be in chronological order, with the newest addition at the top (accessing the head is the most performant way to use Lists anyway) but you can always List.reverse or List.sort it.
-}
list : RepSet a -> List a
list aRepSet =
    []
