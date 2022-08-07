module Replicated.Reducer.RepDb exposing (Member, RepDb, buildFromReplicaDb, empty, get, getMember, getPointer, listValues, members, reducerID, size, spawnNoChange, spawnWithChanges, update)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Dict.Extra as Dict
import ID exposing (ID)
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
type RepDb memberType
    = RepDb
        { pointer : Change.Pointer
        , members : AnyDict OpID.OpIDSortable InclusionOpID (Member memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Change.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


{-| Internal reminder that the ID of the inclusion Op is not the same as the member object's ID.
-}
type alias InclusionOpID =
    OpID


type alias Member memberType =
    { id : ID memberType
    , value : memberType
    , remove : Change
    }


empty : RepDb a
empty =
    RepDb
        { pointer = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
        , members = AnyDict.empty OpID.toSortablePrimitives
        , included = Object.All
        , memberChanger =
            \memberType opIDMaybe -> Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "uninitialized"))
        , memberGenerator = \() -> Nothing
        }


getPointer : RepDb memberType -> Change.Pointer
getPointer (RepDb repSet) =
    repSet.pointer


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Object -> (JE.Value -> Maybe memberType) -> (memberType -> Maybe OpID -> Change.ObjectChange) -> RepDb memberType
buildFromReplicaDb object payloadToMember memberChanger =
    let
        memberDict : AnyDict OpID.OpIDSortable InclusionOpID (Member memberType)
        memberDict =
            case Object.getCreationID object of
                Just objectID ->
                    AnyDict.filterMap (eventToKeyMemberPairMaybe objectID) (Object.getEvents object)

                Nothing ->
                    AnyDict.empty OpID.toSortablePrimitives

        eventToKeyMemberPairMaybe : ObjectID -> InclusionOpID -> Object.Event -> Maybe (Member memberType)
        eventToKeyMemberPairMaybe containerObjectID eventID event =
            case
                ( Object.extractOpIDFromEventPayload event
                , payloadToMember (Object.eventPayloadAsJson event)
                )
            of
                ( Just memberObjectID, Just memberValue ) ->
                    Just
                        { id = ID.tag memberObjectID
                        , value = memberValue
                        , remove = remover containerObjectID eventID
                        }

                _ ->
                    Nothing

        remover containerObjectID inclusionEventID =
            Change.Chunk
                { target = Change.ExistingObjectPointer containerObjectID
                , objectChanges = [ Change.RevertOp inclusionEventID ]
                }
    in
    RepDb
        { pointer = Object.getPointer object
        , members = memberDict
        , memberChanger = memberChanger
        , memberGenerator = \_ -> payloadToMember (JE.string "{}") -- "{}" for decoding nothingness
        , included = Object.getIncluded object
        }



-- ACCESSORS


get : ID memberType -> RepDb memberType -> Maybe memberType
get givenID (RepDb repDbRecord) =
    AnyDict.get (ID.read givenID) repDbRecord.members
        |> Maybe.map .value


getMember : ID memberType -> RepDb memberType -> Maybe (Member memberType)
getMember givenID (RepDb repDbRecord) =
    AnyDict.get (ID.read givenID) repDbRecord.members


{-| Get your RepDb as a read-only List.
-}
listValues : RepDb memberType -> List memberType
listValues (RepDb repSetRecord) =
    AnyDict.values repSetRecord.members
        |> List.map .value


{-| Get your RepDb as a listValues of `Member`s, providing you access to the Db-removal changer and the item's ID.
-}
members : RepDb memberType -> List (Member memberType)
members (RepDb repSetRecord) =
    AnyDict.values repSetRecord.members


size : RepDb memberType -> Int
size (RepDb record) =
    AnyDict.size record.members


spawnNoChange : RepDb memberType -> Change
spawnNoChange repDict =
    spawnWithChanges (\_ -> []) repDict


update : ID memberType -> (memberType -> List Change) -> RepDb memberType -> List Change
update givenID changer repDb =
    case get givenID repDb of
        Just foundDesiredMember ->
            changer foundDesiredMember

        Nothing ->
            [ spawnWithChanges changer repDb ]


spawnWithChanges : (memberType -> List Change) -> RepDb memberType -> Change
spawnWithChanges changer (RepDb record) =
    let
        newItemMaybe =
            record.memberGenerator ()

        newItemChanges =
            case newItemMaybe of
                Nothing ->
                    []

                Just newItem ->
                    changer newItem
                        -- combining here is necessary for now because wrapping the end result in the parent RepDb changer makes us not able to group
                        |> Change.combineChangesOfSameTarget

        newItemChangesAsRepDbObjectChanges =
            List.map (Change.NewPayload << Change.changeToChangePayload) newItemChanges

        finalChangeList =
            case ( newItemChangesAsRepDbObjectChanges, newItemMaybe ) of
                ( [], Just newItem ) ->
                    -- effectively a no-op so the member object will still initialize
                    [ record.memberChanger newItem Nothing ]

                ( [], Nothing ) ->
                    Log.crashInDev "Should never happen, no item generated to add to list" []

                ( nonEmptyChangeList, _ ) ->
                    newItemChangesAsRepDbObjectChanges
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges =
            finalChangeList
        }
