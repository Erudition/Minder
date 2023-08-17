module Replicated.Reducer.RepStore exposing (RepStore, RepStoreEntry(..), buildFromReplicaDb, get, getInit, getPointer, listModified, reducerID)

import List.Nonempty exposing (Nonempty(..))
import Replicated.Change as Change exposing (Change(..), ChangeSet, Changer, Parent(..))
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op



-- TODO rename to RepDictSparse


{-| A Rep.Store maps custom keys to reptype values, but you don't explicitly add/remove/update entries - instead the store presents a "read-only" interface and you modify the objects in the store instead. Values must have a seedless Codec, because the defaults are used when there is no object yet at that key. Unlike dictionaries, this guarantees you always get a value for a given key - no `Maybe`!

  - Since all entries "already exist" (are generated on the fly if missing) for each possible key, there are no library functions to add, remove, or update entries - just `get`.

-}
type RepStore k v
    = Store
        { entryFetcher : k -> v
        , included : Object.InclusionInfo
        , startWith : Changer (RepStore k v)
        , pointer : Change.Pointer
        }


type RepStoreEntry k v
    = RepStoreEntry k v


getPointer : RepStore k v -> Change.Pointer
getPointer (Store store) =
    store.pointer


reducerID : Op.ReducerID
reducerID =
    "store"


{-| Only run in codec
-}
buildFromReplicaDb : { object : Object, fetcher : k -> v, start : Changer (RepStore k v) } -> RepStore k v
buildFromReplicaDb { object, fetcher, start } =
    Store
        { entryFetcher = fetcher
        , included = Object.getIncluded object
        , startWith = start
        , pointer = Object.getPointer object
        }



-- ACCESSORS


{-| Get the stored item at the given key. The return value is guaranteed - no `Maybe` - that's the best part of a `Rep.Store`!
-}
get : k -> RepStore k v -> v
get key (Store store) =
    store.entryFetcher key


{-| Get your RepDict as a read-only List.
-}
listModified : RepStore k v -> List ( k, v )
listModified (Store store) =
    Debug.todo "List store entries?"


getInit : RepStore k v -> ChangeSet
getInit ((Store record) as store) =
    record.startWith store
        |> Change.collapseChangesToChangeSet "RepStoreInit"
