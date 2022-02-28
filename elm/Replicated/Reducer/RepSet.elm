module Replicated.Reducer.RepSet exposing (RepSet, append, buildFromObject, buildFromReplicaDb, dict, insertAfter, list, reducerID, remove)

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


{-| A replicated Set.
Order is maintained, but cannot be changed.
-}
type RepSet memberType
    = RepSet
        { id : ObjectID
        , members : Dict MemberID memberType
        , included : Object.InclusionInfo
        , addMember : memberType -> Change
        }


type alias MemberID =
    ( OpIDString, OpIDString )


memberIDToOpID : MemberID -> OpID
memberIDToOpID ( opID, _ ) =
    OpID.fromStringForced opID


reducerID : Op.ReducerID
reducerID =
    "repset"


buildFromObject : Object -> (String -> Maybe a) -> (a -> String) -> RepSet a
buildFromObject object unstringifier stringifier =
    let
        eventsAsMembers : Dict MemberID memberType
        eventsAsMembers =
            Dict.foldl
                (\k event acc ->
                    Dict.insert ( Object.eventReference event |> OpID.toString, Object.eventID event |> OpID.toString )
                        (unstringifier (Object.eventPayload event))
                        acc
                )
                Dict.empty
                object.events
    in
    RepSet
        { id = object.creation
        , members = eventsAsMembers
        , memberToString = stringifier
        , included = object.included
        }


{-| We assume object exists, missing object should be handled beforehand.
-}
buildFromReplicaDb : Node -> OpID.ObjectID -> (String -> Maybe a) -> (a -> String) -> Maybe (RepSet a)
buildFromReplicaDb node objectID unstringifier stringifier =
    let
        convertObjectToRepSet object =
            buildFromObject object unstringifier stringifier
    in
    Maybe.map convertObjectToRepSet (Node.getObjectIfExists node objectID reducerID)



-- ACCESSORS


{-| Get your RepSet as a read-only List.
The List will always be in chronological order, with the newest addition at the top (accessing the head is the most performant way to use Lists anyway) but you can always List.reverse or List.sort it.
-}
list : RepSet memberType -> List memberType
list (RepSet repSetRecord) =
    Dict.values repSetRecord.members


{-| Get your RepSet as a standard Dict, where the provided keys are unique identifiers that can be used for mutating the collection:

  - removing an item
  - inserting new items after a known existing item
  - using it as your item's unique ID in a record type

-}
dict : RepSet memberType -> Dict MemberID memberType
dict (RepSet repSetRecord) =
    repSetRecord.members



-- {-| Insert an item, right after the member with the given ID.
-- -}
-- insert : RepSet memberType -> Dict MemberID memberType -> Change
-- insert (RepSet repSetRecord) =
--     Debug.todo "insertAfter"


{-| Insert an item, right after the member with the given ID.
-}
insertAfter : RepSet memberType -> MemberID -> memberType -> Change
insertAfter (RepSet repSetRecord) attachmentPoint newItem =
    Op.Chunk
        { object = Op.ExistingObject repSetRecord.id
        , objectChanges =
            [ Op.NewPayloadWithRef { payload = repSetRecord.memberToString newItem, ref = memberIDToOpID attachmentPoint } ]
        }


{-| Add items to the collection.
-}
append : RepSet memberType -> List memberType -> Change
append (RepSet repSetRecord) newItems =
    let
        newItemToObjectChange newItem =
            Op.NewPayload (repSetRecord.memberToString newItem)
    in
    Op.Chunk
        { object = Op.ExistingObject repSetRecord.id
        , objectChanges = List.map newItemToObjectChange newItems
        }


remove : RepSet memberType -> MemberID -> Change
remove (RepSet repSetRecord) itemToRemove =
    Op.Chunk
        { object = Op.ExistingObject repSetRecord.id
        , objectChanges =
            [ Op.RevertOp (memberIDToOpID itemToRemove) ]
        }
