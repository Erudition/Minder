module Replicated.Collection exposing (..)

{-| Reptypes that are built from a set of changes, like registers and lists, are a `Collection` at the app level, rather than a RON Object directly.

 A collection typically maps to a single Object in RON -- you can almost always think of a Collection as just an Object.

 But it can also be a union of RON objects, which are permanently merged. This is needed in case the collection is created concurrently, in separate replicas, before the replicas know about the existence of the other object IDs.

 For example, if `organization.members` has never been set (the lazy equivalent to an empty set of person-tags), but "Alice" is added on replica A, and "Bob" is added on replica B concurrently, both replicas will create a new RON Object for the "members" set and add their members to it. There are now technically two RON objects that are intended to represent the same Collection. Until they sunc, each Replica keeps adding new members to its own Object.

 If the `organization` Register were to follow the usual "last write wins" semantics for this field, then when the Replicas finally sync, the object with a later timestamp would be rendered as the sole `organization.members` collection on both Replicas! This means the other set(s) of members are effectively overwritten.

 When a Register field has a Collection as its type, there is no need to write a new value - that happens in the nested set itself, the set being assigned to that field is permanent. So for these fields we switch to "union" semantics - the value of the field, the Collection, is a set that is the union of all the sets that have been ever assigned to it. Now the final synced result is a Collection with the set ["Alice", "Bob"], which is what we want!

 From then on, all Replicas will use the oldest ObjectID for future changes to the collection. The Objects will remain distinct at the RON level, which is okay, and even helps to recover if they're ever merged by mistake. For causal consistency, though, new RON Ops will will reference the previous Op in the Collection as it's predecessor, even if it's from a different ObjectID. (This means merges can be detectable at the RON level.)
-}

import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Nonempty as Nonempty exposing (Nonempty)
import Log
import Replicated.Change as Change exposing (ChangeSet)
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Op.Atom as RonAtom
import Replicated.Op.ID as OpID exposing (ObjectID, OpID, OpIDSortable, OpIDString)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.Payload as Payload exposing (Payload)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import SmartTime.Moment as Moment exposing (Moment)


{-| Reptypes that are built from a set of changes, like registers and lists, inherit this basic type.

-}
type Collection event
    = Saved (SavedCollection event)
    | Unsaved UnsavedCollection


type alias SavedCollection event =
    { reducer : ReducerID
    , creation : ObjectID
    , events : EventDict event
    , reversions : List Op
    , deleted : EventDict event
    , included : InclusionInfo
    , aliases : List ObjectID
    , version : OpID.ObjectVersion
    }


type alias OpDict =
    AnyDict OpID.OpIDSortable OpID Op


type alias EventDict event =
    AnyDict OpID.OpIDSortable OpID (Event event)


