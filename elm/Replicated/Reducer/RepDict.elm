module Replicated.Reducer.RepDict exposing (RepDict, RepDictEntry(..), buildFromReplicaDb, bulkInsert, get, getInit, getPointer, insert, insertNew, list, reducerID, size, update)

import Array exposing (Array)
import Console
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change, ChangeSet, Changer, Creator, Parent(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Collection as Collection exposing (Collection)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Op.Atom exposing (Atom)
import Replicated.Op.ID as OpID exposing (ObjectID, OpID, OpIDString)
import Replicated.Op.ObjectHeader as ObjectHeader exposing (ObjectHeader)
import Replicated.Op.Payload as Payload exposing (Payload)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated list.
-}
type RepDict k v
    = RepDict
        { pointer : Change.Pointer
        , members : AnyDict KeyAsString k (Member v)
        , included : Collection.InclusionInfo
        , memberAdder : Location -> RepDictEntry k v -> Change.ObjectChange
        , startWith : Changer (RepDict k v)
        }


type alias KeyAsString =
    String


{-| Internal wrapper to track if an item is removed from the dict.
-}
type RepDictEntry k v
    = Present k v
    | Cleared k


type alias FieldPayload =
    Nonempty Atom


type alias Member v =
    { value : v
    , remove : ChangeSet
    }


getPointer : RepDict k v -> Change.Pointer
getPointer (RepDict repDict) =
    repDict.pointer


type alias Handle =
    OpIDString


reducerID : ReducerID
reducerID =
    ReducerID.RepDictReducer


{-| Only run in codec
-}
buildFromReplicaDb :
    (k -> String)
    -> (Payload -> Maybe (RepDictEntry k v))
    -> (Location -> RepDictEntry k v -> Change.ObjectChange)
    -> Changer (RepDict k v)
    -> Collection Payload
    -> RepDict k v
buildFromReplicaDb keyToString payloadToEntry memberAdder initChanger targetObject =
    let
        eventsAsMemberPairs =
            case Collection.getCreationID targetObject of
                Just objectID ->
                    List.filterMap (eventToMemberPair { reducer = reducerID, operationID = objectID }) (AnyDict.toList (Collection.getEvents targetObject))

                Nothing ->
                    []

        eventToMemberPair : ObjectHeader -> ( OpID, Collection.Event Payload ) -> Maybe ( k, Member v )
        eventToMemberPair containerExistingID ( eventID, event ) =
            case payloadToEntry (Collection.eventPayload event) of
                Just (Present key val) ->
                    Just
                        ( key
                        , { value = val
                          , remove = remover containerExistingID eventID
                          }
                        )

                _ ->
                    Nothing

        remover containerExistingID inclusionEventID =
            Change.changeObject
                { target = Change.ExistingObjectPointer containerExistingID
                , objectChanges = [ Change.RevertOp inclusionEventID ]
                }
                |> .changeSet
    in
    RepDict
        { pointer = Collection.getPointer targetObject
        , members = AnyDict.fromList keyToString eventsAsMemberPairs
        , memberAdder = memberAdder
        , included = Collection.getIncluded targetObject
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
        newItemToObjectChange frameIndex =
            record.memberAdder (Location.nestSingle frameIndex "insert") (Present newKey newValue)

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = [ newItemToObjectChange frameIndex ]
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


{-| Bulk insert entries into a replicated dictionary of primitives, via a list of (key, value) tuples.
Only works with dictionaries with primitives.
-}
bulkInsert : List ( k, v ) -> RepDict k v -> Change
bulkInsert newItems (RepDict record) =
    let
        newItemToObjectChange frameIndex myIndex ( newKey, newValue ) =
            record.memberAdder (Location.nest frameIndex "bulkInsert" myIndex) (Present newKey newValue)

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = List.indexedMap (newItemToObjectChange frameIndex) newItems
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


{-| Insert an entry whose value needs a context clue for initialization.
The new value will be generated from the function you pass, which has the `Context` as its input.

    - If you don't need a context (e.g. you are adding an already-saved reptype), just use `insert`.

-}
insertNew : k -> Creator v -> RepDict k v -> Change
insertNew key newValueFromContext (RepDict repDictRecord) =
    let
        newValue frameIndex =
            newValueFromContext (Change.Context frameIndex (Change.becomeInstantParent repDictRecord.pointer))

        finalChangeSet frameIndex =
            Change.changeObject
                { target = repDictRecord.pointer
                , objectChanges =
                    [ repDictRecord.memberAdder (Location.nestSingle frameIndex "insertNew") (Present key (newValue frameIndex)) ]
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


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

        newMemberAsObjectChange frameIndex =
            record.memberAdder (Location.nestSingle frameIndex "update") updatedEntry

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = [ newMemberAsObjectChange frameIndex ]
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


size : RepDict k v -> Int
size (RepDict record) =
    AnyDict.size record.members


getInit : RepDict k v -> ChangeSet
getInit ((RepDict record) as repDict) =
    record.startWith repDict
        |> Change.collapseChangesToChangeSet "RepDictInit"
