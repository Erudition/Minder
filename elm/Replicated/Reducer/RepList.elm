module Replicated.Reducer.RepList exposing (Handle, InsertionPoint(..), Item, RepList, append, buildFromReplicaDb, dict, getInit, getPointer, handleString, head, headValue, insert, insertNew, last, length, list, listValues, reducerID, remove)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Dict.Extra as Dict
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change(..), ChangeSet, Changer, Creator, Parent(..), Pointer)
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Collection as Object exposing (Object)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Op.ID as OpID exposing (ObjectID, OpID, OpIDString)
import Replicated.Op.Op as Op
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated list.
-}
type RepList memberType
    = RepList
        { pointer : Pointer
        , members : List (Item memberType)
        , included : Object.InclusionInfo
        , memberAdder : Location -> memberType -> Maybe OpID -> Change.ObjectChange
        , startWith : Changer (RepList memberType)
        }


type alias Item memberType =
    { handle : Handle
    , value : memberType
    }


{-| Want to use a replist with Html.Keyed?
Here's your key.
-}
handleString : Item memberType -> String
handleString { handle } =
    let
        (Handle itemID) =
            handle
    in
    OpID.toString itemID


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


getPointer : RepList memberType -> Change.Pointer
getPointer (RepList repSet) =
    repSet.pointer


type Handle
    = Handle OpID


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Object -> (JE.Value -> Maybe memberType) -> (Location -> memberType -> Maybe OpID -> Change.ObjectChange) -> Changer (RepList memberType) -> Maybe (RepList memberType) -> RepList memberType
buildFromReplicaDb targetObject payloadToMember memberAdder init oldRepListMaybe =
    let
        compareEvents : ( OpID, Object.Event ) -> ( OpID, Object.Event ) -> Order
        compareEvents ( eventIDA, eventA ) ( eventIDB, eventB ) =
            case compare (OpID.toSortablePrimitives (Object.eventReference eventA)) (OpID.toSortablePrimitives (Object.eventReference eventB)) of
                GT ->
                    GT

                LT ->
                    LT

                EQ ->
                    -- same reference
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
            case payloadToMember (Object.eventPayloadAsJson event) of
                Just item ->
                    Just
                        { handle = Handle eventID
                        , value = item
                        }

                _ ->
                    Nothing
    in
    case oldRepListMaybe of
        Just (RepList existing) ->
            --TODO
            RepList
                { pointer = Object.getPointer targetObject
                , members = sortedEventsAsItems
                , memberAdder = memberAdder
                , included = Object.getIncluded targetObject
                , startWith = init
                }

        Nothing ->
            RepList
                { pointer = Object.getPointer targetObject
                , members = sortedEventsAsItems
                , memberAdder = memberAdder
                , included = Object.getIncluded targetObject
                , startWith = init
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
        handleToString (Handle handle) =
            OpID.toString handle
    in
    Dict.fromList (List.map (\member -> ( handleToString member.handle, member.value )) repSetRecord.members)



-- MODIFIERS


{-| Where should we insert new stuff?

  - `First`: The item(s) will become the first in the replist.\*
  - `Last`: The item(s) will become the last in the replist.\*
  - `After`: The item(s) will be placed immediately after the item with the given handle.\*

Unsaved same-frame changes do not know about each other, so if you insert things multiple separate times before saving your changes, be sure the change list is also in the desired order. It's usually better to combine these into a single insertion though!

\*until the next time this is done! Keep in mind other unsynced replicas may be doing this too...

-}
type InsertionPoint
    = First
    | Last
    | After Handle


{-| Internal helper to put an item in the correct place.
-}
attachmentPointHelper : Pointer -> InsertionPoint -> Maybe OpID
attachmentPointHelper containerPointer insertionPoint =
    case insertionPoint of
        Last ->
            Nothing

        After (Handle opID) ->
            Just opID

        First ->
            Change.getPointerObjectID containerPointer


{-| Insert an item at the given location.
-}
insert : InsertionPoint -> memberType -> RepList memberType -> Change
insert insertionPoint newItem (RepList repSetRecord) =
    let
        finalChangeSet frameIndex =
            Change.changeObject
                { target = repSetRecord.pointer
                , objectChanges =
                    [ repSetRecord.memberAdder (Location.nestSingle frameIndex "insert") newItem (attachmentPointHelper repSetRecord.pointer insertionPoint) ]
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


{-| Add items at the given location.
-}
append : InsertionPoint -> List memberType -> RepList memberType -> Change
append insertionPoint newItems (RepList record) =
    let
        newItemToObjectChange frameIndex newIndex newItem =
            record.memberAdder (Location.nest frameIndex "append" newIndex) newItem (attachmentPointHelper record.pointer insertionPoint)

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = List.indexedMap (newItemToObjectChange frameIndex) newItems
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


{-| Remove an item with the given handle.
-}
remove : Handle -> RepList memberType -> Change
remove (Handle itemToRemove) (RepList record) =
    let
        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges =
                    [ Change.RevertOp itemToRemove ]
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


{-| How many saved items are in this replist?
-}
length : RepList memberType -> Int
length (RepList record) =
    List.length record.members


getInit : RepList memberType -> ChangeSet
getInit ((RepList record) as repList) =
    record.startWith repList
        |> Change.collapseChangesToChangeSet "RepListInit"


{-| Insert items at the given location, which must be created anew with a context clue.
The new items will be generated from the Creator you pass, which has the `Context` as its input.

    - If you don't need a context (e.g. you are addding an already-saved reptype), just use `insert`.

-}
insertNew : InsertionPoint -> List (Creator memberType) -> RepList memberType -> Change
insertNew insertionPoint newItemCreators (RepList record) =
    let
        newItem frameIndex index creator =
            creator (Change.Context (Location.nest frameIndex "repListInsertNew" index) (Change.becomeInstantParent record.pointer))

        newItems frameIndex =
            List.indexedMap (newItem frameIndex) newItemCreators

        memberToObjectChange frameIndex item =
            -- the child# is only passed to the frameIndex of the child creator
            record.memberAdder (Location.nestSingle frameIndex "insertNew") item refMaybe

        refMaybe =
            attachmentPointHelper record.pointer insertionPoint

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = List.map (memberToObjectChange frameIndex) (newItems frameIndex)
                }
                |> .changeSet
    in
    WithFrameIndex finalChangeSet
