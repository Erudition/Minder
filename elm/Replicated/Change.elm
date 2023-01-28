module Replicated.Change exposing (Change(..), Changer, ComplexAtom(..), ComplexPayload, Creator, ExistingID, Frame(..), ObjectChange(..), Parent, PendingID, Pointer(..), PrimitiveAtom(..), PrimitivePayload, SiblingIndex, SoloObjectEncoded, becomeDelayedParent, becomeInstantParent, changeObject, changeObjectWithExternal, complexFromSolo, emptyChange, genesisParent, genesisPointer, getPointerObjectID, newPointer, nonEmptyFrames, none, pendingIDToComparable, primitiveAtomToRonAtom, primitiveAtomToString, saveChanges, isPlaceholder, pendingIDToString)

import Console
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID)


{-| Represents a _POTENTIAL_ change to the node - if you have one, you can "apply" your pending changes to make actual modifications to your model.

Outputs a Chunk - Chunks are same-object changes within a Frame.

-}
type Change
    = Change ChangeSet


existingIDToComparable : ExistingID -> (Op.ReducerID, OpID.ObjectIDString)
existingIDToComparable { reducer, object } =
    (reducer, OpID.toString object)


pendingIDToComparable : PendingID -> List String
pendingIDToComparable pendingID =
    let 
        (parent, ancestors) =
            case pendingID.location of
                ParentExists objectID siblings ->
                    (OpID.toString objectID, Nonempty.toList siblings)

                ParentPending reducerID siblings ->
                    (reducerID, (Nonempty.toList siblings))

                ParentIsRoot ->
                    ("root", [])
    in
    [ pendingID.reducer, parent ] ++ List.reverse ancestors


pendingIDToString : PendingID -> String
pendingIDToString pendingID =
    String.join " -> " (pendingIDToComparable pendingID)

mergeChanges : Change -> Change -> Change
mergeChanges (Change changeSetA) (Change changeSetB) =
    Change
        { existingObjectChanges = AnyDict.union changeSetA.existingObjectChanges changeSetB.existingObjectChanges
        , objectsToCreate = AnyDict.union changeSetA.objectsToCreate changeSetB.objectsToCreate
        , opsToRepeat = AnyDict.union changeSetA.opsToRepeat changeSetB.opsToRepeat
        }


mergeMaybeChange : Maybe Change -> Change -> Change
mergeMaybeChange maybeChange change =
    case maybeChange of
        Just changeToMerge ->
            mergeChanges changeToMerge change

        Nothing ->
            change


type alias ChangeSet =
    { objectsToCreate : AnyDict (List String) PendingID (List ObjectChange)
    , existingObjectChanges : AnyDict (Op.ReducerID, OpID.ObjectIDString) ExistingID (List ObjectChange)
    , opsToRepeat : OpDb
    }


emptyChange : Change
emptyChange =
    Change <|
        { existingObjectChanges = AnyDict.empty existingIDToComparable
        , objectsToCreate = AnyDict.empty pendingIDToComparable
        , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
        }


type alias OpDb =
    AnyDict OpID.OpIDSortable OpID Op


type alias Changer o =
    o -> List Change


type alias Creator a =
    Parent -> a


type ObjectChange
    = NewPayload ComplexPayload
    | NewPayloadWithRef { payload : ComplexPayload, ref : OpID }
    | RevertOp OpID


type alias PendingID =
    { reducer : Op.ReducerID
    , location : PendingObjectLocation
    }


type alias ExistingID =
    { reducer : Op.ReducerID
    , object : ObjectID
    }



-- PRIMITIVE PAYLOADS


{-| Full payload when an encoder only produces primitives - no ID references, no nested changes.
These can be used for e.g. dictionary keys.
-}
type alias PrimitivePayload =
    Nonempty PrimitiveAtom


{-| Simple change encoder atoms, to be converted to RON - no standalone objects or references.
-}
type PrimitiveAtom
    = NakedStringAtom String
    | StringAtom String
    | IntegerAtom Int
    | FloatAtom Float


complexFromPrimitive : PrimitivePayload -> ComplexPayload
complexFromPrimitive primitivePayload =
    Nonempty.map FromPrimitiveAtom primitivePayload


primitiveAtomToRonAtom : PrimitiveAtom -> Op.OpPayloadAtom
primitiveAtomToRonAtom primitiveAtom =
    case primitiveAtom of
        NakedStringAtom ns ->
            Op.NakedStringAtom ns

        StringAtom s ->
            Op.StringAtom s

        IntegerAtom i ->
            Op.IntegerAtom i

        FloatAtom f ->
            Op.FloatAtom f


