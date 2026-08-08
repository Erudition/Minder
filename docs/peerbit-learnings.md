# Peerbit Unintuitive Learnings

## Cross-Browser Sync Testing

### Firefox MCP Environment Limitations
- **Module Scripts**: Firefox headless MCP environment has issues loading ES6 module scripts (`<script type="module">`)
- **Symptom**: Page shows "HTML loaded, Starting JS." but Elm never initializes (`window.Elm` undefined)
- **Diagnosis**: The module script `/assets/index-84e61f11.js` is accessible via curl but doesn't execute in the Firefox MCP browser context
- **Impact**: Cannot use Firefox headless MCP for full E2E sync testing of Minder app
- **Workaround**: Use desktop Chromium with CDP for both ends of sync test

### Chromium CDP Connection Issues
- **Chrome MCP Server**: Chrome MCP connection fails despite CDP responding to `curl http://127.0.0.1:9222/json/version`
- **Symptom**: Chrome MCP reports "Could not connect to Chrome. Check if Chrome is running." while CDP works via curl
- **Diagnosis**: MCP server network/fetch issue (not a CDP endpoint issue)
- **Impact**: Cannot use Chrome MCP tools despite Chromium running with remote debugging
- **Workaround**: Use curl to interact with CDP JSON API directly, or use Firefox MCP for the other end

