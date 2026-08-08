# Manual Verification Guide for Peerbit Persistence Fix

This guide documents the manual verification steps for the two critical fixes that were implemented but couldn't be E2E-verified due to browser environment instability.

## Environment Requirements

- Stable desktop browser (Chromium/Chrome or Firefox)
- `pnpm run build` completed (green)
- `dist/` directory regenerated with new code
- Local dev server: `python3 -m http.server dist/ 8899`

## Verification Checklist

### Fix 1: Data-Holder Head Recovery (Bug B)

**Goal:** After browser restart, the data-holder (main context, no `?program=`) should recover its heads and show tasks instead of an empty list.

**Steps:**
1. Start fresh: Clear all IndexedDB for localhost:8899
   - DevTools → Application → IndexedDB → `http://localhost:8899` → Delete all databases
2. Open `http://localhost:8899/`
3. Create a task (e.g., "Test task 1")
4. **Capture the program address:**
   - DevTools → Application → Local Storage → `CapacitorStorage.minder-peerbit-program-address`
   - Copy the value (it's a base58 address starting with `zb2rh...`)
5. Reload the page (Cmd+R or F5)
6. **Expected:**
   - ✅ Task "Test task 1" is still visible (not lost)
   - ✅ SW console logs show `RECOVERED HEADS for <address>: X entries from Y persisted heads`
   - ✅ No "DIAG[acquire] heads=0" messages (or if they appear, they're followed by recovery)

**If it fails:**
- ❌ Tasks disappear (blank list)
- ❌ SW console shows `DIAG[acquire] heads=0` without `RECOVERED HEADS`
- ❌ SW console shows `persistHeadHashes failed` or `recoverHeadHashes failed`

**Console evidence of success:**
```
ACQUIRED CANONICAL PROGRAM zb2rh... CHANNELS COUNT NOW: 1
RECOVERED HEADS for zb2rh...: 1 entries from 1 persisted heads
PERSISTED HEADS for zb2rh...: 1 heads
```

---

### Fix 2: URL-Share Bounded Wait → Explicit Error (Bug A)

**Goal:** Fresh receiver at `?program=<address>` should either get data within 20s OR show an explicit error message (not a silent blank list).

**Setup:** Need two browser tabs or windows.

**Steps:**
1. **Tab A (Data-holder):**
   - Open `http://localhost:8899/`
   - Create a task: "Shared task A"
   - Copy program address from Local Storage

2. **Tab B (Receiver):**
   - Open `http://localhost:8899/?program=<address>` (replace with actual address)
   - Wait up to 25 seconds

3. **Expected (one of two outcomes):**
   - **Outcome 1 (replication works):** Task "Shared task A" appears within ~5-10 seconds
   - **Outcome 2 (replication fails):** Error message appears after 20 seconds:
     - Title: "Could not open shared program"
     - Body: "The program <address> could not be loaded from the other browser. Is it online? Reload to retry."
     - Button: "Start from Scratch"

**What should NOT happen:**
- ❌ Blank task list for 20+ seconds with no message (the old silent behavior)
- ❌ Auto-creation of a fresh profile (old clobber bug)

**Console evidence of bounded wait:**
```
URL-SHARE: waiting for replicated data, entries: 0
URL-SHARE: waiting for replicated data, entries: 0
... (repeats up to ~20 times)
URL-SHARE: no data within 20000 ms; program address does not exist from the receiver's perspective
```

---

### Combined Verification (Best Path)

If you can run two browsers simultaneously, test both fixes together:

1. **Browser A (Data-holder):**
   - Open `http://localhost:8899/`
   - Create task "Combined test task"
   - Copy program address

2. **Browser A (Restart Test):**
   - Reload page
   - ✅ Task persists (Fix 1 verified)

3. **Browser B (URL-Share Test):**
   - Open `http://localhost:8899/?program=<address>`
   - ✅ Either task appears OR explicit error shows (Fix 2 verified)

---

## Troubleshooting

### Task disappears after reload (Fix 1 failure)
1. Check SW console for `RECOVERED HEADS` log
2. Check if IndexedDB `minder-peerbit-heads` store exists
3. Check if `persistHeadHashes` is called (add more console logs if needed)
4. Verify `@peerbit/log` version is 6.2.10 (check package.json and pnpm lock)

### URL-share stays blank (Fix 2 failure)
1. Check if `programAddressFromUrl` is truthy in continueAfterOpen
2. Check if bounded wait loop runs (look for `URL-SHARE: waiting` logs)
3. Check if `showLoadError` is called after timeout
4. Verify the error element exists in the DOM (check `load-info` element)

### Both issues persist
1. Verify build is fresh: `pnpm run build` and check timestamp of `dist/sw.js`
2. Hard-refresh with cache clear: Cmd+Shift+R (Chrome) or Ctrl+Shift+R (Firefox)
3. Check Service Worker registration: DevTools → Application → Service Workers → "Update on reload"

## What Was Verified Automatically

✅ **Build:** `pnpm run build` completed successfully (green)
✅ **Code presence:** `RECOVERED HEADS` and `PERSISTED HEADS` markers found in `dist/sw.js`
✅ **Type safety:** No TypeScript errors related to the new code
✅ **API correctness:** Verified `Entry.fromMultihash` signature and `load({reset:true, heads})` behavior via source inspection

## What Requires Manual Testing

❌ **E2E browser behavior:** Actual browser execution blocked by environment instability
❌ **IDB persistence:** Real IndexedDB storage across page reloads
❌ **Replication timing:** Real peer-to-peer head exchange
❌ **UI rendering:** Error screen appearance and task list display

## Status

- **Implementation:** ✅ Complete
- **Build:** ✅ Green
- **Automated verification:** ⏸️ Blocked by environment
- **Manual verification:** 📋 Ready to run (use this guide)
