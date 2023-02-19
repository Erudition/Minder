module Replicated.Reducer.RepDb exposing (Member, RepDb, addMultipleNew, addNew, buildFromReplicaDb, get, getInit, getMember, getPointer, listValues, members, reducerID, size)

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
import Maybe.Extra
import Replicated.Change as Change exposing (Change, ChangeSet, Changer, Creator, Parent(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| A replicated database.
-}
type RepDb memberType
    = RepDb
        { pointer : Change.Pointer
        , members : AnyDict OpID.OpIDSortable ObjectID (Member memberType)
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
        memberDict : AnyDict OpID.OpIDSortable ObjectID (Member memberType)
        memberDict =
            case Object.getCreationID object of
                Just objectID ->
                    AnyDict.foldl (addMemberFromEvent (Change.ExistingID reducerID objectID)) (AnyDict.empty OpID.toSortablePrimitives) (Object.getEvents object)

                Nothing ->
                    AnyDict.empty OpID.toSortablePrimitives

        addMemberFromEvent : Change.ExistingID -> InclusionOpID -> Object.Event -> AnyDict OpID.OpIDSortable ObjectID (Member memberType) -> AnyDict OpID.OpIDSortable ObjectID (Member memberType)
        addMemberFromEvent containerExistingID inclusionEventID event accumulatedDict =
            case
                ( Object.extractOpIDFromEventPayload event
                , payloadToMember (Object.eventPayloadAsJson event)
                )
            of
                ( Just memberObjectID, Just memberValue ) ->
                    AnyDict.insert memberObjectID
                        { id = ID.fromObjectID memberObjectID
                        , value = memberValue
                        , remove = Change.WithFrameIndex (\_ -> remover containerExistingID inclusionEventID)
                        }
                        accumulatedDict

                _ ->
                    accumulatedDict

        remover containerObjectID inclusionEventID =
            Change.changeObject
                { target = Change.ExistingObjectPointer containerObjectID
                , objectChanges = [ Change.RevertOp inclusionEventID ]
                }
                |> .changeSet
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
    case ID.getObjectID givenID of
        Just objectID ->
            AnyDict.get objectID repDbRecord.members
                |> Maybe.map .value

        _ ->
            Nothing


getMember : ID memberType -> RepDb memberType -> Maybe (Member memberType)
getMember givenID (RepDb repDbRecord) =
    case ID.getObjectID givenID of
        Just objectID ->
            AnyDict.get objectID repDbRecord.members

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
        newMember index =
            -- No need to pass creation change, will happen as part of change below
            newMemberCreator (Change.Context index (Change.becomeInstantParent record.pointer))

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = [ record.memberAdder (newMember frameIndex) ]
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


addMultipleNew : List (Creator memberType) -> RepDb memberType -> Change
addMultipleNew newMemberCreators (RepDb record) =
    let
        createWithContext frameIndex index creator =
            creator (Change.Context (Location.nest frameIndex "addMultipleNew" index) (Change.becomeInstantParent record.pointer))

        newMembers frameIndex =
            List.indexedMap (createWithContext frameIndex) newMemberCreators

        finalChangeSet frameIndex =
            Change.changeObject
                { target = record.pointer
                , objectChanges = List.map record.memberAdder (newMembers frameIndex)
                }
                |> .changeSet
    in
    Change.WithFrameIndex finalChangeSet


getInit : RepDb memberType -> ChangeSet
getInit ((RepDb record) as repDb) =
    record.startWith repDb
        |> Change.collapseChangesToChangeSet "repDbInitFrame"
