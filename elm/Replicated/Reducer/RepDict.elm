module Replicated.Reducer.RepDict exposing (RepDict, RepDictEntry(..), buildFromReplicaDb, empty, getID, insertNew, insertNewWithChanges, list, reducerID, remove, update)

import Array exposing (Array)
import Console
import Dict
import Dict.Any as AnyDict exposing (AnyDict)
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
type RepDict k v
    = RepDict
        { id : Change.Pointer
        , members : AnyDict String k (Member v)
        , included : Object.InclusionInfo
        , memberChanger : RepDictEntry k v -> Change.ObjectChange
        , memberGenerator : () -> Maybe v
        }


empty : RepDict k v
empty =
    RepDict
        { id = Change.PlaceholderPointer reducerID (Change.usePendingCounter 0 Change.unmatchableCounter).id identity
        , members = AnyDict.empty (\_ -> "")
        , included = Object.All
        , memberChanger =
            \memberType -> Change.NewPayload <| List.singleton (Change.RonAtom (Op.NakedStringAtom "uninitialized"))
        , memberGenerator = \() -> Nothing
        }


type RepDictEntry k v
    = Present k v
    | Cleared k


type alias Member v =
    { handle : Handle
    , value : v
    }


getID : RepDict k v -> Change.Pointer
getID (RepDict repSet) =
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
buildFromReplicaDb : Node -> Change.Pointer -> (JE.Value -> Maybe (RepDictEntry k v)) -> (RepDictEntry k v -> Change.ObjectChange) -> (k -> String) -> RepDict k v
buildFromReplicaDb node targetObject payloadToEntry memberChanger keyToString =
    let
        existingObjectMaybe =
            case targetObject of
                Change.ExistingObjectPointer objectID ->
                    Node.getObjectIfExists node [ objectID ]

                _ ->
                    Nothing

        eventsAsMemberPairs : List ( k, Member v )
        eventsAsMemberPairs =
            case existingObjectMaybe of
                Just foundObject ->
                    List.filterMap eventToMemberPair (Dict.values foundObject.events)

                Nothing ->
                    []

        eventToMemberPair : Object.KeptEvent -> Maybe ( k, Member v )
        eventToMemberPair event =
            case payloadToEntry (Object.eventPayloadAsJson event) of
                Just (Present key val) ->
                    Just
                        ( key
                        , { handle = OpID.toString (Object.eventID event)
                          , value = val
                          }
                        )

                _ ->
                    Nothing

        generateMemberValue _ =
            case payloadToEntry (JE.string "{}") of
                Just (Present k v) ->
                    Just v

                _ ->
                    Nothing
    in
    RepDict
        { id = targetObject
        , members = AnyDict.fromList keyToString eventsAsMemberPairs
        , memberChanger = memberChanger
        , memberGenerator = generateMemberValue
        , included = Maybe.map .included existingObjectMaybe |> Maybe.withDefault Object.All
        }



-- ACCESSORS


{-| Get an a member as an `Member`, which gives you access to its `Handle`.
-}
get : k -> RepDict k v -> Maybe v
get key repDict =
    Maybe.map .value (getMember key repDict)


{-| Get your RepDict as a read-only List.
-}
list : RepDict k v -> List ( k, v )
list repDict =
    List.map (\( k, v ) -> ( k, v.value )) (listMembers repDict)


{-| Get an a member as an `Member`, which gives you access to its `Handle`.
-}
getMember : k -> RepDict k v -> Maybe (Member v)
getMember key ((RepDict record) as repDict) =
    AnyDict.get key record.members


{-| Get your RepDict as a read-only List, with values wrapped in `Member` records so you still have access to the handle
-}
listMembers : RepDict k v -> List ( k, Member v )
listMembers (RepDict repSetRecord) =
    AnyDict.toList repSetRecord.members


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : k -> (Maybe v -> Maybe v) -> RepDict k v -> Change
update key updater ((RepDict record) as repDict) =
    let
        oldValueMaybe =
            get key repDict

        updatedEntry =
            case updater oldValueMaybe of
                Just newValue ->
                    Present key newValue

                Nothing ->
                    Cleared key

        newMemberAsObjectChange =
            record.memberChanger updatedEntry
    in
    Change.Chunk
        { target = record.id
        , objectChanges = [ newMemberAsObjectChange ]
        }


remove : RepDict k v -> Handle -> Change
remove (RepDict record) itemToRemove =
    Change.Chunk
        { target = record.id
        , objectChanges =
            [ Change.RevertOp (memberIDToOpID itemToRemove) ]
        }


size : RepDict k v -> Int
size (RepDict record) =
    AnyDict.size record.members


insertNew : k -> RepDict k v -> Change
insertNew key repDict =
    insertNewWithChanges key (\_ -> []) repDict


insertNewWithChanges : k -> (v -> List Change) -> RepDict k v -> Change
insertNewWithChanges key valueChanger (RepDict record) =
    let
        newMemberMaybe =
            record.memberGenerator ()

        newMemberChanges =
            case newMemberMaybe of
                Nothing ->
                    []

                Just newMember ->
                    valueChanger newMember
                        -- combining here is necessary for now because wrapping the end result in the parent replist changer makes us not able to group
                        |> Change.combineChangesOfSameTarget

        newMemberChangesAsRepDictObjectChanges =
            List.map (Change.NewPayload << Change.changeToChangePayload) newMemberChanges

        finalChangeList =
            case ( newMemberChangesAsRepDictObjectChanges, newMemberMaybe ) of
                ( [], Just newMember ) ->
                    -- effectively a no-op so the member object will still initialize
                    [ record.memberChanger (Present key newMember) ]

                ( [], Nothing ) ->
                    Log.crashInDev "Should never happen, no item generated to add to list" []

                ( nonEmptyChangeList, _ ) ->
                    newMemberChangesAsRepDictObjectChanges
    in
    Change.Chunk
        { target = record.id
        , objectChanges =
            finalChangeList
        }
