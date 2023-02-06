module Replicated.Change exposing (Change(..), ChangeSet(..), Changer, ComplexAtom(..), ComplexPayload, Context(..), Creator, DelayedChange, ExistingID, Frame(..), ObjectChange(..), Parent, PendingID, Pointer(..), PrimitiveAtom(..), PrimitivePayload, SiblingIndex, SoloObjectEncoded, becomeDelayedParent, becomeInstantParent, changeObject, changeObjectWithExternal, collapseChangesToChangeSet, complexFromSolo, contextDifferentiatorString, delayedChangeObject, delayedToChangeSet, emptyChangeSet,  frameIndexString, genesisContext, genesisParent, genesisPointer, getContextParent, getPointerObjectID, isEmptyChangeSet, isPlaceholder, mergeChanges, mergeMaybeChange, newPointer, nonEmptyFrames, none, pendingIDToComparable, pendingIDToString, primitiveAtomToRonAtom, primitiveAtomToString, saveChanges, changeSetDebug, equalPointers)

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
type ChangeSet
    = ChangeSet ChangeSetDetails


type Change
    = WithFrameIndex (FrameIndex -> ChangeSet)


type alias FrameIndex =
    List Int


collapseChangesToChangeSet : FrameIndex -> List Change -> ChangeSet
collapseChangesToChangeSet context changes =
    let
        supplyIndexToChange index (WithFrameIndex toChangeSet) =
            toChangeSet (index :: context)

        listOfChangeSets =
            List.indexedMap supplyIndexToChange changes
    in
    List.foldl mergeChanges emptyChangeSet listOfChangeSets


existingIDToComparable : ExistingID -> ( Op.ReducerID, OpID.ObjectIDString )
existingIDToComparable { reducer, object } =
    ( reducer, OpID.toString object )


existingIDToString : ExistingID -> String
existingIDToString { reducer, object } =
    reducer ++ OpID.toString object


pendingIDToComparable : PendingID -> List String
pendingIDToComparable pendingID =
    let
        ( parent, ancestors ) =
            case pendingID.location of
                ParentExists objectID siblings ->
                    ( OpID.toString objectID, Nonempty.toList siblings )

                ParentPending reducerID siblings ->
                    ( reducerID, Nonempty.toList siblings )

                ParentIsRoot ->
                    ( "root", [] )
    in
    [ pendingID.reducer, parent ] ++ List.reverse ancestors


pendingIDToString : PendingID -> String
pendingIDToString pendingID =
    String.join " -> " (pendingIDToComparable pendingID)


{-| A helper to union two AnyDicts of Lists, by concatenating the Lists on collision rather than overwriting.
-}
unionCombine : AnyDict comparable k (List v) -> AnyDict comparable k (List v) -> AnyDict comparable k (List v) -> AnyDict comparable k (List v)
unionCombine empty dictA dictB =
    AnyDict.merge
        AnyDict.insert
        (\key a b -> AnyDict.insert key (a ++ b))
        AnyDict.insert
        dictA
        dictB
        empty


{-| Helper to merge two Changes. Put the later change first, earlier change last (pipelining) for proper duplicate handling.
-}
mergeChanges : ChangeSet -> ChangeSet -> ChangeSet
mergeChanges (ChangeSet changeSetLater) (ChangeSet changeSetEarlier) =
    ChangeSet
        { objectsToCreate =
            unionCombine emptyObjectsToCreate changeSetEarlier.objectsToCreate changeSetLater.objectsToCreate
        , existingObjectChanges =
            -- later-specified changes should be added at bottom of list for correct precedence
            unionCombine emptyExistingObjectChanges changeSetEarlier.existingObjectChanges changeSetLater.existingObjectChanges
        , delayed = changeSetEarlier.delayed ++ changeSetLater.delayed
        , opsToRepeat =
            -- on collision, preference is given to later set, though ops should never differ
            AnyDict.union changeSetLater.opsToRepeat changeSetEarlier.opsToRepeat
        }


mergeMaybeChange : Maybe ChangeSet -> ChangeSet -> ChangeSet
mergeMaybeChange maybeChange change =
    case maybeChange of
        Just changeToMerge ->
            mergeChanges change changeToMerge

        Nothing ->
            change


type alias ChangeSetDetails =
    { objectsToCreate : AnyDict (List String) PendingID (List ObjectChange)
    , existingObjectChanges : AnyDict ( Op.ReducerID, OpID.ObjectIDString ) ExistingID (List ObjectChange)
    , delayed : List DelayedChange
    , opsToRepeat : OpDb
    }


