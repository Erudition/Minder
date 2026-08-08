declare let self: ServiceWorkerGlobalScope & {
  skipWaiting: () => void
  addEventListener: typeof globalThis.addEventListener
  clients: any
  location: Location
}
declare interface ExtendableMessageEvent extends MessageEvent {
  readonly ports: MessagePort[]
  waitUntil: (promise: Promise<any>) => void
}

console.log("SW: Script starting evaluation...");
self.skipWaiting();

import { cleanupOutdatedCaches, precacheAndRoute } from 'workbox-precaching'
import { clientsClaim } from 'workbox-core'

console.log("SW: Imports completed successfully.");

if (typeof (globalThis as any).Worker === 'undefined') {
  (globalThis as any).Worker = class LazyWorker {
    constructor(url: any) {
      // Lazy check at construction time (runtime), not during module import
      throw new Error("ServiceWorker cannot spawn Workers: " + String(url));
    }
  };
}

try {
  cleanupOutdatedCaches()
  precacheAndRoute(self.__WB_MANIFEST)
  clientsClaim()
  console.log("SW: Workbox setup complete.");
} catch(e) {
  console.error("SW: Workbox setup failed:", e);
}

self.addEventListener('error', (e: Event) => console.error('SW Global Error:', e));
self.addEventListener('unhandledrejection', (e: PromiseRejectionEvent) => console.error('SW Unhandled Rejection:', e.reason));

import { CanonicalHost, PeerbitCanonicalRuntime } from '@peerbit/canonical-host'
import { minderLogModule } from './minder-log-host-module.js'

let hostPromise: Promise<any> | undefined

self.addEventListener('message', (event: any) => {
  console.log("SW Message Received:", event.data);
	if (
		event.data?.op === '__peerbit_canonical_connect__' ||
		event.data?.__peerbit_canonical_connect__ === true
	) {
		const port = event.ports?.[0]
		if (!port) return

		event.waitUntil(
			(async () => {
				try {
					if (!hostPromise) {
						hostPromise = (async () => {
							console.log("SW: Creating PeerbitCanonicalRuntime...");
							const runtime = new PeerbitCanonicalRuntime({ peerOptions: { bootstrapRecovery: true } })
							console.log("SW: Creating CanonicalHost...");
							const host = new CanonicalHost(runtime)
							console.log("SW: Registering module...");
							host.registerModule(minderLogModule)
							console.log("SW: Host created, registering module done");
							return host
						})().catch(async (e) => {
              console.error("SW: hostPromise failed:", e);
              try {
                const allClients = await self.clients.matchAll({ includeUncontrolled: true, type: 'window' });
                for (const c of allClients) {
                  c.postMessage({ type: 'sw-debug', msg: 'hostPromise FAILED: ' + String(e?.message || e) });
                }
              } catch {}
              port.postMessage({ __peerbit_canonical_ready__: false, error: String(e.message || e) });
              throw e;
            });
					}
					const host = await hostPromise
					host.attachControlPort(port)
					try {
						port.postMessage({ __peerbit_canonical_ready__: true })
					} catch {}
          console.log("SW: canonical connect success");
          // Forward debug to all client tabs so it's visible in page console
          try {
            const allClients = await self.clients.matchAll({ includeUncontrolled: true, type: 'window' });
            for (const c of allClients) {
              c.postMessage({ type: 'sw-debug', msg: 'canonical connect success, host attached' });
            }
          } catch {}
				} catch (err: any) {
					console.error('SW canonical connect failed:', err)
					try {
						port.postMessage({
							__peerbit_canonical_ready__: false,
							error: String(err?.message || err),
						})
					} catch {}
				}
			})(),
		)
	}
})
console.log("SW: Script finished evaluation successfully!");

