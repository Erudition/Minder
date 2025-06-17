# Main Elm Architecture
- New way to init subviews in one place only
- URL codecs for view state
- Consider using Lamdera framework where service worker is "backend"

# Replicator Framework
- Node needs to store objects again, for lazy updates - object must store their parents too
  - Can't just store objects in their replica host (the reptype in the model that expresses them) because incoming external ops won't know where to go without checking the whole replica
  - Can't just store updaters (lenses) for parent collections at the top level to update nested parts of the replica, because incoming external ops have only their leaf objectID and no way to tell what their ancestors are
  - Having a top-level dict with updaters for every single nested object, even those in big lists, would create a huge dictionary
  - Best way is to have parent-child relationships reported from the start, so we can find any child given the ID of an ancestor
    - Could store all this in a separate object dictionary again and update it, but might as well just store it in the op itself, no new dict
    - Now we don't need accessors/lenses and avoid another type var on codecs, since we can skip whole branches of the replica tree when updating

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
