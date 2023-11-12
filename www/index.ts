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
import {startOrbit} from './scripts/orbit'
import { defineCustomElements as loadPwaElements } from '@ionic/pwa-elements/loader';
import { detectDarkMode, toggleDarkTheme } from './darkMode';
//import { defineCustomElements as loadIonicElements } from '@ionic/core/loader'
import './scripts/ionicInit'
import * as TaskPort from 'elm-taskport';
import {registerNotificationTaskPorts, scheduleNotifications} from './scripts/capacitor/notifications'
import {registerPreferencesTaskPorts} from './scripts/capacitor/preferences'
import { native } from '@nativescript/capacitor';
import { minderAsciiLogo } from './scripts/asciiArt';




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



var orbitIsReady = false;


// START ELM
async function startElmApp() {

    installTaskPorts();

    let app = Elm.Main.init({ flags: 
        { storedRonMaybe : (null) 
        , userFlags : {darkTheme: window.matchMedia('(prefers-color-scheme: dark)').matches}
        }
    });
    elmStarted(app);

}
startElmApp();

function installTaskPorts() {
  
  TaskPort.install({ logCallErrors: true, logInteropErrors: false });
  
  registerPreferencesTaskPorts();
  registerNotificationTaskPorts();
  TaskPort.register("changePassphrase", () => getPassphrase(true));
  TaskPort.register("requestNotificationPermission", LocalNotifications.requestPermissions)
  TaskPort.register("ionInputSetFocus", (id : String) => document?.getElementById(id).setFocus())
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
        attachOrbit(app);
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
        const fallbackPassphrase = notPreviouslySet ? ("tester" + Math.floor(Math.random()*1000)) : storedPassphrase

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
    const storedPassphrase : string | null = await  getPassphrase(false);
    const db = await startOrbit(storedPassphrase);
    globalThis["minderLog"] = db;
    const dbEntries = db.iterator({ limit: -1 }).collect();
    console.log("Loaded inital database entries", dbEntries);
    let oldFrames = dbEntries.map((e) => e.payload.value).join('\n');

    elmApp.ports.incomingRon.send(oldFrames);

    // SET STORAGE
    elmApp.ports.setStorage.subscribe(async function(state) {
        if (state.trim() != "")
        {
          // TODO elm may call this before it's ready. make taskport, hoist to top and use await db.load? or onReady?
          console.log("Adding state to database", state);
          const hash = db.add(state); //async?
        }
  });

    // Notify elm of new frame from peers
    db.events.on("replicate.progress", (address, hash, entry, progress, have) => {
      const newFrame = entry.payload.value;
      elmApp.ports.incomingRon.send(newFrame);
      console.log("New frames from peer @", address, "Progress is ", progress)
    })
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

