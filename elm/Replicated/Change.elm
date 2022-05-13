module Replicated.Change exposing (..)

import Json.Encode as JE
import List.Extra
import Replicated.Op.Op as Op
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID)


{-| Represents a _POTENTIAL_ change to the node - if you have one, you can "apply" your pending changes to make actual modifications to your model.

Outputs a Chunk - Chunks are same-object changes within a Frame.

-}
type Change
    = Chunk
        { target : Pointer
        , objectChanges : List ObjectChange
        }


type alias Payload =
    List Atom


type ObjectChange
    = NewPayload Payload
    | NewPayloadWithRef { payload : Payload, ref : OpID }
    | RevertOp OpID


type Pointer
    = ExistingObjectPointer ObjectID
    | PlaceholderPointer Op.ReducerID PendingID ParentNotifier


equalPointers pointer1 pointer2 =
    case ( pointer1, pointer2 ) of
        ( ExistingObjectPointer objectID1, ExistingObjectPointer objectID2 ) ->
            objectID1 == objectID2

        ( PlaceholderPointer reducerID1 pendingID1 _, PlaceholderPointer reducerID2 pendingID2 _ ) ->
            reducerID1 == reducerID2 && pendingIDMatch pendingID1 pendingID2

        _ ->
            False


isPlaceholder pointer =
    case pointer of
        PlaceholderPointer _ _ _ ->
            True

        _ ->
            False


type Atom
    = ValueAtom JE.Value
    | QuoteNestedObject Change
    | NestedAtoms Payload



-- wrapNestedPayload : List Atom -> Atom
-- wrapNestedPayload changeAtomList =
--     let
--         encodedAtoms =
--             case changeAtomList of
--                 [] ->
--                     JE.list JE.string []
--
--                 [(singleton)] ->
--                     JE
--     in
--
--     NestedAtoms (JE.encode 0 encodedAtoms)


changeToChangePayload : Change -> Payload
changeToChangePayload change =
    [ QuoteNestedObject change ]


type alias ParentNotifier =
    Change -> Change


type PendingCounter
    = PendingCounter (List Int)
    | PendingWildcard


type PendingID
    = PendingID (List Int)


usePendingCounter : Int -> PendingCounter -> { id : PendingID, passToChild : PendingCounter }
usePendingCounter siblingNum givenPendingCounter =
    case givenPendingCounter of
        PendingWildcard ->
            { id = PendingID [] -- these are always considered unequal
            , passToChild = firstPendingCounter -- children can become matchable again
            }

        PendingCounter inCounterList ->
            let
                ancestors =
                    case inCounterList of
                        [] ->
                            []

                        myNum :: prior ->
                            prior
            in
            { id = PendingID inCounterList
            , passToChild = PendingCounter (siblingNum :: ancestors)
            }


unmatchableCounter : PendingCounter
unmatchableCounter =
    PendingWildcard


firstPendingCounter =
    PendingCounter [ 0 ]


pendingIDMatch : PendingID -> PendingID -> Bool
pendingIDMatch pendingID1 pendingID2 =
    case ( pendingID1, pendingID2 ) of
        ( PendingID [], _ ) ->
            False

        ( _, PendingID [] ) ->
            False

        _ ->
            pendingID1 == pendingID2


pendingIDToString : PendingID -> String
pendingIDToString (PendingID intList) =
    String.concat <| List.intersperse "." (List.map String.fromInt intList)


combineChangesOfSameTarget changeList =
    -- bundle together changes that have the same target object
    List.map groupCombiner (List.Extra.groupWhile sameTarget changeList)


sameTarget (Chunk a) (Chunk b) =
    equalPointers a.target b.target


groupCombiner ( firstChange, moreChanges ) =
    -- for each grouping, fold multiple changes together
    case moreChanges of
        [] ->
            firstChange

        rest ->
            List.foldr mergeSameTargetChanges firstChange rest


mergeSameTargetChanges (Chunk change1Details) (Chunk change2Details) =
    Chunk
        { target = change1Details.target
        , objectChanges = change1Details.objectChanges ++ change2Details.objectChanges
        }



-- CHANGEFRAMES


type Frame
    = Frame
        { normalizedChanges : List Change
        , description : String
        }


saveChanges : String -> List Change -> Frame
saveChanges description changes =
    Frame { normalizedChanges = normalizeChanges changes, description = description }


{-| Since the user can get changes from anywhere and batch them together, we need to make sure that the same object isn't changed multiple times in separate entries, to optimize RON chain output (all same-object changes should be in a row). So we add them to a Dict to make sure all chunks are unique, combining contents if need be.

We also may have a change that targets a placeholder, and needs to modify the parent, and maybe the parent's parent, etc to include the nested object once initialized. This should also be merged with other disparate changes to those parent objects, so we add them to the dictionary at the highest level (the object that actually exists is the change, wrapping all nested changes). This causes placeholders to properly notify their parents, while also making sure the dict merges changes at the same level. Otherwise, given changes A, B, C, C, D where B contains a nested change to D, the C changes will merge but the D changes will not.

-}
normalizeChanges : List Change -> List Change
normalizeChanges changesToNormalize =
    let
        wrapInParent : Change -> Change
        wrapInParent ((Chunk chunkDetails) as originalChange) =
            case chunkDetails.target of
                ExistingObjectPointer _ ->
                    originalChange

                PlaceholderPointer reducerID pendingID parentNotifier ->
                    -- TODO how to recurse upwards
                    parentNotifier originalChange
    in
    combineChangesOfSameTarget changesToNormalize
        |> List.map wrapInParent
