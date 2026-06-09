# Onboarding: From Overwhelm to Focus

> This document describes Minder's onboarding philosophy — how a new user goes from "I have too much to do and nothing is organized" to a functional, personalized system that improves over time. Designed for ADHD users who have burned out on traditional productivity apps.

---

## The Problem with Traditional Onboarding

Most task management apps start with: **"Tell me everything you need to do."**

This is the worst possible question to ask an overwhelmed person. It requires:
1. **Complete recall** — listing every task in your life, right now, from memory
2. **Accurate estimation** — assigning due dates, priorities, and durations to each
3. **Structural decisions** — organizing tasks into projects, folders, and categories before you've used the system enough to know what structure works
4. **Front-loaded effort** — spending hours on setup before receiving any value

For ADHD users, this is especially cruel. Executive dysfunction means difficulty with exactly these skills: prioritization, estimation, organization, and sustained focus on a tedious meta-task. The onboarding itself becomes a task you can't complete.

---

## Minder's Approach: Interview, Not Inventory

Minder's onboarding is a **conversation**, not a data entry form. Instead of "list all your tasks," it asks:

> **"What, off the top of your head, are the things you care about most in your life right now — the things you'd feel relieved if Minder helped you take care of?"**

This question is:
- **Open-ended and low-pressure.** No wrong answers. You don't need to be comprehensive.
- **Noun-based, not verb-based.** "My health," "My car," "My daughter" come naturally. "Exercise three times a week, rotate tires every 6 months, help with homework daily" requires detailed planning that comes later.
- **Emotionally grounded.** The question asks about *relief* — what's causing stress? — rather than abstract organizational structure.

From this starting point, follow-up questions **optionally** drill deeper:
- "What are the biggest things that [your car] needs right now?"
- "How often do you think [exercise] should happen?"
- "When do you usually [eat dinner]?"

Each answer populates the Cares, Needs, and scheduling data — but the user isn't thinking in those terms. They're just answering natural questions about their life.

---

## Personal Context Bootstrapping

Because Minder is **fully offline and local-first**, it can safely ask for personal details that power the smart scheduler. This information never leaves the device:

### Location & Work Schedule
- "Where do you work?" → LLM looks up the company website → autofills the icon for the Work Care, infers business hours for the work schedule, estimates commute if home address is known.
- "Where do you live?" → Establishes the home base for location-aware scheduling.

### Daily Rhythms
- "When do you usually eat?" → Sets up default timing for meal Needs. Unlike productivity-only systems, Minder needs to account for *all* of your time — so meals, sleep, and other mandatory Activities won't be scheduled over.
- "When do you usually go to sleep? Wake up?" → Defines the schedulable window. The system won't suggest tasks during sleep hours.
- "Do you have any regular commitments?" → Weekly meetings, kids' school pickups, recurring appointments → pre-blocked time that the scheduler works around.

### Sensor Permissions
- "Can Minder use your step counter?" → Enables pedometer-based Activity detection.
- "Can Minder see which apps you're using?" → Enables foreground-app Evidence for automatic Activity tracking.
- "Would you like to connect a sleep tracker?" → More precise sleep/wake data.

Each permission is optional, explained in context, and directly tied to a concrete benefit ("So I can tell when you're exercising and not interrupt you").

---

## The Bootstrap Strategy: Overcautious by Design

A new user has no historical data. No duration estimates, no condition curves, no scoring calibration. Minder handles this through **deliberate overcaution**:

### Duration Estimates Start High

When no completion history exists, the time allotted for a task is the **80th percentile** estimate — not the average. This means:

- Time blocks are **generous**. You'll likely finish early.
- Your day fills up with **fewer tasks** than you could probably handle.
- You are **virtually guaranteed** to complete what Minder suggests for the day.

The psychological effect is critical: **early success breeds engagement.** If your first week with Minder feels like "I actually got everything done today," you'll keep using it. If it feels like "I'm already behind on day one," you'll quit — just like every other app.

### Asymptotic Calibration

As you complete tasks and track durations, the estimates **asymptotically approach true values from the high side:**

```
Estimated Duration
    ▲
    │ ●  (80th percentile default — too generous)
    │   ●
    │     ●
    │       ●  (converging on true duration)
    │         ● ● ● ● ● ●
    │─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  (true average)
    │
    └──────────────────────────► Completions
```

The first tracked completion becomes one data point in the list. If it was much shorter than the default, the next prediction shifts down — but conservatively, because one data point isn't enough to trust. After 5-10 completions, the estimate is close to your actual average, and the 50th/90th percentile split (used for fuzzy time blocks — see [scheduling.md](scheduling.md)) becomes meaningful.