emptyChangeSet : ChangeSet
emptyChangeSet =
    ChangeSet <|
        { objectsToCreate = emptyObjectsToCreate
        , existingObjectChanges = emptyExistingObjectChanges
        , delayed = []
        , opsToRepeat = emptyOpsToRepeat
        }


emptyOpsToRepeat : AnyDict OpID.OpIDSortable OpID Op
emptyOpsToRepeat =
    AnyDict.empty OpID.toSortablePrimitives


emptyExistingObjectChanges =
    AnyDict.empty existingIDToComparable


emptyObjectsToCreate : AnyDict (List String) PendingID (List ObjectChange)
emptyObjectsToCreate =
    AnyDict.empty pendingIDToComparable


changeSetDebug : Int -> ChangeSet -> String
changeSetDebug indent (ChangeSet changeSetToDebug) =
    let
        ifNonemptyConcat list =
            if List.isEmpty list then
                Nothing

            else
                Just <| String.join "\n" list

        sayObjectsToCreate =
            List.map sayObjectToCreate (AnyDict.toList changeSetToDebug.objectsToCreate)
                |> ifNonemptyConcat

        sayExistingObjectChanges =
            List.map sayExistingObject (AnyDict.toList changeSetToDebug.existingObjectChanges)
                |> ifNonemptyConcat

        sayObjectToCreate ( pendingID, objectChangeList ) =
            Console.bold ("Pending " ++ (Console.underline <| pendingIDToString pendingID)) ++ " changes: [" ++ String.join "," (List.map sayObjectChange objectChangeList) ++ "]"


        sayExistingObject ( existingID, objectChangeList ) =
            Console.bold ("Existing " ++ (Console.underline <| existingIDToString existingID)) ++ " changes: [" ++ String.join "," (List.map sayObjectChange objectChangeList) ++ "]"

        sayObjectChange objectChange =
            case objectChange of
                NewPayload complexPayload ->
                    sayComplexPayload complexPayload

                NewPayloadWithRef {payload} ->
                    sayComplexPayload payload

                RevertOp opID ->
                    "Reverting op " ++ (OpID.toString opID)

        sayComplexPayload complexPayload =
            Nonempty.map sayComplexAtom complexPayload
                    |> Nonempty.toList
                    |> String.join " "

        sayComplexAtom complexAtom =
            case complexAtom of
                FromPrimitiveAtom primitiveAtom ->
                    primitiveAtomToString primitiveAtom

                PendingObjectReferenceAtom {reducer} ->
                    "<pending " ++ (reducer) ++ " ref>"

                ExistingObjectReferenceAtom objectID ->
                    "<" ++ (Console.underline <| OpID.toString objectID) ++ ">"

                QuoteNestedObject {toReference, changeSet, skippable } ->
                    let
                        saySkippable =
                            if skippable then "a skippable" else "an unskippable"

                        sayInstaller installer =
                            if installer == [] then "without parent installer" else "with parent installer"

                        sayNestedChangeSet =
                            "\n" ++ (changeSetDebug (indent + 4) changeSet)
                    in
                    case toReference of
                        ExistingObjectPointer {reducer, object} ->
                            "{" ++ saySkippable ++ " nested existing?! " ++ reducer ++ ": " ++ OpID.toString object ++ "}" ++ sayNestedChangeSet

                        PlaceholderPointer {reducer} installers ->
                            "{" ++ saySkippable ++ " nested pending " ++ reducer ++ ", " ++ sayInstaller installers ++ "}" ++ sayNestedChangeSet

                NestedAtoms complexPayload ->
                    "Nested Atoms: " ++ sayComplexPayload complexPayload

        allOuts =
            [ sayObjectsToCreate
            , sayExistingObjectChanges
            ]
                |> List.filterMap identity
    in
    String.join "\n" allOuts



-- DELAYED CHANGE SETS -----------------------------


type alias DelayedChange = (Pointer, ObjectChange)


delayedToChangeSet : DelayedChange -> ChangeSet
delayedToChangeSet (target, objectChange) =
    case target of
        ExistingObjectPointer existingID ->
            ChangeSet <|
                { objectsToCreate = AnyDict.empty pendingIDToComparable
                , existingObjectChanges = AnyDict.singleton existingID [objectChange] existingIDToComparable
                , delayed = []
                , opsToRepeat = emptyOpsToRepeat
                }

        PlaceholderPointer pendingID _ ->
            ChangeSet <|
                { objectsToCreate = AnyDict.singleton pendingID [objectChange] pendingIDToComparable
                , existingObjectChanges = AnyDict.empty existingIDToComparable
                , delayed = []
                , opsToRepeat = emptyOpsToRepeat
                }


