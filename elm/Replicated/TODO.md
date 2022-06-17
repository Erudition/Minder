# Now
- get all node decoders working with new unwrapped skins
- do single quotes get properly escaped on output?
- kept events not always loaded backwards into register field history dict?






# Later
- tolerate double-quote strings as well
- if object changes are nested in a parent object change, they cannot be grouped together properly (thus each creating their own object) because it would be difficult and inefficient to recurse the whole nest change list every time we saveChanges (every frame). So we regroup at every level we can, such as in the replist adder. But we could move away from needing to use a function wrapper from the parent frame, and instead just have a change include a list of parent notifiers (as a flat custom type that indicated how to wrap it) and it would be easy to group them by same values in same places in that list.
