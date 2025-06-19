module Replicated.Change exposing (Change(..), ChangeSet(..), Changer, ComplexAtom(..), ComplexPayload, Context(..), Creator, DelayedChange, Frame(..), ObjectChange(..), Parent, Pointer(..), SoloObjectEncoded, UndoData, becomeDelayedParent, becomeInstantParent, changeObject, changeObjectWithExternal, changeSetDebug, collapseChangesToChangeSet, complexFromSolo, contextDifferentiatorString, createReversionFrame, delayedChangeObject, delayedChangesToSets, emptyChangeSet, emptyFrame, equalPointers, extractOwnSubChanges, genesisParent, getContextLocation, getContextParent, getObjectChanges, getPointerObjectID, getPointerReducer, isEmptyChangeSet, isPlaceholder, mapChanger, mapCreator, mergeChanges, mergeMaybeChange, newPointer, noChange, nonEmptyFrames, redundantObjectChange, reuseContext, saveSystemChanges, saveUserChanges, startContext)

import Console
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (del)
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Replicated.Change.Location as Location exposing (Location, toString)
import Replicated.Change.PendingID as PendingID exposing (PendingID)
import Replicated.Change.Primitive as Primitive
import Replicated.Op.Atom as Atom exposing (Atom(..))
import Replicated.Op.ID as OpID exposing (ObjectID, OpID)
import Replicated.Op.ObjectHeader as ObjectHeader exposing (ObjectHeader)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import Result.Extra
import Set.Any as AnySet exposing (AnySet)


type ChangeSet
    = ChangeSet ChangeSetDetails


{-| Represents a _POTENTIAL_ change to the node - if you have one, you can "apply" your pending changes to make actual modifications to your model.
-}
type Change
    = WithFrameIndex (Location -> ChangeSet)


{-| A change that does nothing.
-}
noChange =
    WithFrameIndex (\_ -> emptyChangeSet)


collapseChangesToChangeSet : String -> List Change -> ChangeSet
collapseChangesToChangeSet layerName changes =
    let
        supplyIndexToChange newIndex (WithFrameIndex toChangeSet) =
            toChangeSet (Location.new layerName newIndex)

        listOfChangeSets =
            List.indexedMap supplyIndexToChange changes
    in
    List.foldl mergeChanges emptyChangeSet listOfChangeSets


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
        }


mergeMaybeChange : Maybe ChangeSet -> ChangeSet -> ChangeSet
mergeMaybeChange maybeChange change =
    case maybeChange of
        Just changeToMerge ->
            mergeChanges change changeToMerge

        Nothing ->
            change


{-| Set of all changes to make.
Decision: real changes only, no repeated ops. Ops to be reverted are specified at the frame level.
-}
type alias ChangeSetDetails =
    { objectsToCreate : AnyDict (List String) PendingID (List ObjectChange)
    , existingObjectChanges : AnyDict ( ReducerID.ReducerIDString, OpID.ObjectIDString ) ObjectHeader (List ObjectChange)
    , delayed : List DelayedChange
    }


getObjectChanges : Pointer -> ChangeSet -> List ObjectChange
getObjectChanges pointer (ChangeSet changeSet) =
    case pointer of
        ExistingObjectPointer existingID ->
            AnyDict.get existingID changeSet.existingObjectChanges
                |> Maybe.withDefault []

        PlaceholderPointer pendingID _ ->
            AnyDict.get pendingID changeSet.objectsToCreate
                |> Maybe.withDefault []


emptyChangeSet : ChangeSet
emptyChangeSet =
    ChangeSet <|
        { objectsToCreate = emptyObjectsToCreate
        , existingObjectChanges = emptyExistingObjectChanges
        , delayed = []
        }


emptyOpIDSet : AnySet OpID.OpIDSortable OpID
emptyOpIDSet =
    AnySet.empty OpID.toSortablePrimitives


emptyExistingObjectChanges =
    AnyDict.empty ObjectHeader.toComparable


emptyObjectsToCreate : AnyDict (List String) PendingID (List ObjectChange)
emptyObjectsToCreate =
    AnyDict.empty PendingID.toComparable


