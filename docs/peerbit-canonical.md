# Peerbit Canonical SW-Host: Architecture, Data-Integrity Bug, and Fix

> Technical record of how Minder's Peerbit persistence actually works, the silent
> data-clobbering bug found in it, and the fix that landed. Covers the canonical
> client/host/module/adapter model, the mode protocol, error propagation, and the
> environment quirks discovered along the way.

---

## TL;DR

The app previously **silently created a fresh, empty MinderLog program and clobbered
persisted data** whenever a stored/shared program address failed to load. The cause:
the SW host module had an auto-create fallback that made `peer.open()` *succeed*
instead of failing, so the client's error screen never triggered.

**Fixed** by giving the channel payload a mode: **reuse-only** (default, fails loudly)
vs **create-allowed** (explicit fresh-profile flows only). Reuse failures now throw and
surface as an error screen with a "Start from Scratch" button.

---

## Architecture

### The model: page ↔ SW host via canonical channels

Minder runs Peerbit's canonical model with the **Service Worker as the host**:

```
┌────────────────────────── Page ──────────────────────────┐
│ PeerbitCanonicalClient                                   │
│   minderLogAdapter (www/minder-log-client-adapter.ts)    │
│   openPort("minder-log", payload) ───────────────┐       │
└──────────────────────────────────────────────────┼───────┘
                                                   ▼
┌────────────────────────── SW Host ─────────────────────────┐
│ CanonicalHost                                            │
│   minderLogModule (www/minder-log-host-module.ts)         │
│     acquireProgram → real MinderLog program               │
│     exposes its SharedLog via SharedLogService RPC        │
└────────────────────────────────────────────────────────────┘
```

- **Client adapter** (`minder-log-client-adapter.ts`): translates "open this MinderLog"
  into opening a canonical channel named `"minder-log"`, carrying the program id
  (32 bytes) as the payload. Builds a `SharedLogProxy` over the channel.
- **Host module** (`minder-log-host-module.ts`): handles `"minder-log"` channels.
  Opens (or reuses) the real `MinderLog` program, binds its `SharedLog` to the channel
  via `createSharedLogService`/`bindService`, and broadcasts append ops back to all
  open channels for that program.
- **Program refcounting**: `openPrograms` map (keyed by address) tracks live program
  instances + channel sets so concurrent tabs share one program and it only closes
  when the last channel drops.

### Two open flows

1. `peer.open(addressString)` — canonical load path:
   `loadProgram` on host → `blocks.get(address)` → returns stored payload → client
   deserializes → adapter → `openPort("minder-log", idBytes)` → host `acquireProgram`.
2. `peer.open(new MinderLog({ id }))` — skips `loadProgram`, goes straight to the
   adapter → `openPort(...)` → host `acquireProgram`.

Both end at `acquireProgram`; only flow 1 reads the blockstore first.

### Error propagation (verified by reading source)

```
host module open throws
  → canonical-host index.js ~263 catch
  → sendResponse({ id, ok: false, error: String(e) })
  → canonical-client client.js:664-665: entry.reject(new Error(message.error ?? "Unknown error"))
  → openPort rejects
  → peer.open rejects
  → www/index.ts:280-289 catch → showLoadError(...)
```

---

## The Bug

### Symptom

App receives a program address (from URL `?program=...` or `localStorage`) — an address
that *implies prior data exists* — and the load fails for whatever reason (block never
saved, storage cleared, network). Old behavior: the host **silently created a fresh,
empty MinderLog**, saved it, and the client stored the *new* address. The old profile
data was effectively orphaned/clobbered. No error ever appeared.

### Root cause

`acquireProgram` had a fallback:

```ts
try {
  program = await peer.open(addressKey, { existing: "reuse", ... });
} catch (e) {
  // OLD: always fall through and create fresh
  program = await peer.open(new MinderLog({ id }), ...);
  await program.save();
}
```

The fallback made `peer.open()` **succeed**, so the client's catch block at
`www/index.ts:280-289` was never reached. Silent success, no error screen. The stealth
was the problem, not the error itself.

### Why it only creates when it shouldn't

The only time a *fresh* program should be created is an explicit "Start from Scratch"
(or equivalent fresh-profile) flow. A stored/shared address must never auto-create.

---

## The Fix: mode protocol

### Channel payload now encodes intent

- **32-byte payload** (`idBytes` only) → **reuse-only**. If the program can't be
  loaded, the host **throws** — the error propagates to the client error screen.
- **33-byte payload** (`[0x01, ...idBytes]`) → **create-allowed**. Reuse is tried
  first; a fresh program is created **only if reuse fails**. Used exclusively by the
  explicit fresh-profile flows.

