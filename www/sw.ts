declare let self: ServiceWorkerGlobalScope & {
  skipWaiting: () => void
  addEventListener: typeof globalThis.addEventListener
  clients: any
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
							const runtime = new PeerbitCanonicalRuntime({})
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
