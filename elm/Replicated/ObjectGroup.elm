module Replicated.ObjectGroup exposing (..)

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


{-| The most generic "object", to be inherited by other replicated data types for specific functionality.
-}
type ObjectGroup
    = Saved SavedObjectGroup
    | Unsaved UnsavedObject


type alias SavedObjectGroup =
    { reducer : ReducerID
    , creation : ObjectID
    , events : EventDict
    , included : InclusionInfo
    , aliases : List ObjectID
    , version : OpID.ObjectVersion
    }


type alias OpDict =
    AnyDict OpID.OpIDSortable OpID Op


type alias EventDict =
    AnyDict OpID.OpIDSortable OpID Event


buildSavedObject : OpDict -> ( Maybe SavedObjectGroup, List ObjectBuildWarning )
buildSavedObject opDict =
    case AnyDict.values opDict of
        [] ->
            ( Nothing, [ NoHeader ] )

        firstOp :: moreOps ->
            let
                base =
                    { reducer = Op.reducerID firstOp
                    , creation = Op.objectID firstOp
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
applyOp : OpDict -> Op -> ( SavedObjectGroup, List ObjectBuildWarning ) -> ( SavedObjectGroup, List ObjectBuildWarning )
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
revertEventHelper : OpID -> EventDict -> OpDict -> ( EventDict, List ObjectBuildWarning )
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


type alias UnsavedObject =
    { reducer : ReducerID
    , parent : Change.Parent
    , position : Location
    }


getCreationID : ObjectGroup -> Maybe ObjectID
getCreationID object =
    case object of
        Saved initializedObject ->
            Just initializedObject.creation

        Unsaved uninitializedObject ->
            Nothing


getPointer : ObjectGroup -> Change.Pointer
getPointer object =
    case object of
        Saved savedObject ->
            Change.ExistingObjectPointer (Change.ExistingID savedObject.reducer savedObject.creation)

        Unsaved unsavedObject ->
            Change.newPointer { parent = unsavedObject.parent, position = unsavedObject.position, reducerID = unsavedObject.reducer }


getIncluded : ObjectGroup -> InclusionInfo
getIncluded object =
    case object of
        Saved initializedObject ->
            initializedObject.included

        Unsaved uninitializedObject ->
            All


getReducer : ObjectGroup -> ReducerID
getReducer object =
    case object of
        Saved initializedObject ->
            initializedObject.reducer

        Unsaved uninitializedObject ->
            uninitializedObject.reducer


getEvents : ObjectGroup -> EventDict
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
    Event
    -- TODO do we want a separate type of event for "summaries"? or an isSummary field?
    = Event { referencedOp : OpID, payload : EventPayload }


eventReference : Event -> OpID
eventReference (Event event) =
    event.referencedOp


eventPayload : Event -> EventPayload
eventPayload (Event event) =
    event.payload


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
    = OpDecodeFailed OpIDString Payload
