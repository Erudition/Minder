module Replicated.Reducer.RepDict exposing (RepDict, addNew, addNewWithChanges, append, buildFromReplicaDb, dict, empty, getID, reducerID, remove, size)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
import Dict.Extra as Dict
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated list.
-}
type RepDict memberType
    = RepDict
        { id : Change.Pointer
        , members : Dict Handle memberType
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Change.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


empty : RepDict a
empty =
    RepDict
        { id = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
        , members = Dict.empty
        , included = Object.All
        , memberChanger =
            \memberType opIDMaybe -> Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "uninitialized"))
        , memberGenerator = \() -> Nothing
        }


getID : RepDict memberType -> Change.Pointer
getID (RepDict repSet) =
    repSet.id


type alias Handle =
    OpID.OpIDSortable


memberIDToOpID : Handle -> OpID
memberIDToOpID opID =
    OpID.fromSortable opID


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Node -> Change.Pointer -> (JE.Value -> Maybe memberType) -> (memberType -> Maybe OpID -> Change.ObjectChange) -> RepDict memberType
buildFromReplicaDb node targetObject payloadToMember memberChanger =
    let
        existingObjectMaybe =
            case targetObject of
                Change.ExistingObjectPointer objectID ->
                    Node.getObjectIfExists node [ objectID ]

                _ ->
                    Nothing

        eventsAsItems =
            case existingObjectMaybe of
                Just foundObject ->
                    Dict.filterMap eventToItem foundObject.events

                Nothing ->
                    Dict.empty

        eventToItem key event =
            payloadToMember (Object.eventPayloadAsJson event)
    in
    RepDict
        { id = targetObject
        , members = eventsAsItems
        , memberChanger = memberChanger
        , memberGenerator = \_ -> payloadToMember (JE.string "{}") -- "{}" for decoding nothingness
        , included = Maybe.map .included existingObjectMaybe |> Maybe.withDefault Object.All
        }



-- ACCESSORS


{-| Get your RepDict as a read-only List.
The List will always be in chronological order, with the newest addition at the top (accessing the head is the most performant way to use Lists anyway) but you can always List.reverse or List.sort it.
-}
list : RepDict memberType -> List memberType
list (RepDict repSetRecord) =
    Dict.values repSetRecord.members


{-| Get your RepDict as a standard Dict, where the provided keys are unique identifiers that can be used for mutating the collection:

  - removing an item
  - inserting empty items after a known existing item
  - using it as your item's unique ID in a record type

-}
dict : RepDict memberType -> Dict Handle memberType
dict (RepDict repSetRecord) =
    repSetRecord.members



-- {-| Insert an item, right after the member with the given ID.
-- -}
-- insert : RepDict memberType -> Dict Handle memberType -> Change
-- insert (RepDict repSetRecord) =
--     Debug.todo "insertAfter"


{-| Insert an item, right after the member with the given ID.
-}
insertAfter : RepDict memberType -> Handle -> memberType -> Change
insertAfter (RepDict repSetRecord) attachmentPoint newItem =
    Change.Chunk
        { target = repSetRecord.id
        , objectChanges =
            [ repSetRecord.memberChanger newItem (Just (memberIDToOpID attachmentPoint)) ]
        }


{-| Add items to the collection.
-}
append : RepDict memberType -> List memberType -> Change
append (RepDict record) newItems =
    let
        newItemToObjectChange newItem =
            record.memberChanger newItem Nothing
    in
    Change.Chunk
        { target = record.id
        , objectChanges = List.map newItemToObjectChange newItems
        }


remove : RepDict memberType -> Handle -> Change
remove (RepDict record) itemToRemove =
    Change.Chunk
        { target = record.id
        , objectChanges =
            [ Change.RevertOp (memberIDToOpID itemToRemove) ]
        }


size : RepDict memberType -> Int
size (RepDict record) =
    Dict.size record.members


addNew : RepDict memberType -> Change
addNew repDict =
    addNewWithChanges repDict (\_ -> [])


addNewWithChanges : RepDict memberType -> (memberType -> List Change) -> Change
addNewWithChanges (RepDict record) changer =
    let
        newItemMaybe =
            record.memberGenerator ()

        newItemChanges =
            case newItemMaybe of
                Nothing ->
                    []

                Just newItem ->
                    changer newItem
                        -- combining here is necessary for now because wrapping the end result in the parent RepDict changer makes us not able to group
                        |> Change.combineChangesOfSameTarget

        newItemChangesAsRepDictObjectChanges =
            List.map (Change.NewPayload << Change.changeToChangePayload) newItemChanges

        finalChangeList =
            case ( newItemChangesAsRepDictObjectChanges, newItemMaybe ) of
                ( [], Just newItem ) ->
                    -- effectively a no-op so the member object will still initialize
                    [ record.memberChanger newItem Nothing ]

                ( [], Nothing ) ->
                    Log.crashInDev "Should never happen, no item generated to add to list" []

                ( nonEmptyChangeList, _ ) ->
                    newItemChangesAsRepDictObjectChanges
    in
    Change.Chunk
        { target = record.id
        , objectChanges =
            finalChangeList
        }



-- Normal list functions
-- map : (memberTypeA -> memberTypeB) -> RepDict memberTypeA -> RepDict memberTypeB
-- map mapper (RepDict repSetRecord) =
--     let
--         mappedMembers : List (Item memberTypeB)
--         mappedMembers =
--             List.map (\item -> { handle = item.handle, value = mapper item.value }) repSetRecord.members
--     in
--     { repSetRecord | members = mappedMembers }
