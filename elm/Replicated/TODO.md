# Now
- A change setting a field's value to the default should still be emitted to RON if the field has been set to something non-default before. Do I currently do that? What if some unknown peer has set something non-default but the local replica doesn't know yet - the local one would be unable to LWW-override it with the default...



# Soon
- change register to use label_3 naked string format (like variants) rather than separate Int
- do single quotes get properly escaped on output?
- Parse OpIDs upfront and store in proper record form



# Later
- tolerate double-quote strings as well
- if object changes are nested in a parent object change, they cannot be grouped together properly (thus each creating their own object) because it would be difficult and inefficient to recurse the whole nest change list every time we saveChanges (every frame). So we regroup at every level we can, such as in the replist adder. But we could move away from needing to use a function wrapper from the parent frame, and instead just have a change include a list of parent notifiers (as a flat custom type that indicated how to wrap it) and it would be easy to group them by same values in same places in that list.

# Way later
- Consider using the new standard, UUID version 7 for IDs, which now has a simply sortable time-based counter just like we use with RON UUIDs.
  - Consider using the new UUID version 8 as well, which is designed for custom inclusions so we can still include the Node ID, etc in the UUID. Actually section 6.3 specifically says including a node ID is suggested but should use v8.
  - On the other hand, section 6.8 says UUIDs should not be inspected to get that node/time/whatever data, which is exactly what we want to be able to do (so we don't have to store it elsewhere.) Further, we don't really need any random bits for unique ops, the monotonic counter and node ID should do the trick. Including a globally unique user ID will need it though.
