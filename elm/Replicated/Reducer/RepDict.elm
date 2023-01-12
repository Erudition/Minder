module Replicated.Reducer.RepDict exposing (RepDict, RepDictEntry(..), buildFromReplicaDb, bulkInsert, get, getInit, getPointer, insert, insertNew, list, reducerID, size, update)

import Array exposing (Array)
import Console
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change, Changer, Parent(..), Creator)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (I, Object, Placeholder)
import Replicated.Op.Op as Op
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated list.
-}
type RepDict k v
    = RepDict
        { pointer : Change.Pointer
        , members : AnyDict KeyAsString k (Member v)
        , included : Object.InclusionInfo
        , memberAdder : Change.SiblingIndex -> RepDictEntry k v -> Change.ObjectChange
        , startWith : Changer (RepDict k v)
        }


type alias KeyAsString =
    String


{-| Internal wrapper to track if an item is removed from the dict.
-}
type RepDictEntry k v
    = Present k v
    | Cleared k


type alias Member v =
    { value : v
    , remove : Change
    }


getPointer : RepDict k v -> Change.Pointer
getPointer (RepDict repDict) =
    repDict.pointer


type alias Handle =
    OpIDString


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Object -> (JE.Value -> Maybe (RepDictEntry k v)) -> (Change.SiblingIndex -> RepDictEntry k v -> Change.ObjectChange) -> (k -> String) -> Changer (RepDict k v) -> RepDict k v
buildFromReplicaDb targetObject payloadToEntry memberAdder keyToString initChanger =
    let
        eventsAsMemberPairs : List ( k, Member v )
        eventsAsMemberPairs =
            case Object.getCreationID targetObject of
                Just objectID ->
                    List.filterMap (eventToMemberPair objectID) (AnyDict.toList (Object.getEvents targetObject))

                Nothing ->
                    []

        eventToMemberPair : ObjectID -> ( OpID, Object.Event ) -> Maybe ( k, Member v )
        eventToMemberPair containerObjectID ( eventID, event ) =
            case ( payloadToEntry (Object.eventPayloadAsJson event), Object.eventReverted event ) of
                ( Just (Present key val), False ) ->
                    Just
                        ( key
                        , { value = val
                          , remove = remover containerObjectID eventID
                          }
                        )

                _ ->
                    Nothing

        remover containerObjectID inclusionEventID =
            Change.ChangeSet
                { target = Change.ExistingObjectPointer containerObjectID identity
                , objectChanges = [ Change.RevertOp inclusionEventID ]
                , externalUpdates = []
                }
    in
    RepDict
        { pointer = Object.getPointer targetObject
        , members = AnyDict.fromList keyToString eventsAsMemberPairs
        , memberAdder = memberAdder
        , included = Object.getIncluded targetObject
        , startWith = initChanger
        }



-- ACCESSORS


{-| Get an a member as an `Member`, which gives you access to its `Handle`.
-}
get : k -> RepDict k v -> Maybe v
get key repDict =
    Maybe.map .value (getMember key repDict)


{-| Insert an entry into a replicated dictionary of primitives.
-}
insert : k -> v -> RepDict k v -> Change
insert newKey newValue (RepDict record) =
    let
        newItemToObjectChange =
            record.memberAdder "singleInsert" (Present newKey newValue)
    in
    Change.ChangeSet
        { target = record.pointer
        , objectChanges = [ newItemToObjectChange ]
        , externalUpdates = []
        }


{-| Bulk insert entries into a replicated dictionary of primitives, via a list of (key, value) tuples.
Only works with dictionaries with primitives.
-}
bulkInsert : List ( k, v ) -> RepDict k v -> Change
bulkInsert newItems (RepDict record) =
    let
        newItemToObjectChange index ( newKey, newValue ) =
            record.memberAdder ("bulkInsert#" ++ String.fromInt index) (Present newKey newValue)
    in
    Change.ChangeSet
        { target = record.pointer
        , objectChanges = List.indexedMap newItemToObjectChange newItems
        , externalUpdates = []
        }


{-| Insert an entry whose value needs a context clue for initialization.
The new value will be generated from the function you pass, which has the `Context` as its input.

    - If you don't need a context (e.g. you are adding an already-saved reptype), just use `insert`.

-}
insertNew : k -> Creator v -> RepDict k v -> Change
insertNew key newValueFromContext (RepDict repDictRecord) =
    let
        newValue =
            newValueFromContext (Change.ParentContext repDictRecord.pointer)
    in
    Change.ChangeSet
        { target = repDictRecord.pointer
        , objectChanges =
            [ repDictRecord.memberAdder "insertNew" (Present key newValue) ]
        , externalUpdates = []
        }


{-| Get your RepDict as a read-only List.
-}
list : RepDict k v -> List ( k, v )
list repDict =
    List.map (\( k, v ) -> ( k, v.value )) (listMembers repDict)


{-| Get an a member as an `Member`, which gives you access to its remover.
-}
getMember : k -> RepDict k v -> Maybe (Member v)
getMember key ((RepDict record) as repDict) =
    AnyDict.get key record.members



--
-- getOrNew : k -> RepDict k v -> Maybe (Member v)
-- getOrNew key ((RepDict record) as repDict) =
--     case AnyDict.get key record.members of
--         Just found ->
--             Just found
--
--         Nothing ->
--             case record.memberGenerator () of
--                 Just generated ->
--                     Just <|
--                         Member generated
--                             (Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "can't remove uninitialized")))
--
--                 Nothing ->
--                     Nothing


{-| Get your RepDict as a read-only List, with values wrapped in `Member` records so you still have access to the handle
-}
listMembers : RepDict k v -> List ( k, Member v )
listMembers (RepDict repSetRecord) =
    AnyDict.toList repSetRecord.members


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : k -> (Maybe v -> Maybe v) -> RepDict k v -> Change
update key updater ((RepDict record) as repDict) =
    let
        oldValueMaybe =
            get key repDict

        updatedEntry =
            case updater oldValueMaybe of
                Just newValue ->
                    Present key newValue

                Nothing ->
                    Cleared key

        newMemberAsObjectChange =
            record.memberAdder "update" updatedEntry
    in
    Change.ChangeSet
        { target = record.pointer
        , objectChanges = [ newMemberAsObjectChange ]
        , externalUpdates = []
        }


size : RepDict k v -> Int
size (RepDict record) =
    AnyDict.size record.members


getInit : RepDict k v -> List Change
getInit ((RepDict record) as repDict) =
    record.startWith repDict
