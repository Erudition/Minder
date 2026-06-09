# Scheduling: How Minder Decides What to Do When

> This document describes Minder's scheduling engine — the system that takes the task layers (what needs doing), the Cares and conditions (why it matters), and the user's available time, and produces an optimized schedule. It assumes you've read [task-layers.md](task-layers.md) and [cares.md](cares.md).

---

## Design Philosophy: No Overdue, No Guilt

Minder's scheduling engine is designed for people with ADHD and executive dysfunction. This is not an afterthought — it is the foundational design constraint that shapes every decision.

### The Problem with Traditional Reminders

Traditional task management relies on alarms and deadlines: "Do X by Y." If you miss Y, the task is "overdue." This creates a binary flip from "everything is fine" to "you've failed." For neurotypical users, this is mildly annoying. For ADHD users, it's catastrophic:

1. **The first missed alarm starts a spiral.** You dismiss a reminder — not from laziness, but because you're driving, or in a meeting, or mid-crisis. The alarm came at the wrong time.
2. **Dismissal becomes habit.** After a few dismissed reminders, the brain learns that alarms are ignorable. The notification sound stops triggering urgency and starts triggering guilt.
3. **Guilt becomes avoidance.** The app fills with overdue items. Opening it feels bad. You stop opening it.
4. **The system is now worse than nothing.** You've spent time setting up tasks, defining deadlines, and configuring reminders — and the net effect is negative. You've trained yourself to ignore the one tool that was supposed to help.

The core failure is that traditional systems assume you *can* always act on a reminder when it fires. ADHD brains can't guarantee that.

### Minder's Alternative: Scores, Not Alarms

Minder replaces the binary "overdue/not overdue" model with a **continuous scoring function**. Nothing is ever "overdue." Tasks just become gradually more valuable to do as conditions drift, and gradually less valuable when conditions are fresh. The system never punishes you for being human — it just keeps doing math.

When you open Minder, you see a ranked list: "Here's what would be most valuable to do next, given your current capacity." If you can do one thing, it shows you the one thing. If you can do five, it shows five. If you can do nothing right now, the scores quietly adjust in the background, and when you *are* ready, the ranking reflects reality.

This means:
- **There is no "catch up" state.** You can't fall behind, because there's no fixed timeline to fall behind on. You're always exactly where you are, and the system optimizes from here.
- **No guilt spiral.** Nothing is red. Nothing is overdue. Nothing is yelling at you. There's just a list, sorted by value.
- **Capacity-aware.** "How much can I practically handle right now?" is the first question, not "what's overdue?" Start by deciding your capacity, then the system fills it from the top.

### Smart Alarms: Only When You Definitely Can *and* Should

Minder (the name comes from "reminder") absolutely will have alarms — ADHDers can't be relied on to passively decide to check a list at reasonable intervals. But Minder's alarms are **contextually aware**:

