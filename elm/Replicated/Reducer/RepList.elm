module Replicated.Reducer.RepList exposing (RepList, addNew, addNewWithChanges, append, buildFromReplicaDb, dict, getID, insertAfter, length, list, reducerID, remove)

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


{-| A replicated list.
-}
type RepList memberType
    = RepList
        { id : Op.Pointer
        , members : List (Item memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Op.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


type alias Item memberType =
    { handle : Handle
    , value : memberType
    }


getID : RepList memberType -> Op.Pointer
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
buildFromReplicaDb : Node -> Op.Pointer -> (String -> Maybe memberType) -> (memberType -> Maybe OpID -> Op.ObjectChange) -> RepList memberType
buildFromReplicaDb node targetObject unstringifier memberChanger =
    let
        existingObjectMaybe =
            case Debug.log "@@ creating replist from" targetObject of
                Op.ExistingObjectPointer objectID ->
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
            case unstringifier (Object.eventPayload event) of
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
        , memberGenerator = \_ -> unstringifier "{}"
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
    Op.Chunk
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
    Op.Chunk
        { target = record.id
        , objectChanges = List.map newItemToObjectChange newItems
        }


remove : RepList memberType -> Handle -> Change
remove (RepList record) itemToRemove =
    Op.Chunk
        { target = record.id
        , objectChanges =
            [ Op.RevertOp (memberIDToOpID itemToRemove) ]
        }


length : RepList memberType -> Int
length (RepList record) =
    List.length record.members


addNew : RepList memberType -> Change
addNew repList =
    addNewWithChanges repList []


addNewWithChanges : RepList memberType -> List (memberType -> Change) -> Change
addNewWithChanges (RepList record) desiredChanges =
    let
        newItemMaybe =
            record.memberGenerator ()

        newItemChanges =
            case newItemMaybe of
                Nothing ->
                    []

                Just newItem ->
                    List.map (\modification -> modification newItem) desiredChanges
                        |> Op.combineChangesOfSameTarget

        newItemChangesAsRepListObjectChanges =
            List.map (Op.NewPayload << Op.changeToRonPayload) newItemChanges

        finalChangeList =
            case ( newItemChangesAsRepListObjectChanges, newItemMaybe ) of
                ( [], Just newItem ) ->
                    -- effectively a no-op so the member object will still initialize
                    [ record.memberChanger newItem Nothing ]

                ( [], Nothing ) ->
                    Debug.todo "Should never happen, no item generated to add to list"

                ( nonEmptyChangeList, _ ) ->
                    newItemChangesAsRepListObjectChanges
    in
    Op.Chunk
        { target = record.id
        , objectChanges =
            Debug.log ">>> new replist member with changes" finalChangeList
        }
