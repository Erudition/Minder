# Peerbit Integration Architecture

This document outlines the architecture and phased implementation plan for using Peerbit as the storage, synchronization, and querying backend for the Elm `Replicated` library. 

The core philosophy of this integration is: **Elm owns the CRDT semantics (reducers, causality, identity), while Peerbit handles transport, persistence, and peer discovery.**

## Architecture Overview

1.  **Unit of Storage**: The individual RON Op. Frame boundaries are disposable batches; the Op is the fundamental unit of causality and state.
2.  **Canonical Host**: A `ServiceWorker` runs the Peerbit node. This allows multiple tabs to share a single Peerbit instance (like `SharedWorker`) but also allows background sync and reactivity even when the app is closed.
3.  **Startup Hydration**: The critical user profile is cached in `localStorage` for synchronous, instant startup. The rest of the replica is streamed asynchronously from Peerbit's local IndexedDB via the ServiceWorker.
4.  **Identity**: A single Peerbit keypair represents the "user's replica" across devices. RON's granular NodeIDs (tracking sessions/threads) are treated as internal CRDT bookkeeping, not separate network peers.

## Phased Implementation Plan

To manage complexity and validate the core mechanics, the integration is split into phases.

### Phase 1: The "Stock Peerbit" MVP

**Goal**: Prove the end-to-end sync works using out-of-the-box Peerbit primitives, ignoring metadata overhead for now.

*   **Storage Primitive**: Use the stock Peerbit `SharedLog<Uint8Array>` (or string). Each RON Op is serialized and appended as a separate entry.
*   **Encryption**: None. Plaintext sync to establish baseline performance and simplify debugging.
*   **Elm Bridge**: Implement a backend-agnostic port contract (`replicatorOut` and `replicatorIn`) to replace the hardcoded `setStorage` logic in `Components/Replicator.elm`.
*   **Loading**: 
    *   Cache the "root/profile" Ops in `localStorage` for instant UI render.
    *   On startup, request the full log from Peerbit and feed it to `Node.updateWithRon`.

### Phase 2: The Custom `RONLog` Program

**Goal**: Eliminate Peerbit's metadata overhead (which assumes opaque payloads) by teaching Peerbit about RON's native metadata.

*   **The Problem**: Stock Peerbit adds ~200 bytes of metadata per entry (clocks, DAG links, signatures, CIDs) which is redundant with RON's native `OpID`, `Reference`, and authorship semantics.
*   **The Solution**: Build a custom `RONLog` subclass of Peerbit's `Program`. 
    *   It uses Peerbit's block store and pubsub directly.
    *   It treats the Op's payload as opaque bytes.
    *   It extracts the RON Op header (`*reducer #objectID @opID :reference`) to drive its own indexing.
    *   This drops the per-Op overhead from ~200 bytes to ~50 bytes.

### Phase 3: Intelligent Lazy-Loading & Indexing

**Goal**: Support massive activity timelines without loading the entire history into RAM on startup.

*   **Op-Header Index**: The `RONLog` maintains a lightweight index of Op headers on the JS side.
*   **Targeted Hydration**: The Elm app can request Ops by criteria instead of a full dump:
    *   "Give me the latest 1000 Ops by timestamp" (derived from OpID).
    *   "Give me all Ops for Object X".
*   **Sharding**: If certain collections (like a global timeline) grow too large, use Peerbit's resource-aware sharding to distribute the storage load across peers, using the `OpID`'s timestamp (hashed) as the sharding coordinate.

### Phase 4: Access-Boundary Encryption

**Goal**: Secure data at rest on untrusted VPS relays, and support secure sharing.

*   **Solo Mode**: One global user key encrypts the entire `RONLog`. The VPS stores ciphertext.
*   **Shared Projects**: Encryption is applied at the *access boundary* (the root object of a shared project).
    *   The JS bridge maps an Op's `#objectID` to its parent project.
    *   If it belongs to a shared project, it is encrypted with that project's specific key (shared via Peerbit).
    *   If not, it falls back to the user's global key.
    *   This avoids the complexity of per-object or per-field keys.

---

## Design Decisions and Rationale

*   **Why ServiceWorker over SharedWorker?** Both provide multi-tab sharing (one Peerbit instance per origin). ServiceWorker adds the ability to wake up in the background (e.g., to process a sync that finishes after the user closes the app, or to trigger a local alarm based on a remote change).
*   **Why not Peerbit `Documents`?** Peerbit Documents map CRDT semantics (LWW, etc.) onto fields. Replicator already does this via RON. Using Documents would duplicate logic and metadata. The raw `SharedLog` (and later, `RONLog`) is the correct layer of abstraction.
*   **Why not content-addressed (CID) deduplication for Ops?** RON Ops are uniquely identified by their `OpID`. Two Ops with identical payloads might have different references, timings, or objects. Semantic deduplication is handled by RON; network-level block deduplication (CID) adds overhead without semantic value for tiny Op payloads.