primitiveAtomToString : PrimitiveAtom -> String
primitiveAtomToString primitiveAtom =
    case primitiveAtom of
        NakedStringAtom ns ->
            ns

        StringAtom s ->
            s

        IntegerAtom i ->
            String.fromInt i

        FloatAtom f ->
            String.fromFloat f



-- SOLO OBJECT PAYLOADS --------------------------------------


{-| For encoders that output embedded objects.
If there are no changes to make yet (only an object to init), we can indicate to the parent that this change is skippable.
-}
type alias SoloObjectEncoded =
    { toReference : Pointer
    , change : Change
    , skippable : Bool
    }


complexFromSolo : SoloObjectEncoded -> ComplexPayload
complexFromSolo solo =
    Nonempty.singleton (QuoteNestedObject solo)


changeObject :
    { target : Pointer
    , objectChanges : List ObjectChange
    }
    -> SoloObjectEncoded
changeObject { target, objectChanges } =
    changeObjectWithExternal { target = target, objectChanges = objectChanges, externalUpdates = [] }


changeObjectWithExternal :
    { target : Pointer
    , objectChanges : List ObjectChange
    , externalUpdates : List Change
    }
    -> SoloObjectEncoded
changeObjectWithExternal { target, objectChanges, externalUpdates } =
    let
        withExternalChanges thisSet =
            List.foldl mergeChanges thisSet externalUpdates

        finalChange =
            case target of
                ExistingObjectPointer existingID ->
                    Change
                        { existingObjectChanges = AnyDict.singleton existingID objectChanges existingIDToComparable
                        , objectsToCreate = AnyDict.empty pendingIDToComparable
                        , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
                        }
                        |> withExternalChanges

                PlaceholderPointer pendingID ancestorsInstallChangeMaybe ->
                    Change
                        { existingObjectChanges = AnyDict.empty existingIDToComparable
                        , objectsToCreate = AnyDict.singleton pendingID objectChanges pendingIDToComparable
                        , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
                        }
                        -- |> mergeMaybeChange ancestorsInstallChangeMaybe
                        |> withExternalChanges
    in
    { toReference = target
    , change = finalChange
    , skippable = List.isEmpty objectChanges && List.isEmpty externalUpdates
    }



-- COMPLEX PAYLOADS ---------------------------------------


{-| Change encoder atoms, which supports references and nested object changes.
-}
type ComplexAtom
    = FromPrimitiveAtom PrimitiveAtom
    | PendingObjectReferenceAtom PendingID
    | ExistingObjectReferenceAtom ObjectID
    | QuoteNestedObject SoloObjectEncoded
    | NestedAtoms ComplexPayload


{-| All encoder output can be expressed as a complex payload.
-}
type alias ComplexPayload =
    Nonempty ComplexAtom



-- CHANGEFRAMES ------------------------------------------------


type Frame
    = Frame
        { changes : List Change
        , description : String
        }


saveChanges : String -> List Change -> Frame
saveChanges description changes =
    Log.log (Console.blue "Saving Changes:") <| Frame { changes = changes, description = description }


{-| An empty Frame, for when you have no changes to save.
-}
none : Frame
none =
    Frame { changes = [], description = "Empty Frame" }


isEmpty : Frame -> Bool
isEmpty (Frame { changes }) =
    List.isEmpty changes


nonEmptyFrames : List Frame -> List Frame
nonEmptyFrames frames =
    List.filter (not << isEmpty) frames



-- POINTERS -----------------------------------------------------------------


{-| Pointer to either an existing object, or a future one.

For future (placeholder) objects, there is a change built in, allowing us to keep track of what other objects need to be created and updated when a given placeholder is created.

  - This was put in-pointer because naked records can't store it, and because RW setters may init their containing registers (bypassing the encoder tree), for example.
  - It's only ever touched when a new pointer is created, which is when it also inherits the ancestor installers.
  - Even existing objects have child installers, because it's about how new children get installed in it, not just about creating the object.

-}
type Pointer
    = ExistingObjectPointer ExistingID
    | PlaceholderPointer PendingID (Maybe Change)


equalPointers pointer1 pointer2 =
    case ( pointer1, pointer2 ) of
        ( ExistingObjectPointer objectID1, ExistingObjectPointer objectID2 ) ->
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

        ExistingObjectPointer existingID ->
            Just existingID.object


