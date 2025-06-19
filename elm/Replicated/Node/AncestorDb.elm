module Replicated.Node.AncestorDb exposing (AncestorDb, empty, getAncestry, update, wrap)

import Dict.Any as AnyDict exposing (AnyDict)
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Replicated.Change exposing (ChangeSet(..), Pointer(..))
import Replicated.Identifier exposing (..)
import Replicated.Op.ID as OpID exposing (ObjectID, OpID, OpIDSortable)
import Replicated.Op.Op exposing (Op, objectID)
import Set exposing (Set)


type alias AncestorDb =
    AnyDict OpIDSortable ObjectID KnownAncestors


type alias KnownAncestors =
    Set OpIDSortable


empty : AncestorDb
empty =
    AnyDict.empty OpID.toSortablePrimitives


update : ObjectID -> Nonempty ObjectID -> AncestorDb -> AncestorDb
update objectID newParents db =
    let
        newSet =
            Nonempty.map OpID.toSortablePrimitives newParents
                |> Nonempty.toList
                |> Set.fromList

        addParent existingMaybe =
            case existingMaybe of
                Just existingSet ->
                    Just <| Set.union existingSet newSet

                Nothing ->
                    Just newSet
    in
    AnyDict.update objectID addParent db


getAncestry : AncestorDb -> ObjectID -> List ObjectID
getAncestry db objectID =
    case AnyDict.get objectID db of
        Nothing ->
            []

        Just foundAncestors ->
            Set.toList foundAncestors
                |> List.map OpID.fromSortable


wrap : AncestorDb -> ObjectID -> AncestorDb
wrap db objectID =
    let
        wrapEntry _ existingAncestors =
            Set.insert (OpID.toSortablePrimitives objectID) existingAncestors
    in
    AnyDict.map wrapEntry db
