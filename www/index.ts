/// <reference types="vite/client" />
import { Capacitor } from '@capacitor/core';
import { App } from '@capacitor/app'
import { Toast } from '@capacitor/toast'
import { SplashScreen } from '@capacitor/splash-screen';
import { StatusBar, Style } from '@capacitor/status-bar';
import {Clipboard} from '@capacitor/clipboard'
import {LocalNotifications} from '@capacitor/local-notifications'
import { Preferences } from '@capacitor/preferences';
// import {Elm} from '../elm/Main.elm'
import {Elm} from '../.elm-land/src/Main.elm'
import { Dialog } from '@capacitor/dialog';
import { defineCustomElements as loadPwaElements } from '@ionic/pwa-elements/loader';
import { detectDarkMode, toggleDarkTheme } from './darkMode';
//import { defineCustomElements as loadIonicElements } from '@ionic/core/loader'
import './scripts/ionicInit'
import * as TaskPort from 'elm-taskport';
import {registerNotificationTaskPorts, scheduleNotifications} from './scripts/capacitor/notifications'
import {registerPreferencesTaskPorts} from './scripts/capacitor/preferences'
import { native } from '@nativescript/capacitor';
import { minderAsciiLogo } from './scripts/asciiArt';
// import { registerSW } from 'virtual:pwa-register';
import { connectServiceWorker, connectSharedWorker, PeerbitCanonicalClient } from '@peerbit/canonical-client';
import { CanonicalConnection, CanonicalChannelMessage, CanonicalFrame } from '@peerbit/canonical-transport';
import { deserialize } from '@dao-xyz/borsh';
import { MinderLog } from './minder-log.js';
import { minderLogAdapter, type MinderLogProxy } from './minder-log-client-adapter.js';
import { registerSW } from 'virtual:pwa-register';

// Monkey patch CanonicalConnection.prototype.onMessage to survive instanceof mismatch across bundler chunks
const origOnMessage = (CanonicalConnection.prototype as any).onMessage;
(CanonicalConnection.prototype as any).onMessage = function (data: Uint8Array) {
  try {
    const frame = deserialize(data, CanonicalFrame) as any;
    if (frame && typeof frame.channelId === "number" && frame.payload instanceof Uint8Array) {
      let state = (this as any).channels.get(frame.channelId);
      if (!state) {
        state = (this as any).channels.values().next().value;
      }
      if (state && !state.closed) {
        for (const handler of state.handlers) {
          console.log("EXECUTING HANDLER FOR PAYLOAD LENGTH:", frame.payload.length, "PREFIX:", frame.payload[0], frame.payload[1]);
          handler(frame.payload);
        }
        return;
      }
    }
  } catch (e) {
    console.error("MONKEY PATCH ERROR:", e);
  }
  return origOnMessage.call(this, data);
};





/* Core CSS required for Ionic components to work properly */
import '@ionic/core/css/core.css';

/* Basic CSS for apps built with Ionic */
import '@ionic/core/css/normalize.css';
import '@ionic/core/css/structure.css';
import '@ionic/core/css/typography.css';

/* Optional CSS utils that can be commented out */
import '@ionic/core/css/padding.css';
import '@ionic/core/css/float-elements.css';
import '@ionic/core/css/text-alignment.css';
import '@ionic/core/css/text-transformation.css';
import '@ionic/core/css/flex-utils.css';
import '@ionic/core/css/display.css';

// Display content under transparent status bar (Android only)
// Fails in browser, suppress error
// StatusBar.setOverlaysWebView({ overlay: true }).catch(e => {return});
// StatusBar.setStyle({}); // set to opposite of current theme
// FIXME: can't underlay status bar because theme switch resets status bar padding 



addEventListener("error", (event) => {alert(event.message + "\n filename: " + event.filename + "\n line: " + event.lineno + "\n column: " + event.colno + "\n error: " + event.error)});

function updateLoadInfo(message : string) : void {
  const el = document.getElementById("load-info");
  if (el) el.innerText = message;
}
updateLoadInfo("Starting JS");

const PROGRAM_ADDRESS_KEY = "minder-peerbit-program-address";