### Files changed

**`www/minder-log-host-module.ts`**
- `acquireProgram(ctx, address, port, id, mode)` — new `mode: "reuse" | "create"` param.
- `mode === "reuse"` failure → throws:
  `"MinderLog program not found or could not be loaded at address ${addressKey}. Start from Scratch to create a new profile."`
- `mode === "create"` failure → original fallback (`peer.open(new MinderLog({ id }))` + `save()`).
- Module `open` parses payload: 33-byte `[0x01, ...]` → create; 32-byte → reuse; anything
  else → throw.

**`www/minder-log-client-adapter.ts`**
- `openMinderLog({ ..., create?: boolean })`.
- `payload = create ? new Uint8Array([0x01, ...idBytes]) : idBytes`.
- Adapter `open` handler: `create: options?.create === true`.

**`www/index.ts`**
- Both fresh-profile call sites pass `{ create: true }`:
  - `startFromScratch()` (explicit Start from Scratch)
  - passphrase-derived open (`peer.open(new MinderLog({ id: programId }), { create: true })`)
- Typed as `CanonicalOpenOptions<MinderLog> & { create?: boolean }` — **not `as any`**.
- `www/index.ts:280-289` catch already existed and renders the not-found screen with a
  "Start from Scratch" button; the fix makes it reachable.

---

## Verification

### Build gates

| Gate | Result |
|---|---|
| `tsc -p tsconfig.sw.json` | clean |
| `tsc -p tsconfig.peerbit-host.json` (covers minder-log.ts, host-module, adapter) | clean |
| `vite build` | exit 0 (dist regenerated, fix present in `dist/sw.js`) |

### Live repro (localhost:8899, python3 static server serving `dist/`)

| Scenario | Result |
|---|---|
| Stored address + no data in blockstore | ✅ Error screen "Could not load your profile"; no fresh create; stored address unchanged; block count stays 0 |
| Corrupted block (exists but unopenable — the old clobber trigger) | ✅ Error screen; address unchanged; no new block written (count stays 1, entry still the corrupted bytes) |
| Explicit create (passphrase flow, `create: true`) | ✅ Fresh program created, block stored, address saved |
| Valid stored address reload (reuse path) | ✅ Existing program opens, Elm app starts |

---

## Peerbit version pins (pnpm virtual store)

| Package | Version |
|---|---|
| `@peerbit/canonical-client` | 1.1.43 |
| `@peerbit/canonical-host` | 1.0.53 (react-native@0.86.0 peer) |
| `@peerbit/blocks` | 4.2.7 |
| `@peerbit/program` | 6.0.40 |
| `@peerbit/shared-log` | 13.2.15 |

---

## Type-safety learnings

- `peer.open` signature (canonical-client):
  `open<S extends Program<any>>(storeOrAddress: S | Address, openOptions?: CanonicalOpenOptions<S>)`.
- `CanonicalOpenOptions<S> = Omit<OpenOptions<S>, "parent"> & { parent?: unknown }`
  (auto.d.ts). Custom adapter options like `create` are **not** part of it, so pass a
  typed intersection assertion:
  `{ create: true } as CanonicalOpenOptions<MinderLog> & { create?: boolean }`.
- Adapter `open` context (auto.d.ts): `{ program: S; options: OpenOptions<S>; peer: ProgramClient; client: CanonicalClient }` — custom flags ride through `options`.

---

## Environment quirks (Guix workstation)

### Dev server (vite dev) is broken; production build is fine

- `pnpm run start` (vite dev) fails pre-bundling:
  `Failed to resolve import "@peerbit/shared-log-rust"`.
- `@peerbit/shared-log-rust` is an **optional peer dep** of `@peerbit/shared-log` and
  is **not installed**. In shared-log source the import is `/* @vite-ignore */` +
  try/catch-guarded with a TypeScript fallback, so production (rollup) is fine. Vite's
  dev-mode esbuild pre-bundling chokes on it.
- `vite.config.ts` already lists it under `optimizeDeps.exclude`; the failure comes from
  a pre-bundled chunk, so exclude alone doesn't help.
- **Workarounds**: `pnpm add @peerbit/shared-log-rust@0.1.3` (match peer range), or
  add a `resolve.alias` stub. Do **not** rely on `vite dev` until fixed.

### elm binary wrapper is broken globally

- `/home/adroit/.local/bin/elm` is a broken pnpm-global wrapper (points to a missing
  `share/pnpm/global/5/...` path).
