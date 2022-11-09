module Replicated.Reducer.RepDb exposing (Member, RepDb, addNew, buildFromReplicaDb, get, getInit, getMember, getPointer, listValues, members, reducerID, size, addMultipleNew)

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
import Replicated.Change as Change exposing (Change, Changer, Parent(..), Creator)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (I, Object, Placeholder)
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
        , memberAdder : memberType -> Change.ObjectChange
        , startWith : Changer (RepDb memberType)
        }


{-| Internal reminder that the ID of the inclusion Op is not the same as the member object's ID.
-}
type alias InclusionOpID =
    OpID


type alias Member memberType =
    { id : ID memberType -- "meta-tag"
    , value : memberType
    , remove : Change
    }


getPointer : RepDb memberType -> Change.Pointer
getPointer (RepDb repSet) =
    repSet.pointer


reducerID : Op.ReducerID
reducerID =
    "replist"


{-| Only run in codec
-}
buildFromReplicaDb : Object -> (JE.Value -> Maybe memberType) -> (memberType -> Change.ObjectChange) -> Changer (RepDb memberType) -> RepDb memberType
buildFromReplicaDb object payloadToMember memberAdder init =
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
                        { id = ID.tag (Change.ExistingObjectPointer memberObjectID identity)
                        , value = memberValue
                        , remove = remover containerObjectID eventID
                        }

                _ ->
                    Nothing

        remover containerObjectID inclusionEventID =
            Change.Chunk
                { target = Change.ExistingObjectPointer containerObjectID identity
                , objectChanges = [ Change.RevertOp inclusionEventID ]
                }
    in
    RepDb
        { pointer = Object.getPointer object
        , members = memberDict
        , memberAdder = memberAdder
        , included = Object.getIncluded object
        , startWith = init
        }



-- ACCESSORS


get : ID memberType -> RepDb memberType -> Maybe memberType
get givenID (RepDb repDbRecord) =
    case ID.read givenID of
        Change.ExistingObjectPointer objectID _ ->
            AnyDict.get (objectID) repDbRecord.members
            |> Maybe.map .value

        _ ->
            Nothing


getMember : ID memberType -> RepDb memberType -> Maybe (Member memberType)
getMember givenID (RepDb repDbRecord) =
    case ID.read givenID of
        Change.ExistingObjectPointer objectID _ ->
            AnyDict.get (objectID) repDbRecord.members

        _ ->
            Nothing


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


addNew : Creator memberType -> RepDb memberType -> Change
addNew newMemberCreator (RepDb record) =
    let
        newMember =
            newMemberCreator (ParentContext record.pointer)
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = [ record.memberAdder newMember ]
        }


addMultipleNew : Creator (List memberType) -> RepDb memberType -> Change
addMultipleNew newMembersCreator (RepDb record) =
    let
        newMembers =
            newMembersCreator (ParentContext record.pointer)
    in
    Change.Chunk
        { target = record.pointer
        , objectChanges = List.map record.memberAdder newMembers
        }


getInit : RepDb memberType -> List Change
getInit ((RepDb record) as repDb) =
    record.startWith repDb