- An alarm only fires when you *definitely can* do the thing (you're in the right location, you're not mid-task on something more important, your sensors suggest you're available).
- An alarm only fires when you *definitely should* do the thing (the score is high enough that acting now is clearly better than waiting).
- The determination of availability is informed by **Activity tracking** — Minder uses sensors to estimate whether you're still doing what you said you're doing. If you're mid-workout, it won't remind you to file your taxes. If you've been idle at your desk for 20 minutes, it might gently surface the next high-value task.

The result: when a Minder alarm fires, the user can trust it. "If Minder is telling me this, it's because right now is genuinely the right time." That trust is the opposite of the dismissal habit — it's an engagement habit.

---

## The Scoring Engine

### Per-Need Scoring

The fundamental unit of scheduling is not a task — it's a **Need**. The pathfinding algorithm iterates through Needs (weighted by importance of the Care they belong to) and for each Need, evaluates which implementation task in which timeslot produces the highest score.

This is the key insight: **multiple tasks can satisfy the same Need, and the scheduler picks the best one given the context.**

- Biking to work takes 5x longer than driving, but if you have the time, it meets your Exercise need *and* your Commute need — scoring double.
- Eating at the diner you've been wanting to try costs more gas and time than cooking at home, but if you're already in the area, it satisfies Dinner *and* the "try new restaurant" Wish — scoring double.
- A gym workout is your preferred exercise, but if you're stuck at the airport, a phone app workout still scores positive against the Exercise need — better than nothing.

This is fundamentally different from "recurring tasks." Traditional recurring tasks say "do X every Y days." Minder says: "Need Z must be satisfied. Here are tasks A, B, C that can satisfy it. Pick the best one given the current schedule, location, and capacity."

### The Score Curve

For each Need with a condition-tracked attribute, the score of scheduling a remedying task at a given point in time follows a smooth curve:

```
Score
  ▲
  │                                              ╱ increasing score
  │                                           ╱    (neglect penalty ramps up)
  │                                        ╱
  │                        ╭─── peak ───╮╱
  │                      ╱   (late ideal = most efficient)
  │                   ╱
  │                ╱
  │─ ─ ─ ─ ─ ─ ╱─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  │           ╱
  │  near-zero (too fresh — task is ineffective)
  │╱
  └────────────────────────────────────────────────► Time since last done
       Fresh     Ideal      Okay      Poor     Critical
```

- **Too fresh** → near-zero score. Doing the task now wastes a time slot that could be used for something that actually scores. (But not literally zero — see graceful degradation below.)
- **Late ideal window** → peak score. This is the most efficient placement: you got the maximum "life" out of the last maintenance, and you're acting before any degradation.
- **Past okay** → still increasing, but with diminishing returns relative to the accumulating damage. The task is urgent but the condition is already degraded.
- **Cumulative neglect** → negative points accumulated over the timeline. This prevents the optimizer from stacking all maintenance at the last minute. A schedule that lets teeth go unbrushed for a week before finally brushing "scores" negatively for each day of neglect, even if the eventual brushing scores high. (See anti-procrastination below.)

### Anti-Procrastination: Cumulative Scoring

Without cumulative scoring, a pure optimizer would push every maintenance task to the last possible moment — because that's when each individual task scores highest (maximum time since last done = maximum per-task score). This is mathematically "optimal" but humanly terrible.

Minder prevents this by scoring not just the moment of task execution, but the **entire condition trajectory over the scheduled period.** Every time unit where a condition sits in the "poor" or "critical" zone accumulates negative score. The optimizer sees:

- Schedule A: brush teeth every morning → condition stays in Fresh/Ideal zone → no negative accumulation
- Schedule B: brush teeth once a week → condition spends 5+ days in Poor/Critical zone → heavy negative accumulation

Schedule A wins, even though each individual brushing in Schedule B would score higher at the moment of execution (more neglect = higher immediate score).

### Multi-Care Tiebreaking

When two scheduling choices satisfy the same Need equally, the **number of additional Cares they serve** breaks the tie:

- "Walk the dog" satisfies your Exercise need *and* your dog's Exercise need → two Cares
- "Go for a solo run" satisfies only your Exercise need → one Care

The walk scores higher, all else being equal. This is how the many-to-many relationship between tasks and Cares directly influences scheduling — the system naturally surfaces tasks that efficiently address multiple concerns at once.

### Graceful Degradation

The scoring model degrades gracefully when the ideal schedule is impossible:

- **Overscheduled?** If you have more important tasks that fill the ideal window for a maintenance task, the task slides to the next-best slot — slightly too fresh or slightly too late, but still better than not at all.
- **Going out of town?** If you can't water the plants for two weeks and they'll be past "critical" by the time you return, the system recognizes that watering them now (even though it's "too fresh") scores higher than not watering them at all. The "too fresh" score is near-zero but positive; the two-week neglect accumulates deeply negative. Near-zero wins over deeply negative.
- **Everything is urgent?** The system doesn't panic. It serves the ranked list: here's the most valuable thing to do with the next available time slot. Then the next. And the next. No red flags, no guilt — just one thing at a time, in order.

---

## Schedule Structure

### Fuzzy Time Blocks

Minder's schedule does not have strict start and end times for most blocks. Each scheduled block includes a **fuzzy window** at the end (and sometimes the beginning) that represents buffer time:

```
┌─────────────────────────────────────────────┐
│ Core task time               │ Fuzzy window │
│ (50th percentile duration)   │ (buffer)     │
└─────────────────────────────────────────────┘
```

The fuzzy window is determined by the gap between the Assignable's **50th percentile duration** (typical case) and **90th percentile duration** (long case). These estimates are refined over time as Assignments are completed and their actual durations recorded.

- By default, the fuzzy window is blocked off — no other tasks are scheduled in it.
- The user can **manually compress** a fuzzy window if they need tighter scheduling, accepting the risk that the task might run long.
- The total amount of fuzzy time in a schedule determines how much **flexibility** it has. A schedule packed with compressed fuzzy windows is fragile; one with generous buffers can absorb surprises.

### Task Switching Costs

The scheduler optimizes not just for *what* to do, but for *how to sequence it*. Task switching has real psychological costs:

- **Willpower demand.** Each switch is an opportunity for distraction. More switches = more opportunities to lose focus.
- **Decision fatigue.** Choosing what to do next is cognitively expensive, especially for ADHD brains. The schedule should minimize the number of decisions.
- **Loss of flow state.** Deep Work requires sustained focus. Frequent switching prevents the flow state from ever establishing.
- **Satisfaction.** A day spent on five things for 20 minutes each feels less productive than a day where you made real progress on two things, even if the total output is identical. The sense of momentum matters.

This means the scheduler penalizes fragmented schedules — many short blocks of different Activities score lower than fewer, longer blocks of sustained work. The penalty is a tunable parameter, because some days call for variety and some call for deep focus.

---

## The Pathfinding Algorithm

### Approach: Experimental, Not Predetermined

The specific algorithm for the scheduler is **not yet finalized by design.** The system needs to be built to the point where real scoring data is available before the algorithm can be properly tuned. The current design intent:

### Original Concept: Iterative Greedy with Relaxation

The initial design involves a greedy solver that runs in multiple passes:

1. **First pass:** Place the most important task in its most preferred time slot. Then the second most important. And so on. This is a strict greedy approach — highest priority wins, no compromises.
2. **Second pass:** Re-run with slightly relaxed insistence on preferred times. Maybe the most important task can move to its second-best slot if that frees up a better overall schedule.
3. **Further passes:** Continue relaxing until the schedule stabilizes.

This handles cases like: "I'd prefer to work on Minder at my desk, but I'll be at the airport on Tuesday. If I clean my room on Monday and do Minder work at the airport, I can fit both in. If I insist on desk-Minder on Monday, the room doesn't get cleaned before the trip." The first pass might greedily place Minder-at-desk on Monday; the second pass recognizes that relaxing that placement unblocks the room cleaning.

### Trade-offs Under Consideration

- **Pure greedy** can be exactly right when you want to prioritize the most important task above all else — "cramming for a college exam instead of sleeping" is a valid human choice, and a global optimizer might try to balance sleep and studying when the student wants to go all-in.
- **Stochastic solvers** would introduce valuable diversity (different schedule candidates each run), but may conflict with the task-switching penalty. A schedule that's globally optimal by score but switches tasks every 30 minutes is humanly worse than a slightly lower-scoring schedule with sustained focus blocks.
- **The right answer is probably a hybrid** — greedy priority ordering with local optimization for sequencing and multi-Care synergies. But this needs to be validated with real data.

---

## How the Scheduler Connects to Everything Else

```
Cares                           Task Layers
  │                                │
  ├─ Need (condition curve)        ├─ Assignable (task template)
  │    └─ Goal (target, strategy)  │    └─ Assignment (instance)
  │         └─ links to ──────────►│
  │                                │
  ├─ Wish (aspirational)           ├─ Action (atomic step)
  │    └─ optionally linked to ──►│    └─ AssignedAction (instance)
  │                                │
  └─ Attribute → Condition ────────┘
       (scoring input)           
                    │
                    ▼
            Scoring Engine
                    │
                    ▼
        Pathfinding Algorithm
                    │
                    ▼
             Schedule Output
              ├─ Time blocks (with fuzzy windows)
              ├─ Smart alarms (contextual)
              └─ Ranked task list (for manual selection)
```

---

## Summary of Design Principles

1. **No overdue, no guilt.** Nothing in Minder is ever "overdue." Tasks become gradually more valuable to schedule as conditions drift. There is no binary flip from "fine" to "failed."

2. **Scores, not deadlines.** The scheduler produces a ranked list based on continuous scoring, not a set of pass/fail deadlines. The user chooses capacity first, then the system fills from the top.

3. **Smart alarms earn trust.** Alarms fire only when you definitely can *and* should act. The goal is an engagement habit (trust the alarm) not a dismissal habit (ignore the alarm).

4. **Per-Need, not per-task.** The scheduler evaluates which task satisfies a Need best in context, not which task is "due." Multiple implementation plans compete naturally.

5. **Anti-procrastination is structural.** Cumulative condition-trajectory scoring prevents the optimizer from stacking maintenance at the last minute. Living in "poor" condition accumulates negative score.

6. **Graceful degradation over optimal rigidity.** When the ideal schedule is impossible, the system finds the next-best option rather than marking everything overdue.

7. **Task switching has real costs.** The scheduler penalizes fragmented schedules. Sustained focus blocks score higher than equivalent time split across many tasks.

8. **Fuzzy, not rigid.** Time blocks have probabilistic buffers based on historical duration data. Schedules are flexible by default and compressible when needed.

9. **The algorithm is experimental.** The specific pathfinding approach (greedy, stochastic, hybrid) is intentionally deferred until real scoring data is available for validation.
