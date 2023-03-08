module Replicated.Change exposing (Change(..), ChangeSet(..), Changer, ComplexAtom(..), ComplexPayload, Context(..), Creator, DelayedChange, ExistingID, Frame(..), ObjectChange(..), Parent, PendingID, Pointer(..), PrimitiveAtom(..), PrimitivePayload, SoloObjectEncoded, becomeDelayedParent, becomeInstantParent, changeObject, changeObjectWithExternal, changeSetDebug, collapseChangesToChangeSet, complexFromSolo, contextDifferentiatorString, delayedChangeObject, delayedChangesToSets, emptyChangeSet, equalPointers, extractOwnSubChanges, genesisParent, getContextLocation, getContextParent, getObjectChanges, getPointerObjectID, getPointerReducer, isEmptyChangeSet, isPlaceholder, mergeChanges, mergeMaybeChange, newPointer, nonEmptyFrames, none, pendingIDToComparable, pendingIDToString, primitiveAtomToRonAtom, primitiveAtomToString, redundantObjectChange, reuseContext, saveChanges, startContext)

import Console
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (del)
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Replicated.Change.Location as Location exposing (Location, toString)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID)
import Result.Extra


{-| Represents a _POTENTIAL_ change to the node - if you have one, you can "apply" your pending changes to make actual modifications to your model.

Outputs a Chunk - Chunks are same-object changes within a Frame.

-}
type ChangeSet
    = ChangeSet ChangeSetDetails


type Change
    = WithFrameIndex (Location -> ChangeSet)


collapseChangesToChangeSet : String -> List Change -> ChangeSet
collapseChangesToChangeSet layerName changes =
    let
        supplyIndexToChange newIndex (WithFrameIndex toChangeSet) =
            toChangeSet (Location.new layerName newIndex)

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


pendingIDToComparable : PendingID -> List Int
pendingIDToComparable pendingID =
    Location.toComparable (pendingObjectGlobalLocation pendingID)


pendingIDToString : PendingID -> String
pendingIDToString pendingID =
    Location.toString (pendingObjectGlobalLocation pendingID)


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
    { objectsToCreate : AnyDict (List Int) PendingID (List ObjectChange)
    , existingObjectChanges : AnyDict ( Op.ReducerID, OpID.ObjectIDString ) ExistingID (List ObjectChange)
    , delayed : List DelayedChange
    , opsToRepeat : OpDb
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
        , opsToRepeat = emptyOpsToRepeat
        }


emptyOpsToRepeat : AnyDict OpID.OpIDSortable OpID Op
emptyOpsToRepeat =
    AnyDict.empty OpID.toSortablePrimitives


emptyExistingObjectChanges =
    AnyDict.empty existingIDToComparable


emptyObjectsToCreate : AnyDict (List Int) PendingID (List ObjectChange)
emptyObjectsToCreate =
    AnyDict.empty pendingIDToComparable


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
            Console.bold ("Pending " ++ (Console.underline <| pendingIDToString pendingID)) ++ " changes: [" ++ sayObjectChangeList objectChangeList ++ "]"

        sayExistingObject ( existingID, objectChangeList ) =
            Console.bold ("Existing " ++ (Console.underline <| existingIDToString existingID)) ++ " changes:[" ++ sayObjectChangeList objectChangeList ++ "]"

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
                    primitiveAtomToString primitiveAtom

                PendingObjectReferenceAtom { reducer } ->
                    "<pending " ++ reducer ++ " ref>"

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
                        ExistingObjectPointer { reducer, object } ->
                            "{" ++ saySkippable ++ " nested existing?! " ++ reducer ++ ": " ++ OpID.toString object ++ "}" ++ sayNestedChangeSet

                        PlaceholderPointer { reducer } installers ->
                            "{" ++ saySkippable ++ " nested pending " ++ reducer ++ ", " ++ sayInstaller installers ++ "}" ++ sayNestedChangeSet

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
                        { objectsToCreate = AnyDict.empty pendingIDToComparable
                        , existingObjectChanges = AnyDict.singleton existingID givenObjectChanges existingIDToComparable
                        , delayed = []
                        , opsToRepeat = emptyOpsToRepeat
                        }

                PlaceholderPointer pendingID _ ->
                    ChangeSet <|
                        { objectsToCreate = AnyDict.singleton pendingID givenObjectChanges pendingIDToComparable
                        , existingObjectChanges = AnyDict.empty existingIDToComparable
                        , delayed = []
                        , opsToRepeat = emptyOpsToRepeat
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
    , myLocation : Location
    , parentLocation : Maybe Location
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
    AnyDict.isEmpty details.existingObjectChanges && AnyDict.isEmpty details.objectsToCreate && AnyDict.isEmpty details.opsToRepeat && List.isEmpty details.delayed


extractOwnSubChanges : Pointer -> List Change -> { earlier : ChangeSet, mine : List ObjectChange, later : ChangeSet }
extractOwnSubChanges pointer changeList =
    -- TODO FIXME
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
    = FromPrimitiveAtom PrimitiveAtom
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
                            ExistingObjectReferenceAtom existingID.object

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


type Frame
    = Frame
        { changes : ChangeSet
        , description : String
        }


saveChanges : String -> List Change -> Frame
saveChanges description changes =
    Frame { changes = collapseChangesToChangeSet "save" changes, description = description }


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
            Just existingID.object


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


pendingObjectGlobalLocation : PendingID -> Location
pendingObjectGlobalLocation { reducer, myLocation, parentLocation } =
    case parentLocation of
        Nothing ->
            Location.nestSingle myLocation reducer

        Just foundParentLoc ->
            Location.wrap foundParentLoc myLocation reducer


newPointer : { parent : Parent, position : Location, reducerID : Op.ReducerID } -> Pointer
newPointer { parent, position, reducerID } =
    case parent of
        Parent (ExistingObjectPointer { object }) childInstallerMaybe ->
            let
                newPendingID : PendingID
                newPendingID =
                    { reducer = reducerID
                    , myLocation = position
                    , parentLocation = Just <| Location.newSingle (OpID.toString object)
                    }

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
                        Just childInstallChange ->
                            -- merge the new child install Change with the ancestor installers Change.
                            ancestorInstallChanges ++ [ childInstallChange ]

                        Nothing ->
                            -- perhaps this pointer is an InstantParent, even if ancestors are not
                            ancestorInstallChanges

                newPendingID : PendingID
                newPendingID =
                    { reducer = reducerID
                    , myLocation = position
                    , parentLocation = Just <| pendingObjectGlobalLocation parentPendingID
                    }
            in
            PlaceholderPointer newPendingID finalInstallChanges


genesisParent : String -> Parent
genesisParent whereWeStarted =
    Parent (PlaceholderPointer (PendingID (whereWeStarted ++ "-root") Location.none Nothing) []) Nothing


startContext : String -> Context
startContext reasonForNewContext =
    Context Location.none (genesisParent reasonForNewContext)


getContextParent : Context -> Parent
getContextParent (Context _ parent) =
    parent


getContextLocation : Context -> Location
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
reuseContext : String -> Context -> Context
reuseContext uniqueString (Context location parent) =
    Context (Location.nestSingle location uniqueString) parent


contextDifferentiatorString : Context -> String
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
    = Parent Pointer (Maybe ChildInstaller)


type Context
    = Context Location Parent


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
