# Main Elm Architecture
- New way to init subviews in one place only
- URL codecs for view state


# Replicator Framework
- Node needs to store objects again, for lazy updates - object must store their parents too

- [X] Remove custom error type variable to simplify code
    - [] allow user to provide string codec to handle errors with their custom error type
- [X] Split codec module into pieces to simplify code
- [] decoder functions compare to previous object for skipping
    - [] Decoders return ObSubs (Object subscriptions) - list of ObjectIDs that are contained within them
- [] consider removing custom error type from JSON/Bytes decoders entirely
- [] separate reducers from reptypes, many reptypes are just collections
- [] Make Node contain objects in already reduced form, with already decoded values

- Why do certain .set changes get ignored in tests?
- Why is parent init change not required?
- Put showstopper RON debugger in place
- Rename RepStore to RepDictSparse
- [X] Put OpDb in its own type file

- UNDO/REDO Framework
    - Create ReversibleOps type - `List OpID` of reversible ops
    - Allow output of changes with ReversibleOps placeholder as value
    - When converting changes to ops, fill in any ReversibleOps placeholder with the frame's reversible OpIDs
    - When converting reversal changes to reversal ops, calculate OpIDs' ExistingObjectIDs and merge into ChangeSets

- Codecs
    - [] Create elm-review rule to auto generate codecs - already supports elm-serialize
        - https://package.elm-lang.org/packages/gampleman/elm-review-derive/latest/

# Task list
- "////" in title causes slow/infinite loop - properly escape?

# Timeflow
- Take widget out of dictionary, we'll probably only need a pre-known amount
- Responsive screen sizing

# Task data structures
- [X] move Assignment et. al. back into their own modules