// START ELM
async function startElmApp() {
    console.log("startElmApp ENTERED");
    updateLoadInfo("Installing TaskPorts");
    await installTaskPorts();
    console.log("installTaskPorts DONE");
    updateLoadInfo("Loading stored data");
    const storedRon = await Preferences.get({ key: 'appData' });
    console.log("Preferences.get DONE");
    updateLoadInfo("Loading program address");
    let storedProgramAddress: string | undefined;
    try {
        const storedProgramAddressResult = await Preferences.get({ key: PROGRAM_ADDRESS_KEY });
        storedProgramAddress = storedProgramAddressResult.value ?? undefined;
        if (storedProgramAddress === "") {
            storedProgramAddress = undefined;
        }
    } catch (error) {
        console.error("Failed to read stored program address; continuing without one.", error);
    }
    updateLoadInfo("Connecting Peerbit host");
    let client: Awaited<ReturnType<typeof connectServiceWorker>> | null = null;
    if (navigator.serviceWorker) {
      const base = import.meta.env.BASE_URL;
      const registration = await navigator.serviceWorker.register(`${base}sw.js`, { scope: base, ...(import.meta.env.DEV ? { type: 'module' } : {}) }).catch((e) => {
        console.error("SW registration failed:", e);
        return undefined;
      });
      const swReady = await Promise.race([
        navigator.serviceWorker.ready.catch((e) => {
          console.error("navigator.serviceWorker.ready failed:", e);
          return undefined;
        }),
        new Promise<ServiceWorkerRegistration | undefined>((resolve) => setTimeout(() => resolve(undefined), 10_000)),
      ]);
      const swTarget = swReady?.active || navigator.serviceWorker.controller || registration?.active;
      if (swTarget) {
        if (swTarget.state !== 'activated') {
          console.log("RELOAD DEBUG: SW is activating, waiting for activated state...", swTarget.state);
          await new Promise<void>((resolve) => {
            const onStateChange = () => {
              console.log("RELOAD DEBUG: SW state changed to:", swTarget.state);
              if (swTarget.state === 'activated') {
                swTarget.removeEventListener('statechange', onStateChange);
                resolve();
              }
            };
            swTarget.addEventListener('statechange', onStateChange);
          });
        }
        
        console.log("RELOAD DEBUG: Sending test ping to SW...");
        const channel = new MessageChannel();
        channel.port1.onmessage = (e) => console.log("RELOAD DEBUG: SW PING REPLY:", e.data);
        swTarget.postMessage("TEST_PING", [channel.port2]);

        console.log("RELOAD DEBUG: Calling connectServiceWorker with target SW...", swTarget.state);
        client = await connectServiceWorker({ serviceWorker: swTarget, timeoutMs: 30_000 }).catch((e) => {
          console.error("connectServiceWorker failed:", e);
          return null;
        });
        console.log("RELOAD DEBUG: connectServiceWorker returned client:", !!client);
      } else {
        console.error("Service worker ready but target worker is missing");
      }
    }
    if (!client) {
      console.warn("Could not connect to service worker, running without Peerbit sync.");
      let fallbackApp = Elm.Main.init({ flags: 
        { storedRonMaybe : null
        , darkTheme: window.matchMedia('(prefers-color-scheme: dark)').matches
        , notifPermission : await LocalNotifications.checkPermissions()
        , launchTime : Date.now()
        }
      });
      elmStarted(fallbackApp);
      updateLoadInfo("App loaded (offline mode)");
      // Remove the pre-js class so the app becomes visible
      document.body.classList.remove("pre-js");
      const loadInfo = document.getElementById("load-info");
      if (loadInfo) loadInfo.style.display = "none";
      return;
    }
    const peer = await PeerbitCanonicalClient.create(client, { adapters: [minderLogAdapter] });
    updateLoadInfo("Opening MinderLog");
    let proxy: MinderLogProxy | undefined;
    let result: any;
    console.log("RELOAD DEBUG: storedProgramAddress is:", storedProgramAddress);
    try {
      if (storedProgramAddress) {
        console.log("RELOAD DEBUG: Opening stored address:", storedProgramAddress);
        result = await peer.open(storedProgramAddress);
        console.log("RELOAD DEBUG: Opened stored address result:", result);
      } else {
        console.log("RELOAD DEBUG: Opening new MinderLog...");
        result = await peer.open(new MinderLog());
        console.log("RELOAD DEBUG: Opened new MinderLog result:", result);
      }
    } catch (e: any) {
      console.warn("Failed to open stored program address, clearing and creating fresh", e?.stack || e);
      await Preferences.remove({ key: PROGRAM_ADDRESS_KEY }).catch(() => {});
      try {
        result = await peer.open(new MinderLog());
      } catch (freshErr) {
        console.error("Peerbit host open fresh MinderLog failed:", freshErr);
      }
    }
    if (result?.address) {
      await Preferences.set({ key: PROGRAM_ADDRESS_KEY, value: result.address.toString() }).catch(() => {});
    }
    proxy = result?.proxy || result;

    let allOpsText: string | undefined;
    if (proxy) {
      const entries = await proxy.log.toArray();
      console.log("RELOAD: PROXY LOG TOARRAY LENGTH:", entries.length);
      const decoder = new TextDecoder();
      const ops: string[] = [];
      for (const entry of entries) {
        const value = await Promise.resolve(entry.getPayloadValue());
        if (value instanceof Uint8Array) ops.push(decoder.decode(value));
        else if (typeof value === "string") ops.push(value);
      }
      allOpsText = ops.join("❃");
      console.log("RELOAD: ALL OPS TEXT LENGTH:", allOpsText.length, "OPS COUNT:", ops.length, "PREVIEW:", allOpsText.slice(0, 100));
      updateLoadInfo("Peerbit host ready");
    }

    updateLoadInfo("Starting Elm app");
    let app = Elm.Main.init({ flags: 
        { storedRonMaybe : null // Phase 1: do not migrate old Preferences data; Peerbit is the source of truth
        , darkTheme: window.matchMedia('(prefers-color-scheme: dark)').matches
        , notifPermission : await LocalNotifications.checkPermissions()
        , launchTime : Date.now()
        }
    });
    (window as any).app = app;

    if (app.ports.replicatorOut) {
      const encoder = new TextEncoder();
      app.ports.replicatorOut.subscribe(async function(data: string) {
        console.log("REPLICATOR OUT RECEIVED:", data, "proxy:", proxy);
        if (proxy) {
          const ops = data.split("❃").filter((op: string) => op.length > 0);
          const appendFn = (proxy as any).proxy?.append || (proxy as any).append || (proxy as any).log?.append;
          console.log("APPEND TARGET IS:", appendFn);
          if (appendFn) {
            for (const op of ops) {
              await appendFn(encoder.encode(op));
            }
          }
        }
      });
    }

    if (proxy) {
      if (allOpsText && app.ports.replicatorIn) {
        const opsToSend = allOpsText;
        setTimeout(() => {
          console.log("SENDING INITIAL STORED OPS TO ELM:", opsToSend.slice(0, 50));
          if (app.ports.replicatorIn) {
            app.ports.replicatorIn.send(opsToSend);
          }
        }, 100);
      }
      // Live cross-tab & replication sync
      const onSyncChange = async (evt?: any) => {
        console.log("ON SYNC CHANGE FIRED! Detail:", !!evt?.detail);
        const decoder = new TextDecoder();
        let opText: string | undefined;
        if (evt?.detail instanceof Uint8Array) {
          opText = decoder.decode(evt.detail);
        } else {
          const entries = await proxy.log.toArray();
          const ops: string[] = [];
          for (const entry of entries) {
            const value = await Promise.resolve(entry.getPayloadValue());
            if (value instanceof Uint8Array) ops.push(decoder.decode(value));
            else if (typeof value === "string") ops.push(value);
          }
          opText = ops.join("❃");
        }
        console.log("ON SYNC CHANGE SENDING TO ELM:", opText?.slice(0, 50));
        if (opText && app.ports.replicatorIn) {
          app.ports.replicatorIn.send(opText);
        }
      };
      proxy.events.addEventListener("change", onSyncChange);
      proxy.events.addEventListener("replication:change", onSyncChange);
    }

    elmStarted(app);
    document.body.classList.remove("pre-js");
    const loadInfo = document.getElementById("load-info");
    if (loadInfo) loadInfo.style.display = "none";

}
startElmApp();