{-| When an object contains nested objects, it may not need to know about them until they need to be created. When they do, this Change tells us how to "install" the nested object (given its PendingID) in its proper place in the containing object.
-}
type alias ChildInstaller =
    PendingID -> Change


type PendingCounter
    = PendingCounter (List SiblingIndex)
    | PendingWildcard


type PendingObjectLocation
    = ParentExists ObjectID (Nonempty SiblingIndex)
    | ParentPending Op.ReducerID (Nonempty SiblingIndex)
    | ParentIsRoot


type alias PendingLocationString =
    String





type alias SiblingIndex =
    String


pendingLocationMatch : PendingObjectLocation -> PendingObjectLocation -> Bool
pendingLocationMatch pendingID1 pendingID2 =
    pendingID1 == pendingID2


newPointer : { parent : Parent, position : Nonempty SiblingIndex, reducerID : Op.ReducerID } -> Pointer
newPointer { parent, position, reducerID } =
    case parent of
        Parent (ExistingObjectPointer objectID) childInstallerMaybe ->
            let
                newPendingID : PendingID
                newPendingID =
                    PendingID reducerID (ParentExists objectID.object position)

                childInstallChangeMaybe : Maybe Change
                childInstallChangeMaybe =
                    -- install the new child in the existing parent.
                    Maybe.map (\f -> f newPendingID) childInstallerMaybe
            in
            PlaceholderPointer newPendingID childInstallChangeMaybe

        Parent (PlaceholderPointer parentPendingID ancestorInstallChangeMaybe) childInstallerMaybe ->
            let
                childInstallChangeMaybe : Maybe Change
                childInstallChangeMaybe =
                    -- install the new child in the pending parent.
                    Maybe.map (\f -> f newPendingID) childInstallerMaybe

                finalInstallChangeMaybe : Maybe Change
                finalInstallChangeMaybe =
                    case ( childInstallChangeMaybe, ancestorInstallChangeMaybe ) of
                        ( Just childInstallChange, Just ancestorInstallChange ) ->
                            -- merge the new child install Change with the ancestor installers Change.
                            Just <| mergeChanges ancestorInstallChange childInstallChange

                        ( Just _, Nothing ) ->
                            childInstallChangeMaybe

                        ( Nothing, Just _ ) ->
                            -- TODO does this case make sense? if we had ancestors to install, why wouldn't we have to install the new child too?
                            ancestorInstallChangeMaybe

                        ( Nothing, Nothing ) ->
                            Nothing

                newPendingID : PendingID
                newPendingID =
                    case parentPendingID.location of
                        ParentExists parentObjectID parentPosition ->
                            PendingID reducerID (ParentPending parentPendingID.reducer (Nonempty.append position parentPosition))

                        ParentPending grandparentReducerID parentPosition ->
                            PendingID reducerID (ParentPending parentPendingID.reducer (Nonempty.append position parentPosition))

                        ParentIsRoot ->
                            PendingID reducerID (ParentPending parentPendingID.reducer position)
            in
            PlaceholderPointer newPendingID finalInstallChangeMaybe


genesisPointer : Pointer
genesisPointer =
    PlaceholderPointer (PendingID "genesis" ParentIsRoot) Nothing


genesisParent : Parent
genesisParent =
    Parent genesisPointer Nothing



-- addInstaller : Pointer -> Installer -> Pointer
-- addInstaller pointer newInstaller =
--     case pointer of
--         ExistingObjectPointer objectID ->
--             ExistingObjectPointer objectID
--         PlaceholderPointer pendingID Nothing ->
--             PlaceholderPointer pendingID (Just newInstaller)
--         PlaceholderPointer pendingID (Just oldInstaller) ->
--             -- oops, careful, this was backwards before, the new wrapper needs to be inserted before the outer parent wrapper
--             PlaceholderPointer pendingID (Just <| mergeChangeSets newInstaller oldInstaller)


type Parent
    = Parent Pointer (Maybe ChildInstaller)


{-| A delayed Parent is capable of hosting child objects that can stay in pending form until they are first modified. This keeps the data store lean, so most objects should be delayed Parents if possible.
Pass in the ChildInstaller, the change that would be needed to add the child to the parent once it's created.
-}
becomeDelayedParent : Pointer -> ChildInstaller -> Parent
becomeDelayedParent pointer childInstaller =
    Parent pointer (Just childInstaller)


{-| An instant Parent must initialize all child objects immediately, so they don't lose their place inside. Use a delayed Parent instead, when possible.
-}
becomeInstantParent : Pointer -> Parent
becomeInstantParent pointer =
    Parent pointer Nothing