changeSetDebug : Int -> ChangeSet -> String
changeSetDebug indent (ChangeSet changeSetToDebug) =
    let
        indentHere =
            String.repeat (indent * 4) " "

        ifNonemptyConcat list =
            if List.isEmpty list then
                Nothing

            else
                Just <| String.join ("\n" ++ indentHere) list

        sayObjectsToCreate =
            List.map sayObjectToCreate (AnyDict.toList changeSetToDebug.objectsToCreate)
                |> ifNonemptyConcat

        sayExistingObjectChanges =
            List.map sayExistingObject (AnyDict.toList changeSetToDebug.existingObjectChanges)
                |> ifNonemptyConcat

        sayObjectToCreate ( pendingID, objectChangeList ) =
            Console.bold ("Pending " ++ (Console.underline <| PendingID.toString pendingID)) ++ " changes: [" ++ sayObjectChangeList objectChangeList ++ "]"

        sayExistingObject ( existingID, objectChangeList ) =
            Console.bold ("Existing " ++ (Console.underline <| ObjectHeader.toString existingID)) ++ " changes:[" ++ sayObjectChangeList objectChangeList ++ "]"

        sayObjectChangeList objectChangeList =
            if List.isEmpty objectChangeList then
                "none"

            else
                "\n    " ++ indentHere ++ String.join (",\n" ++ indentHere ++ "    ") (List.map sayObjectChange objectChangeList)

        sayObjectChange objectChange =
            case objectChange of
                NewPayload complexPayload ->
                    sayComplexPayload complexPayload

                NewPayloadWithRef { payload } ->
                    sayComplexPayload payload

                RevertOp opID ->
                    "Reverting op " ++ OpID.toString opID

        sayComplexPayload complexPayload =
            Nonempty.map sayComplexAtom complexPayload
                |> Nonempty.toList
                |> String.join " "

        sayComplexAtom complexAtom =
            case complexAtom of
                FromPrimitiveAtom primitiveAtom ->
                    Primitive.toString primitiveAtom

                PendingObjectReferenceAtom { reducer } ->
                    "<pending " ++ ReducerID.toString reducer ++ " ref>"

                ExistingObjectReferenceAtom objectID ->
                    "<" ++ (Console.underline <| OpID.toString objectID) ++ ">"

                QuoteNestedObject { toReference, changeSet, skippable } ->
                    let
                        saySkippable =
                            if skippable then
                                "a skippable"

                            else
                                "an unskippable"

                        sayInstaller installer =
                            if installer == [] then
                                "without parent installer"

                            else
                                "with " ++ String.fromInt (List.length installer) ++ " parent installers"

                        sayNestedChangeSet =
                            "\n" ++ changeSetDebug (indent + 2) changeSet
                    in
                    case toReference of
                        ExistingObjectPointer { reducer, operationID } ->
                            "{" ++ saySkippable ++ " nested existing?! " ++ ReducerID.toString reducer ++ ": " ++ OpID.toString operationID ++ "}" ++ sayNestedChangeSet

                        PlaceholderPointer { reducer } installers ->
                            "{" ++ saySkippable ++ " nested pending " ++ ReducerID.toString reducer ++ ", " ++ sayInstaller installers ++ "}" ++ sayNestedChangeSet

                NestedAtoms complexPayload ->
                    "Nested Atoms: " ++ sayComplexPayload complexPayload

        allOuts =
            [ sayObjectsToCreate
            , sayExistingObjectChanges
            ]
                |> List.filterMap identity

        delayedCount =
            String.fromInt (List.length changeSetToDebug.delayed)
    in
    indentHere ++ ("ChangeSet with " ++ delayedCount ++ " delayed:" ++ "\n" ++ indentHere) ++ String.join ("\n" ++ indentHere) allOuts



-- DELAYED CHANGE SETS -----------------------------


type alias DelayedChange =
    ( Pointer, ObjectChange )