async function installTaskPorts() {
  
  TaskPort.install({ logCallErrors: true, logInteropErrors: false });
  await attachODDElmLibrary();
  registerPreferencesTaskPorts();
  registerNotificationTaskPorts();
  TaskPort.register("changePassphrase", () => getPassphrase(true));
  TaskPort.register("requestNotificationPermission", LocalNotifications.requestPermissions)
  TaskPort.register("ionInputSetFocus", (id : string) => document?.getElementById(id)!.setFocus())
  TaskPort.register("dialogPrompt", Dialog.prompt)
}

function elmStarted(app) {
    console.log(minderAsciiLogo);
    // hide the splash screen
    SplashScreen.hide().catch((err) => {
        console.log("No Capacitor splash screen to hide.");
    });

    // Try to make storage persistent
    if (navigator.storage && navigator.storage.persist)
    navigator.storage.persist().then(granted => {
      if (granted)
        console.log("Storage will not be cleared except by explicit user action");
      else
        console.log("Storage may be cleared by the UA under storage pressure.");
    });


    // FLASH OR TOAST
    app.ports.toastPort.subscribe(function(data) {

        // Workaround for https://github.com/ionic-team/pwa-elements/issues/34
        // (Line breaks are ignored and replaced with spaces)
        //let reformatted = data.replace(/(?:\r\n|\r|\n)/g, " — ");

        try {
          Toast.show({ text: data, duration: "short"}).then();
        //console.log("Toast: "+data)
        } catch (e) {
          console.error("Failed to show Toast!", e)
        }
        
    });

    app.ports.ns_notify.subscribe(scheduleNotifications);


      // Clipboard.write({
      //   string: "Hello, Moto"
      // });

      App.addListener('appStateChange', ({ isActive }) => {
        detectDarkMode();
        Toast.show({ text: ("App became " + (isActive ? "active!" : "inactive.")), duration: "short"}).then();
      });
      
      App.addListener('appUrlOpen', data => {
        console.log('App opened with URL:', data);
      });
      
      App.addListener('appRestoredResult', data => {
        console.log('Restored state:', data);
      });
      
      const checkAppLaunchUrl = async () => {
        const url = await App.getLaunchUrl();
      
        console.log('App opened with URL: ' + url);
      };
      Toast.show({ text: window.location.href, duration: "short"}).then();
      try {
        //attachOrbit(app);
        //attachODDManual(app);
      } catch (problemWithOrbit)
      {
        console.error("Failed to attach Orbit to Elm!", problemWithOrbit)
      }

}  
//loadIonicElements(window);
loadPwaElements(window);




