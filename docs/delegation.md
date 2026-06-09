# Delegation: Just Another Project

> This document explains why Minder doesn't need a special "delegated" task state, and why delegating work is itself a complex, trackable project.

---

## The Misconception

Many task management systems have a "delegated" or "waiting for" state — you assign a task to someone else, and the system tracks it differently: the task is no longer yours to do, just yours to monitor. The expectation is that delegation simplifies your workload.

Minder takes a different view: **delegation is not simpler than doing it yourself. It's often *more* complex.**

---

## Why Delegation Is Complex

Consider: you're going on a two-week trip and need someone to water your plants. The "delegated task" framing suggests this is simple — you hand off "water the plants" and wait. But the *actual* work involved is:

1. Contact multiple trusted neighbors to see who's going to be around
2. Wait for responses
3. Get one to commit to watering your plants on a specific day that fits the schedule
4. Set up a way for them to access your property when needed
5. Lay out unambiguous steps and a plan for the watering, including contingencies
6. *(You leave for the trip — project still not done)*
7. Midway through your vacation, send a reminder text or call to check on progress
8. Deal with the response (or lack thereof) as needed
9. *(Return from trip)*
10. Verify results and remove any special access provisions

That's a **ten-step project** with waiting periods, contingencies, and actions spread across weeks. Calling it "delegated" and treating it as a passive checkbox fundamentally misrepresents the work involved.

For ADHD users especially, the difficulty of a task is often better measured by **number of steps** and **how disconnected those steps are** than by total time or labor intensity. Delegation is a multi-step, multi-day process with context switches between each step — exactly the kind of task that ADHD brains find hardest to manage.

---

## How Minder Models Delegation

In Minder, delegation is modeled as what it actually is: **a project with multiple Actions**, some of which involve waiting.

```
Assignable: "Arrange plant watering for trip"
  Actions (ordered chain):
    1. Contact neighbors about availability
    2. [Pending] Wait for responses
    3. Confirm commitment and schedule
    4. Set up property access
    5. Write watering instructions
    6. [Pending] Mid-trip check-in
    7. Handle check-in response
    8. [Pending] Return from trip
    9. Verify results
    10. Remove access provisions
```

The "delegation" is a detail within the project — not a special system state. The Actions flow through the same scheduling, scoring, and tracking systems as any other task. The "[Pending]" steps are blocked states that set reminders for when the waiting period is expected to end, then resume the chain.

---

## What About the Condition?

A natural objection: "But the plant's condition (time since last watered) should stop degrading once the neighbor agrees to water them."

No — the condition tracks the **plant's actual state**, not the neighbor's agreement. The plant doesn't care who agreed to what. It cares about water.

What changes is the **schedule projection.** Once step 3 is complete (neighbor committed to watering on Thursday), the scheduler knows that the "water plants" task will be executed on Thursday by someone. The condition is "satisfied by future plan" — the same way any scheduled task satisfies its Need in the projection. The condition curve still runs, but the projected satisfaction point is known, so the scheduler can stop trying to find time for you to personally water the plants.

If the neighbor flakes (step 7 reveals no watering happened), the condition projection reverts — the Need is now unmet and the condition has been degrading since you left. The system surfaces this and the user decides: call another neighbor? Accept the loss? Rush home?

---

## The ADHD Case for Explicit Delegation Projects

The explicit multi-step model is especially valuable for ADHD users because:

1. **Nothing falls through the cracks.** "Delegate watering" as a single checkbox means you might remember to ask the neighbor but forget to provide access, or forget the mid-trip check-in. The Action chain makes every step visible.

2. **Waiting periods are tracked.** ADHD brains are terrible at remembering to follow up. The "[Pending] wait for response" action sets a reminder for when you should check back — so you don't forget to confirm the neighbor actually agreed.

3. **The full scope is visible upfront.** When you see the 10-step breakdown, you can make a realistic assessment: "Is delegating this actually worth the overhead, or should I just water the plants before I leave?" Sometimes the answer is the latter.

4. **Context switches are minimized.** The scheduler can batch the delegation steps with other pre-trip preparation tasks, rather than sprinkling them randomly through your week.

---

## Summary

1. **Delegation is a project, not a state.** There is no "delegated" task state in Minder. Delegating work is modeled as a multi-step Assignable with Actions.
2. **The condition tracks reality, not agreements.** The plant's water condition doesn't pause because the neighbor said "sure." It's satisfied when the watering actually happens.
3. **Waiting periods are first-class.** Pending/blocked Actions set reminders and resume the chain when the wait ends.
4. **Delegation complexity is visible.** The full step breakdown helps ADHD users realistically assess whether delegating is worth the overhead.