delayedChangesToSets : List DelayedChange -> List ChangeSet
delayedChangesToSets delayed =
    let
        uniqueDelayedChanges : List DelayedChange
        uniqueDelayedChanges =
            -- drop later changes that already appeared earlier
            List.foldl
                (\a uniques ->
                    if List.member a uniques then
                        uniques

                    else
                        uniques ++ [ a ]
                )
                []
                delayed

        groupedByPointer =
            List.Extra.groupWhile (\( p1, _ ) ( p2, _ ) -> equalPointers p1 p2) uniqueDelayedChanges

        delayedGroupToChangeSet : ( DelayedChange, List DelayedChange ) -> ChangeSet
        delayedGroupToChangeSet ( ( target, _ ) as head, tail ) =
            let
                givenObjectChanges =
                    List.map Tuple.second (head :: tail)
            in
            case target of
                ExistingObjectPointer existingID ->
                    ChangeSet <|
                        { objectsToCreate = AnyDict.empty PendingID.toComparable
                        , existingObjectChanges = AnyDict.singleton existingID givenObjectChanges ObjectHeader.toComparable
                        , delayed = []
                        }

                PlaceholderPointer pendingID _ ->
                    ChangeSet <|
                        { objectsToCreate = AnyDict.singleton pendingID givenObjectChanges PendingID.toComparable
                        , existingObjectChanges = AnyDict.empty ObjectHeader.toComparable
                        , delayed = []
                        }
    in
    List.map delayedGroupToChangeSet groupedByPointer


delayedChangeObject :
    Pointer
    -> ObjectChange
    -> DelayedChange
delayedChangeObject target objectChange =
    ( target, objectChange )



-- CHANGE MISC --------------------------------------------------


type alias OpIDSet =
    AnySet OpID.OpIDSortable OpID


type alias Changer o =
    o -> List Change


{-| Convert a `Changer` from operating on one type, to operating on another type that is derived from the original.

This can be used to create your own Changers for opaque types, that wrap a reptype object in some way.
If you use this function on multiple input types with the same output type, you can combine Changers. This allows you to create a Changer for a composite type that includes multiple different underlying reptypes.

-}
mapChanger : (a -> b) -> Changer b -> Changer a
mapChanger aToB bChanger =
    \a -> bChanger (aToB a)


type alias Creator a =
    Context a -> a


{-| Convert a `Creator` from operating on one type, to operating on another type that is derived from the original.
-}
mapCreator : (a -> b) -> Creator a -> Creator b
mapCreator aToB aCreator =
    let
        bCreator : Context b -> b
        bCreator (Context location parent) =
            let
                aContext : Context a
                aContext =
                    Context location parent
            in
            aToB (aCreator aContext)
    in
    bCreator


type ObjectChange
    = NewPayload ComplexPayload
    | NewPayloadWithRef { payload : ComplexPayload, ref : OpID }
    | RevertOp OpID


complexFromPrimitive : Primitive.Payload -> ComplexPayload
complexFromPrimitive primitivePayload =
    Nonempty.map FromPrimitiveAtom primitivePayload



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
                        { objectsToCreate = AnyDict.empty PendingID.toComparable
                        , existingObjectChanges = AnyDict.singleton existingID objectChanges ObjectHeader.toComparable
                        , delayed = []
                        }
                        |> withExternalChanges

                PlaceholderPointer pendingID ancestorsInstallChanges ->
                    ChangeSet
                        { objectsToCreate = AnyDict.singleton pendingID objectChanges PendingID.toComparable
                        , existingObjectChanges = AnyDict.empty ObjectHeader.toComparable
                        , delayed = ancestorsInstallChanges
                        }
                        |> withExternalChanges
    in
    { toReference = target
    , changeSet = finalChangeSet
    , skippable = skippable
    }


isEmptyChangeSet : ChangeSet -> Bool
isEmptyChangeSet (ChangeSet details) =
    AnyDict.isEmpty details.existingObjectChanges && AnyDict.isEmpty details.objectsToCreate && List.isEmpty details.delayed


