# Cares: How Minder Models What Matters

> This document introduces Minder's Cares system. It assumes you've read [task-layers.md](task-layers.md) and understand the task hierarchy (Projects, Assignables, Assignments, etc.). Cares are the orthogonal axis — while tasks model *what you do*, Cares model *what you do it for*.

---

## The Problem Cares Solve

Traditional task management systems organize work by **what the work is**: projects, folders, labels, priorities. But when you ask a person *why* they're doing something, the answer is almost never about the task itself — it's about something they care about:

- "I'm changing the oil because I need my car to keep running."
- "I'm practicing Spanish because I want to be fluent."
- "I'm flossing because I want healthy teeth."
- "I'm doing my timesheet because I need to keep my job."

Each of these answers points to a **noun** — a thing, a person, a relationship, a skill, an obligation — whose wellbeing motivates the work. In most systems, this motivation is invisible. You might tag tasks with "Health" or "Work," but those tags don't carry any semantics — the system doesn't know *why* you tagged something, what it means for the tag to be "neglected" or "satisfied," or how to prioritize across tags.

Cares make this motivation explicit and structured.

---

## What Is a Care?

A Care is simply a **thing you care about** — an entity or concept that you want to take care of. A noun.

The word "Care" is chosen deliberately to avoid the implications of other candidates:
- "Thing" implies objectification, which is uncomfortable when the Care is a person (your child, your partner, your aging parent) or a living creature (your dog, your garden).
- "Asset" is too transactional.
- "Responsibility" is too narrow — you care about your health not because you're obligated to, but because it's *yours*.

For people specifically, the Care isn't the person themselves (they're a peer, not your possession) — it's the **relationship** with that person, or your role as their caretaker if they're a dependent.

Cares also include abstract concerns: your health, your spirituality, your career, your financial stability. These aren't physical objects, but they absolutely are things whose condition degrades if neglected and improves when attended to.

---

## The Taxonomy of Cares

The codebase stubs out a taxonomy of Care types in `Care.elm`:

| Type | What it covers | Examples |
|---|---|---|
| **Self** | The user alone — mind and body | Your physical health, your mental health, your skills |
| **Person** | Relationships with other humans | Your partner, your child, your friend, your parent |
| **Creature** | Living non-human dependents | Your dog, your cat, your houseplants, your garden |
| **Place** | Stationary physical locations | Your home, your office, your yard, a rental property |
| **Object** | Physical things, including containers | Your car, your laptop, your skis, your bookbag |
| **Collection** | Groups of related physical objects | Your wardrobe, your tool set, your book collection |
| **Responsibility** | Duties and obligations not covered above | Your job, your volunteer role, a legal obligation |

This taxonomy exists to give structure, but it's not rigid — the important thing is that each Care is a concrete, specific noun, not an abstract category.

---

## Cares Are Hierarchical

Cares nest naturally, because the things you care about have parts:

```
My body                          ← Self
  My head
    My teeth
    My hair
  My hands
    My nails
```

```
My car                           ← Object
  Engine
  Brakes
  Tires
  Interior
```

```
My relationship with my daughter ← Person
  Her education
  Our quality time together
  Her health
```

This nesting is essentially **nested tags** — "My teeth" is a sub-Care of "My head" which is a sub-Care of "My body." A task that cares for "My teeth" implicitly also cares for "My head" and "My body." But unlike the Project hierarchy (which is exclusive — a task lives in exactly one Project), Care nesting is purely semantic. A task can serve Cares at any level, and can serve Cares in different branches simultaneously.

---

## Needs: What a Care Requires

Each Care has **Needs** — things that must be done (or done regularly) to keep the Care in good condition. A Need is the bridge between the noun world (Cares) and the verb world (Tasks).

```
My teeth (Care)
  Needs:
    - Brushing (daily)
    - Flossing (daily)
    - Dental checkup (biannual)
    - Whitening (optional, cosmetic)
```

```
My car (Care)
  Needs:
    - Oil change (~6 months)
    - Tire rotation (~yearly)
    - Brake replacement (~3 years)
    - Annual inspection (yearly)
    - Washing (variable)
```

A Need is not itself a task — it's a **requirement** of the Care. The tasks that *satisfy* a Need can vary. This is a crucial distinction.

---

## The Many-to-Many Relationship

This is where Cares diverge most sharply from Projects (and from traditional folder/tag systems):

**A single task can serve multiple Cares simultaneously.**

Consider: "Practice Spanish with my daughter." This single activity serves:
- **My Spanish skills** (Self → Skills → Spanish)
- **My daughter's Spanish skills** (Person → Daughter → Education)
- **My relationship with my daughter** (Person → Daughter → Quality time)

In a traditional system with exclusive folders, you'd have to pick one: is this a Language task? A Parenting task? A Relationship task? The answer is all three, and forcing a choice loses information.

In Minder, this isn't just tolerated — it's **actively rewarded**. The scheduling engine can prioritize tasks that satisfy multiple Cares at once, because they're more efficient: you're getting three things done in the time it takes to do one. This is the multi-Care efficiency principle — finding tasks that tackle multiple needs is as if you had more time in the day.

Similarly, a Need can be satisfied by **multiple alternative tasks**:

```
My body → Exercise (Need)
  Satisfied by any of:
    - Go for a run
    - Play basketball with the boys
    - Play an hour of Beat Saber
    - Walk the dog (also serves: My dog → Exercise need)
```

None of these is individually required, but at least one is. The scheduler doesn't care which one you pick — it cares that the Need gets met. And if one of the options also serves another Care (walking the dog = your exercise + your dog's exercise), it gets priority.

---

## Conditions: How Well a Care Is Doing

