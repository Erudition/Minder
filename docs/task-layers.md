# Task Layers: How Minder Models Work

> This document introduces Minder's task architecture from the ground up. It assumes you are familiar with traditional to-do list apps (Todoist, Things, OmniFocus, pen-and-paper checklists) but have not encountered Minder's model before. If you're a developer or AI agent working on this codebase, this is the conceptual foundation you need before touching anything in `src/Task/`.

---

## The Problem with Traditional To-Do Lists

In most task management systems, a task is an atomic thing. You write "Take out the trash," you check it off, it disappears. If you need to take out the trash again next week, you create a new entry — or you set up a recurrence rule that generates new entries for you.

This works, but it has consequences:

- **No memory.** Each instance is born knowing nothing about previous instances. If you want to know how long "take out the trash" usually takes you, you'd have to go spelunking through your completed items, assuming they haven't been archived or deleted.

- **No structure without special-casing.** A simple task and a 40-step project live in the same flat list. Most apps bolt on "subtasks" as an afterthought, but these are just cosmetic groupings — the system doesn't know the difference between "buy milk" (one action, done in 30 seconds) and "file my taxes" (a multi-day project with sequential dependencies).

- **Metadata is disposable.** You spend time specifying effort estimates, deadlines, activities, and priorities — then the task is marked complete and all that context evaporates. If you ever need to do it again, you start over.

- **Templates are an add-on.** Some apps let you create "template" tasks that you can stamp out copies of, but these are a separate mechanism from regular tasks, and copies don't maintain a living connection to the template.

Minder takes a different approach. Instead of modeling tasks as disposable one-shot items, it separates *what a task is* from *a particular time you do it*.

---

## The Core Insight: Classes and Instances

The central concept in Minder's task architecture is a separation borrowed from object-oriented programming: the distinction between a **class** (what something is, in the abstract) and an **instance** (a particular occurrence of it).

In Minder's vocabulary:

| Traditional To-Do | Minder Equivalent |
|---|---|
| A task | An **Assignable** (the class — what the task *is*) |
| Checking off a task | Completing an **Assignment** (a particular instance of doing it) |
| Creating a new task | Either creating a new Assignable, or creating a new Assignment of an existing one |

An **Assignable** is a durable definition: "take out the trash." It carries metadata about what the task involves — how long it typically takes, what activity category it belongs to, how important it is, what its subtasks are. It persists in your library indefinitely, whether or not you're currently doing it or planning to do it.

An **Assignment** is an ephemeral instantiation: "I need to take out the trash." That's it — no time required. An Assignment means something is *to-do*, not that it's *scheduled*. You might add a deadline ("before the truck comes tomorrow"), or schedule it precisely ("6 PM tonight"), or leave it completely open ("someday"). All that is necessary for an Assignment to exist is that the work is, well, assigned to you. It carries instance-specific data — this particular deadline (if any), this particular completion status. When it's done, it's done. But the Assignable remains, ready for the next time.

This means:
- **17 completions of "take out the trash" give you n=17 for duration learning**, not 17 disconnected data points with n=1 each.
- **Your library grows over time.** The longer you use Minder, the less you need to define new Assignables. Creating a new Assignment eventually becomes a one-tap operation — autocomplete from your existing library, and all the metadata is already there.
- **Pre-built templates are just Assignables.** The app can ship with common tasks already defined. There's no separate "template" mechanism.

---

## The Five Layers

Minder organizes work into a hierarchy of five layers. Three of them define the *structure* of what a task is (the template side), and two of them track *particular times you do it* (the instance side).

### Template Side (What the task *is*)

```
Project
  └── Assignable          ← the instantiation boundary
        └── SubAssignable
              └── Action   ← the atomic unit
```

### Instance Side (A particular time you do it)

```
Assignment               ← instance of an Assignable
  └── AssignedAction      ← instance of an Action within that Assignment
```

Let's walk through each layer.

---

### Layer 1: Project

