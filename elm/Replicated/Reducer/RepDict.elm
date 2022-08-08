module Replicated.Reducer.RepDict exposing (RepDict, RepDictEntry(..), buildFromReplicaDb, bulkInsert, empty, get, getPointer, insert, list, reducerID, spawn, spawnWithChanges, update)

import Array exposing (Array)
import Console
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change, New(..))
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
        , memberChanger : RepDictEntry k v -> Change.ObjectChange
        , memberGenerator : () -> Maybe v
        }


type alias KeyAsString =
    String


empty : New (RepDict k v)
empty =
    New <|
        RepDict
            { pointer = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
            , members = AnyDict.empty (\_ -> "")
            , included = Object.All
            , memberChanger =
                \memberType -> Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "uninitialized"))
            , memberGenerator = \() -> Nothing
            }


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
buildFromReplicaDb : Object -> (JE.Value -> Maybe (RepDictEntry k v)) -> (RepDictEntry k v -> Change.ObjectChange) -> (k -> String) -> RepDict k v
buildFromReplicaDb targetObject payloadToEntry memberChanger keyToString =
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

        generateMemberValue _ =
            case payloadToEntry (JE.string "{}") of
                Just (Present k v) ->
                    Just v

                _ ->
                    Nothing
    in
    RepDict
        { pointer = Object.getPointer targetObject
        , members = AnyDict.fromList keyToString eventsAsMemberPairs
        , memberChanger = memberChanger
        , memberGenerator = generateMemberValue
        , included = Object.getIncluded targetObject
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
            record.memberChanger (Present newKey newValue)
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
        newItemToObjectChange ( newKey, newValue ) =
            record.memberChanger (Present newKey newValue)
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = List.map newItemToObjectChange newItems
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



-- TODO
-- getOrCreateMember : k -> RepDict k v -> Maybe (Member v)
-- getOrCreateMember key ((RepDict record) as repDict) =
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
            record.memberChanger updatedEntry
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = [ newMemberAsObjectChange ]
        }


size : RepDict k v -> Int
size (RepDict record) =
    AnyDict.size record.members


{-| Spawn a new member at the given key.
Works with reptypes only - use `insert` if your members are primitives.
-}
spawn : k -> RepDict k v -> Change
spawn key repDict =
    spawnWithChanges key (\_ -> []) repDict


{-| Spawn a new member at the given key, then immediately make the given changes to it.
Works with reptypes only - use `insert` if your members are primitives.
-}
spawnWithChanges : k -> (v -> List Change) -> RepDict k v -> Change
spawnWithChanges key valueChanger (RepDict record) =
    let
        newMemberMaybe =
            record.memberGenerator ()

        newMemberChanges =
            case newMemberMaybe of
                Nothing ->
                    []

                Just newMember ->
                    valueChanger newMember
                        -- combining here is necessary for now because wrapping the end result in the parent replist changer makes us not able to group
                        |> Change.combineChangesOfSameTarget

        newMemberChangesAsRepDictObjectChanges =
            List.map (Change.NewPayload << Change.changeToChangePayload) newMemberChanges

        finalChangeList =
            case ( newMemberChangesAsRepDictObjectChanges, newMemberMaybe ) of
                ( [], Just newMember ) ->
                    -- effectively a no-op so the member object will still initialize
                    [ record.memberChanger (Present key newMember) ]

                ( [], Nothing ) ->
                    Log.crashInDev "Should never happen, no item generated to add to list" []

                ( nonEmptyChangeList, _ ) ->
                    newMemberChangesAsRepDictObjectChanges
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            finalChangeList
        }