The VISION.md document outlines a condition model for Cares — a way to express how well-maintained something is. Conditions apply primarily to Cares whose Needs are **maintenance tasks**: recurring work with no external deadline, where neglect causes gradual degradation.

```
Conditions (of a Care):
  Acceptable
    Fresh       ← recently tended, too soon to refresh
    Ideal       ← in great shape
    Okay        ← fine, but will need attention eventually
  Unacceptable
    Poor        ← noticeably degraded
    Critical    ← urgent attention needed
```

The properties that make a task a "maintenance task" (as distinct from a deadline-driven or one-shot task):

- **No external deadline.** Waiting longer just means conditions get gradually worse. (Practice Spanish: the longer you wait, the rustier you get.)
- **No expiration.** You can neglect it indefinitely, yet at any point it's still doable. (Wax your skis: always relevant.)
- **It may be "too soon."** There's a cooldown period where repeating the task is ineffective. (Mow the lawn: cutting it again an hour later won't help.)
- **Importance increases with neglect.** More-neglected tasks are strictly prioritized over recently refreshed ones. (Take a shower: 8 hours since the last one? Low priority. A week? High priority.)
- **Ideals may change.** What counts as "acceptable" is subjective and can shift over time. (Haircuts: short-hair you and long-hair you have different maintenance windows.)

This condition model lets Minder automatically prioritize maintenance work: if your teeth haven't been flossed in three days and your car was washed last week, the flossing gets priority — not because you manually set it, but because the system understands the degradation curve.

---

## Goals, Needs, and Wants

The MODEL.md notes explore an open question: what's the right vocabulary for what a Care requires?

- A **Need** is something the Care requires to stay in acceptable condition. Neglecting it causes degradation. Examples: oil changes for a car, brushing for teeth, regular contact for a relationship.
- A **Want** is something that would improve the Care beyond its current baseline, but isn't required for maintenance. Examples: whitening your teeth, upgrading your car's sound system, learning a new recipe for date night.
- A **Goal** might be the umbrella term that covers both — or it might be a more specific concept with its own structure.

The MODEL.md prototype suggests goals have additional properties:
- **Exemptions**: temporary statuses (illness, vacation) that disable the goal without it counting as failure. This is distinct from an "excuse" — exemptions are pre-approved and structurally recognized.
- **A game plan**: a WOOP-derived strategy for meeting obstacles (inner obstacles) and blockers (outer obstacles). A complete game plan is one where every branch has a solution; no path ends in "give up." Rare, low-probability obstacle branches can be marked as UNPLANNED ("wing it") to avoid over-engineering.

This area of the design is still evolving. The important invariant is: **Needs belong to Cares, and tasks satisfy Needs.** Whether the vocabulary distinguishes needs from wants, or unifies them under "goals," is an open question.

---

## How Cares Relate to Projects

As discussed in [task-layers.md](task-layers.md), the Project layer and the Cares system have significant conceptual overlap. Many groupings that initially seem like Projects turn out to be Cares:

| Seems like a Project | Actually a Care |
|---|---|
| "My 2020 Honda Civic" → oil changes, tire rotations... | It's a thing you take care of. The tasks are its Needs. |
| "My Job" → timesheets, reviews, project work... | It's a responsibility you maintain. |
| "Learning Spanish" → practice, classes, apps... | It's a skill you're developing (Self). |
| "My Home" → cleaning, repairs, bills... | It's a place you maintain. |

The key difference is ownership semantics:
- **Projects provide exclusive hierarchical grouping.** A task lives in exactly one Project. The Project's lifecycle governs its tasks.
- **Cares provide non-exclusive, many-to-many tagging.** A task can serve multiple Cares. Cares don't "own" tasks — they motivate them.

Whether the Project layer has a non-redundant purpose (grouping coordinated efforts that aren't about maintaining an entity) remains an open design question. The type system supports both, and they're kept separate pending further real-world usage evidence.

---

## Cares vs. Activities

It's worth clarifying the distinction with Activities, which exist in the task layer:

- An **Activity** is *what kind of work you're doing*: cleaning, coding, phone calls, exercise. It's about the nature of the labor.
- A **Care** is *what you're doing it for*: your car, your teeth, your daughter. It's about the motivation.

You might do the Activity "Cleaning" for multiple Cares (cleaning the kitchen → My Home; cleaning the car → My Car). And a single Care might involve many Activities (My Car → Cleaning, Paperwork, Mechanical work). They're orthogonal dimensions.

---

## Summary of Design Principles

1. **Cares are the noun layer; tasks are the verb layer.** Cares model what matters to you. Tasks model what you do about it. They're orthogonal.

2. **A Care is a concrete, specific thing you take care of.** Not an abstract category, but a real noun: your teeth, your car, your daughter, your job.

3. **Cares are many-to-many with tasks.** A task can serve multiple Cares, and a Care can be served by multiple tasks. This is the fundamental difference from Projects.

4. **Multi-Care tasks are prioritized.** A task that serves three Cares at once is more efficient than one that serves only one. The scheduler rewards this.

5. **Needs bridge Cares and tasks.** Each Care has Needs. Tasks satisfy Needs. A Need can be satisfied by alternative tasks — the system cares that the Need is met, not how.

6. **Conditions drive automatic prioritization.** Cares with maintenance-type Needs have a condition model (Fresh → Ideal → Okay → Poor → Critical). The scheduler prioritizes neglected Cares over recently-tended ones.

7. **Cares are hierarchical.** They nest (your teeth are part of your head, which is part of your body). Satisfying a child Care implicitly contributes to its ancestors.

8. **Cares may subsume Projects.** Many real-world "projects" are actually Cares — entities you maintain. Whether there exists a class of groupings that are genuinely about coordinated effort (not entity maintenance) remains an open question.
