module Replicated.Change exposing (..)

import Console
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID)


{-| Represents a _POTENTIAL_ change to the node - if you have one, you can "apply" your pending changes to make actual modifications to your model.

Outputs a Chunk - Chunks are same-object changes within a Frame.

-}
type Change
    = Change ChangeSet


changeSetFromOldChange :
    Op.ReducerID ->
    { target : Pointer
    , objectChanges : List ObjectChange
    , externalUpdates : List Change
    }
    -> Change
changeSetFromOldChange reducerID { target, objectChanges, externalUpdates } =
    let
        withExternalChanges thisSet =
            List.foldl mergeChangeSets thisSet externalUpdates
    in
    case target of
        ExistingObjectPointer objectID installer ->
            Change
                { existingObjectChanges = AnyDict.singleton (reducerID, objectID) objectChanges (existingObjectToComparable)
                , objectsToCreate = AnyDict.empty pendingToComparable
                , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
                }
                |> withExternalChanges

        PlaceholderPointer pendingID installer ->
            let
                creationInstructions =
                    { objectChanges = objectChanges
                    , afterCreation = \_ -> Debug.todo "afterCreation"
                    }
            in
            Change
                { existingObjectChanges = AnyDict.empty existingObjectToComparable
                , objectsToCreate = AnyDict.singleton pendingID creationInstructions pendingToComparable
                , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
                }
                |> withExternalChanges

existingObjectToComparable : (Op.ReducerID, ObjectID) -> String
existingObjectToComparable (reducerID, objectID) = 
    reducerID ++ OpID.toString objectID

pendingToComparable : PendingID -> (Op.ReducerID, PendingLocationString)
pendingToComparable pID =
    ( pID.reducer, pendingObjectLocationToString pID.location )

mergeChangeSets : Change -> Change -> Change
mergeChangeSets (Change changeSetA) (Change changeSetB) =
    Change
        { existingObjectChanges = AnyDict.union changeSetA.existingObjectChanges changeSetB.existingObjectChanges
        , objectsToCreate = AnyDict.union changeSetA.objectsToCreate changeSetB.objectsToCreate
        , opsToRepeat = AnyDict.union changeSetA.opsToRepeat changeSetB.opsToRepeat
        }


type alias ChangeSet =
    { objectsToCreate : AnyDict ( Op.ReducerID, PendingLocationString ) PendingID ObjectCreation
    , existingObjectChanges : AnyDict String (Op.ReducerID, ObjectID) (List ObjectChange)
    , opsToRepeat : OpDb
    }


type alias ObjectCreation =
    { objectChanges : List ObjectChange
    , afterCreation : ObjectID -> Change
    }


type ChangeWithNecessity
    = Skippable PotentialPayload
    | Necessary PotentialPayload

skippableIf : Bool -> PotentialPayload -> ChangeWithNecessity
skippableIf unchanged =
    if unchanged then Skippable else Necessary
 

mapNecessity mapper wrapped =
    case wrapped of
        Skippable payload ->
            Skippable (mapper payload)

        Necessary payload ->
            Necessary (mapper payload)


unwrapSkippability wrapped =
    case wrapped of
        Skippable payload ->
            payload

        Necessary payload ->
            payload


type alias OpDb =
    AnyDict OpID.OpIDSortable OpID Op


type alias Changer o =
    o -> List Change


type alias Creator a =
    Parent -> a


{-| Atoms to use in the final change
-}
type alias PotentialPayload =
    Nonempty ChangeAtom


type ObjectChange
    = NewPayload PotentialPayload
    | NewPayloadWithRef { payload : PotentialPayload, ref : OpID }
    | RevertOp OpID


type alias PendingID =
    { reducer : Op.ReducerID
    , location : PendingObjectLocation
    }


type ChangeAtom
    = JsonValueAtom JE.Value
    | RonAtom Op.OpPayloadAtom
    | QuoteNestedObject Pointer Change
    | NestedAtoms PotentialPayload
    | PendingObjectReferenceAtom PendingID


-- compareToRonPayload : PotentialPayload -> Op.OpPayloadAtoms -> Bool
-- compareToRonPayload changePayload ronPayload =
--     case ( Nonempty.toList changePayload, ronPayload ) of
--         ( [ JsonValueAtom valueJE ], [ ronAtom ] ) ->
--             Op.atomToJsonValue ronAtom == valueJE

