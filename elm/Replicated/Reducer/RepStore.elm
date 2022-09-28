module Replicated.Reducer.RepStore exposing ( Store, buildFromReplicaDb, get, getInit,  getPointer, reducerID)

import Array exposing (Array)
import Console
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Dict.Extra as Dict
import ID exposing (ID)
import Json.Encode as JE
import List.Extra as List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Replicated.Change as Change exposing (Change, Changer, Context(..), Creator)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Node.NodeID as NodeID exposing (NodeID)
import Replicated.Object as Object exposing (I, Object, Placeholder)
import Replicated.Op.Op as Op
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID, OpIDString)
import SmartTime.Moment as Moment exposing (Moment)


{-| A Rep.Store maps custom keys to reptype values, but you don't explicitly add/remove/update entries - instead the store presents a "read-only" interface and you modify the objects in the store instead. Values must have a seedless Codec, because the defaults are used when there is no object yet at that key. Unlike dictionaries, this guarantees you always get a value for a given key - no `Maybe`!

- Since all entries "already exist" (are generated on the fly if missing) for each possible key, there are no library functions to add, remove, or update entries - just `get`.
-}
type Store k v
    = Store
        { entryFetcher : k -> v
        , entryAdder : Change.SiblingIndex -> StoreEntry k v -> Change.ObjectChange
        , included : Object.InclusionInfo
        , startWith : Changer (Store k v)
        , pointer : Change.Pointer
        }


type StoreEntry k v
    = StoreEntry k v


getPointer : Store k v -> Change.Pointer
getPointer (Store store) =
    store.pointer


reducerID : Op.ReducerID
reducerID =
    "store"


{-| Only run in codec
-}
buildFromReplicaDb : Object -> (Change.SiblingIndex -> (StoreEntry k v) -> Change.ObjectChange) -> (k -> v) -> Changer (Store k v) -> Store k v
buildFromReplicaDb object entryAdder entryFetcher init =
    Store
        { entryFetcher = entryFetcher
        , entryAdder = entryAdder
        , included = Object.getIncluded object
        , startWith = init
        , pointer = Object.getPointer object
        }



-- ACCESSORS

{-| Get the stored item at the given key. The return value is guaranteed - no `Maybe` - that's the best part of a `Rep.Store`!
-}
get : k -> Store k v -> v
get key (Store store) =
    store.entryFetcher key



getInit : Store k v -> List Change
getInit ((Store record) as store) =
    record.startWith store