extractOwnSubChanges : Pointer -> List Change -> { earlier : ChangeSet, mine : List ObjectChange, later : ChangeSet }
extractOwnSubChanges pointer changeList =
    -- TODO no longer needed?
    -- ideally this would find changes that directly modify nested objects, and turn them into QuoteNestedObject references, with full nested contents, rather than just a pending ref and a delayed installer for the object that's already being created anyway. this optimizes op order.
    let
        supplyIndexToChange index (WithFrameIndex toChangeSet) =
            toChangeSet (Location.new "extractOwnSubChanges" index)

        listOfChangeSets =
            List.indexedMap supplyIndexToChange changeList

        getMyInitAndDescendents : ChangeSet -> Result ChangeSet ( ObjectChange, ChangeSet )
        getMyInitAndDescendents ((ChangeSet givenChangeSetDetails) as inChangeSet) =
            let
                myInstallerMaybe =
                    List.Extra.find objectChangeOfMine givenChangeSetDetails.delayed
                        |> Maybe.map Tuple.second

                objectChangeOfMine ( delayedPointer, delayedObjectChange ) =
                    delayedPointer == pointer
            in
            case myInstallerMaybe of
                Nothing ->
                    Err inChangeSet

                Just installerFound ->
                    Ok ( installerFound, inChangeSet )

        checkAllChangeSets =
            List.map getMyInitAndDescendents listOfChangeSets

        ( mySubChangeSetsAndInstallers, otherChangeSets ) =
            Result.Extra.partition checkAllChangeSets

        myObjectChanges =
            List.map Tuple.first mySubChangeSetsAndInstallers

        mySubChangeSets =
            List.map Tuple.second mySubChangeSetsAndInstallers
    in
    { earlier = List.foldl mergeChanges emptyChangeSet mySubChangeSets
    , mine = myObjectChanges
    , later = List.foldl mergeChanges emptyChangeSet otherChangeSets
    }



-- COMPLEX PAYLOADS ---------------------------------------


{-| Change encoder atoms, which supports references and nested object changes.
-}
type ComplexAtom
    = FromPrimitiveAtom Primitive.Atom
    | PendingObjectReferenceAtom PendingID
    | ExistingObjectReferenceAtom ObjectID
    | QuoteNestedObject SoloObjectEncoded
    | NestedAtoms ComplexPayload


{-| All encoder output can be expressed as a complex payload.
-}
type alias ComplexPayload =
    Nonempty ComplexAtom


{-| Determine whether the first object change is redundant and can be discarded, assuming the second object change will stay regardless. If they are equal, the answer is yes, but the first can also be redundant by having a simple pointer to an object, while the second contains a nested object with the same pointer.

Currently needed only when node encoder defaults mode is on, where installers would be redundant with generated defaults (but not equivalent, as the latter is the real nested object).

-}
redundantObjectChange : ObjectChange -> ObjectChange -> Bool
redundantObjectChange possiblyRedundantObjectChange canonicalObjectChange =
    let
        payloadEquivalence payload1 payload2 =
            payload1 == Nonempty.map convertQuotesToRefs payload2

        convertQuotesToRefs : ComplexAtom -> ComplexAtom
        convertQuotesToRefs complexAtom =
            case complexAtom of
                NestedAtoms nestedComplexPayload ->
                    NestedAtoms (Nonempty.map convertQuotesToRefs nestedComplexPayload)

                QuoteNestedObject solo ->
                    case solo.toReference of
                        ExistingObjectPointer existingID ->
                            ExistingObjectReferenceAtom existingID.operationID

                        PlaceholderPointer pendingID _ ->
                            PendingObjectReferenceAtom pendingID

                otherAtom ->
                    otherAtom
    in
    if possiblyRedundantObjectChange == canonicalObjectChange then
        True

    else
        case ( possiblyRedundantObjectChange, canonicalObjectChange ) of
            ( NewPayload payload1, NewPayload payload2 ) ->
                payloadEquivalence payload1 payload2

            ( NewPayloadWithRef first, NewPayloadWithRef second ) ->
                payloadEquivalence first.payload second.payload

            _ ->
                False



-- CHANGEFRAMES ------------------------------------------------


type Frame desc
    = Frame
        { changes : ChangeSet
        , description : Maybe desc
        }


saveUserChanges : desc -> List Change -> Frame desc
saveUserChanges description changes =
    Frame { changes = collapseChangesToChangeSet "save" changes, description = Just description }


saveSystemChanges : List Change -> Frame desc
saveSystemChanges changes =
    Frame { changes = collapseChangesToChangeSet "save" changes, description = Nothing }


{-| An empty Frame, for when you have no changes to save.
-}
emptyFrame : Frame desc
emptyFrame =
    Frame { changes = emptyChangeSet, description = Nothing }


{-| Returns True if a change Frame contains no changes (including Ops to invert).
-}
isEmpty : Frame desc -> Bool
isEmpty (Frame { changes }) =
    isEmptyChangeSet changes


