# Now
- [ ] Fix all RON Parsing errors
- [X] Create nice RON parser error messages
- [ ] Track Placeholder<->ObjectID coorespondence when initializing so substitutions can be made
- [ ] Move Codec.new functionality to individual reptypes - allows blocking naked record pre-changes
- [ ] Deal with prechanges that affect some other object - maybe a separate field in Chunk {}?
- [X] Get naked records read-only enforced
- [ ] Always auto-detect root object


# Soon
- change register to use label_3 naked string format (like variants) rather than separate Int
- do single quotes get properly escaped on output?
- Parse OpIDs upfront and store in proper record form
- Constrain the exposing(..) of Codec
- get json decoding working
- get bytes decoding working


# Later
- spit out warnings for nested errors
- tolerate double-quote strings as well
- if object changes are nested in a parent object change, they cannot be grouped together properly (thus each creating their own object) because it would be difficult and inefficient to recurse the whole nest change list every time we saveChanges (every frame). So we regroup at every level we can, such as in the replist adder. But we could move away from needing to use a function wrapper from the parent frame, and instead just have a change include a list of parent notifiers (as a flat custom type that indicated how to wrap it) and it would be easy to group them by same values in same places in that list.


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