--         ( [ RonAtom ronAtom1 ], [ ronAtom2 ] ) ->
--             ronAtom1 == ronAtom2

--         ( [ QuoteNestedObject (ChangeSet { target, objectChanges }) ], [ ronAtom ] ) ->
--             case ( target, objectChanges ) of
--                 ( ExistingObjectPointer objectID _, [] ) ->
--                     -- see if it's just a ref to the same object. TODO: necessary?
--                     String.contains (OpID.toString objectID) (Op.atomToRonString ronAtom)

--                 _ ->
--                     -- can't match if object does not exist yet, or there are changes to make.
--                     False

--         ( [ NestedAtoms payload ], _ ) ->
--             False

--         -- TODO
--         ( unhandledChange, unhandledOpPayload ) ->
--             Debug.todo <| "When updating a register I needed to check if " ++ Debug.toString unhandledChange ++ " was equivalent to " ++ Debug.toString unhandledOpPayload ++ " to see if the change is the default value - but you unimaginatively did not handle that case, go add it..."


payloadFromNested : Pointer -> Change -> PotentialPayload
payloadFromNested pointer change =
    Nonempty.singleton (QuoteNestedObject pointer change)


-- {-| This only needs to be called once, when changes are saved. calling any other place is redundant
-- -}
-- combineChangesOfSameTarget changeList =
--     -- bundle together changes that have the same target object
--     List.map groupCombiner (List.Extra.groupWhile sameTarget changeList)


-- sameTarget (ChangeSet a) (ChangeSet b) =
--     equalPointers a.target b.target


-- groupCombiner ( firstChange, moreChanges ) =
--     -- for each grouping, fold multiple changes together
--     case moreChanges of
--         [] ->
--             firstChange

--         rest ->
--             -- can't use foldR because it reverses the whole list EXCEPT the head, shuffling the change order. instead we preserve the backwards order and reverse subchanges in mergeSameTargetChanges if need be.
--             List.foldl mergeSameTargetChanges firstChange rest


-- {-| Combine chunks known to be changing the same object.
-- -}
-- mergeSameTargetChanges (ChangeSet change1Details) (ChangeSet change2Details) =
--     ChangeSet
--         { target = change1Details.target
--         , objectChanges = change2Details.objectChanges ++ change1Details.objectChanges -- reverses subchanges again.
--         , externalUpdates = change2Details.externalUpdates ++ change1Details.externalUpdates
--         }



-- CHANGEFRAMES


type Frame
    = Frame
        { normalizedChanges : List Change
        , description : String
        }


saveChanges : String -> List Change -> Frame
saveChanges description changes =
    Log.log (Console.blue "Saving Changes:") <| Frame { normalizedChanges = changes, description = description }


{-| An empty Frame, for when you have no changes to save.
-}
none : Frame
none =
    Frame { normalizedChanges = [], description = "Empty Frame" }


isEmpty : Frame -> Bool
isEmpty (Frame { normalizedChanges }) =
    List.isEmpty normalizedChanges


nonEmptyFrames : List Frame -> List Frame
nonEmptyFrames frames =
    List.filter (not << isEmpty) frames


-- {-| Since the user can get changes from anywhere and batch them together, we need to make sure that the same object isn't changed multiple times in separate entries, to optimize RON chain output (all same-object changes should be in a row). So we add them to a Dict to make sure all chunks are unique, combining contents if need be.

-- We also may have a change that targets a placeholder, and needs to modify the parent, and maybe the parent's parent, etc to include the nested object once initialized. This should also be merged with other disparate changes to those parent objects, so we add them to the dictionary at the highest level (the object that actually exists is the change, wrapping all nested changes). This causes placeholders to properly notify their parents, while also making sure the dict merges changes at the same level. Otherwise, given changes A, B, C, C, D where B contains a nested change to D, the C changes will merge but the D changes will not.

-- -}
-- normalizeChanges : List Change -> List Change
-- normalizeChanges changesToNormalize =
--     combineChangesOfSameTarget changesToNormalize
--         |> List.map wrapInParentNotifier
--         |> combineChangesOfSameTarget





