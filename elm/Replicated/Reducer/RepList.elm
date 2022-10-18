module Replicated.Reducer.RepList exposing (Handle, InsertionPoint(..), RepList, append, buildFromReplicaDb, dict, getInit, getPointer, head, headValue, insert, insertNew,  last, length, list, listValues, reducerID, remove)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Dict.Extra as Dict
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change, Changer, Context(..), Pointer)
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
        { pointer : Pointer
        , members : List (Item memberType)
        , included : Object.InclusionInfo
        , memberAdder : Change.SiblingIndex -> memberType -> Maybe OpID -> Change.ObjectChange
        , startWith : Changer (RepList memberType)
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
buildFromReplicaDb : Object -> (JE.Value -> Maybe memberType) -> (Change.SiblingIndex -> memberType -> Maybe OpID -> Change.ObjectChange) -> Changer (RepList memberType) -> RepList memberType
buildFromReplicaDb targetObject payloadToMember memberAdder init =
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
                ( Just item, False ) ->
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
        handleString (Handle handle) =
            OpID.toString handle
    in
    Dict.fromList (List.map (\member -> ( handleString member.handle, member.value )) repSetRecord.members)



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
    Change.Chunk
        { target = repSetRecord.pointer
        , objectChanges =
            [ repSetRecord.memberAdder "insert" newItem (attachmentPointHelper repSetRecord.pointer insertionPoint) ]
        }


{-| Add items at the given location.
-}
append : InsertionPoint -> List memberType -> RepList memberType -> Change
append insertionPoint newItems (RepList record) =
    let
        newItemToObjectChange newIndex newItem =
            record.memberAdder ("append#" ++ String.fromInt newIndex) newItem (attachmentPointHelper record.pointer insertionPoint)
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = List.indexedMap newItemToObjectChange newItems
        }


{-| Remove an item with the given handle.
-}
remove : Handle -> RepList memberType -> Change
remove (Handle itemToRemove) (RepList record) =
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            [ Change.RevertOp itemToRemove ]
        }


{-| How many saved items are in this replist?
-}
length : RepList memberType -> Int
length (RepList record) =
    List.length record.members


getInit : RepList memberType -> List Change
getInit ((RepList record) as repList) =
    record.startWith repList


{-| Insert an item at the given location, that must be created anew with a context clue.
The new item will be generated from the function you pass, which has the `Context` as its input.

    - If you don't need a context (e.g. you are addding an already-saved reptype), just use `insert`.

-}
insertNew : InsertionPoint -> (Context -> memberType) -> RepList memberType -> Change
insertNew insertionPoint newItemFromContext (RepList record) =
    let
        newItem =
            newItemFromContext (Change.Context record.pointer)

        -- newItemChanges =
        --     itemChanger newItem
        --         -- combining here is necessary for now because wrapping the end result in the parent replist changer makes us not able to group
        --         |> Change.combineChangesOfSameTarget

        -- newItemChangesAsRepListObjectChanges =
        --     List.map wrapSubChangeWithRef newItemChanges

        -- wrapSubChangeWithRef subChange =
        --     case attachmentPointHelper record.pointer insertionPoint of
        --         Just opID ->
        --             Change.NewPayloadWithRef { payload = Change.changeToChangePayload subChange, ref = opID }

        --         Nothing ->
        --             Change.NewPayload (Change.changeToChangePayload subChange)


        memberToObjectChange =
            record.memberAdder "insertNew" newItem refMaybe

        refMaybe =
            attachmentPointHelper record.pointer insertionPoint
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            [memberToObjectChange]
        }



-- Normal listValues functions
-- map : (memberTypeA -> memberTypeB) -> RepList memberTypeA -> RepList memberTypeB
-- map mapper (RepList repSetRecord) =
--     let
--         mappedMembers : List (Item memberTypeB)
--         mappedMembers =
--             List.map (\item -> { handle = item.handle, value = mapper item.value }) repSetRecord.members
--     in
--     { repSetRecord | members = mappedMembers, startWith = List.map mapper repSetRecord.startWith }