nonEmptyFrames : List (Frame desc) -> List (Frame desc)
nonEmptyFrames frames =
    List.filter (not << isEmpty) frames


{-| Data that can be used for user undo/redo.
Internally, this type contains a set of IDs for all the Ops that can be reverted, if any, that were generated by an applied Change Frame. You can use this to create a new Change Frame to undo those changes, or redo those changes if they were previously undone.
-}
type alias UndoData =
    OpIDSet


{-| Used internally by Node module to create a Change Frame that reverts the given Ops.

Note: does not work with the original Ops (before all reversions). The Node module takes the UndoData (OpIDs of original changes) and traces all undo/redo operations recursively to the most recent reversion of each one, and provides this function with the those Ops (actual Ops, not just IDs).

-}
createReversionFrame : List Op -> Frame desc
createReversionFrame opsToRevert =
    let
        -- add a reversion operation to the existingObjectChanges for the target object.
        addOpToChangeSet op existingObjectChanges =
            let
                existingID =
                    ObjectHeader (Op.objectID op) (Op.reducer op)
            in
            -- AnyDict ( Op.ReducerID, OpID.ObjectIDString ) ExistingID (List ObjectChange)
            AnyDict.insert existingID [ RevertOp (Op.id op) ] existingObjectChanges

        changeSet =
            ChangeSet
                { objectsToCreate = emptyObjectsToCreate
                , existingObjectChanges = List.foldl addOpToChangeSet emptyExistingObjectChanges opsToRevert
                , delayed = []
                }
    in
    Frame { changes = changeSet, description = Nothing }



--Frame { changes = emptyChangeSet, description = Nothing, opsToReverse = opsToReverse }
-- POINTERS -----------------------------------------------------------------


{-| Pointer to either an existing object, or a future one.

For future (placeholder) objects, there is a change built in, allowing us to keep track of what other objects need to be created and updated when a given placeholder is created.

  - This was put in-pointer because naked records can't store it, and because RW setters may init their containing registers (bypassing the encoder tree), for example.
  - It's only ever touched when a new pointer is created, which is when it also inherits the ancestor installers.
  - Even existing objects have child installers, because it's about how new children get installed in it, not just about creating the object.

-}
type Pointer
    = ExistingObjectPointer ObjectHeader
    | PlaceholderPointer PendingID (List DelayedChange)


equalPointers pointer1 pointer2 =
    case ( pointer1, pointer2 ) of
        ( ExistingObjectPointer objectID1, ExistingObjectPointer objectID2 ) ->
            objectID1 == objectID2

        ( PlaceholderPointer pendingID1 _, PlaceholderPointer pendingID2 _ ) ->
            pendingID1 == pendingID2

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
            Just existingID.operationID


getPointerReducer pointer =
    case pointer of
        PlaceholderPointer { reducer } _ ->
            reducer

        ExistingObjectPointer { reducer } ->
            reducer


{-| When an object contains nested objects, it may not need to know about them until they need to be created. When they do, this Change tells us how to "install" the nested object (given its PendingID) in its proper place in the containing object.
-}
type alias ChildInstaller =
    PendingID -> DelayedChange


newPointer : { parent : Parent, position : Location, reducerID : ReducerID } -> Pointer
newPointer { parent, position, reducerID } =
    let
        newPendingIDForExistingParent existingID =
            { reducer = reducerID
            , myLocation = position
            , parentLocation = Just <| Location.newSingle (OpID.toString existingID)
            }

        newPendingIDForPendingParent parentPendingID =
            { reducer = reducerID
            , myLocation = position
            , parentLocation = Just <| PendingID.toLocation parentPendingID
            }
    in
    case parent of
        DelayedParent (ExistingObjectPointer { operationID }) childInstaller ->
            let
                newPendingID =
                    newPendingIDForExistingParent operationID

                childInstallChanges : List DelayedChange
                childInstallChanges =
                    -- install the new child in the existing parent.
                    [ childInstaller newPendingID ]
            in
            PlaceholderPointer newPendingID childInstallChanges

        InstantParent (ExistingObjectPointer { operationID }) ->
            PlaceholderPointer (newPendingIDForExistingParent operationID) []

        DelayedParent (PlaceholderPointer parentPendingID ancestorInstallChanges) childInstaller ->
            let
                newPendingID =
                    newPendingIDForPendingParent parentPendingID

                finalInstallChanges : List DelayedChange
                finalInstallChanges =
                    -- install the new child in the pending parent.
                    -- merge the new child install Change with the ancestor installers Change.
                    ancestorInstallChanges ++ [ childInstaller newPendingID ]
            in
            PlaceholderPointer newPendingID finalInstallChanges

        InstantParent (PlaceholderPointer parentPendingID ancestorInstallChanges) ->
            PlaceholderPointer (newPendingIDForPendingParent parentPendingID) ancestorInstallChanges

        GenesisParent origin ->
            let
                newPendingID =
                    { reducer = reducerID
                    , myLocation = position
                    , parentLocation = Just <| Location.newSingle origin
                    }
            in
            PlaceholderPointer newPendingID []


