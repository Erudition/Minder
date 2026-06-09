# Replicator Library Architecture & Constraints

## Overview
Replicator is a CRDT library (RON-based) that treats synchronization and persistence as a serialization target. The library is undergoing a major refactor to a `Collection`-based architecture.

## Core Philosophical Constraints
- **Long Files are OK**: Following Evan Czaplicki's convention from "The Life of a File," do not prematurely split files. Only separate into modules by logical type (e.g., Codecs, Reducers, Op types).
- **Inextricable Links**: ADTs (Custom Types) and their associated codecs should stay in their respective modules to avoid dependency cycles and unnecessary qualification.
- **Protocol Integrity**: Maintain strict RON compatibility. `ReducerID` is the source of truth for protocol tags (e.g., "lww", "replist", "store").

## Data Structures & Refactoring Status
- **RepTypes**: These are the native CRDT types.
- **Collection Architecture**: Transitioning from direct RON Objects to `Collection` (a union of `Saved` and `Unsaved` variants).
- **Union Semantics**: For `Collection` fields (like members in an organization), we use "union" semantics instead of "last-write-wins" to handle concurrent initialization gracefully.
- **Payload Strictness**: Payloads have transitioned from `List Atom` to `Nonempty Atom` in the core architecture to ensure every operation contains data.

## RepStore Nuances
- **Read-Only Generation**: `RepStore` uses a read-only, on-the-fly model.
- **StoreReducer**: A specific `ReducerID` variant added to support `RepStore`'s unique causal tracking needs.
- **Scalar Unwrapping**: `RepStore` relies on `Change.Delayed` to process updates that reference objects created within the same frame.

## Technical Gotchas
- **Modified Libraries**: The standard `Url` module in `~/.elm` must be patched (see `elm-patches/`) to support `File` and `File2` schemes. If the compiler complains about missing `Url.File`, re-run the patches and clear `elm-stuff`.
- **Scratchpad Malformation**: `Scratchpad.elm` often contains malformed runtime data (with `<function>` labels) during debugging—it should be commented out or cleared if it causes project-wide parsing errors.
- **Codec Modularity**: Refactoring to `SyncSafe`/`SyncUnsafe` and `Mutable`/`Immutable` folders is intended to simplify `Codec.elm` into a module of simple stubs and prevent dependency loops.

## Deployment & Build
- **No systemd**: The host uses Guix (GNU Shepherd), not systemd.
- **Patches**: Managed by `elm-patches/Makefile`. Direct modification of the `~/.elm` package store is required.
- **Url Patch**: After clearing `elm-stuff`, the Url artifacts also need clearing (`rm ~/.elm/0.19.1/packages/elm/url/1.0.0/artifacts.dat`). The `patch` CLI tool is not installed on this system, so if the patch hasn't been applied, it must be done manually.

## Codec Design Philosophy

The Codec system is designed so that defining your Elm types with a single Codec declaration gives you symmetric encoders/decoders for JSON, Bytes, and RON (CRDT operations) — all for free. The goal: **the easiest way to define your types and make changes is also the CRDT-friendly way**.

### One `Codec` Type, Phantom Constraints

Rather than having multiple incompatible codec types, everything is a single `type Codec init compat thing`. The type variables serve as phantom-type constraint slots:

- **`init`**: The initialization input. Serves double duty as seed, changer, or both (see below). Set to `()` when unused.
- **`compat`**: A phantom record type for encoding-strategy constraints. `{}` is unconstrained (matches anything); more specific record fields (like `SoloObject`, `Primitive`) restrict which helper functions accept the codec. Most constraints relate to the Node/RON encoding side.
- **`thing`**: The actual Elm type being encoded/decoded.

### The `init` Slot: Seeds, Changers, and Both

The `init` type variable carries the initialization input for `Codec.new` and friends:

- **No seed, no changer** → `init = ()`. Most types. Use `Codec.new`.
- **Changer only** → `init = Changer thing`. For types you want to initialize with upfront Changes (the preferred method). Use `Codec.newWithChanges`.
- **Seed only** → `init = seed`. For types that *cannot* be initialized from nothing (e.g. nonempty lists, registers with required fields). Rare. Use `Codec.newWithSeed`.
- **Both** → `init = (seed, Changer thing)`. Paired in a tuple when both are needed. Use `Codec.newWithSeedAndChanges`.

Seeds exist to solve a specific constraint: when a type can't be built without a starting value. The `Replicated.Codec` facade hides the `init` slot entirely unless the user calls a `newWith*` variant.