- The project-local `node_modules/.bin/elm` works (0.19.1).
- **Build with**: `PATH="/home/adroit/Projects/Minder/node_modules/.bin:$PATH" pnpm run build`
  (or the full `build-ci`).

### Serving for live testing

- `localhost:8899` is a `python3 -m http.server` serving `dist/` (already running).
  Rebuild `dist` via `vite build`, then just reload the page.
- "Update on reload" (DevTools → Application → Service Workers) works on
  `http://localhost:8899` and the GitHub Pages origin.

### IndexedDB storage layout

- IDBs: `level-js-minder-peerbit-blocks`, `-cache`, `-keychain` (same-origin, one object
  store each).
- **All keys are byte-keyed (ArrayBuffer)**, normalized via `www/minder-idb-store.ts`
  (base58). This is why earlier "local vs localStore" wiring theories were dead ends —
  `@peerbit/blocks` `libp2p.js:74` confirms `localStore` **is** consumed as `local`.
- Test data is disposable (user-confirmed); tabs were throwaway. Clearing an IDB via
  DevTools/`indexedDB.deleteDatabase` is the reset path.

---

## Remaining / known issues

- **Dev server**: `@peerbit/shared-log-rust` pre-bundling blocker (see above).
- **Byte-keyed IDB writes** (minder-idb-store.ts writing byte keys directly) are a
  separate concern from the clobber bug; the canonical adapter/host now routes through
  the proper channel protocol.
- The full-session SW update on the **GitHub Pages** origin picks up the fix once the
  rebuilt `dist/` is deployed there.

---

## Bug B: Data-holder loses own index on browser restart

### Symptom
After a browser restart, the data-holder (main context, no `?program=`) loads its own program address successfully (`reuse-open RESOLVED`), but `toArray()` returns 0 and all tasks disappear. The program block is found (confirming blocks persist), but the log index is empty.

### Root cause (confirmed via DIAG)
- **Missing COOP/COEP headers**: `www/sw.ts` serves **no** `Cross-Origin-Opener-Policy` / `Cross-Origin-Embedder-Policy` / `crossOriginIsolated` / `SharedArrayBuffer` headers (verified via grep: no matches).
- **OPFS sqlite3_vfs unavailable**: Without `crossOriginIsolated` + `SharedArrayBuffer`, the sqlite VFS in `@peerbit/indexer-sqlite3` cannot install (SW warning logged).
- **EntryIndex falls back to memory**: The SharedLog's EntryIndex becomes a **memory store**, losing all heads on browser restart.
- **Blocks survive**: The blockstore (`IndexedDBStore` → `browser-level` → IDB) persists — `reuse-open RESOLVED` confirms the program block is found.

### Fix: head-hash persistence + recovery
- **Persist heads**: On every log change (`replication:change` / `replicator:join`), save head hashes to a dedicated IDB store (`minder-peerbit-heads`) keyed by program address.
- **Recover on acquire**: In `acquireProgram`, after the program opens, if `getHeads()` returns 0 and persisted hashes exist:
  1. Reconstruct `Entry` instances via `Entry.fromMultihash(peer.services.blocks, hash, { remote: false })`
  2. Call `log.load({ reset: true, heads: [Entry instances] })` — `join` recursively fetches ancestors from persisted blocks, rebuilding the index
- **Critical**: `load({ reset: true, heads })` expects **Entry objects**, not hash strings — the pruning path (`opts.heads.map(x => x.hash)`) uses `.hash`, so raw strings are destructive (would remove all provided heads).
- **Direct dep added**: `"@peerbit/log": "6.2.10"` pinned to match `@peerbit/shared-log`'s exact version (avoids dual-package hazard under strict pnpm).

### Files changed
- **`package.json`**: Added `"@peerbit/log": "6.2.10"` (direct dependency, exact version).
- **`www/minder-log-host-module.ts`**:
  - Import `Entry` from `@peerbit/log`, `IndexedDBStore` from `./minder-idb-store.js`
  - `headsStore = new IndexedDBStore("minder-peerbit-heads")`
  - `persistHeadHashes(peer, addressKey, shared)` — saves `lower.getHeads(true).map(h => h.hash)` as JSON
  - `recoverHeadHashes(peer, addressKey, shared)` — reads hashes, reconstructs Entries, calls `lower.load({ reset: true, heads: entries })`
  - In `acquireProgram`, after refcounting, calls `recoverHeadHashes`, then `persistHeadHashes`, then subscribes to `replication:change` / `replicator:join` to persist on future changes.