-- wrapInParentNotifier : Change -> Change
-- wrapInParentNotifier ((ChangeSet chunkDetails) as originalChange) =
--     case chunkDetails.target of
--         ExistingObjectPointer objectID installer ->
--             let
--                 changeWithoutNotifier =
--                     -- to make sure we never wrap twice for some reason
--                     ChangeSet { chunkDetails | target = ExistingObjectPointer objectID identity }

--                 wrappedChange =
--                     installer changeWithoutNotifier
--             in
--             wrappedChange

--         PlaceholderPointer pendingID installer ->
--             let
--                 changeWithoutNotifier =
--                     -- to make sure we never wrap twice for some reason
--                     ChangeSet { chunkDetails | target = PlaceholderPointer pendingID identity }

--                 wrappedChange =
--                     installer changeWithoutNotifier
--             in
--             wrappedChange



-- POINTERS


type Pointer
    = ExistingObjectPointer ObjectID Installer
    | PlaceholderPointer PendingID Installer


equalPointers pointer1 pointer2 =
    case ( pointer1, pointer2 ) of
        ( ExistingObjectPointer objectID1 _, ExistingObjectPointer objectID2 _ ) ->
            objectID1 == objectID2

        ( PlaceholderPointer pendingID1 _, PlaceholderPointer pendingID2 _ ) ->
            pendingID1.reducer == pendingID2.reducer && pendingLocationMatch pendingID1.location pendingID2.location

        _ ->
            False


isPlaceholder pointer =
    case pointer of
        PlaceholderPointer _ _ ->
            True

        _ ->
            False


getPointerObjectID pointer =
    case pointer of
        PlaceholderPointer _ _ ->
            Nothing

        ExistingObjectPointer objectID _ ->
            Just objectID


type alias Installer =
    Change -> Change


type PendingCounter
    = PendingCounter (List SiblingIndex)
    | PendingWildcard


type PendingObjectLocation
    = ParentExists ObjectID (Nonempty SiblingIndex)
    | ParentPending Op.ReducerID (Nonempty SiblingIndex)
    | ParentIsRoot


type alias PendingLocationString =
    String


pendingObjectLocationToString : PendingObjectLocation -> PendingLocationString
pendingObjectLocationToString pendingID =
    case pendingID of
        ParentExists objectID _ ->
            OpID.toString objectID

        ParentPending reducerID siblings ->
            reducerID ++ String.join " " (Nonempty.toList siblings)

        ParentIsRoot ->
            "root"


type alias SiblingIndex =
    String


pendingLocationMatch : PendingObjectLocation -> PendingObjectLocation -> Bool
pendingLocationMatch pendingID1 pendingID2 =
    pendingID1 == pendingID2


newPointer : { parent : Pointer, position : Nonempty SiblingIndex, reducerID : Op.ReducerID } -> Pointer
newPointer { parent, position, reducerID } =
    case parent of
        ExistingObjectPointer objectID installer ->
            PlaceholderPointer (PendingID reducerID (ParentExists objectID position)) installer

        PlaceholderPointer pendingID installer ->
            case pendingID.location of
                ParentExists parentObjectID parentPosition ->
                    PlaceholderPointer (PendingID reducerID (ParentPending pendingID.reducer (Nonempty.append position parentPosition))) installer

                ParentPending grandparentReducerID parentPosition ->
                    PlaceholderPointer (PendingID reducerID (ParentPending pendingID.reducer (Nonempty.append position parentPosition))) installer

                ParentIsRoot ->
                    PlaceholderPointer (PendingID reducerID (ParentPending pendingID.reducer position)) installer


genesisPointer : Pointer
genesisPointer =
    PlaceholderPointer (PendingID "genesis" ParentIsRoot) identity


updateChildChangeWrapper : Pointer -> Installer -> Pointer
updateChildChangeWrapper pointer newWrapper =
    case pointer of
        ExistingObjectPointer objectID installer ->
            ExistingObjectPointer objectID (\change -> installer (newWrapper change))

        PlaceholderPointer pendingID installer ->
            -- oops, careful, this was backwards before, the new wrapper needs to be inserted before the outer parent wrapper
            PlaceholderPointer pendingID (\change -> installer (newWrapper change))


type Parent
    = ParentContext Pointer
