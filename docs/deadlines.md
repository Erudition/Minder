# Deadlines: Why Minder Discourages Them

> This document explains Minder's philosophy on deadlines — why they're treated as a last resort, what replaces them, and how the system handles the messy reality of "due dates" in human life.

---

## The Tyranny of Deadlines

In most task management systems, a deadline is the primary urgency signal: "Do X by Y." The system treats the deadline as sacred — before Y, the task is "not yet due"; after Y, the task is "overdue." This binary flip creates problems:

1. **Fake deadlines crowd out real ones.** When everything has a deadline, nothing does. Users set "deadlines" for tasks that don't actually have one ("clean the garage by Saturday") alongside tasks that truly do ("file taxes by April 15"). The system treats them identically, so the user must mentally triage which deadlines are real — defeating the purpose of the system.

2. **Deadlines tyrannize flexibility.** A hard deadline on a low-importance task can force it ahead of a high-importance task with no deadline. If "buy birthday card by Thursday" and "prepare for job interview next week" are both in the system, the birthday card wins on urgency alone, even though the interview is vastly more important. The deadline's binary nature exploits the flexibility of everything else.

3. **Missed deadlines trigger the guilt spiral.** Once a deadline passes, the task is "overdue" — a permanent failure state that can only be resolved by completing the task or deleting it. For ADHD users especially, this creates the avoidance spiral described in [scheduling.md](scheduling.md): the app fills with red items, opening it feels bad, so you stop opening it.

4. **Deadlines imply false precision.** "Due April 15" suggests that April 14 is fine and April 16 is failure. In reality, most deadlines have a gradient of consequences — turning in homework one day late might cost 10%, a week late might cost 50%, and a month late might still be worth doing for partial credit. The binary model can't represent this.

---

## Minder's Approach: External Deadlines Only

In Minder, the deadline field is explicitly called the **"external deadline"** — even in the code. The word "external" is technically redundant (a self-imposed deadline is not really a deadline), but it serves as a constant reminder: **only set a deadline if it's a real, authoritative limit that is out of your control.**

Examples of genuine external deadlines:
- Tax filing date (set by the government)
- Flight departure time (set by the airline)
- Application closing date (set by the institution)
- Rent due date (set by the lease)

Examples of things that are NOT deadlines:
- "I want to clean the garage this weekend" → This is a wish, not a constraint.
- "I should finish this report by Friday" → This is a goal, not an external limit.
- "I need to exercise three times this week" → This is a condition target (see [conditions.md](conditions.md)), not a deadline.

The urgency that fake deadlines create — that sense of "I should do this soon" — is achieved in Minder by other, more appropriate mechanisms: condition scoring, Need importance, Care neglect, and the scheduling engine's continuous score curve.

---

## Deadline ≠ Expiration

Minder distinguishes between two temporal boundaries:

**Deadline** = the date by which the task *should* be completed. After this point, there may be consequences (late fees, reduced credit, social embarrassment), but the task can often still be done.

**Expiration** = the date after which the task *cannot* be completed, or has zero remaining value. After this point, there is literally no point in doing it.

The expiration, when defined, is always ≥ the deadline. The gap between them is the **grace period** — the window where completing the task still has *some* value, even if reduced.

```
     Deadline          Expiration
        │                  │
────────┼──────────────────┼──────────────►
        │   Grace Period   │
        │  (partial value) │  (zero value,
        │                  │   task removed)
```

### Examples

| Task | Deadline | Expiration | Grace Period |
|---|---|---|---|
| File US taxes | April 15 | Never (can file years late) | Indefinite, with increasing penalties |
| Submit homework | Monday 9am | Friday 5pm | 4 days at reduced credit |
| Catch a flight | Gate closes 10min before | Departure time | ~10 minutes |
| Water plants before trip | Day of departure | ~2 weeks (plant death) | Variable, degrading |
| RSVP to wedding | RSVP date | Wedding date | Weeks, but increasingly awkward |

Notice: the **expiration == deadline** case (zero grace period) is actually rare. Most "deadlines" that people treat as absolute have a grace period — you just don't want to use it. Minder makes this explicit so that if you *do* miss the deadline, the system doesn't throw the task away. It adjusts the score (reduced value, increasing urgency to capture remaining value) rather than marking it "overdue."

---

## Deadlines as Degenerate Condition Curves

Under the hood, deadline-driven tasks use the same scoring framework as condition-driven maintenance tasks. The "condition" being tracked is **the number of remaining scheduling opportunities** before the deadline:

- If a task takes an estimated 3 hours and the user works in 90-minute sessions, how many 90-minute openings remain before the deadline?
- The fewer openings remain, the "worse" the condition — and the higher the score for placing the task now.

This means the scoring engine doesn't need special deadline logic. A deadline task and a maintenance task both flow through the same per-Need scoring pipeline. The only difference:

- **Maintenance tasks** have a "too fresh" zone — doing them too soon is wasteful. The score curve is bell-shaped.
- **Deadline tasks** typically have no "too fresh" zone — doing them now is always at least as good as doing them later. The score curve ramps monotonically. For important tasks, the natural result is "do it as soon as you assign it," with variance for convenience (time of day, location, energy level). This aligns with standard advice for school assignments and provides the maximum possible buffer against procrastination.

The user can always override the schedule by dragging a time block elsewhere in the timeline. But the *default* placement for a deadline task is "as early as practical," not "as close to the deadline as possible."

---

## Start and Stop Dates

For tasks without hard external deadlines, Minder offers **Start and Stop dates** as an alternative framing:

- **Start date** = the earliest this task could be done. Before this date, the task isn't actionable (e.g., "pick up dry cleaning" can't happen before the cleaning is ready).
- **Stop date** = the latest this task should ideally be done. Unlike a deadline, this is a soft boundary — the scheduler prefers to complete the task before the stop date, but doesn't treat missing it as failure.

The scheduler finds a time within the start-stop window for completion. Slotting closer to the end of the window scores lower — not because of a deadline penalty, but because there's less buffer time to recover if the task runs long or an emergency arises.

---

## Summary

1. **Deadlines should be external and real.** Self-imposed deadlines belong in the scoring system as condition targets or goals, not as hard temporal boundaries.
2. **Expiration is distinct from deadline.** Most tasks have value even after their deadline. Making the grace period explicit prevents premature abandonment.
3. **Deadline urgency is achieved by scores, not by binary flags.** The scoring engine treats deadline proximity as a continuously increasing score, not a flip from "fine" to "overdue."
4. **Start/Stop dates are the preferred framing** for tasks without genuine external deadlines.
5. **"Priority" is not a Minder concept.** Urgency (time-sensitive) and importance (value-weighted) are orthogonal dimensions. The scoring engine computes their interaction; the user doesn't need to manually set a single "priority" number.