### Minimum Viable Alias Convention

As a rule, the raw `Codec` type is never invoked directly in user code. Instead, type aliases fill in the unused type variables with their placeholder values, keeping signatures clean and enforcing correct usage at the type level:

| Alias | Expands To | Use Case |
|---|---|---|
| `NullCodec thing` | `Codec thing {} thing` | Self-seeded, no constraints (custom types, building blocks) |
| `SelfSeededCodec compat thing` | `Codec thing compat thing` | Self-seeded with constraints (value IS the seed; e.g. wrapped types like Maybe/Result where the inner codec's seed percolates up) |
| `PrimitiveCodec thing` | `Codec thing Primitive thing` | Primitive values (String, Int, etc.) |
| `SkelCodec thing` | `Codec Skel SoloObject thing` | Seedless register/record codecs (`Skel = () -> List Change = Changer ()`) |
| `WrappedCodec thing` | `Codec (Changer thing) SoloObject thing` | Registers initialized purely from a changer (no external seed) |
| `WrappedSeededCodec seed thing` | `Codec (seed, Changer thing) SoloObject thing` | Registers that need both external seed data and a changer |
| `WrappedOrSkelCodec s thing` | `Codec (Changer s) SoloObject thing` | Functions accepting either wrapped or skel codecs (generalizes `SkelCodec` when `s = ()`) |
| `SeededRecordCodec seed thing` | `Codec seed SoloObject thing` | Naked records that need a seed but no changer (e.g. all-required-field records, read-only records) |

### `finishRecord` / `finishRegister` Return Types

The `finish*` functions determine which alias the resulting codec matches:

| Function | Returns | Notes |
|---|---|---|
| `finishRecord` | `SkelCodec full` | Seedless record |
| `finishSeededRecord` | `SeededRecordCodec s full` | Seeded record (no changer paired with seed) |
| `finishRegister` | `WrappedCodec (Reg full)` | Seedless register (changer-only init) |
| `finishSeededRegister` | `WrappedSeededCodec s (Reg full)` | Seeded register (seed + changer paired) |

## Codec Type Alias Conventions (Post-Collection Migration)
- **NullCodec, SkelCodec, WrappedCodec**: Now take only 1 type argument (the `thing` type). Old code may have 2 args (seed + thing) — the seed arg must be removed.
- **Codec type not re-exportable**: Elm doesn't allow re-exporting imported concrete types. The `Codec` type from `Base` cannot appear in `Replicated.Codec`'s exposing list. Consumer modules should use type alias names (NullCodec, SkelCodec, etc.) or drop annotations entirely.
- **WrappedSeededCodec annotations**: Often wrong after refactoring because `finishSeededRecord` returns `Codec seed SoloObject thing` where seed is the raw seed, but `WrappedSeededCodec` wraps it as `(seed, Changer thing)`. Drop these annotations when they cause mismatches.
- **BytesDecoder/JsonDecoder wrapping**: All raw `BD.Decoder`/`JD.Decoder` values must be wrapped with `BytesDecoder.fromRaw`/`toRaw` when crossing the opaque type boundary.
- **NodeDecoder.Output**: Returns `{ decoder, ancestors }` — older code may destructure as `{ decoder, obSubs }`.

## Elm-CSS Namespace & Styling Constraints
- **Ambiguous property**: All custom/vendor CSS properties (e.g., `--padding-start`, `--background`, `-webkit-background-clip`) must be explicitly qualified as `Css.property` to avoid namespace conflicts with `Html.Styled.Attributes.property`.
- **Ambiguous int**: Font weight levels or grid dimensions must be qualified as `Css.int` to avoid conflicts with `Json.Encode.int` or `Url.Parser.int`.
- **Gap property**: The standard `gap` layout helper is unsupported in our `elm-css` library. Use `Css.property "gap" "Xrem"` (or similar dimensions) instead.
- **Scroll snap alignment**: Do not mix `Html.Styled.Attributes.style` directly inside `css [ ... ]` blocks. Standardize scroll-snap configurations using `Css.property "scroll-snap-align" "start"` inside `css` style lists.

## Task List Stepped Deck & Underlay Layout Constraints
- **Self-Contained Cards with See-Through Holes**: Each assignment card must be completely self-contained in its DOM element representation. The top-left region of the card must remain fully transparent and see-through to display the underlay header underneath.
- **Normal Flow Header Underlay with Negative Margin**: The assignable's title header row must remain relatively positioned in the normal DOM flow rather than absolutely positioned. The scroll container must be pulled up to overlap the header by assigning the header a matching height and a negative bottom margin (e.g. `margin-bottom: -3.5rem; height: 3.5rem;`).
- **Interactive Click Pass-Through**: The scroll container must be assigned `pointer-events: none` and the cards `pointer-events: auto` to allow interactive clicks to pass through transparent sections directly to the underlying assignable header title.
- **Dashed Uniform Add Card**: The "New Assignment" card-button must match standard cards exactly in height (`180px`), margins, and sticky offsets, rendering a dashed outline backing at `top: 3.5rem` to remain visually uniform and aligned in the stack.
- **Tag Element Formatting**: Display the card's `#Number` followed by the `Identicon` (`[#Number] [Identicon]`) inside the top-right tag backing.
- **Mathematical Stack Snapping**: Sticky card decks that stack on the left must have their `.absolute-snap-target` offsets mathematically aligned leftwards to match the stacking offset: `left: calc(var(--card-start) + var(--index) * (var(--card-width) + var(--card-gap)) - var(--index) * var(--stack-step))`.

## Task Architecture Semantic Constraints
- **Assignments are timing-agnostic**: Assigning ≠ scheduling. An Assignment is an intention to do something, not a calendar entry. Timing fields (deadlines, relevance windows) are all optional. An assigned-but-unscheduled task is the normal, expected state. Scheduling is a separate system that consumes task layers as input.
- **Multiple concurrent Assignments are valid**: An Assignable may have multiple active Assignments simultaneously (e.g. backlog accrual: three years of unfiled taxes = three Assignments). This is configurable per-Assignable for idempotent tasks where multiples don't make sense.
- **Projects must be concrete, not categorical**: Broad life categories ("Home", "Work", "Health") are an antipattern for Projects because they aren't mutually exclusive. Projects should be bounded and obviously distinct from all other projects, present and hypothetical. Cross-cutting categories belong in the Cares system instead.
- **Project nesting tends to be shallow in practice**: Infinite nesting is supported as an exhaustiveness guarantee (0-1-infinity rule), not because deep folder hierarchies are expected. Don't design features or UI that assume or encourage deep project nesting.
- **Deadlines must be external**: The deadline field is called "external deadline" even in code. Self-imposed deadlines are an antipattern — use condition scoring, Need importance, and the scheduling engine instead. Urgency that fake deadlines create should be achieved by other means.
- **Deadline ≠ Expiration**: Expiration (when the task has zero remaining value) is distinct from deadline (when it should ideally be done). Expiration ≥ deadline. Most tasks have value even after their deadline. The grace period between them prevents premature abandonment.
- **"Priority" is not a Minder concept**: Urgency (time-sensitive) and importance (value-weighted) are orthogonal dimensions. The scoring engine computes their interaction. A single "priority" number is a stopgap for the scoring engine and will be removed. It exists only temporarily for Todoist import compatibility.
- **Delegation is just another project**: There is no "delegated" task state. Delegating work is a multi-step Assignable with Actions (contact, wait, confirm, verify). The condition tracks reality (the plant's water level), not agreements (the neighbor said yes).

## Cares & Scoring Semantic Constraints
- **Needs maintain; Wishes aspire; Goals operationalize**: Needs are maintenance requirements with condition curves. Wishes are aspirational improvements without them. Goals bind either to measurable targets, implementation plans, and frequency intentions. These three terms are distinct and should not be conflated.
- **Attributes are objective; Conditions are subjective**: Measurement (hair length in inches) is stored separately from interpretation (10 inches = overgrown). Ideals can shift without invalidating measurement history.
- **Conditions are gradients, not thresholds**: The user defines smooth bezier-like curves, not hard cutoffs. There is no "overdue" moment — just a continuous scoring function that makes tasks gradually more valuable as conditions drift.
- **Scoring is per-Need, not per-task**: The scheduler evaluates which task satisfies a Need best in context, not which task is "due." Multiple implementation plans for a Need compete naturally.
- **No overdue, no guilt**: Nothing in Minder is ever "overdue." The system never creates a binary flip from "fine" to "failed." This is a foundational ADHD-first design constraint, not a cosmetic choice.
- **Duration estimates start overcautious**: New tasks use 80th percentile estimates, not averages. The system asymptotically approaches true values from the high side, ensuring early user success.

