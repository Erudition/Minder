# Cares: How Minder Models What Matters

> This document introduces Minder's Cares system. It assumes you've read [task-layers.md](task-layers.md) and understand the task hierarchy (Projects, Assignables, Assignments, etc.). Cares are the orthogonal axis — while tasks model *what you do*, Cares model *what you do it for*.

---

## The Problem Cares Solve

Traditional task management systems organize work by **what the work is**: projects, folders, labels, priorities. But when you ask a person *why* they're doing something when they could be doing something else, it can always be boiled down to the consequences for something they _care_ about:

- "I'm changing the oil because I need my car to keep running."
- "I'm practicing Spanish because I want to be fluent."
- "I'm flossing because I want healthy teeth."
- "I'm doing my timesheet because I need to keep my job."

Each of these answers points to a **noun** — a thing, a person, a relationship, a skill, an obligation — whose wellbeing motivates the work. In most systems, this motivation is invisible. You might tag tasks with "Health" or "Work," but those tags don't carry any semantics — the system doesn't know *why* you tagged something, what it means for the tag to be "neglected" or "satisfied," or how to prioritize across tags.

Cares make this motivation explicit and structured. Minder can then derive priorities for otherwise equal tasks, such as preferring to take care of the most neglected entity.

---

## What Is a Care?

A Care is simply a **thing you care about** — an entity or concept that you want to take care of. A noun.

The word "Care" is chosen deliberately to avoid the implications of other candidates:
- "Thing" implies "it", which is probably not how you want to refer to your friends, family, pets, or deities.
- "Possession" is often simply not true.
- "Asset" is too transactional.
- "Project" can make relationships sound like labor with an end goal.
- "Responsibility" is too narrow — you care about your health not because you're obligated to, but because it's *yours*. A rich and loving life involves taking care of things and people that are not necessarily your "responsibility".

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

In Minder, this isn't just tolerated — it's **actively rewarded**. The scheduling engine can prioritize tasks that satisfy multiple Cares at once, because they're more efficient: you're "getting three things done" (or at least, _taking care_ of three things) in the time it takes to do one. This is the multi-Care efficiency principle — finding tasks that tackle multiple needs is as if you had more time in the day.

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

## Attributes and Conditions

Each Care has measurable **Attributes** — objective dimensions that describe its state. Each Attribute has a **Condition** — the subjective interpretation of its current value.

**Attribute** = an objective, measurable dimension. Hair has `length` and `cleanliness`. A car's engine has `miles since last oil change`. Your lawn has `grass height`. The value is a number (or at least orderable), and its trajectory over time is something Minder can observe, record, and eventually predict.

**Condition** = the subjective interpretation of an attribute's value. This is where the user maps their personal standards onto the measurement: "10 inches → overgrown," "just washed → fresh," "7 days since wash → poor."

### Gradients, Not Thresholds

Critically, the condition mapping is **not a set of hard thresholds**. The user doesn't define "below 4 inches = ideal, 4-6 inches = okay, above 6 inches = poor." Instead, they adjust handles on a **smooth gradient** — more like defining the control points of a bezier curve than drawing boundaries between zones. The labels (Fresh, Ideal, Okay, Poor, Critical) are signposts along a continuum, not discrete states with sharp transitions.

This matters because:
1. **There is no "overdue" moment.** The condition doesn't flip from "fine" to "bad" — it smoothly degrades. The scoring engine (see [scheduling.md](scheduling.md)) uses the continuous curve directly, so tasks become gradually more valuable to schedule as conditions drift, rather than suddenly urgent at an arbitrary cutoff.
2. **Users aren't forced to define arbitrary lines.** "When exactly does my hair go from 'fine' to 'too long'?" is a question most people can't answer precisely, and forcing them to produces false confidence. The fuzzy gradient embraces the fuzziness.
3. **Ideals can shift without invalidating data.** If you decide to grow your hair longer, you drag the gradient handles. The raw measurements stay; only the interpretation shifts. Short-hair you and long-hair you have different condition curves but the same underlying attribute history.

### Multi-Attribute Cares

