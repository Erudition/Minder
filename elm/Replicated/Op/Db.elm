module Replicated.Op.Db exposing (..)

import Dict.Any as AnyDict exposing (AnyDict)
import List.Nonempty exposing (Nonempty(..))
import Replicated.Change exposing (ChangeSet(..), Pointer(..))
import Replicated.Identifier exposing (..)
import Replicated.Op.ID as OpID exposing (OpID, OpIDSortable)
import Replicated.Op.Op exposing (Op)



-- Should we index by ref? probably not, that's a lot of duplication in memory and big trees.
-- Ron site says: https://web.archive.org/web/20220223000037/http://replicated.cc/rdts/rga/
-- The reason for this behavior is to avoid the overhead of maintaining reference-based datastructures (trees, linked lists, etc). Instead, CT uses sequential access and flat datastructures as much as possible. Even in C++, maintaining a tree is plenty of overhead. In higher-level languages (think Java/JavaScript) a tree may consume 100x more RAM than a flat buffer. A linked list is considered a worst-case datastructure for a garbage collector. Hence, we aim to maximize the use of flat buffers and sequential access.
-- Why we would want to index by ref:
-- - To tell whether an op is reverted, we need to see if any reversion ops reference it, and then check if any revert that reversion, and so on.
--   - Worth the recursion if only done at undo time? Just store reversion status in the op?
-- UPDATE:
-- On second thought, we're already storing our ops in a reference-based datastructure (no other way to go about it in Elm?) and having a "copy" of a non-primitive in Elm is actually just a pointer to the original since it's all immutable - so we're not saving much by avoiding it


type alias OpDb =
    AnyDict OpIDSortable OpID Op


empty : OpDb
empty =
    AnyDict.empty OpID.toSortablePrimitives
