module Replicated.Reducer.RepDb exposing (Member, RepDb, addNew, addNewWithChanges, buildFromReplicaDb, empty, get, getID, getMember, listValues, members, reducerID, size, update)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
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
        { id : Change.Pointer
        , members : Dict OpID.OpIDSortable (Member memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Change.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


type alias Member memberType =
    { id : ID memberType
    , value : memberType
    , remove : Change
    }


empty : RepDb a
empty =
    RepDb
        { id = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
        , members = Dict.empty
        , included = Object.All
        , memberChanger =
            \memberType opIDMaybe -> Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "uninitialized"))
        , memberGenerator = \() -> Nothing
        }


getID : RepDb memberType -> Change.Pointer
getID (RepDb repSet) =
    repSet.id


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Node -> Change.Pointer -> (JE.Value -> Maybe memberType) -> (memberType -> Maybe OpID -> Change.ObjectChange) -> RepDb memberType
buildFromReplicaDb node targetObject payloadToMember memberChanger =
    let
        existingObjectMaybe =
            case targetObject of
                Change.ExistingObjectPointer objectID ->
                    Node.getObjectIfExists node [ objectID ]

                _ ->
                    Nothing

        keyValueList : List ( OpID.OpIDSortable, Member memberType )
        keyValueList =
            case existingObjectMaybe of
                Just foundObject ->
                    List.filterMap (eventToKeyMemberPairMaybe (Object.getID foundObject)) (Dict.values foundObject.events)

                Nothing ->
                    []

        eventToKeyMemberPairMaybe : ObjectID -> Object.KeptEvent -> Maybe ( OpID.OpIDSortable, Member memberType )
        eventToKeyMemberPairMaybe containerObjectID event =
            case
                ( Object.extractOpIDFromEventPayload event
                , payloadToMember (Object.eventPayloadAsJson event)
                )
            of
                ( Just memberObjectID, Just memberValue ) ->
                    Just
                        ( OpID.toSortablePrimitives memberObjectID
                        , { id = ID.tag memberObjectID
                          , value = memberValue
                          , remove = remover containerObjectID (Object.eventID event)
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
    RepDb
        { id = targetObject
        , members = Dict.fromList keyValueList
        , memberChanger = memberChanger
        , memberGenerator = \_ -> payloadToMember (JE.string "{}") -- "{}" for decoding nothingness
        , included = Maybe.map .included existingObjectMaybe |> Maybe.withDefault Object.All
        }



-- ACCESSORS


get : ID memberType -> RepDb memberType -> Maybe memberType
get givenID (RepDb repDbRecord) =
    Dict.get (OpID.toSortablePrimitives (ID.read givenID)) repDbRecord.members
        |> Maybe.map .value


getMember : ID memberType -> RepDb memberType -> Maybe (Member memberType)
getMember givenID (RepDb repDbRecord) =
    Dict.get (OpID.toSortablePrimitives (ID.read givenID)) repDbRecord.members


{-| Get your RepDb as a read-only List.
-}
listValues : RepDb memberType -> List memberType
listValues (RepDb repSetRecord) =
    Dict.values repSetRecord.members
        |> List.map .value


{-| Get your RepDb as a listValues of `Member`s, providing you access to the Db-removal changer and the item's ID.
-}
members : RepDb memberType -> List (Member memberType)
members (RepDb repSetRecord) =
    Dict.values repSetRecord.members


size : RepDb memberType -> Int
size (RepDb record) =
    Dict.size record.members


addNew : RepDb memberType -> Change
addNew repDict =
    addNewWithChanges (\_ -> []) repDict


update : ID memberType -> (memberType -> List Change) -> RepDb memberType -> List Change
update givenID changer repDb =
    case get givenID repDb of
        Just foundDesiredMember ->
            changer foundDesiredMember

        Nothing ->
            [ addNewWithChanges changer repDb ]


addNewWithChanges : (memberType -> List Change) -> RepDb memberType -> Change
addNewWithChanges changer (RepDb record) =
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
        { target = record.id
        , objectChanges =
            finalChangeList
        }