delayedChangeObject :
    Pointer
    -> ObjectChange
    -> DelayedChange
delayedChangeObject target objectChange =
    (target, objectChange)



-- CHANGE MISC --------------------------------------------------


type alias OpDb =
    AnyDict OpID.OpIDSortable OpID Op


type alias Changer o =
    o -> List Change


type alias Creator a =
    Context -> a


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
    , changeSet : ChangeSet
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
    changeObjectWithExternal { target = target, objectChanges = objectChanges, externalUpdates = emptyChangeSet }


changeObjectWithExternal :
    { target : Pointer
    , objectChanges : List ObjectChange
    , externalUpdates : ChangeSet
    }
    -> SoloObjectEncoded
changeObjectWithExternal { target, objectChanges, externalUpdates } =
    let
        withExternalChanges thisSet =
            mergeChanges externalUpdates thisSet

        skippable =
            -- skippable if we ONLY make the object, not change it (nor change anything else)
            List.isEmpty objectChanges && isEmptyChangeSet externalUpdates

        finalChangeSet =
            case target of
                ExistingObjectPointer existingID ->
                    ChangeSet
                        { objectsToCreate = AnyDict.empty pendingIDToComparable
                        , existingObjectChanges = AnyDict.singleton existingID objectChanges existingIDToComparable
                        , delayed = []
                        , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
                        }
                        |> withExternalChanges

                PlaceholderPointer pendingID ancestorsInstallChanges ->
                    ChangeSet
                        { objectsToCreate = AnyDict.singleton pendingID objectChanges pendingIDToComparable
                        , existingObjectChanges = AnyDict.empty existingIDToComparable
                        , delayed = ancestorsInstallChanges
                        , opsToRepeat = AnyDict.empty OpID.toSortablePrimitives
                        }
                        |> withExternalChanges
    in
    { toReference = target
    , changeSet = finalChangeSet
    , skippable = skippable
    }


isEmptyChangeSet : ChangeSet -> Bool
isEmptyChangeSet (ChangeSet details) =
    AnyDict.isEmpty details.existingObjectChanges && AnyDict.isEmpty details.objectsToCreate && AnyDict.isEmpty details.opsToRepeat



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
        { changes : ChangeSet
        , description : String
        }


saveChanges : String -> List Change -> Frame
saveChanges description changes =
    Frame { changes = collapseChangesToChangeSet [] changes, description = description }


{-| An empty Frame, for when you have no changes to save.
-}
none : Frame
none =
    Frame { changes = emptyChangeSet, description = "Empty Frame" }


isEmpty : Frame -> Bool
isEmpty (Frame { changes }) =
    isEmptyChangeSet changes


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
    | PlaceholderPointer PendingID (List DelayedChange)


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
    PendingID -> DelayedChange


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

                childInstallChanges : List DelayedChange
                childInstallChanges =
                    -- install the new child in the existing parent.
                    Maybe.map (\f -> f newPendingID) childInstallerMaybe
                    |> Maybe.Extra.toList
            in
            PlaceholderPointer newPendingID childInstallChanges

        Parent (PlaceholderPointer parentPendingID ancestorInstallChanges) childInstallerMaybe ->
            let
                childInstallChangeMaybe : Maybe DelayedChange
                childInstallChangeMaybe =
                    -- install the new child in the pending parent.
                    Maybe.map (\f -> f newPendingID) childInstallerMaybe

                finalInstallChanges : List DelayedChange
                finalInstallChanges =
                    case childInstallChangeMaybe of
                        ( Just childInstallChange ) ->
                            -- merge the new child install Change with the ancestor installers Change.
                            ancestorInstallChanges ++ [childInstallChange]

                        ( Nothing ) ->
                            -- perhaps this pointer is an InstantParent, even if ancestors are not
                            ancestorInstallChanges

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
            PlaceholderPointer newPendingID finalInstallChanges


genesisPointer : Pointer
genesisPointer =
    PlaceholderPointer (PendingID "genesis" ParentIsRoot) []


genesisParent : Parent
genesisParent =
    Parent genesisPointer Nothing


genesisContext : Context
genesisContext =
    Context [] genesisParent


getContextParent : Context -> Parent
getContextParent (Context _ parent) =
    parent


contextDifferentiatorString : Context -> String
contextDifferentiatorString (Context frameIndex parent) =
    List.map String.fromInt frameIndex
        |> String.join "<"


frameIndexString frameIndex =
    List.map String.fromInt frameIndex
        |> String.join "<"



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


type Context
    = Context FrameIndex Parent


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