**What it is:** A static organizational container above the instantiation boundary. Projects group related Assignables together. They can nest infinitely within each other, but they are never themselves instantiated — you can't "do" a Project, you can't schedule it, it has no notion of start or end dates, no effort estimate, no completion status. It's a folder. When all its Assignables are done (or have no active Assignments), the Project simply sits there, ready to be revived whenever new work arises.

**How to find the boundary:** When breaking down work, every layer could be described as answering "what is this work?" — so that question can't delineate layers. Instead, the question is: **"What is the highest level at which you would do it all in one instance?"** or equivalently, **"What group, if repeated, repeats together?"** That level is the Assignable. Everything above it is Project.

**Honest status:** The Project layer may be partially redundant with Minder's *Cares* system (see below). Many real-world groupings that seem like Projects turn out to be Cares — entities or concerns you "take care of" (your car, your job, your Spanish skills), where the tasks are maintenance of that entity. The Project layer is retained because (a) the type system already supports it cleanly, (b) there may be legitimate groupings that are about coordinated effort rather than entity maintenance, and (c) removing a layer prematurely is riskier than leaving a rarely-used one in place.

**The mega-project trap:** Broad life categories like "Home," "Health," or "Work" are *not* good projects — they're Cares. If a task could plausibly live under multiple such categories ("bring home the fitness treadmill I won at the work party" — is that Home, Work, or Health?), the categories aren't mutually exclusive, and that's a sign they belong in the Cares system rather than the project hierarchy. If a Project exists, it should be concrete, bounded, and obviously distinct from all other projects — both present and hypothetical.

**Nesting:** Infinite, but shallow in practice. Infinite nesting is supported so that the system is exhaustive and never needs to be expanded to fit edge cases (the 0-1-infinity rule), not because deeply nested folder hierarchies are expected or encouraged. Many Assignables will have no Project wrapper at all — the Assignable *is* the top level.

In the code, the boundary between Projects and Assignables is expressed as a union type:

```
type NestedOrAssignable
    = AssignableIsDeeper (Reg ProjectSkel)     -- keep going, it's another folder
    | AssignableIsHere (Reg AssignableSkel)     -- we've arrived at a real task definition
```

---

### Layer 2: Assignable

**What it is:** The definition of a specific task, in the abstract, independent of any particular time you do it. This is the most important layer in the system — it is the **instantiation boundary**, the point at which "class" meets "instance." It answers: "what is the thing that, when repeated, repeats as a unit?" Everything inside it (SubAssignables, Actions) comes along for the ride when you create an instance.

**What it carries:**
- A title (e.g., "Take out the trash")
- An activity category (optional — usually inherited by its children)
- Effort estimates (min, predicted, max duration)
- Importance rating
- Completion unit definition (percent, discrete steps, etc.)
- Default timing rules (deadlines, relevance windows) expressed as relative timing
- Children (SubAssignables and/or Actions — the internal structure of the task)
- A database of Assignments (the instances — past, present, and future)

**Key design rule:** Assignables are the *only* layer that can have Assignments. Projects above cannot be instantiated. Actions below cannot be independently instantiated. If you want to commit to doing a particular thing, you do it through the Assignable — by creating an Assignment.

**An Assignable with no Assignments is perfectly valid.** It means the task is defined in your library but you haven't committed to doing it. Maybe you defined "replace brake pads" for your car, but you might sell the car before the brakes wear out. The definition exists; it costs nothing to keep; it'll be ready if you need it. Note that "no Assignments" is not the same as "unscheduled" — an Assignable with an Assignment but no timing information is an assigned-but-unscheduled task, which is also perfectly valid. The absence of Assignments means the task isn't even on your to-do list yet; it's purely a library entry.

**An Assignable with no children (no Actions) is also valid.** It means you've captured the task but haven't yet broken it down into atomic steps. This is a deliberate "needs enrichment" signal — the system (or an LLM) can decompose it later. But it's already in your library, already findable via autocomplete, already accumulating whatever metadata you've provided.