// ---- Wasm / worker asset URL rewrite --------------------------------------
// Peerbit's host runtime loads wasm and sqlite/riblt/opfs workers through URLs
// that break once the module graph is bundled into a single sw.js served from a
// deployment subpath:
//   - absolute "/peerbit/<pkg>/<file>"  (loaders assume deployment at domain root)
//   - package-relative "../wasm/*.wasm" / "../../wasm/*.wasm" (resolve against
//     sw.js's own URL and escape the deployment root)
//   - sqlite3's emscripten locateFile builds URLs dynamically at runtime
//   - vite-hashed asset refs like "/assets/<name>-<hash>.wasm"
// All those files actually live under the deployment root (publicDir copies in
// peerbit/<pkg>/, and vite hashed assets in assets/). Map by basename and
// resolve against self.location so the same sw.js works for master, branch,
// and PR preview deployments without knowing the base path.
//
// CRITICAL: requests made BY the service worker are sent with `service-workers
// mode: 'none'`, so the SW's own fetch event handler never fires for them. The
// wasm loads happen inside the SW host runtime, therefore globalThis.fetch is
// wrapped to rewrite them. The fetch event handler below additionally covers
// requests from controlled pages (the page bundle also references peerbit
// assets via absolute /assets/ and /peerbit/ URLs).
const PEERBIT_ASSET_ROOTS: Record<string, string> = {
  // un-hashed copies emitted by copy-peerbit-assets.js
  'shared_log_rust_bg.wasm': 'peerbit/wasm/',
  'shared_log_rust.js': 'peerbit/wasm/',
  'native_backbone_bg.wasm': 'peerbit/wasm/',
  'native_backbone.js': 'peerbit/wasm/',
  // publicDir copies (www/vite-extra-assets/peerbit/<pkg>)
  'rateless_iblt_bg.wasm': 'peerbit/riblt/',
  'sqlite3.wasm': 'peerbit/sqlite3/',
  'sqlite3.js': 'peerbit/sqlite3/',
  'sqlite3.mjs': 'peerbit/sqlite3/',
  'sqlite3-worker1.js': 'peerbit/sqlite3/',
  'sqlite3-worker1.mjs': 'peerbit/sqlite3/',
  'sqlite3-worker1-promiser.js': 'peerbit/sqlite3/',
  'sqlite3-worker1-promiser.mjs': 'peerbit/sqlite3/',
  'sqlite3-worker1-promiser-bundler-friendly.mjs': 'peerbit/sqlite3/',
  'sqlite3-worker1-bundler-friendly.mjs': 'peerbit/sqlite3/',
  'sqlite3.worker.min.js': 'peerbit/sqlite3/',
  'sqlite3-opfs-async-proxy.js': 'peerbit/sqlite3/',
  'opfs.worker.min.js': 'peerbit/opfs/',
};

// vite-hashed variants of the peerbit assets (live under assets/<name>).
const PEERBIT_HASHED_ASSET_PREFIXES = [
  'native_backbone_bg-',
  'shared_log_rust_bg-',
  'rateless_iblt_bg-',
  'sqlite3-',
];

function rewritePeerbitAssetUrl(url: URL): URL | null {
  if (url.origin !== self.location.origin) return null;
  const name = url.pathname.split('/').pop() ?? '';
  let root = PEERBIT_ASSET_ROOTS[name];
  if (!root) {
    const hashed = PEERBIT_HASHED_ASSET_PREFIXES.find(
      (p) => name.startsWith(p) && (name.endsWith('.wasm') || name.endsWith('.js')),
    );
    if (hashed) root = 'assets/';
  }
  if (!root) return null;
  const target = new URL(root + name, self.location.href);
  // Guard against rewriting the same URL again (idempotence / no recursion).
  if (target.href === url.href) return null;
  return target;
}

function swDebug(msg: string) {
  console.log("SW:", msg);
  try {
    self.clients.matchAll({ includeUncontrolled: true, type: 'window' }).then((all: any[]) => {
      for (const c of all) c.postMessage({ type: 'sw-debug', msg });
    });
  } catch {}
}

// 1) Wrap fetch so SW-internal requests (wasm loads inside the host runtime)
// are rewritten. globalThis.fetch is rebound before the host ever runs.
const originalFetch = globalThis.fetch.bind(globalThis);
globalThis.fetch = ((input: RequestInfo | URL, init?: RequestInit) => {
  const requestUrl =
    typeof input === 'string'
      ? new URL(input, self.location.href)
      : input instanceof URL
        ? input
        : new URL(input.url, self.location.href);
  const target = rewritePeerbitAssetUrl(requestUrl);
  if (target) {
    swDebug(`asset rewrite (sw fetch): ${requestUrl.href} -> ${target.href}`);
    if (typeof input === 'string') {
      return originalFetch(target.href, init);
    }
    return originalFetch(new Request(target.href, input instanceof Request ? input : init));
  }
  return originalFetch(input as RequestInfo, init);
}) as typeof fetch;

// 2) Fetch event: cover requests from controlled pages.
self.addEventListener('fetch', (event: any) => {
  const url = new URL(event.request.url);
  const target = rewritePeerbitAssetUrl(url);
  if (!target) return;
  swDebug(`asset rewrite (page fetch): ${url.href} -> ${target.href}`);
  event.respondWith(fetch(target, { credentials: 'same-origin' }));
});
