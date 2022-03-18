module Replicated.Reducer.RepList exposing (RepList, append, buildFromReplicaDb, dict, getID, insertAfter, list, reducerID, remove)

import Array exposing (Array)
import Dict exposing (Dict)
import Dict.Extra as Dict
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Change)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated list.
-}
type RepList memberType
    = RepList
        { id : ObjectID
        , members : List (Item memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Op.ObjectChange
        }


type alias Item memberType =
    { handle : Handle
    , value : memberType
    }


getID : RepList memberType -> ObjectID
getID (RepList repSet) =
    repSet.id


type alias Handle =
    OpIDString


memberIDToOpID : Handle -> OpID
memberIDToOpID opID =
    OpID.fromStringForced opID


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| We assume object exists, missing object should be handled beforehand.
-}
buildFromReplicaDb : Node -> Object -> (String -> Maybe memberType) -> (memberType -> Maybe OpID -> Op.ObjectChange) -> RepList memberType
buildFromReplicaDb node object unstringifier memberChanger =
    let
        sortedEvents =
            Dict.values object.events
                |> List.sortWith compareEvents

        compareEvents : Object.KeptEvent -> Object.KeptEvent -> Order
        compareEvents eventA eventB =
            case compare (OpID.toString (Object.eventReference eventA)) (OpID.toString (Object.eventReference eventB)) of
                GT ->
                    GT

                LT ->
                    LT

                EQ ->
                    case compare (OpID.toString (Object.eventID eventA)) (OpID.toString (Object.eventID eventB)) of
                        GT ->
                            -- later additions come first
                            LT

                        LT ->
                            GT

                        EQ ->
                            EQ

        sortedEventsAsItems =
            List.filterMap eventToItem sortedEvents

        eventToItem event =
            case unstringifier (Object.eventPayload event) of
                Nothing ->
                    Nothing

                Just item ->
                    Just
                        { handle = OpID.toString (Object.eventID event)
                        , value = item
                        }
    in
    RepList
        { id = object.creation
        , members = sortedEventsAsItems
        , memberChanger = memberChanger
        , included = object.included
        }



-- ACCESSORS


{-| Get your RepList as a read-only List.
The List will always be in chronological order, with the newest addition at the top (accessing the head is the most performant way to use Lists anyway) but you can always List.reverse or List.sort it.
-}
list : RepList memberType -> List memberType
list (RepList repSetRecord) =
    List.map .value repSetRecord.members


{-| Get your RepList as a standard Dict, where the provided keys are unique identifiers that can be used for mutating the collection:

  - removing an item
  - inserting new items after a known existing item
  - using it as your item's unique ID in a record type

-}
dict : RepList memberType -> Dict Handle memberType
dict (RepList repSetRecord) =
    Dict.fromList (List.map (\mem -> ( mem.handle, mem.value )) repSetRecord.members)



-- {-| Insert an item, right after the member with the given ID.
-- -}
-- insert : RepList memberType -> Dict Handle memberType -> Change
-- insert (RepList repSetRecord) =
--     Debug.todo "insertAfter"


{-| Insert an item, right after the member with the given ID.
-}
insertAfter : RepList memberType -> Handle -> memberType -> Change
insertAfter (RepList repSetRecord) attachmentPoint newItem =
    Op.Chunk
        { object = Op.ExistingObject repSetRecord.id
        , objectChanges =
            [ repSetRecord.memberChanger newItem (Just (memberIDToOpID attachmentPoint)) ]
        }


{-| Add items to the collection.
-}
append : RepList memberType -> List memberType -> Change
append (RepList repSetRecord) newItems =
    let
        newItemToObjectChange newItem =
            repSetRecord.memberChanger newItem Nothing
    in
    Op.Chunk
        { object = Op.ExistingObject repSetRecord.id
        , objectChanges = List.map newItemToObjectChange newItems
        }


remove : RepList memberType -> Handle -> Change
remove (RepList repSetRecord) itemToRemove =
    Op.Chunk
        { object = Op.ExistingObject repSetRecord.id
        , objectChanges =
            [ Op.RevertOp (Debug.log "reverting op" <| memberIDToOpID (Debug.log "removing member" itemToRemove)) ]
        }
