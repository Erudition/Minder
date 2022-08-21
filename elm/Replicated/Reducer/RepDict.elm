module Replicated.Reducer.RepDict exposing (RepDict, RepDictEntry(..), buildFromReplicaDb, bulkInsert, get, getInit, getPointer, insert, insertNew, list, reducerID, size, update)

import Array exposing (Array)
import Console
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change, Context(..))
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
        , startWith : List ( k, v )
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
buildFromReplicaDb : Object -> (JE.Value -> Maybe (RepDictEntry k v)) -> (Change.SiblingIndex -> RepDictEntry k v -> Change.ObjectChange) -> (k -> String) -> List ( k, v ) -> RepDict k v
buildFromReplicaDb targetObject payloadToEntry memberAdder keyToString initEntries =
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
            Change.Chunk
                { target = Change.ExistingObjectPointer containerObjectID
                , objectChanges = [ Change.RevertOp inclusionEventID ]
                }
    in
    RepDict
        { pointer = Object.getPointer targetObject
        , members = AnyDict.fromList keyToString eventsAsMemberPairs
        , memberAdder = memberAdder
        , included = Object.getIncluded targetObject
        , startWith = initEntries
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
            record.memberAdder -1 (Present newKey newValue)
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = [ newItemToObjectChange ]
        }


{-| Bulk insert entries into a replicated dictionary of primitives, via a list of (key, value) tuples.
Only works with dictionaries with primitives.
-}
bulkInsert : List ( k, v ) -> RepDict k v -> Change
bulkInsert newItems (RepDict record) =
    let
        newItemToObjectChange index ( newKey, newValue ) =
            record.memberAdder index (Present newKey newValue)
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = List.indexedMap newItemToObjectChange newItems
        }


{-| Insert an entry whose value needs a context clue for initialization.
The new value will be generated from the function you pass, which has the `Context` as its input.

    - If you don't need a context (e.g. you are addding an already-saved reptype), just use `insert`.

-}
insertNew : k -> (Context -> v) -> RepDict k v -> Change
insertNew key newValueFromContext repDict =
    insertNewAndChange key newValueFromContext (\_ -> []) repDict


{-| Insert an entry whose value needs a context clue for initialization, and make some changes to it!
The new item will be generated from the function (1) you pass, which has the `Context` as its input.
Upon saving, the changes will be applied to the new object in the way specified by your changer function (2), which takes the new object as its input.

    - If you don't need to make any changes this frame, just use `insertNew`.

-}
insertNewAndChange : k -> (Context -> v) -> (v -> List Change) -> RepDict k v -> Change
insertNewAndChange key newValueFromContext valueChanger (RepDict record) =
    let
        newValue =
            newValueFromContext (Change.Context record.pointer)

        newValueChanges =
            valueChanger newValue
                -- combining here is necessary for now because wrapping the end result in the parent replist changer makes us not able to group
                |> Change.combineChangesOfSameTarget

        newValueChangesAsRepDictObjectChanges =
            List.map wrapSubChange newValueChanges

        wrapSubChange subChange =
            Change.NewPayload (Change.changeToChangePayload subChange)

        objectChangeList =
            case newValueChangesAsRepDictObjectChanges of
                [] ->
                    [ record.memberAdder 0 (Present key newValue) ]

                nonEmptyChangeList ->
                    newValueChangesAsRepDictObjectChanges
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            objectChangeList
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
            record.memberAdder -2 updatedEntry
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = [ newMemberAsObjectChange ]
        }


size : RepDict k v -> Int
size (RepDict record) =
    AnyDict.size record.members


getInit : RepDict k v -> List ( k, v )
getInit (RepDict record) =
    record.startWith
