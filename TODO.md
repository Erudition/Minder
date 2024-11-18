# Main Elm Architecture
- New way to init subviews in one place only
- URL codecs for view state


# Replicator Framework
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


# Task list
- "////" in title causes slow/infinite loop - properly escape?

# Timeflow
- Take widget out of dictionary, we'll probably only need a pre-known amount
- Responsive screen sizing

# Task data structures
- [X] move Assignment et. al. back into their own modules
