import { Capacitor } from '@capacitor/core';
import { App } from '@capacitor/app'
import { Toast } from '@capacitor/toast'
import { SplashScreen } from '@capacitor/splash-screen';
import {Clipboard} from '@capacitor/clipboard'
import {LocalNotifications} from '@capacitor/local-notifications'
import { Preferences } from '@capacitor/preferences';
import {Elm} from '../elm/Main.elm'
import {startOrbit} from './scripts/orbit'
import { defineCustomElements as loadPwaElements } from '@ionic/pwa-elements/loader';
import { detectDarkMode, toggleDarkTheme } from './darkMode';
//import { defineCustomElements as loadIonicElements } from '@ionic/core/loader'
import './scripts/ionicInit'
import * as TaskPort from 'elm-taskport';
import {registerNotificationTaskPorts} from './scripts/capacitor/notifications'
import {registerPreferencesTaskPorts} from './scripts/capacitor/preferences'



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

//import '/styles/theme.css'

// Where we save the personal data
var storagefilename = "Minder/personal-data.json"
var browserStorageKey = 'docket-v0.2-data';



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
}

function elmStarted(app) {
  
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
    app.ports.flash.subscribe(function(data) {

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

    app.ports.ns_notify.subscribe(function(notificationList) {
        try {
          LocalNotifications.schedule({
            notifications: notificationList
          });
          console.log("Notification: ", notificationList)
        } catch (e) {
          console.error("Failed to schedule notification(s)!" , e)
        }
        
    });


      // Clipboard.write({
      //   string: "Hello, Moto"
      // });

      App.addListener('appStateChange', ({ isActive }) => {
        console.log('App state changed. Is active?', isActive);
        detectDarkMode();
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

      try {
        attachOrbit(app);
      } catch (problemWithOrbit)
      {
        console.error("Failed to attach Orbit to Elm!", problemWithOrbit)
      }

}  
//loadIonicElements(window);
loadPwaElements(window);







async function attachOrbit(elmApp) {

    const getPassphraseResult = await Preferences.get({ key: 'minder-alpha-passphrase' });
    var storedPassphrase = getPassphraseResult.value;

    if (storedPassphrase == null) {
        const fallbackPassphrase = ("tester" + Math.floor(Math.random()*1000))
        const newPassphrase = prompt("New device. Enter a secret account passphrase to begin storing your data. If you've already got data in Minder on some other device, be sure to use the same passphrase here, and it will eventually sync over.", fallbackPassphrase);

        storedPassphrase = newPassphrase ? newPassphrase : fallbackPassphrase;
        console.log(`Storing new passphrase: ${storedPassphrase}`);
        await Preferences.set({
          key: 'minder-alpha-passphrase',
          value: storedPassphrase,
        });


    } else {
      console.log(`Passphrase previously specified: ${storedPassphrase}`);
    }



    var currentlyStored: string | null = null;

    const db = await startOrbit(storedPassphrase);
    const dbEntries = db.iterator({ limit: -1 }).collect();
    console.log("Loaded inital database entries", dbEntries);
    let oldFrames = dbEntries.map((e) => e.payload.value).join('\n');

    elmApp.ports.incomingFramesFromElsewhere.send(oldFrames);


    // SET STORAGE
    elmApp.ports.setStorage.subscribe(async function(state) {
      const hash = await db.add(state);
  });

    // Notify elm of new frame from peers
    db.events.on("replicate.progress", (address, hash, entry, progress, have) => {
      const newFrame = entry.payload.value;
      elmApp.ports.incomingFramesFromElsewhere.send(newFrame);
      console.log("New frames from peer @", address, "Progress is ", progress)
    })
}
