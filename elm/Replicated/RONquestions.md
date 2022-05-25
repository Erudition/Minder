# op text compression
  - If the second chunk in a frame will have an incremental op ID, can it's header op omit the ID, like elsewhere in a chain? Or must we specify opID on every new chunk?

# Op text parsing
  - spec ordering: since *reducers, #objects, @ids, and :references each have their unique start token, it would be unambiguous which is missing. does that mean they can appear in any order? or must it be in that order only?
