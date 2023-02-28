# Now
- [ ] Figure out if Contexts are needed
- [X] Fix case where pointers merge for some reason
- [X] If new object is wrapped in custom type, it will be ref'd and init without its changes. fix 
- [ ] write test for above
- [ ] Determine what parts of Node.processDelayedInMapping are now unneeded
- [ ] Test delayed changes getting pulled into later object init rather than done last
- [ ] Determine why delayed changes need to be reversed
- [X] Stop producing redundant delayed changes. Join adjacent same-object changes
- [X] Refactor late installers to be ordered
- [X] Detect Node root on first run
- [ ] Figure out how to encode empty flatlists, or allow [] to parse
- [X] Write test for late installers
- [ ] Write test for divergent nodes
- [X] Refactor codebase around Changes that contain any-object changes
- [X] Prescribe all node encoders and decoders, no maybe fallbacks
- [X] Wrap all encoded values in type saying whether the encoding can be skipped
- [X] Registers not initialized if their first usage is external (within a creator function) (taskInstances)
- [X] Get only non-default register values to encode
- [X] Test post-init substitutions (above)
- [X] Get late installers to work
- [X] Skip empty naked record field encoding


# Soon
- use Codec.new as defaults for reg fields, so that seeded is the only time default is missing. Try to pass in Encoder with Context so we can benefit from proper EncoderInputs
- always startNewNode with a root object, the master replica
- change register to use label_3 naked string format (like variants) rather than separate Int
- do single quotes get properly escaped on output?
- Parse OpIDs upfront and store in proper record form
- Constrain the exposing(..) of Codec
- get json decoding working
- get bytes decoding working


# Later
- switch elm/parser to the-sett/parser-recoverable so that bad ops can be skipped without crashing
- Ops should be custom type like EventOp {record} | ReversionOp opID | CreationOp reducerID | AssertionOp ...
- spit out warnings for nested errors
- tolerate double-quote strings as well
- To format RON Ops that have been stripped of newlines, regex replace "[,|;|.]" with "$0\n" (vscodium format)


# Way later
- Consider using the new standard, UUID version 7 for IDs, which now has a simply sortable time-based counter just like we use with RON UUIDs.
  - Consider using the new UUID version 8 as well, which is designed for custom inclusions so we can still include the Node ID, etc in the UUID. Actually section 6.3 specifically says including a node ID is suggested but should use v8.
  - On the other hand, section 6.8 says UUIDs should not be inspected to get that node/time/whatever data, which is exactly what we want to be able to do (so we don't have to store it elsewhere.) Further, we don't really need any random bits for unique ops, the monotonic counter and node ID should do the trick. Including a globally unique user ID will need it though.


# Differences from offical RON 2 (at replicated.cc)
- (+) Unlike LWW registers in RON, ours natively support merging of concurrently created objects. This could be considered a feature of Multi-Valued Registers rather than simple LWW.
- (-) UUIDs ("OpIDs") use simple integer counters/clocks/timestamps rather than RON's "calendar-aware" timestamps for now.
- (-) Support for Pseudo-ops covers only comment-like functionality for now. 
- (-) The RON API is not yet implemented.
  - (-) That means no Query and Assertion Chunks (end in ? and !), only Event chunks (;)
- (-) Reducers currently supported are only LWW and RGA (replist).
- (-) Only the nominal text format (open and closed!) are currently supported. Binary is planned.
- (!) RGA uses the "replist" reducer ID instead of "rga" for now


# Archive
- [X] Determine why newly initialized objects (replist) are not detected until refresh (causing multiple inits while still placeholder in-ram) - update - due to lack of below
- [X] Always auto-detect root object
- [X] Fix missing nodeID from reference OpID when it's a reversion op
- [X] Fix reversion Ops not persisting
- [X] Fix all RON Parsing errors
- [X] Create nice RON parser error messages
- [X] Track Placeholder<->ObjectID coorespondence when initializing so substitutions can be made
- [X] Deal with prechanges that affect some other object (externalChanges)
- [X] Get naked records read-only enforced
- [X] if object changes are nested in a parent object change, they cannot be grouped together properly (thus each creating their own object) because it would be difficult and inefficient to recurse the whole nest change list every time we saveChanges (every frame). So we regroup at every level we can, such as in the replist adder. But we could move away from needing to use a function wrapper from the parent frame, and instead just have a change include a list of parent notifiers (as a flat custom type that indicated how to wrap it) and it would be easy to group them by same values in same places in that list. DONE - all changes are now Sets, ChangeSets.