### Verification row
| Scenario | Result |
|---|---|
| Data-holder browser restart (no `?program=`) | ✅ Heads recover from persisted hashes; `toArray()` > 0; tasks reappear |
| Fresh data-holder (first launch, no persisted hashes) | ✅ Normal behavior; index builds from scratch on first append |

---

## Bug A: URL-share receiver gets endless churn, never shows data or error

### Symptom
Fresh receiver at `?program=<address>` opens successfully (`reuse-open RESOLVED`), sees `replicator:join` + `mature` events, but `toArray()` stays at 0 and the task list remains blank (no data, no error). Endless `replication:change` churn.

### Root cause (hypothesized)
- Head exchange never completes in the synchronizer — likely a deep Peerbit issue with head message delivery or processing.
- **Not addressed by persistence fix**: Even after the data-holder regains its heads, the receiver still doesn't get them via replication.

### Fix: client-side bounded wait → explicit error
- **Bounded wait**: In `www/index.ts` `continueAfterOpen`, after `peer.open()`, if `programAddressFromUrl` is set and `toArray()` is 0, wait up to `URL_SHARE_DATA_WAIT_MS` (20s) polling `toArray()`.
- **Explicit error**: If still 0 after the wait, show `showLoadError("Could not open shared program", ...)` — the same error screen used for open failures.
- **Rationale**: Per user constraint, "If it can't find the data from peering with the other browser, then the program address effectively does not exist - it should not 'create' it implicitly." A silent blank is misleading; an error is correct.

### Files changed
- **`www/index.ts`**:
  - `const URL_SHARE_DATA_WAIT_MS = 20_000`
  - In `continueAfterOpen`, after `proxy = result?.proxy || result`, bounded wait loop for URL shares; `showLoadError` if timeout.

### Verification row
| Scenario | Result |
|---|---|
| Fresh receiver at `?program=<address>` with healthy data-holder | ✅ Either data arrives within 20s (if replication works) OR explicit error "Could not open shared program" after timeout (no silent blank) |
| Fresh receiver at `?program=<nonexistent>` | ✅ Same bounded wait + explicit error (same as above) |

---

## Combined verification (data-holder recovery + client error)

| Scenario | Data-holder (no `?program=`) | Receiver (`?program=<address>`) |
|---|---|---|
| First launch (no persisted hashes, no prior data) | ✅ Normal; index builds from scratch on first append | ✅ Bounded wait + error if no data arrives |
| Browser restart (persisted hashes exist) | ✅ Heads recover; tasks reappear | ✅ Bounded wait + error if no data arrives |

---

## Additional Peerbit learnings

### EntryIndex persistence requires COOP/COEP
- `@peerbit/indexer-sqlite3`'s OPFS sqlite3_vfs needs `SharedArrayBuffer` → requires `crossOriginIsolated` → requires `Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy: require-corp` on the served HTML.
- **In SW scope**: SW itself cannot be `crossOriginIsolated` unless the document is. Serving COOP/COEP is a deployment-level change, not just SW configuration.
- **Fallback when missing**: sqlite3 VFS falls back to **memory store** → all heads lost on restart.

### `load({ reset: true, heads })` requires Entry instances, not strings
- **Correct**: `log.load({ reset: true, heads: [entry1, entry2] })` where entries are `Entry` objects.
- **Wrong**: `log.load({ reset: true, heads: ["hash1", "hash2"] })` — raw strings are destructive: the pruning path (`opts.heads.map(x => x.hash)`) uses `.hash`, but the set contains the strings themselves, not the entry hashes, so all heads get removed.
- **Recovery path**: `Entry.fromMultihash(store, hash, { remote: false })` resolves a hash from the blockstore into a full Entry.

### Direct dependencies matter under strict pnpm
- `@peerbit/log` is not a direct dependency of Minder; only `@peerbit/shared-log` and `@peerbit/shared-log-proxy` are.
- Under strict pnpm, transitive deps are **not** exposed to your code — you must explicitly declare what you import.
- **Fix**: Add `"@peerbit/log": "6.2.10"` (exact version matching shared-log's dep) to `dependencies` in `package.json`.

### Cross-browser sync testing environment limitations
- **Firefox headless MCP**: ES6 module scripts (`<script type="module">`) don't load — Elm app never initializes (`window.Elm` undefined).
- **Chromium CDP automation**: Chrome MCP tools fail to connect despite CDP responding to `curl http://127.0.0.1:9222/json/version` (MCP server network issue).
- **Chromium stability**: Headless Chromium with GPU disabled in this environment crashes frequently, making E2E sync testing unreliable.
- **Workaround**: Manual testing in desktop browsers; automation requires a more stable environment or different tools.
