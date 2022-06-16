module Replicated.Reducer.RepList exposing (RepList, addNew, addNewWithChanges, append, buildFromReplicaDb, dict, getID, head, insertAfter, length, list, new, reducerID, remove)

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
type RepList memberType
    = RepList
        { id : Change.Pointer
        , members : List (Item memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Change.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


new : RepList a
new =
    RepList
        { id = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
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


getID : RepList memberType -> Change.Pointer
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


{-| Only run in codec
-}
buildFromReplicaDb : Node -> Change.Pointer -> (JE.Value -> Maybe memberType) -> (memberType -> Maybe OpID -> Change.ObjectChange) -> RepList memberType
buildFromReplicaDb node targetObject payloadToMember memberChanger =
    let
        existingObjectMaybe =
            case targetObject of
                Change.ExistingObjectPointer objectID ->
                    Node.getObjectIfExists node [ objectID ]

                _ ->
                    Nothing

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
            case existingObjectMaybe of
                Just foundObject ->
                    let
                        sortedEvents =
                            Dict.values foundObject.events
                                |> List.sortWith compareEvents
                    in
                    List.filterMap eventToItem sortedEvents

                Nothing ->
                    []

        eventToItem event =
            case payloadToMember (Object.eventPayloadAsJson event) of
                Nothing ->
                    Nothing

                Just item ->
                    Just
                        { handle = OpID.toString (Object.eventID event)
                        , value = item
                        }
    in
    RepList
        { id = targetObject
        , members = sortedEventsAsItems
        , memberChanger = memberChanger
        , memberGenerator = \_ -> payloadToMember (JE.string "{}") -- "{}" for decoding nothingness
        , included = Maybe.map .included existingObjectMaybe |> Maybe.withDefault Object.All
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
    Change.Chunk
        { target = repSetRecord.id
        , objectChanges =
            [ repSetRecord.memberChanger newItem (Just (memberIDToOpID attachmentPoint)) ]
        }


{-| Add items to the collection.
-}
append : RepList memberType -> List memberType -> Change
append (RepList record) newItems =
    let
        newItemToObjectChange newItem =
            record.memberChanger newItem Nothing
    in
    Change.Chunk
        { target = record.id
        , objectChanges = List.map newItemToObjectChange newItems
        }


remove : RepList memberType -> Handle -> Change
remove (RepList record) itemToRemove =
    Change.Chunk
        { target = record.id
        , objectChanges =
            [ Change.RevertOp (memberIDToOpID itemToRemove) ]
        }


length : RepList memberType -> Int
length (RepList record) =
    List.length record.members


addNew : RepList memberType -> Change
addNew repList =
    addNewWithChanges repList (\_ -> [])


addNewWithChanges : RepList memberType -> (memberType -> List Change) -> Change
addNewWithChanges (RepList record) changer =
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
        { target = record.id
        , objectChanges =
            finalChangeList
        }
