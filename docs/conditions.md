# Conditions: Measuring How Well Things Are Going

> This document describes how Minder measures and tracks the state of the things you care about — the Attribute/Condition system. It assumes you've read [cares.md](cares.md) for what Cares and Needs are, and [scheduling.md](scheduling.md) for how conditions feed the scoring engine.

---

## Overview

Every Care has things about it that can be measured. Your hair has a length. Your car's engine has miles since the last oil change. Your lawn has a grass height. These measurable dimensions are called **Attributes**. Each Attribute has a **Condition** — a subjective interpretation of how good or bad the current value is.

The key design principle: **measurement and interpretation are stored separately.** Your hair being 10 inches long is a fact. Whether 10 inches is "fine" or "overgrown" is your opinion. Minder tracks both, independently.

---

## Attributes

An **Attribute** is an objective, measurable dimension of a Care. It has:

- **A name** — "length," "cleanliness," "miles since oil change"
- **A unit** (optional) — inches, days, miles, a 1-10 subjective rating
- **A history** — every measurement recorded over time
- **A progression dimension** — what causes the value to change (see below)

### Progression Dimensions

Most people assume attributes change with time. Hair grows longer over time. Cleanliness degrades over time. But not all attributes work this way:

| Attribute | Progression Dimension | Notes |
|---|---|---|
| Hair length | Time | Grows steadily regardless of what you do |
| Car oil quality | Miles driven | Degrades with use, not time |
| Hair cleanliness | Activity level | Degrades faster on active days |
| Room cleanliness | Occupancy/use | Degrades with how many people use it |
| Lawn height | Time + season | Grows with time but varies by season |
| Tire tread depth | Miles driven | Degrades with use |

When the progression dimension is **derivable from the schedule**, Minder can compute attribute changes automatically. If your schedule contains driving trips with estimated distances, Minder can sum the mileage and project when the oil change condition will cross into "not okay" — without you manually entering odometer readings.

When the dimension is **not derivable** (e.g., a truly external sensor like a bathroom scale), occasional manual measurements calibrate the model. The system interpolates between measurements and refines its projection as more data points arrive.

### Schedule-Derived Dimensions

This is one of Minder's most powerful features. Consider:

- You have a month-long meditation retreat scheduled in India. Zero driving. The car's oil condition **flatlines** — no degradation.
- You have a two-week road trip across the continent. Heavy driving. The oil condition **accelerates** — rapid degradation.

The scheduler accounts for these **second-order effects**: scheduling a road trip advances the oil change condition, which might pull the oil change task forward in the schedule. This creates a feedback loop that the pathfinding algorithm must resolve into a stable solution.

---

## Conditions

A **Condition** is the subjective interpretation of an Attribute's current value. The user defines what values feel "good" and what values feel "bad" — but **not as hard thresholds.**

### Gradients, Not Thresholds

Traditional systems might ask: "At what length is your hair 'too long'?" and store the answer as a cutoff. Below 6 inches = fine. Above 6 inches = needs cutting. This creates a false boundary — is 5.9 inches really "fine" and 6.1 inches really "too long"?

Minder instead presents a **smooth gradient** with adjustable handles — more like defining the control points of a bezier curve than drawing boundary lines:

```
Condition Gradient (example: hair length)

  Fresh ──── Ideal ──── Okay ──── Poor ──── Critical
    │          │          │         │          │
    ▼          ▼          ▼         ▼          ▼
   0"         2"         4"        7"        12"
         ◄── handles are draggable ──►
```

The labels (Fresh, Ideal, Okay, Poor, Critical) are **signposts along a continuum**, not discrete states. Between any two signposts, the condition transitions smoothly. There is no single moment where the condition "flips."

### Why This Matters

1. **No "overdue" moment.** Because there's no hard boundary, the scoring engine uses the continuous curve directly. Tasks become gradually more valuable to schedule as conditions drift — rather than suddenly urgent at an arbitrary cutoff. (See [scheduling.md](scheduling.md) for the score curve.)

2. **No false precision.** The user isn't forced to answer "exactly when does my hair go from fine to too long?" — a question most people can't answer precisely. The fuzzy gradient embraces the fuzziness.

3. **Ideals can shift without invalidating data.** Decide to grow your hair out? Drag the gradient handles. The raw measurements stay; only the interpretation shifts. Short-hair you and long-hair you have different condition curves but the same underlying attribute history.