A single Care can have multiple attributes that degrade independently:

```
My hair (Care)
  Attribute: length         → reset by: haircut
  Attribute: cleanliness    → reset by: shower/wash
  Attribute: condition/health → reset by: deep conditioning treatment
```

Each attribute has its own condition gradient, its own measurement history, and its own projected trajectory. A task resets (or improves) specific attributes — a shower resets cleanliness but doesn't touch length.

### Non-Time Deterioration Axes

Not all attributes degrade as a function of time. A car's oil condition degrades with **miles driven**, not hours elapsed. Hair length grows with time, but cleanliness degrades faster on active days than sedentary ones.

Minder handles this by allowing attributes to progress in relation to **any trackable dimension**, not just clock time. If the dimension is derivable from the schedule itself (e.g., driving miles accumulated from scheduled trips), Minder can compute the progression without manual measurement. On a month-long meditation retreat, the car's oil condition flatlines (zero miles driven). During a two-week road trip, it accumulates rapidly. The scheduler accounts for these second-order effects — scheduling a road trip advances the oil change condition, which might pull the oil change task forward in the schedule.

When the dimension is *not* derivable from the schedule (e.g., a truly external sensor), occasional manual measurements calibrate the model. The system interpolates between measurements and refines its projection as more data points arrive.

### Binary and Event-Driven Conditions

Not all conditions degrade smoothly. A car's "check engine light" is binary — either on or off. This is modeled as a degenerate condition curve: the attribute sits at "fine" for a long time, then flips to "not fine" in a single measurement update.

The timing prediction model can still work: if Minder has seen the check engine light come on three times over four years, it can project the rough interval and pre-allocate flexibility. But when prediction isn't possible (first occurrence, truly random events), the Need simply appears when triggered — this is a "repair" type Need, added ad hoc when the condition flips. The key insight: **Needs can exist independent of condition projections.** A condition-tracked Need is the ideal case; an ad hoc Need is the fallback.

### Maintenance Task Properties

The condition model applies specifically to **maintenance tasks** — recurring work where neglect causes gradual degradation. The hallmarks of a maintenance task (from VISION.md):

- **No external deadline.** Waiting longer just means conditions get gradually worse. (Mow the lawn: the longer you wait, the taller and more uneven it gets.)
- **No expiration.** You can neglect it indefinitely, yet at any point it's still doable. (Wax your skis: always relevant.)
- **It may be "too soon."** There's a cooldown period where repeating the task is ineffective. (Mow the lawn: cutting it again an hour later won't help.)
- **Importance increases with neglect.** More-neglected tasks are strictly prioritized over recently refreshed ones. (Take a shower: 8 hours since the last one? Low priority. A week? High priority.)
- **Ideals may change.** What counts as "acceptable" is subjective and can shift over time. (Haircuts: short-hair you and long-hair you have different maintenance windows.)

---

## Needs, Wishes, and Goals

A Care's relationship to the task system flows through three concepts:

### Needs

A **Need** is a maintenance requirement — something the Care requires to stay in acceptable condition. Needs have condition curves. They degrade when neglected. They're the thing where "importance increases with neglect" applies.

- Your hair *needs* cutting. Your teeth *need* brushing. Your car *needs* oil changes.
- Each Need is linked to one or more Attributes of the Care — satisfying the Need resets or improves those Attributes.
- A Need can be satisfied by **multiple alternative tasks** (implementation plans). Going for a run, playing basketball, and doing Beat Saber all satisfy the "exercise" Need. None is individually required, but one of them is.

### Wishes

A **Wish** is an aspirational improvement — something that would enhance the Care beyond its current baseline, but isn't required for maintenance. Wishes don't have condition curves. Neglecting a Wish doesn't degrade anything — you just don't get the nice thing.

- "I wish I could play guitar" (Self → Skills)
- "I wish we could visit Italy together" (Person → Partner)
- "I wish my car had a better sound system" (Object → Car)