async function getPassphrase(shouldReset) {
    const getPassphraseResult = await Preferences.get({ key: 'minder-alpha-passphrase' });
    var storedPassphrase = getPassphraseResult.value;

    const notPreviouslySet = storedPassphrase == null || storedPassphrase == ""

    if (notPreviouslySet || shouldReset) {
        const fallbackPassphrase = storedPassphrase ? ("tester" + Math.floor(Math.random()*1000)) : storedPassphrase

        const { value, cancelled } = await Dialog.prompt({
          title: 'New Device',
          message: "Enter a secret account passphrase to begin storing your data. If you've already got data in Minder on some other device, be sure to use the same passphrase here, and it will eventually sync over.",
        });

        const newPassphrase = cancelled ? fallbackPassphrase : value

        storedPassphrase = newPassphrase ? newPassphrase : fallbackPassphrase;
        Toast.show({ text: `Storing new passphrase: ${storedPassphrase}`, duration: "short"}).then();
        await Preferences.set({
          key: 'minder-alpha-passphrase',
          value: storedPassphrase,
        });
        return storedPassphrase;
    } else {
      Toast.show({ text: `Loading account: ${storedPassphrase}`, duration: "short"}).then();
      return storedPassphrase;
    }
}

async function attachOrbit(elmApp) {
    // OrbitDB/IPFS integration is defunct — stubbed out
    console.log("OrbitDB: skipped (defunct)")
}


async function attachODDManual(elmApp) {
  // ODD SDK (Fission) is defunct — stubbed out
  console.log("ODD SDK: skipped (Fission is defunct)")
}

async function attachODDElmLibrary() {
  // Fission/webnative is defunct — stubbed out
  console.log("webnative-elm: skipped (Fission is defunct)")
}

// FLIP ANIMATIONS
// Requires patch to ~/.elm/0.19.1/packages/elm/browser/1.0.2/src/Elm/Kernel/Browser.js
// in function _Browser_makeAnimator(model, draw)
// only in nested function updateIfNeeded(), change this line:
// : ( _Browser_requestAnimationFrame(updateIfNeeded), flipDraw(model), __4_EXTRA_REQUEST );
// and add function flipDraw(modelIn) {window.flipping.read();draw(modelIn);window.afterDraw();}
//import Flipping from 'flipping/lib/adapters/web';
//compare to:
import Flipping from 'flipping/lib/adapters/css';

(window as any).flipping = new Flipping({duration:300});

(window as any).afterDraw = async () => {
  
  //for normal updates
  (window as any).flipping.flip()
  
  //for delayed updates
  //requestAnimationFrame(async () => await (window as any).flipping.flip());
}

