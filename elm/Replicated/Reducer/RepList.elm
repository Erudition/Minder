module Replicated.Reducer.RepList exposing (RepList, append, buildFromReplicaDb, dict, getID, head, headValue, insertAfter, last, length, list, listValues, new, reducerID, remove, spawn, spawnWithChanges)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Dict.Extra as Dict
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
type RepList memberType
    = RepList
        { pointer : Change.Pointer
        , members : List (Item memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Change.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


new : New (RepList memberType)
new =
    New <|
        RepList
            { pointer = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
            , members = []
            , included = Object.All
            , memberChanger =
                \memberType opIDMaybe -> Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "uninitialized"))
            , memberGenerator = \() -> Nothing
            }


type alias Item memberType =
    { handle : Handle
    , value : memberType
    }


head : RepList memberType -> Maybe (Item memberType)
head (RepList repList) =
    List.head repList.members


headValue : RepList memberType -> Maybe memberType
headValue (RepList repList) =
    List.head repList.members
        |> Maybe.map .value


last : RepList memberType -> Maybe (Item memberType)
last (RepList repList) =
    List.last repList.members


getID : RepList memberType -> Change.Pointer
getID (RepList repSet) =
    repSet.pointer


type Handle
    = Handle OpID


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Object -> (JE.Value -> Maybe memberType) -> (memberType -> Maybe OpID -> Change.ObjectChange) -> RepList memberType
buildFromReplicaDb targetObject payloadToMember memberChanger =
    let
        compareEvents : ( OpID, Object.Event ) -> ( OpID, Object.Event ) -> Order
        compareEvents ( eventIDA, eventA ) ( eventIDB, eventB ) =
            case compare (OpID.toSortablePrimitives (Object.eventReference eventA)) (OpID.toSortablePrimitives (Object.eventReference eventB)) of
                GT ->
                    GT

                LT ->
                    LT

                EQ ->
                    case compare (OpID.toSortablePrimitives eventIDA) (OpID.toSortablePrimitives eventIDB) of
                        GT ->
                            -- later additions come first
                            LT

                        LT ->
                            GT

                        EQ ->
                            EQ

        sortedEventsAsItems =
            let
                sortedEvents =
                    AnyDict.toList (Object.getEvents targetObject)
                        |> List.sortWith compareEvents
            in
            List.filterMap eventToItem sortedEvents

        eventToItem ( eventID, event ) =
            case ( payloadToMember (Object.eventPayloadAsJson event), Object.eventReverted event ) of
                ( Just item, True ) ->
                    Just
                        { handle = Handle eventID
                        , value = item
                        }

                _ ->
                    Nothing
    in
    RepList
        { pointer = Object.getPointer targetObject
        , members = sortedEventsAsItems
        , memberChanger = memberChanger
        , memberGenerator = \_ -> payloadToMember (JE.string "{}") -- "{}" for decoding nothingness
        , included = Object.getIncluded targetObject
        }



-- ACCESSORS


{-| Get your RepList as a read-only List.
The List will always be in chronological order, with the newest addition at the top (accessing the head is the most performant way to use Lists anyway) but you can always List.reverse or List.sort it.
-}
listValues : RepList memberType -> List memberType
listValues (RepList repSetRecord) =
    List.map .value repSetRecord.members


{-| Get your RepList as a List of `Item`s.
-}
list : RepList memberType -> List (Item memberType)
list (RepList repSetRecord) =
    repSetRecord.members


{-| Get your RepList as a standard Dict, where the provided keys are unique identifiers that can be used for mutating the collection:

  - removing an item
  - inserting new items after a known existing item
  - using it as your item's unique ID in a record type

-}
dict : RepList memberType -> Dict OpIDString memberType
dict (RepList repSetRecord) =
    let
        handleString (Handle handle) =
            OpID.toString handle
    in
    Dict.fromList (List.map (\member -> ( handleString member.handle, member.value )) repSetRecord.members)



-- {-| Insert an item, right after the member with the given ID.
-- -}
-- insert : RepList memberType -> Dict Handle memberType -> Change
-- insert (RepList repSetRecord) =
--     Debug.todo "insertAfter"


{-| Insert an item, right after the member with the given ID.
-}
insertAfter : Handle -> memberType -> RepList memberType -> Change
insertAfter (Handle attachmentPoint) newItem (RepList repSetRecord) =
    Change.Chunk
        { target = repSetRecord.pointer
        , objectChanges =
            [ repSetRecord.memberChanger newItem (Just attachmentPoint) ]
        }


{-| Add items to the collection.
-}
append : List memberType -> RepList memberType -> Change
append newItems (RepList record) =
    let
        newItemToObjectChange newItem =
            record.memberChanger newItem Nothing
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = List.map newItemToObjectChange newItems
        }


remove : Handle -> RepList memberType -> Change
remove (Handle itemToRemove) (RepList record) =
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            [ Change.RevertOp itemToRemove ]
        }


length : RepList memberType -> Int
length (RepList record) =
    List.length record.members


spawn : RepList memberType -> Change
spawn repList =
    spawnWithChanges (\_ -> []) repList


spawnWithChanges : (memberType -> List Change) -> RepList memberType -> Change
spawnWithChanges changer (RepList record) =
    let
        newItemMaybe =
            record.memberGenerator ()

        newItemChanges =
            case newItemMaybe of
                Nothing ->
                    []

                Just newItem ->
                    changer newItem
                        -- combining here is necessary for now because wrapping the end result in the parent replist changer makes us not able to group
                        |> Change.combineChangesOfSameTarget

        newItemChangesAsRepListObjectChanges =
            List.map (Change.NewPayload << Change.changeToChangePayload) newItemChanges

        finalChangeList =
            case ( newItemChangesAsRepListObjectChanges, newItemMaybe ) of
                ( [], Just newItem ) ->
                    -- effectively a no-op so the member object will still initialize
                    [ record.memberChanger newItem Nothing ]

                ( [], Nothing ) ->
                    Log.crashInDev "Should never happen, no item generated to add to list" []

                ( nonEmptyChangeList, _ ) ->
                    newItemChangesAsRepListObjectChanges
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            finalChangeList
        }



-- Normal listValues functions
-- map : (memberTypeA -> memberTypeB) -> RepList memberTypeA -> RepList memberTypeB
-- map mapper (RepList repSetRecord) =
--     let
--         mappedMembers : List (Item memberTypeB)
--         mappedMembers =
--             List.map (\item -> { handle = item.handle, value = mapper item.value }) repSetRecord.members
--     in
--     { repSetRecord | members = mappedMembers }