---

### Layer 3: SubAssignable

**What it is:** A grouping layer *within* an Assignable, for organizing its internal structure. Like Projects above the Assignable, SubAssignables nest infinitely — but unlike Projects, they live *below* the instantiation boundary.

**Why it exists:** Complex tasks have internal structure. "File my taxes" might break down into "Gather documents → Calculate deductions → Fill out forms → Submit." Each of those might further break down. SubAssignables let you express that hierarchy without creating separate Assignables (which would each need their own Assignments, losing the connection between them).

**What it does *not* have:** Recurrence rules, its own Assignments, or an independent identity for scheduling purposes. SubAssignables are part of the Assignable's internal anatomy. When you instantiate the Assignable (create an Assignment), the entire SubAssignable tree comes along for the ride.

In the code:

```
type NestedSubAssignableOrSingleAction
    = ActionIsHere (Reg ActionSkel)             -- leaf: an atomic action
    | ActionIsDeeper (Reg SubAssignableSkel)     -- branch: keep nesting
```

---

### Layer 4: Action

**What it is:** The atomic unit of work. An Action is a single, indivisible step — one thing you sit down and *do*. It is the leaf node of the template tree.

**Key constraint: every Action must have an Activity.** This is the only layer where specifying an Activity is required (above this layer, it's optional and typically inherited downward). An Activity represents *what kind of work you're doing* — "cleaning," "coding," "phone call," "exercise" — and the system uses it for time tracking, categorization, and analytics.

**Why Actions are not Assignables:** This is a deliberate design choice to prevent the "everything is just a to-do" collapse. In reality, no assignment worth tracking involves only a single step, and if it does, it can be modeled as an Assignable with one Action inside it. The separation guarantees that the system can always find a natural stopping point when you only have time to complete some steps of a larger task. It also means Actions don't carry their own instance data — completion is tracked at the Assignment level via AssignedActions (see below).

**What it carries:**
- Title
- Activity (required)
- Effort estimates
- Completion units
- Default timing rules

You'll notice these fields overlap heavily with Assignable. This is intentional — both layers need to express "how long does this take?" and "when is it relevant?" — but the fields serve different roles. On the Assignable, they're class-level defaults that seed new Assignments. On the Action, they define the atomic work unit itself.

---

### Layer 5: Assignment (Instance Side)

**What it is:** An intention to do an Assignable. "I need to take out the trash" is an Assignment. "I took out the trash last Thursday" is a completed Assignment. "I need to take out the trash before the truck comes tomorrow at 7 AM" is an Assignment with a deadline. All three are valid — the only thing that makes something an Assignment is that it's *to-do* (or was to-do, and now it's done).

**Assignments are timing-agnostic.** Nothing in the task layer model is inherently about scheduling. An Assignment may carry deadline or relevance information, but it doesn't have to. Many assignments will be completely open-ended — "buy a copy of War and Peace" might sit on your list for years. Others might be precisely timed, or triggered by location ("when I get home"), or scheduled automatically by Minder's planning engine based on your priorities, energy levels, and constraints. The task layers define *what needs doing*; scheduling is a separate concern.

**What it carries:**
- Completion progress
- Instance-specific deadline overrides (absolute moments, not relative rules) — all optional
- Relevance windows (when does this particular instance start/stop mattering?) — also optional
- Per-action completion data (via `AssignedAction` — see below)
- Extra metadata (key-value pairs)

**Multiple assignments of the same Assignable are valid.** This goes beyond simple recurrence. If an Assignable's configuration permits it, you can have multiple concurrent, unscheduled assignments — accruing a backlog. Examples:
- Three years of unfiled taxes → three Assignments of "File taxes"
- Found six boxes in the attic → six Assignments of "Go through one box of memories"
- Want to visit the museum twice to activate a benefit → two Assignments of "Visit the museum," neither with a specific date

For Assignables where this doesn't make sense ("take a shower" — doing it twice simultaneously is meaningless), multiple concurrent assignments can be disabled. But the system supports the general case.