This means:
- **Early on:** Very few, very generously estimated tasks per day. You will succeed.
- **Over time:** More tasks fit as estimates tighten. Capacity increases gradually.
- **The user never notices.** There's no "calibration phase" to wait through. The system just quietly gets more accurate.

### The "One Big Goal" Funnel

Onboarding culminates with a single, focused commitment:

> **"Pick one big, wildly important goal that you've been struggling to maintain. Something where succeeding would feel so relieving that you're willing to accept less productivity in other areas for a while."**

This is the user's **first Assignable** (or first Goal attached to a Care). Everything else is background. The scheduling engine focuses capacity on this one thing, with generous time buffers, and the user gets the experience of actually making progress on the thing they care about most.

The philosophy: **"During the first weeks of adaptation, plan and expect less for yourself."** The system will gradually expand capacity as data accumulates and trust builds.

---

## Data Bootstrapping from Defaults

### Built-In Activity Templates

Minder ships with ~40 built-in Activity templates (see [activities.md](activities.md)). These provide:
- Sensible excusability defaults (Messaging: 7 minutes per 30; Sleep: indefinitely excused)
- Default time budgets (Social Media: 2 hours per day)
- Default evidence associations (foreground apps → Activities)

Users don't need to configure these unless they want to. The defaults are deliberately conservative — a user can always *relax* a limit, which is psychologically easier than imposing one.

### Crowd-Sourced Duration Averages

With enough users volunteering their anonymized averages, Minder can ship realistic duration estimates for common tasks — based on the assumption that a new user is roughly average. "Shower" takes about 12 minutes for the average Minder user. "Grocery shopping" takes about 45 minutes.

This isn't the worst fallback — and it quickly becomes irrelevant. The first personally-tracked completion replaces the crowd-sourced estimate with real data. If the tracked time was much higher or lower, the next prediction jumps to somewhere between the two values. Within a few weeks, the crowd-sourced data is diluted to irrelevance by personal history.

### Activity-Derived Duration Fallback

When even crowd-sourced data is unavailable for a specific task, the system can fall back to the **Activity's average duration.** If the task is categorized as "Cleaning" and no task-specific data exists, the average duration of all "Cleaning" sessions provides a rough estimate. Better than nothing, and replaced by real data quickly.

---

## Progressive Complexity

The onboarding philosophy extends beyond the first session. Minder introduces complexity gradually:

### Week 1: One Goal, Simple Schedule
- Focus on the one big goal
- Schedule shows only a few time blocks
- Minimal configuration required

### Week 2-3: Expanding Awareness
- "You've been tracking for a while. Want to add more Cares?"
- "I noticed you spend about 45 minutes on meals. Should I block that out?"
- "Your commute seems to take about 25 minutes. Should I account for that?"

### Month 1+: Full System
- Condition tracking becomes meaningful (enough data for projections)
- Duration estimates are calibrated
- Multiple Cares and Needs are active
- The scheduling engine has enough data to make genuinely smart suggestions

### Ongoing: LLM-Assisted Interaction
- Users can interact with Minder conversationally, like an assistant
- "What should I do next?" → W.I.N. recommendation with explanation
- "Why did you schedule X here?" → Scoring breakdown with condition curves
- "I just got home from work" → Activity switch, location update, re-prioritize for home context
- No need to understand Cares, Needs, Attributes, or scoring — just ask and the system explains in plain language

---

## The Anti-Todoist Principle

Traditional apps optimize for **task capture** — the more tasks you add, the more "organized" you feel. Minder optimizes for **task completion** — the fewer tasks you see at any moment, the more likely you are to actually do one.

| Traditional App | Minder |
|---|---|
| "Add all your tasks" | "What do you care about most?" |
| Inbox full on day one | One goal on day one |
| Overdue items accumulate | Nothing is ever overdue |
| More items = more organized | Fewer visible items = more focused |
| User manages the system | System manages itself |
| Failure = "you didn't do enough" | Failure = "I estimated wrong, let me adjust" |

---

## Summary

1. **Interview, not inventory.** Onboarding asks what you care about, not what you need to do. Tasks emerge from Cares and Needs.
2. **Personal context bootstraps the scheduler.** Work location, meal times, sleep schedule, and sensor permissions are gathered conversationally and stay on-device.
3. **Overcautious by design.** Duration estimates start high (80th percentile) and tighten asymptotically. You will succeed early.
4. **One big goal first.** The user picks one wildly important thing. Everything else is background until trust and data accumulate.
5. **Progressive complexity.** The system introduces features gradually as data and engagement grow.
6. **LLM as the interface.** Most users should think of Minder as a conversational assistant, not a task management app with screens and buttons.
