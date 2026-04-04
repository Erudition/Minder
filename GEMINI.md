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