### Chromium GPU/Vulkan Errors in Headless Environment
- **Error Pattern**: `ERROR:ui/gl/angle_platform_impl.cc:42] Display.cpp:1093 (initialize): ANGLE Display::initialize error 0: Internal Vulkan error (-3)`
- **Impact**: GPU processes fail to start repeatedly, but CDP endpoint remains functional
- **Mitigation**: Use `--disable-gpu --disable-dev-shm-usage` flags to suppress (doesn't eliminate errors)
- **Learning**: GPU errors don't block CDP or basic functionality in this environment

### Minder App Load Behavior
- **HTML/JS Separation**: App loads HTML immediately, then shows "HTML loaded, Starting JS." while JS initializes
- **Init Bottleneck**: Elm initialization is the critical path - if `window.Elm` is undefined, the app is dead
- **Persistence Signals**: `localStorage` key `CapacitorStorage.minder-peerbit-program-address` indicates previous sessions existed

### Service Worker & Peerbit Considerations (Hypothesized)
- **SW Scope**: Service Worker likely at `/sw.js` with root scope
- **Peerbit Storage**: Uses IndexedDB (`minder-peerbit-blocks` store) for blocks
- **IDB Persistence**: IndexedDB persists across browser restarts (confirmed by localStorage having program address)
- **Potential Issue**: If Service Worker fails to register or install, Peerbit init may hang or fail

## Peerbit-Specific Learnings

### Entry Index Persistence (Root Cause of Bug B)
- **Expected Behavior**: `@peerbit/indexer-sqlite3` uses OPFS SQLite3 VFS for persistent EntryIndex
- **Actual Behavior**: Without COOP/COEP headers, `SharedArrayBuffer` is unavailable, OPFS sqlite3_vfs can't install
- **Fallback**: EntryIndex falls back to **memory store**, losing all heads on browser restart
- **Blocks Persistence**: Blocks survive in IndexedDB (`minder-peerbit-blocks`) - confirmed by reuse-open RESOLVED after restart
- **Evidence**: Post-restart DIAG shows `heads=0 toArray=0` but `blocks.has` returns true for program address

### Recovery Strategy (Implemented Fix)
- **Approach**: Persist head hashes to separate IDB store (`minder-peerbit-heads`) on every log change
- **Recovery Path**: On program acquire, if `getHeads()` returns 0, read persisted hashes, reconstruct `Entry` via `Entry.fromMultihash(blocksStore, hash)`, then `log.load({reset:true, heads:[Entries]})`
- **Critical Detail**: `load({reset:true, heads})` expects **Entry instances**, not hash strings - `opts.heads.map(x=>x.hash)` is used for pruning, so raw strings are destructive
- **Entry.fromMultihash**: Takes `(store, hash, options)` where store is `peer.services.blocks` (Blocks interface with `get(cid, options)`)

### Replication Head Exchange (Bug A - Unresolved by Persistence Fix)
- **Symptom**: Fresh receiver at `?program=<address>` gets `replicator:join` + `mature` events, but heads never arrive
- **Expected**: Head exchange should complete, `toArray()` should populate
- **Actual**: Endless `replication:change` churn, `toArray()` remains empty
- **Client Fix**: Bounded wait (20s) then explicit error - prevents silent blank UI
- **Root Cause**: Deep in Peerbit synchronizer - likely head message not reaching/being processed correctly

### Log API Traps
- **`load({reset:true, heads})`**: Destructive if heads are hash strings - must pass Entry objects
- **`getHeads(resolve)`**: With `resolve=true`, returns full Entry objects (needed for `.hash`)
- **`join(entries, {reset:true})`**: Recursively fetches ancestors from storage via `entry.getNext()`
- **`_loadedOnce` Flag**: Once set, `load()` returns early unless `reset:true` - affects recovery timing
- **`_storage` Property**: Log's block store is `log._storage`, set at log.js:362 during construction

### Direct Dependencies Matter (pnpm Strict)
- **Problem**: `@peerbit/log` is not a direct dependency - only `@peerbit/shared-log` and `@peerbit/shared-log-proxy` are
- **Impact**: Strict pnpm node_modules doesn't expose transitive `@peerbit/log` to `www/` code
- **Fix**: Add `"@peerbit/log": "6.2.10"` as direct dependency (exact version matching shared-log's dep)
- **Learning**: pnpm's strict structure means you must explicitly declare what you import, even if it's in the transitive tree

### Package Resolution Under Strict pnpm
- **Structure**: `.pnpm/@package+version@hash/node_modules/@package/`
- **Symlinks**: `node_modules/` contains symlinks to the actual packages in `.pnpm/`
- **Conflict Resolution**: If two versions of a package are needed, pnpm hoists based on usage patterns
- **Our Fix**: Using the exact version (6.2.10) that `@peerbit/shared-log` already uses avoids dual-instance issues

### IndexedDB Storage Details
- **minder-peerbit-blocks**: Block storage, persisted across restarts (235M after replication)
- **minder-peerbit-heads**: NEW - stores head hashes as JSON for recovery
- **IndexedDBStore**: Custom wrapper around `browser-level` with base58btc key normalization
- **Key Normalization**: Byte keys (CIDs) are encoded as base58btc strings to avoid `[object ArrayBuffer]` collision

## Cross-Browser Sync Test Notes

### Test Setup
- **Endpoint 1**: Firefox (headless via MCP) - LIMITED: Elm app doesn't load
- **Endpoint 2**: Chromium (desktop, CDP on 9222) - FULLY FUNCTIONAL but Chrome MCP connection fails
- **Dev Server**: Vite dev server on `http://localhost:8899/`
- **Goal**: Verify URL-share (`?program=<address>`) sync between browsers

### Current State
- **Build**: Green, `dist/sw.js` contains persistence code
- **Markers**: `RECOVERED HEADS` and `PERSISTED HEADS` logs present in dist/sw.js
- **Client Code**: URL-share bounded wait present in `www/index.ts` (but may not be in the bundle yet)
- **Firefox**: Page loads HTML but Elm doesn't initialize
- **Chromium**: Running with GPU errors, CDP accessible, but Chrome MCP tools can't connect

### What We Can Test
- **Partial**: Chromium can access the app locally (localhost) via CDP JSON API
- **Not Feasible**: Firefox headless can't run the Elm app
- **Alternative**: Use two Chromium windows with different profiles, or one Chromium window with two tabs

### What We Still Need
- **E2E Sync Test**: Two functional browser instances to verify URL-share sync
- **Head Recovery Verification**: Reload data-holder, confirm heads recover from persisted hashes
- **Client Bounded Wait Verification**: Fresh receiver shows explicit error instead of blank
