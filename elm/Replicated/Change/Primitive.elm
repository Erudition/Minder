module Replicated.Change.Primitive exposing (..)

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
import Replicated.Op.Atom as RonAtom
import Replicated.Op.ID as OpID exposing (ObjectID, OpID)
import Replicated.Op.ObjectHeader as ObjectHeader exposing (ObjectHeader)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import Result.Extra
import Set.Any as AnySet exposing (AnySet)



-- PRIMITIVE PAYLOADS
-- TODO - merge with Op.Atom?


{-| Full payload when an encoder only produces primitives - no ID references, no nested changes.
These can be used for e.g. dictionary keys.
-}
type alias Payload =
    Nonempty Atom


{-| Simple change encoder atoms, to be converted to RON - no standalone objects or references.
TODO allow IDs so user can use IDs as dict keys, no need for special behavior
-}
type Atom
    = NakedStringAtom String
    | StringAtom String
    | IntegerAtom Int
    | FloatAtom Float


toRonAtom : Atom -> RonAtom.Atom
toRonAtom primitiveAtom =
    case primitiveAtom of
        NakedStringAtom ns ->
            RonAtom.NakedStringAtom ns

        StringAtom s ->
            RonAtom.StringAtom s

        IntegerAtom i ->
            RonAtom.IntegerAtom i

        FloatAtom f ->
            RonAtom.FloatAtom f


toString : Atom -> String
toString primitiveAtom =
    case primitiveAtom of
        NakedStringAtom ns ->
            ns

        StringAtom s ->
            s

        IntegerAtom i ->
            String.fromInt i

        FloatAtom f ->
            String.fromFloat f
