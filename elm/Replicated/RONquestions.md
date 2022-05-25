# op text compression
  - If the second chunk in a frame will have an incremental op ID, can it's header op omit the ID, like elsewhere in a chain? Or must we specify opID on every new chunk?
  - a chain lets you skip references to the previous op, and a span lets you skip opIDs that are an increment of the previous op's. the glossary says that a span "is a chain" - implying you can only omit opIDs when you're also already omitting references. If the odd op comes along with a different reference, that would mean that not only does the chain end, but the span ends too, even if op IDs continue to be incremental. or can we continue the span (implying it is not bound to a chain by definition)?

# Op text parsing
  - spec ordering: since *reducers, #objects, @ids, and :references each have their unique start token, it would be unambiguous which is missing. does that mean they can appear in any order? or must it be in that order only?
  - suppose we didn't need any chunk type besides event chunks, ending in ";". Then, could we get rid of all line terminators? E.g. Newlines after ops instead of "," and a blank line to separate frames... We can deduce the switch between chunks by the fact that an op is referencing a different object, no? Is there some reason that couldn't always be deduced? RON logs would look much cleaner...


# definitions
  - "Chunk: a group of related ops within a frame, e.g. object state or a patch." This seems much looser than what "chunk" means everywhere else - strictly operations on the same object, not merely "related" ops. saying "or a patch" further implies a chunk could contain ops from different objects, as "patch" is defined as "a group of ops modifying the same tree/object" where "tree" is anything that fits "a causally ordered group of ops forming a tree". Chunks are exclusively same-object ops, yes?


# Ron 3.0
  - it seems that RON IDs are defined differently on "http://doc.replicated.cc/%5EWiki/'serial'/ront.sm" such that they are only ever joined with a "+" and not a "-" (unless there are two of them, one in the middle of the first piece.): (HALF '-' HALF '-' WORD ) or (WORD '+' WORD). This seems simpler, but how then do you handle "undo" operations? Currently you just switch the plus to a minus (exclusively in a reference) to say you mean to undo the op.