**Where it lives:** Inside the Assignable's `manualAssignments` database. Assignments don't float freely — they are always owned by exactly one Assignable. The `AssignmentID` encodes both the owning `AssignableID` and the assignment's own identity, so you can always navigate from an Assignment back to its class.

**Two flavors:**
- **Manual Assignments:** Explicitly created by the user ("I need to do this"). Stored in a `RepDb`.
- **Series Assignments:** Generated from recurrence rules ("Do this every week"). Identified by a `SeriesMemberID` (series ID + index). The series mechanism is not yet fully implemented, but the ID structure is in place.

**The "completed but not deleted" philosophy:** When an Assignment is completed, it stays. It's in the past. It won't show up in your active task list. But it remains connected to its Assignable, contributing to duration learning, completion statistics, and historical context. The Assignable's library of Assignments is its memory.

---

### AssignedAction (Instance Side, Below Assignment)

**What it is:** Instance-specific data for a single Action within a single Assignment. Just as an Assignment is an instance of an Assignable, an AssignedAction is an instance of an Action within that Assignment.

**What it carries:** Completion progress, deadline overrides, relevance windows — the same instance-specific fields as Assignment, but at the per-action granularity.

**How it works:** `AssignmentSkel` contains a `RepStore ActionID (Reg AssignedActionSkel)` — a sparse store keyed by Action ID. If an Action has no entry in this store, it simply uses defaults. If it has an entry, that entry carries the instance-specific overrides. This means you only pay storage costs for Actions you've actually interacted with in a given Assignment.

---

## How Layers Compose: A Concrete Example

Suppose you need to file your taxes. The Assignable is "File tax return" — that's the thing that, when repeated yearly, repeats as a unit. It recurs via a yearly Series. The 2024 and 2025 tax filings are Assignments (instances) of the same Assignable.

```
Assignable: "File tax return"                       ← the task class (yearly recurrence)
  SubAssignable: "Gather documents"
    Action: "Download W-2 from employer"            ← atomic, Activity: Paperwork
    Action: "Request 1099 from bank"                ← atomic, Activity: Paperwork
  SubAssignable: "Calculate deductions"
    Action: "Tally charitable donations"            ← atomic, Activity: Accounting
    Action: "Compile home office expenses"          ← atomic, Activity: Accounting
  Action: "Submit via TurboTax"                      ← atomic, Activity: Paperwork
```

Note there's no Project wrapper here — the Assignable is the top level. "File tax return" is the highest level at which you do it all in one instance; there's nothing above it that needs to be a static organizational folder.

When tax season arrives, a new Assignment is created (no specific date required — just "I need to do this"):

```
Assignment (2025) of "File tax return"              ← to-do (timing TBD)
  AssignedAction for "Download W-2 from employer"    ← completion: 100%
  AssignedAction for "Request 1099 from bank"        ← completion: 100%
  AssignedAction for "Tally charitable donations"    ← completion: 50% (still gathering receipts)
  (no AssignedAction for "Compile home office...")    ← defaults apply, not started
  (no AssignedAction for "Submit via TurboTax")      ← defaults apply, not started
```

If you've been procrastinating and have three years of unfiled taxes, you have three separate Assignments of this same Assignable — each independently tracking its own completion progress. The system now has historical data on how long tax filing takes, and it gets more accurate every year.

If you later realize you should have broken "Submit via TurboTax" into separate federal and state actions, you restructure the Assignable's template. Both past and future Assignments reflect the new structure, because *the thing you do didn't change in reality* — you just described it better. If the tax process fundamentally changes (new country, different tax system), that's a *new Assignable*.

---

## The Traversal: How `Layers.elm` Flattens the Tree

The `buildLayerDatabase` function in `Task/Layers.elm` walks the entire tree from root Projects down to leaf Actions, collecting every entity into flat dictionaries keyed by their IDs. The result is a `ProjectLayers` record:

```elm
type alias ProjectLayers =
    { rootProjects    : AnyDict String ProjectID Project
    , allProjects     : AnyDict String ProjectID Project
    , assignables     : AnyDict String AssignableID Assignable
    , subAssignables  : AnyDict String SubAssignableID SubAssignable
    , actions         : AnyDict String ActionID Action
    }
```

This gives the scheduling engine O(1) access to any entity by ID, while the tree structure is still available through each entity's parent references (every `Assignable` knows its `Project`, every `Action` knows its `Assignable` or `SubAssignable` parent, etc.).

The traversal uses two separate recursive paths — one above the Assignable boundary (Projects, using `NestedOrAssignable`) and one below it (SubAssignables, using `NestedSubAssignableOrSingleAction`). These are deliberately not unified, because Project-level traversal and SubAssignable-level traversal have different semantics and will diverge further as the system evolves.

---

## The Skel/Wrapper Pattern

You'll notice the codebase has pairs of modules: `ProjectSkel.elm` / `Project.elm`, `AssignableSkel.elm` / `Assignable.elm`, `ActionSkel.elm` / `Action.elm`, and so on.

- **Skel** (skeleton) is the bare data that gets persisted — it's the CRDT-friendly, serializable record. It contains `RW` (read-write) fields, `RepList`s, `RepDict`s, and `RepStore`s — all replicated data types that participate in the sync protocol. Skels know nothing about their parents or their position in the tree.

- **The wrapper** (e.g., `Assignable`, `Action`) is the runtime-enriched type that carries navigational context — its parent reference, its computed ID, and any other derived information needed for display or scheduling. Wrappers are constructed during traversal by `fromSkel` functions that attach the parent context.

This separation keeps serialization concerns out of the business logic and vice versa. When you're working with an `Assignable`, you have everything you need to navigate the tree. When you're working with an `AssignableSkel`, you have everything you need to read and write persistent data.

---

## Summary of Design Principles

1. **Template and instance are separate concerns.** The Assignable defines *what*; the Assignment represents an intention to *do it*. Neither is disposable.

2. **The Assignable is the instantiation boundary.** Everything above it (Projects) is organizational. Everything below it (SubAssignables, Actions) is structural. Only the Assignable itself can be instantiated into Assignments.

3. **Zero instances is a valid state.** An Assignable with no Assignments is a library entry, not a bug. An Assignable with no Actions is a captured-but-not-yet-decomposed task. Multiple concurrent Assignments of the same Assignable is also valid — for accruing backlogs, expressing repeated intent, or any case where you need to do the same thing more than once.

4. **Actions are atomic.** They represent a single indivisible step, tagged with exactly one Activity. They cannot be independently instantiated. This guarantees the system can always find natural stopping points.

5. **History is an asset, not clutter.** Completed Assignments are retained. They contribute to duration learning, pattern recognition, and the growing richness of the Assignable's metadata. The system gets smarter the longer you use it.

6. **Template changes are retroactive by design.** If you reorganize an Assignable's internal structure, the change applies to past Assignments too — because the thing you did didn't change in reality; you just described it better. If the thing itself changed, that's a new Assignable.

7. **Nesting is infinite in both directions.** Projects nest infinitely above the boundary. SubAssignables nest infinitely below it. The system is as shallow or as deep as your work requires. In practice, trees tend to be shallow — infinite depth is an exhaustiveness guarantee, not an invitation to build deeply nested folder hierarchies.

8. **Timing is not a layer concern.** Assignments are intentions to do work, not calendar entries. Scheduling — when and where a task actually happens — is a separate system that consumes the task layers as input. An assigned-but-unscheduled task is the normal, expected state.

9. **Projects are concrete, not categorical.** Broad life categories ("Home," "Work," "Health") are an antipattern for projects because they aren't mutually exclusive. Projects should be bounded and obviously distinct. Cross-cutting categories belong in the Cares system. Many Assignables will have no Project at all — the Assignable is its own top level.