4. **Calibration happens naturally.** As you record measurements over time ("I measured my hair at 5 inches and I feel fine about it"; "I measured at 8 inches and felt it was too long"), Minder can suggest gradient adjustments. Your past data teaches the system your actual preferences.

---

## Multi-Attribute Cares

A single Care typically has multiple attributes, each degrading independently:

```
My hair (Care)
  Attribute: length          → reset by: haircut
  Attribute: cleanliness     → reset by: shower/wash
  Attribute: condition/health → reset by: deep conditioning treatment
```

Each attribute has its own:
- Condition gradient
- Measurement history
- Projected trajectory
- Associated Need(s) and implementation task(s)

A task resets or improves **specific attributes** — a shower resets cleanliness but doesn't touch length. A haircut resets length but doesn't change cleanliness.

The Care's overall "health" is effectively determined by its worst-performing attribute. If your hair is clean but overgrown, the hair Care is flagged for attention via the length attribute — the scheduling engine surfaces the haircut, not another wash.

---

## Binary and Event-Driven Conditions

Not all conditions degrade smoothly. A car's "check engine light" is binary — either on or off. A tooth either has a cavity or it doesn't. The hot water heater either works or it doesn't.

These are modeled as **degenerate condition curves**: the attribute sits at "fine" for a long time, then flips to "not fine" in a single measurement update.

### Predictive Value

Even binary conditions can benefit from the tracking model:
- If the check engine light has come on three times in four years, Minder can project the rough interval and pre-allocate scheduling flexibility around the expected next occurrence.
- If a car battery has lasted ~3 years each time, Minder can start surfacing "consider replacing the battery" as the 3-year mark approaches.

### Ad Hoc Needs

When prediction isn't possible (first occurrence, truly random event), the Need simply appears when triggered. You update the measurement ("check engine light is on"), and the Need becomes active. No projected crossing required — the condition just flipped.

This is why **Needs can exist independent of condition projections.** A condition-tracked Need with a smooth degradation curve is the ideal case. An ad hoc Need triggered by a sudden event is the fallback. Both flow through the same scoring and scheduling pipeline.

---

## The Condition Model (Signpost Labels)

The default condition signposts, from best to worst:

| Label | Meaning | Scoring Behavior |
|---|---|---|
| **Fresh** | Recently tended. Too soon to refresh — doing the task again now would be wasteful. | Near-zero score. Time is better spent elsewhere. |
| **Ideal** | In great shape. No action needed, but the window for efficient maintenance is opening. | Low but rising score. |
| **Okay** | Fine, but will need attention eventually. Still comfortable but drifting. | Moderate score. The task is becoming worthwhile. |
| **Poor** | Noticeably degraded. Should have been attended to by now. | High score. The task is clearly valuable. |
| **Critical** | Urgent attention needed. Continued neglect risks damage or loss. | Very high score. May override less important tasks. |

These labels are **customizable per attribute**. Not every attribute needs all five, and the labels can be renamed to fit the domain. The important thing is the **gradient between them**, not the labels themselves.

---

## How Conditions Feed the Scheduler

The condition system's output is simple: for each attribute of each Care, a **continuous score value** representing "how valuable would it be to schedule a task that improves this attribute, at time T?"

This score value feeds directly into the scheduling engine's per-Need scoring (see [scheduling.md](scheduling.md)). The scheduler doesn't need to know about bezier curves or gradient handles — it just receives a number that increases as conditions degrade and approaches zero when conditions are fresh.

The full flow:

```
Attribute value (objective measurement)
    ↓
Condition gradient (user-defined bezier curve)
    ↓
Score value (continuous, 0 to ∞)
    ↓
Scheduling engine (per-Need scoring)
    ↓
Task placement (which task, which timeslot)
```

---

## Summary

1. **Attributes are objective; Conditions are subjective.** The measurement is a fact; the interpretation is an opinion. Both are stored separately.
2. **Gradients, not thresholds.** Condition boundaries are smooth bezier-like curves, not hard cutoffs. There is no "overdue" moment.
3. **Progression isn't always time-based.** Attributes can degrade with miles, activity level, usage, or any trackable dimension — including dimensions derivable from the schedule itself.
4. **Multi-attribute Cares are natural.** Each attribute has its own condition gradient, history, and trajectory. Tasks target specific attributes.
5. **Binary conditions are a special case.** Event-driven conditions (check engine light) are degenerate curves. Ad hoc Needs handle unpredictable events.
6. **The output is always a score.** No matter how complex the condition model, the scheduler receives a single continuous value per attribute per time point.
