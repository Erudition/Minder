# Agent Notes

## Running Playwright on Guix

The default Playwright/MCP setup tries to download browser binaries and expects Chrome at `/opt/google/chrome/chrome`. On Guix, downloaded binaries often fail because of FHS/dependency mismatches, and the Google Chrome path is not present.

Use the system Chromium installed via Guix instead:

- Install: `guix install chromium`
- Typical binary location: `/home/adroit/.guix-profile/bin/chromium`
- Launch Playwright with `executablePath` pointing at that binary:

```javascript
import { chromium } from 'playwright';

const browser = await chromium.launch({
  headless: false, // or true
  executablePath: '/home/adroit/.guix-profile/bin/chromium',
});
```

Notes:
- The Playwright MCP plugin (`/playwright`) may still look for the default Chrome path; for ad-hoc QA use a standalone Node script with `playwright` directly.
- `headless: true` works with the system Chromium for simple DOM inspection, but some Ionic/custom-element interactions may behave differently than in a headed run. Use headed mode when debugging shadow-DOM or custom-element inputs.
- Keep a temporary directory such as `/tmp/playwright-qa/` for throwaway scripts and screenshots.

## Peerbit Persistence in Browser

- The browser build of `@peerbit/any-store` defaults to `MemoryStore` unless `directory` is passed to `Peerbit.create`.
- Pass a directory string (e.g., `directory: "minder-peerbit"`) to switch to `OPFSStore` and survive page reloads.
- When using a directory, copy the OPFS worker asset from `@peerbit/any-store-opfs/dist/assets/opfs/` into `www/vite-extra-assets/peerbit/opfs/` so Vite serves it at `/peerbit/opfs/opfs.worker.min.js`.