buildSaved : OpDict -> ( Maybe (SavedCollection event), List ObjectBuildWarning )
buildSaved opDict =
    case AnyDict.values opDict of
        [] ->
            ( Nothing, [ NoHeader ] )

        firstOp :: moreOps ->
            let
                base =
                    { reducer = Op.reducerID firstOp
                    , creation = Op.objectID firstOp
                    , events = AnyDict.empty OpID.toSortablePrimitives
                    , deleted = AnyDict.empty OpID.toSortablePrimitives
                    , reversions = []
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
applyOp : OpDict -> Op -> ( SavedCollection event, List ObjectBuildWarning ) -> ( SavedCollection event, List ObjectBuildWarning )
applyOp opDict newOp ( oldObject, oldWarnings ) =
    let
        opPayloadToEventPayload opPayload =
            case opPayload of
                [ singleAtom ] ->
                    RonAtom.toJsonValue singleAtom

                multipleAtoms ->
                    JE.list RonAtom.toJsonValue multipleAtoms
    in
    case Op.reference newOp of
        Op.OpReference ref ->
            -- op ref means it's an event op (or reversion)
            let
                ( newEventDict, newWarnings ) =
                    if OpID.isDeletion (Op.id newOp) then
                        -- this op reverts a real event
                        revertEventHelper ref oldObject.events opDict
                        -- |> Debug.log ("Op " ++ OpID.toString (Op.id newOp) ++ " reverts op " ++ OpID.toString ref ++ " in object " ++ OpID.toString oldObject.creation ++ ". new event dict")

                    else
                        ( AnyDict.insert (Op.id newOp)
                            (Event { referencedOp = ref, payload = Op.payload newOp })
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
revertEventHelper : OpID -> EventDict event -> OpDict -> ( EventDict event, List ObjectBuildWarning )
revertEventHelper opIDToRevert eventDict opDict =
    case ( AnyDict.member opIDToRevert eventDict, OpID.isDeletion opIDToRevert ) of
        ( True, _ ) ->
            -- found our reverted event. remove it!
            ( AnyDict.remove opIDToRevert eventDict, [] )

        ( False, True ) ->
            -- the reverted op points to a reversion op. go get the second one it points to
            case AnyDict.get opIDToRevert opDict of
                Nothing ->
                    ( eventDict, [ UnknownReference (Log.log "unknown op ID to revert" opIDToRevert) ] )

                Just secondReversionOp ->
                    -- we found the reversion op that should be reverted!
                    case Op.reference secondReversionOp of
                        Op.ReducerReference _ ->
                            -- impossible, creation ops can't be reversion ops.
                            Log.crashInDev "Tried to revert a creation op!" ( eventDict, [ UnknownReference opIDToRevert ] )

                        Op.OpReference thirdOpID ->
                            -- does the second reversion op point to a third reversion op?
                            if OpID.isDeletion thirdOpID then
                                -- yup. start over with that one.
                                revertEventHelper thirdOpID eventDict opDict

                            else
                                -- nope, normal op! assume it was a former event of ours. go get it
                                case AnyDict.get thirdOpID opDict of
                                    Just opToReinstate ->
                                        case Op.reference opToReinstate of
                                            Op.ReducerReference _ ->
                                                -- impossible, creation ops can't be events, nor can they be reverted.
                                                Log.crashInDev "Tried to unrevert a creation op!" ( eventDict, [ UnknownReference opIDToRevert ] )

                                            Op.OpReference referenceOfThirdOp ->
                                                ( AnyDict.insert (Op.id opToReinstate)
                                                    (Event { referencedOp = referenceOfThirdOp, payload = Op.payload opToReinstate })
                                                    eventDict
                                                , []
                                                )

                                    Nothing ->
                                        ( eventDict, [ UnknownReference thirdOpID ] )

        ( False, False ) ->
            ( eventDict, [ UnknownReference (Log.log "couldn't find op to revert" opIDToRevert) ] )


type ObjectBuildWarning
    = NoHeader
    | UnknownReference OpID


type alias UnsavedCollection =
    { reducer : ReducerID
    , parent : Change.Parent
    , position : Location
    }


getCreationID : Collection event -> Maybe ObjectID
getCreationID object =
    case object of
        Saved initializedObject ->
            Just initializedObject.creation

        Unsaved uninitializedObject ->
            Nothing


getPointer : Collection event -> Change.Pointer
getPointer object =
    case object of
        Saved savedCollection ->
            Change.ExistingObjectPointer (Change.ExistingID savedCollection.reducer savedCollection.creation)

        Unsaved unsavedCollection ->
            Change.newPointer { parent = unsavedCollection.parent, position = unsavedCollection.position, reducerID = unsavedCollection.reducer }


getIncluded : Collection event -> InclusionInfo
getIncluded object =
    case object of
        Saved initializedObject ->
            initializedObject.included

        Unsaved uninitializedObject ->
            All


getReducer : Collection event -> ReducerID
getReducer object =
    case object of
        Saved initializedObject ->
            initializedObject.reducer

        Unsaved uninitializedObject ->
            uninitializedObject.reducer


getEvents : Collection event -> EventDict event
getEvents object =
    case object of
        Saved initializedObject ->
            initializedObject.events

        Unsaved uninitializedObject ->
            AnyDict.empty OpID.toSortablePrimitives


type alias EventPayload =
    Payload


{-| An object update that has not been reverted. Reversion ops themselves are not included, so Object Events are always the type of op the reducer is expecting to work with.
-}
type
    Event event
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = Event { referencedOp : OpID, payload : event }


eventReference : Event event -> OpID
eventReference (Event event) =
    event.referencedOp


eventPayload : Event event -> event
eventPayload (Event event) =
    event.payload


eventPayloadAsJson : Event event -> JE.Value
eventPayloadAsJson (Event event) =
    case List.map Op.atomToJsonValue event.payload of
        [] ->
            JE.null

        [ single ] ->
            single

        multiple ->
            JE.list identity multiple


extractOpIDFromEventPayload : Event event -> Maybe OpID
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
    = OpDecodeFailed OpIDString Payload