Wishes are attached to a Care because they're *motivated by* it, but they exist independently of the condition model. They're essentially Assignables (or Projects, if complex) that are tagged to a Care. "Wish" is deliberately softer than "need" — no guilt for having an unfulfilled wish sitting in the system for years.

### Goals

A **Goal** operationalizes a Need (or a Wish that's been promoted to active pursuit) by pairing it with:

1. **A measurable condition target** — "keep hair below six inches," "run at least three times per week," "floss daily"
2. **An implementation strategy** — which specific task satisfies it: "go to Andy's Salon for $18 men's haircut," "jog the 5K loop near the park"
3. **An intention of frequency** — how often the condition should be maintained, not as a rigid schedule but as a scoring input

Goals are where the WOOP framework lives:
- **Exemptions**: temporary statuses (illness, vacation, travel) that disable the goal without it counting as failure. If an exemption applies, the scheduler stops factoring this goal into the plan. This is distinct from an excuse — exemptions are pre-approved and structurally recognized.
- **Obstacles and Blockers**: inner obstacles (motivation, habit, energy) and outer obstacles (logistics, dependencies, weather) with planned responses. A complete game plan is one where every branch has a solution — no path ends in "give up." Rare, low-probability obstacles can be marked as UNPLANNED ("wing it") to avoid over-engineering contingencies.

### The Information Flow

```
Care (noun: my hair)
  → Attribute (objective: length in inches)
    → Condition (subjective: 10" = overgrown, gradient not threshold)
  → Need (maintenance: haircut)
    → Goal (operationalized: keep below 6", via Andy's Salon, ~6 weeks)
      → Assignable (the task: "Get haircut at Andy's Salon")
        → Assignment (a particular trip to the salon)
```

The Goal is the binding layer between the noun world (Cares/Needs) and the verb world (Tasks/Assignments). Without a Goal, a Need still exists — you know your car needs oil changes even if you haven't chosen a specific shop and interval. And a Wish exists without any pretense of being required.

---

## How Cares Relate to Projects

As discussed in [task-layers.md](task-layers.md), the Project layer and the Cares system have significant conceptual overlap. Many groupings that initially seem like Projects turn out to be Cares:

| Seems like a Project | Actually a Care |
|---|---|
| "My 2020 Honda Civic" → oil changes, tire rotations... | It's a thing you take care of. The tasks are its Needs. |
| "My Job" → timesheets, reviews, project work... | It's a responsibility you maintain. |
| "Learning Spanish" → practice, classes, apps... | It's a skill you're developing (Self). |
| "My Home" → cleaning, repairs, bills... | It's a place you maintain. |

Whether the Project layer has a non-redundant purpose (grouping coordinated efforts that aren't about maintaining an entity) remains an open design question. The type system supports both, and they're kept separate pending further real-world usage evidence. One concrete use for the Project layer: **migration staging** — when importing data from other apps (e.g. Todoist), the imported tree structure can be parked as Projects while the system (or the user, or an LLM) determines where the Assignable boundary belongs and which branches are really Cares.

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

5. **Needs maintain; Wishes aspire; Goals operationalize.** Needs are maintenance requirements with condition curves. Wishes are aspirational improvements without them. Goals bind either to measurable targets, implementation plans, and frequency intentions.

6. **Attributes are objective; Conditions are subjective.** The measurement (hair length in inches) is stored separately from the interpretation (10 inches = overgrown). This means ideals can shift without invalidating history.

7. **Conditions are gradients, not thresholds.** The user defines smooth bezier-like curves, not hard cutoffs. There is no "overdue" moment — just a continuous scoring function that makes tasks gradually more valuable as conditions drift.

8. **Conditions can track non-time dimensions.** Oil degrades with miles, not hours. If the dimension is derivable from the schedule (driving trips = miles), Minder computes the progression automatically.

9. **Cares are hierarchical.** They nest (your teeth are part of your head, which is part of your body). Satisfying a child Care implicitly contributes to its ancestors.

10. **Cares may subsume Projects.** Many real-world "projects" are actually Cares — entities you maintain. The Project layer is retained for migration staging and as a structural possibility, pending real-world evidence of non-redundant use cases.