genesisParent : String -> Parent
genesisParent whereWeStarted =
    GenesisParent (whereWeStarted ++ "-root")


startContext : String -> Context child
startContext reasonForNewContext =
    Context Location.none (genesisParent reasonForNewContext)


getContextParent : Context child -> Parent
getContextParent (Context _ parent) =
    parent


getContextLocation : Context child -> Location
getContextLocation (Context location parent) =
    location


{-| Normally you'd only use a `Context` once, by passing it to one of the new functions, for example. Don't use an ancestor `Context` if your parent's `Context` is available! In pure functions like Elm, same input always equals same output, so using a `Context` twice may mean the new objects will appear the same to the algorithm, causing them to become inextricably merged upon encoding.

That said, if you do reuse a `Context`, strategies are employed to differentiate the uses:

  - Are they the exact same `new` function?
  - Are the Codecs using the same base reptype (e.g. list, lww)?

...that's basically it for now. Two different lww Codecs, for example, may still look the same. So use Codec.reuseContext on at least one of them to be safe!

Dev note : The placeholder pointers generated by use of `new` and friends, are not the same as would be assigned during the first encoding pass. In fact the encoding pass can make use of structure to tell two instantiations apart - but `Codec.new this` and `Codec.new that` are not distinguishable if they are passed the exact same `Context`. Same inputs, same outputs.

Alas, sometimes you only have one `Context`. You're working within a `new` parent and have multiple children to create without creating new Contexts - such as `CustomType (Codec.new someRegCodecA context) (Codec.new someOtherCodecButStillRegBased context)` and so they are seen as equivalent and will be permanently merged upon saving.

Ways to mitigate this:

  - Require a unique number or string to be passed to `new` functions... ugh.
  - Codec.reuseContext to take an existing Context and make it different, warning users to always do this when reusing contexts.
  - Use encoder-assigned pointers instead (they're specific enough to not have this problem) and disallow same-frame references to new objects by pointer/ID, since the references won't resolve correctly after the pointers are changed.\*
  - Make a version of Codec.new that takes a unique string, that is only meant for new objects that the user plans to reference in-frame. The string is added to the pointer so it's unique, and can be resolved (anywhere?).\*

\*We'd also need to go into any nested changes and recursively swap out the old pendingIDs, ugh.

-}
reuseContext : String -> Context childType -> Context a
reuseContext uniqueString (Context location parent) =
    Context (Location.nestSingle location uniqueString) parent


contextDifferentiatorString : Context childType -> String
contextDifferentiatorString (Context frameIndex parent) =
    "⌔" ++ toString frameIndex



-- addInstaller : Parent -> Installer -> Pointer
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
    = DelayedParent Pointer ChildInstaller
    | InstantParent Pointer
    | GenesisParent String


type Context childType
    = Context Location Parent


{-| A delayed Parent is capable of hosting child objects that can stay in pending form until they are first modified. This keeps the data store lean, so most objects should be delayed Parents if possible.
Pass in the ChildInstaller, the change that would be needed to add the child to the parent once it's created.
-}
becomeDelayedParent : Pointer -> ChildInstaller -> Parent
becomeDelayedParent pointer childInstaller =
    DelayedParent pointer childInstaller


{-| An instant Parent must initialize all child objects immediately, so they don't lose their place inside. Use a delayed Parent instead, when possible.
-}
becomeInstantParent : Pointer -> Parent
becomeInstantParent pointer =
    InstantParent pointer
