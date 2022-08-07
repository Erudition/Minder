module Replicated.Change exposing (..)

import Console
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
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


{-| Tried having this as a Nonempty. Made it way more complicated to skip encoding where needed. Back to List...
-}
type alias PotentialPayload =
    List Atom


type ObjectChange
    = NewPayload PotentialPayload
    | NewPayloadWithRef { payload : PotentialPayload, ref : OpID }
    | RevertOp OpID


type Atom
    = JsonValueAtom JE.Value
    | RonAtom Op.OpPayloadAtom
    | QuoteNestedObject Change
    | NestedAtoms PotentialPayload


compareToRonPayload : PotentialPayload -> Op.OpPayloadAtoms -> Bool
compareToRonPayload changePayload ronPayload =
    case ( changePayload, ronPayload ) of
        ( [ JsonValueAtom valueJE ], [ ronAtom ] ) ->
            Op.atomToJsonValue ronAtom == valueJE

        ( [ RonAtom ronAtom1 ], [ ronAtom2 ] ) ->
            ronAtom1 == ronAtom2

        ( [ QuoteNestedObject (Chunk { target, objectChanges }) ], [ ronAtom ] ) ->
            case ( target, objectChanges ) of
                ( ExistingObjectPointer objectID, [] ) ->
                    -- see if it's just a ref to the same object. TODO: necessary?
                    String.contains (OpID.toString objectID) (Op.atomToRonString ronAtom)

                _ ->
                    -- can't match if object does not exist yet, or there are changes to make.
                    False

        ( [ NestedAtoms payload ], _ ) ->
            False

        -- TODO
        ( unhandledChange, unhandledOpPayload ) ->
            Debug.todo <| "When updating a register I needed to check if " ++ Debug.toString unhandledChange ++ " was equivalent to " ++ Debug.toString unhandledOpPayload ++ " to see if the change is the default value - but you unimaginatively did not handle that case, go add it..."


changeToChangePayload : Change -> PotentialPayload
changeToChangePayload change =
    [ QuoteNestedObject change ]


{-| This only needs to be called once, when changes are saved. calling any other place is redundant
-}
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
            -- can't use foldR because it reverses the whole list EXCEPT the head, shuffling the change order. instead we preserve the backwards order and reverse subchanges in mergeSameTargetChanges if need be.
            List.foldl mergeSameTargetChanges firstChange rest


{-| Combine chunks known to be changing the same object.
-}
mergeSameTargetChanges (Chunk change1Details) (Chunk change2Details) =
    Chunk
        { target = change1Details.target
        , objectChanges = change2Details.objectChanges ++ change1Details.objectChanges -- reverses subchanges again.
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


{-| An empty Frame, for when you have no changes to save.
-}
none : Frame
none =
    Frame { normalizedChanges = [], description = "Empty Frame" }


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



-- POINTERS


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
