module Replicated.Object exposing (..)

import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Nonempty as Nonempty exposing (Nonempty)
import Log
import Replicated.Change as Change exposing (Change)
import Replicated.Op.Op as Op exposing (Op, OpPayloadAtoms)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDSortable, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| The most generic "object", to be inherited by other replicated data types for specific functionality.
-}
type Object
    = Saved SavedObject
    | Unsaved UnsavedObject


type alias SavedObject =
    { reducer : Op.ReducerID
    , creation : ObjectID
    , events : EventDict
    , included : InclusionInfo
    , aliases : List ObjectID
    , version : OpID.ObjectVersion
    }


type Placeholder
    = Placeholder


type I
    = Initialized


type alias OpDict =
    AnyDict OpID.OpIDSortable OpID Op


type alias EventDict =
    AnyDict OpID.OpIDSortable OpID Event


buildSavedObject : OpDict -> ( Maybe SavedObject, List ObjectBuildWarning )
buildSavedObject opDict =
    case AnyDict.values opDict of
        [] ->
            ( Nothing, [ NoHeader ] )

        firstOp :: moreOps ->
            let
                base =
                    { reducer = Op.reducer firstOp
                    , creation = Op.object firstOp
                    , events = AnyDict.empty OpID.toSortablePrimitives
                    , included = All -- TODO
                    , version = Op.id firstOp
                    , aliases = []
                    }

                ( outputObject, outputWarnings ) =
                    List.foldl (applyOp opDict) ( base, [] ) moreOps
            in
            ( Just outputObject, outputWarnings )


{-| Apply an incoming Op to an object if we have it.
Ops must have a reference.
-}
applyOp : OpDict -> Op -> ( SavedObject, List ObjectBuildWarning ) -> ( SavedObject, List ObjectBuildWarning )
applyOp opDict newOp ( oldObject, oldWarnings ) =
    let
        opPayloadToEventPayload opPayload =
            case opPayload of
                [ singleAtom ] ->
                    Op.atomToJsonValue singleAtom

                multipleAtoms ->
                    JE.list Op.atomToJsonValue multipleAtoms
    in
    case Op.reference newOp of
        Op.OpReference ref ->
            -- op ref means it's an event op (or reversion)
            let
                ( newEventDict, newWarnings ) =
                    if Op.pattern newOp == Op.DeletionOp then
                        -- this op reverts a real event
                        revertEventHelper ref oldObject.events opDict

                    else
                        ( AnyDict.insert (Op.id newOp)
                            (Event { referencedOp = ref, reverted = False, payload = Op.payload newOp })
                            oldObject.events
                        , []
                        )
            in
            ( { reducer = oldObject.reducer
              , creation = oldObject.creation
              , events = newEventDict
              , included = oldObject.included
              , version = Op.id newOp -- assuming running in chrono order
              , aliases = oldObject.aliases
              }
            , oldWarnings ++ newWarnings
            )

        Op.ReducerReference reducerID ->
            -- reducer ref means it's a header op, add to aliases
            ( { oldObject | aliases = Op.id newOp :: oldObject.aliases }, oldWarnings )


{-| Internal function to find the event to revert.
-}
revertEventHelper : OpID -> EventDict -> OpDict -> ( EventDict, List ObjectBuildWarning )
revertEventHelper ref eventDict opDict =
    case AnyDict.get ref eventDict of
        Just foundEventToRevert ->
            ( AnyDict.insert ref (revertEvent foundEventToRevert) eventDict, [] )

        Nothing ->
            -- maybe the op reverts another reversion op, rather than an event directly
            case AnyDict.get ref opDict of
                Nothing ->
                    ( eventDict, [ UnknownReference ref ] )

                Just referencedOp ->
                    case Op.reference referencedOp of
                        Op.ReducerReference _ ->
                            Log.crashInDev "Tried to revert a creation op!" ( eventDict, [ UnknownReference ref ] )

                        Op.OpReference opID ->
                            -- recursively find the event to revert
                            revertEventHelper opID eventDict opDict


type ObjectBuildWarning
    = NoHeader
    | UnknownReference OpID


type alias UnsavedObject =
    { reducer : Op.ReducerID
    , parent : Change.Pointer
    , childWrapper : Change.ParentNotifier
    , position : Nonempty Change.SiblingIndex
    }


getCreationID : Object -> Maybe ObjectID
getCreationID object =
    case object of
        Saved initializedObject ->
            Just initializedObject.creation

        Unsaved uninitializedObject ->
            Nothing


getPointer : Object -> Change.Pointer
getPointer object =
    case object of
        Saved savedObject ->
            Change.ExistingObjectPointer savedObject.creation

        Unsaved unsavedObject ->
            Change.newPointer { parent = unsavedObject.parent, position = unsavedObject.position, childChangeWrapper = unsavedObject.childWrapper, reducerID = unsavedObject.reducer }


getIncluded : Object -> InclusionInfo
getIncluded object =
    case object of
        Saved initializedObject ->
            initializedObject.included

        Unsaved uninitializedObject ->
            All


getReducer : Object -> Op.ReducerID
getReducer object =
    case object of
        Saved initializedObject ->
            initializedObject.reducer

        Unsaved uninitializedObject ->
            uninitializedObject.reducer


getEvents : Object -> EventDict
getEvents object =
    case object of
        Saved initializedObject ->
            initializedObject.events

        Unsaved uninitializedObject ->
            AnyDict.empty OpID.toSortablePrimitives


type alias EventPayload =
    Op.OpPayloadAtoms


{-| An event that has not been undone/deleted.
-}
type
    Event
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = Event { referencedOp : OpID, reverted : Bool, payload : EventPayload }


eventReference : Event -> OpID
eventReference (Event event) =
    event.referencedOp


eventPayload : Event -> EventPayload
eventPayload (Event event) =
    event.payload


eventReverted : Event -> Bool
eventReverted (Event event) =
    event.reverted


revertEvent : Event -> Event
revertEvent (Event event) =
    Event { event | reverted = not event.reverted }


eventPayloadAsJson : Event -> JE.Value
eventPayloadAsJson (Event event) =
    case List.map Op.atomToJsonValue event.payload of
        [] ->
            JE.null

        [ single ] ->
            single

        multiple ->
            JE.list identity multiple


extractOpIDFromEventPayload : Event -> Maybe OpID
extractOpIDFromEventPayload (Event event) =
    case event.payload of
        [ Op.IDPointerAtom opID ] ->
            Just opID

        other ->
            Log.crashInDev ("item was supposed to be a single OpID pointer, but instead found " ++ Debug.toString other) Nothing


type InclusionInfo
    = All
    | EverythingAfter Moment
    | LatestSnapshotOnly


type ReducerWarning
    = OpDecodeFailed OpIDString OpPayloadAtoms
