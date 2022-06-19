module Replicated.Reducer.RepDb exposing (RepDb, addNew, addNewWithChanges, buildFromReplicaDb, empty, getID, reducerID, remove, size)

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
type RepDb memberType
    = RepDb
        { id : Change.Pointer
        , members : Dict OpID.OpIDSortable (Member memberType)
        , included : Object.InclusionInfo
        , memberChanger : memberType -> Maybe OpID -> Change.ObjectChange
        , memberGenerator : () -> Maybe memberType
        }


type alias Member memberType =
    { included : OpID -- the operation where this object was included - needed for removal
    , value : memberType
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


type ID a
    = ID OpID.OpIDSortable


memberIDToOpID : ID a -> OpID
memberIDToOpID (ID opIDSortable) =
    OpID.fromSortable opIDSortable


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

        memberList : List ( OpID.OpIDSortable, Member memberType )
        memberList =
            case existingObjectMaybe of
                Just foundObject ->
                    List.filterMap eventToMemberPair (Dict.values foundObject.events)

                Nothing ->
                    []

        eventToMemberPair event =
            case
                ( Object.extractOpIDFromEventPayload event
                , payloadToMember (Object.eventPayloadAsJson event)
                )
            of
                ( Just memberObjectID, Just memberValue ) ->
                    Just
                        ( OpID.toSortablePrimitives memberObjectID
                        , Member (Object.eventID event) memberValue
                        )

                _ ->
                    Nothing
    in
    RepDb
        { id = targetObject
        , members = Dict.fromList memberList
        , memberChanger = memberChanger
        , memberGenerator = \_ -> payloadToMember (JE.string "{}") -- "{}" for decoding nothingness
        , included = Maybe.map .included existingObjectMaybe |> Maybe.withDefault Object.All
        }



-- ACCESSORS


get : ID memberType -> RepDb memberType -> Maybe memberType
get (ID memberIDSortable) (RepDb repDbRecord) =
    Dict.get memberIDSortable repDbRecord.members
        |> Maybe.map .value


{-| Get your RepDb as a read-only List.
-}
list : RepDb memberType -> List memberType
list (RepDb repSetRecord) =
    Dict.values repSetRecord.members
        |> List.map .value


remove : RepDb memberType -> ID memberType -> Change
remove (RepDb db) (ID memberIDSortable) =
    let
        lookupInclusionOp =
            Dict.get memberIDSortable db.members

        reversionChange =
            case lookupInclusionOp of
                Just member ->
                    [ Change.RevertOp member.included ]

                Nothing ->
                    []
    in
    Change.Chunk
        { target = db.id
        , objectChanges = reversionChange
        }


size : RepDb memberType -> Int
size (RepDb record) =
    Dict.size record.members


addNew : RepDb memberType -> Change
addNew repDict =
    addNewWithChanges repDict (\_ -> [])


addNewWithChanges : RepDb memberType -> (memberType -> List Change) -> Change
addNewWithChanges (RepDb record) changer =
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
