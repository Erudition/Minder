module Replicated.Codec.Ordering exposing (..)

{-| Lists items can't have a normal index for ordering since we wouldn't know what numbers have been already used elsewhere before replication.
This can be solved by using a float and using (highest index)+1 for appends, (lowest index)-1 for prepends, and (next index)-(previous index)/2 for inserting between existing items (go halfway between).

However, after many middle insertions the fraction would get super long, and the JS number overflow would cause it to lose precision, causing misordering.

This can be solved by using a string instead of a real float, but the length still explodes, and the integer part needs padding to be sorted correctly. Solutions to this are explored here: <https://observablehq.com/@dgreensp/implementing-fractional-indexing>

My current solution is to store an actual compound number (integer + fraction) instead, where three stored ints X, Y, and Z form the number X+(Y/Z). So to go between 3 and 4, we pick "index" 3.5 by storing 3 + 1/2.

The next inbetween is simply 3 + 1/3 (below) and 3 + 2/3 (above). When stored as a float this would mean a long decimal string of repeating 3s, but when stored as a compound number (3 Ints) it's all the same length. The float conversion should stay precise enough for comparison for a long time.

The X therefore indicates the total start/end insertions, the Y/Z fraction hints at the total middle insertions.

If Y is already min (1) and we need to go lower, we use a fraction with a 1-higher denominator. e.g. to insert before 1/3, we use 1/4.
If Y is already max (same as denominator) and we need to go higher, increment the denominator. e.g. to insert after 2/3, we use 3/4.

For bulk insertions, increment the denominator by the total amount upfront, to save precision.

I came up with this method, it's unproven and needs testing. TODO consider algorithms such as
<https://mattweidner.com/2022/10/21/basic-list-crdt.html#intro-string-implementation>

-}


type Ordering
    = Ordering Int Int Int
