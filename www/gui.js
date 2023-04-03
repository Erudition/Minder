// If this file has .mjs extension, Tasker injection will not work.
const { Toast, App, SplashScreen, Clipboard, LocalNotifications, Storage } = window.Capacitor.Plugins;
//const {SplashScreen} = window.Capacitor.Plugins.SplashScreen;


// import IPFS from 'ipfs'
// import OrbitDB from 'orbit-db'

// (async function () {
//   const ipfs = await IPFS.create()
//   const orbitdb = await OrbitDB.createInstance(ipfs)

//   // Create / Open a database
//   const db = await orbitdb.log("hello")
//   await db.load()

//   // Listen for updates from peers
//   db.events.on("replicated", address => {
//     console.log(db.iterator({ limit: -1 }).collect())
//   })

//   // Add an entry
//   const hash = await db.add("world")
//   console.log(hash)

//   // Query
//   const result = db.iterator({ limit: -1 }).collect()
//   console.log(JSON.stringify(result, null, 2))
// })()


// Where we save the personal data
var storagefilename = "Minder/personal-data.json"
var browserStorageKey = 'docket-v0.2-data';



// START ELM
async function startElmApp() {
try { // Errors out if undeclared
    if (inTasker) {
        let storedState = tk.readFile(storagefilename);
        let app = Elm.Main.init(
            { flags: 
                { storedRonMaybe : (storedState ? storedState : null)
                , userFlags : null
                }
            }
            );
    elmStartedWithTasker(app);
    }
} catch (error) { // not inTasker
    const db = await startOrbit();
    const dbEntries = db.iterator({ limit: -1 }).collect();
    console.log(JSON.stringify(dbEntries, null, 2));
    const currentlyStored = dbEntries.map((e) => e.payload.value).join('\n');
    //const currentlyStored = localStorage.getItem(browserStorageKey);


    let app = Elm.Main.init({ flags: 
        { storedRonMaybe : (currentlyStored ? currentlyStored : null) 
        , userFlags : null
        }
    });
    elmStartedWithoutTasker(app, db);
    // Use Capacitor storage
    // Storage.get({ key: browserStorageKey }).then((found) => {
    //     let app = Elm.Main.init({ flags: 
    //         { storedRonMaybe : (found.value ? found.value : null) 
    //         , userFlags : null
    //         }
    //     });
    //     elmStartedWithoutTasker(app);
    // });

    // Try to make it persistent
    if (navigator.storage && navigator.storage.persist)
      navigator.storage.persist().then(granted => {
        if (granted)
          console.log("Storage will not be cleared except by explicit user action");
        else
          console.log("Storage may be cleared by the UA under storage pressure.");
      });
}
}

startElmApp();

function elmStartedWithTasker(app) {

    tk.flash("Welcome to Tasker in the GUI!")

    // SET STORAGE
    app.ports.setStorage.subscribe(function(data) {
        tk.writeFile(storagefilename,data,false)
    });


    // FLASH OR TOAST
    app.ports.flash.subscribe(function(data) {
        tk.flash(data)
    });


    // TASKER VARIABLE OUT
    app.ports.variableOut.subscribe(function(data) {
          if (data[0].toLower == data[0])
            tk.setLocal(data[0], data[1]);
          else
            tk.setGlobal(data[0], data[1]);
    });

    // TASKER STOP EXECUTING
    app.ports.exit.subscribe(function(data) {

        // Must be in this exact form for some reason:
        setTimeout(() => tk.flash("Trying to hide the window" + tk.hideScene("Docket")), 100);
    });

}


function elmStartedWithoutTasker(app, db) {

    //tk.flash("Tasker does not appear to be here!" + tk.global( 'sdk' ))
    // hide the splash screen
    // SplashScreen.hide().catch((err) => {
    //     console.log("No Capacitor splash screen to hide.");
    // });



    // SET STORAGE
    app.ports.setStorage.subscribe(async function(state) {
        // TODO does this account for localStorage disabled/unavailable?
        // https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API
        
        // This was to use Capacitor storage, but it removes linebreaks
        // Storage.get({ key: browserStorageKey }).then((found) => {
        //     Storage.set({
        //         key: browserStorageKey,
        //         value: (found.value ? found.value : "") + state
        //        });
        // });
        // const currentlyStored = localStorage.getItem(browserStorageKey);
        // localStorage.setItem(browserStorageKey, (currentlyStored ? currentlyStored : "") + state);
        const hash = await db.add(state);

    });

    // LISTEN TO STORAGE
    // Capacitor Storage api doesn't seem to have this yet
    // https://github.com/ionic-team/capacitor/blob/master/core/src/web/storage.ts
    // So let's subscribe to localStorage ourselves
    window.addEventListener('storage', function (e) {
        // if (e.key == Storage.KEY_PREFIX + browserStorageKey) { //Capacitor
        if (e.key == browserStorageKey) {
            app.ports.incomingFramesFromElsewhere.send(e.newValue);
        } else {
            console.log("localStorage changed elsewhere, but the key was different.")
        }
    });


    // Get new frames from peers
    db.events.on("replicate.progress", (address, hash, entry, progress, have) => {
      //const newFramesOnlyIHope = db.iterator({ limit: -1 }).collect().map(e => e.payload.value).join('\n');
      const newFramesOnlyIHope = entry.payload.value;
      app.ports.incomingFramesFromElsewhere.send(newFramesOnlyIHope);
      console.log("Got new frames from peer @" + address)
    })


    // FLASH OR TOAST
    app.ports.flash.subscribe(function(data) {

        // Workaround for https://github.com/ionic-team/pwa-elements/issues/34
        // (Line breaks are ignored and replaced with spaces)
        let reformatted = data.replace(/(?:\r\n|\r|\n)/g, " — ");


        Toast.show({ text: reformatted, duration: '10000'}).then();
        console.log("Toast: "+data)
    });

    // const setItem = Storage.set({
    //  key: 'pet',
    //  value: 'dog'
    // });
    // console.log('Set item: ', setItem);
    //
    // const value = Storage.get({ key: 'pet' });
    //   console.log('Got item: ', value);

     // toast = Toast.show({
     //   text: 'Hello! not async'
     // });
     //  console.log('Toasted: ', toast);

      //was await
      // var ret = App.canOpenUrl({ url: 'app.docket' });
      // console.log('Can open url: ', ret.value);

      //ret = await CapApp.openUrl({ url: 'app.docket://page?id=ionicframework' });
      //console.log('Open url response: ', ret);

      //was await
      // ret2 =  App.getLaunchUrl();
      // if(ret2 && ret2.url) {
      //   console.log('App opened with URL: ' + ret2.url);
      // }
      // console.log('Launch url: ', ret2);


      // const show = async () => {
      //   await Toast.show({
      //     text: 'Hello async!'
      //   });
      // }
      //
      // show();
      // CapApp.addListener('appUrlOpen', (data: any) => {
      //   console.log('App opened with URL: ' +  data.url);
      // });

      // CapApp.addListener('appRestoredResult', (data: any) => {
      //   console.log('Restored state:', data);
      // });


    //   WORKS
    // LocalNotifications.schedule({
    //   notifications: [
    //     {
    //       title: "Minder Started",
    //       body: "Now",
    //       id: 1,
    //       schedule: { at: new Date(Date.now() + 1000 * 5) },
    //       sound: null,
    //       attachments: null,
    //       actionTypeId: "",
    //       extra: null
    //     }
    //   ]
    // });

      app.ports.ns_notify.subscribe(function(notificationList) {

        LocalNotifications.schedule({
          notifications: notificationList
        });
        console.log("Notification: ", notificationList)
    });





      // Clipboard.write({
      //   string: "Hello, Moto"
      // });





      // below copied from https://capacitor.ionicframework.com/docs/apis/app

      // import { Plugins, AppState } from '@capacitor/core';
      
      // import { Plugins, AppState } from './capacitor.js';
      // const { Toast, App } = window.Capacitor.Plugins;

      // async show => {
      //   await Toast.show({
      //     text: 'Hello!'
      //   });
      // }
      // const { AppState } = window.Capacitor.AppState;

      // const CapApp = window.Capacitor.Plugins;

      // CapApp.addListener('appStateChange', (state: AppState) => {
      //   // state.isActive contains the active state
      //   console.log('App state changed. Is active?', state.isActive);
      //   app.ports.appStateChange.send(state.isActive);
      // });

      // Listen for serious plugin errors
      // CapApp.addListener('pluginError', (info: any) => {
      //   console.error('There was a serious error with a plugin', err, info);
      //   app.ports.pluginError.send(state.isActive);
      // });


      App.addListener('appStateChange', ({ isActive }) => {
        console.log('App state changed. Is active?', isActive);
      });
      
      App.addListener('appUrlOpen', data => {
        console.log('App opened with URL:', data);
      });
      
      App.addListener('appRestoredResult', data => {
        console.log('Restored state:', data);
      });
      
      const checkAppLaunchUrl = async () => {
        const { url } = await App.getLaunchUrl();
      
        console.log('App opened with URL: ' + url);
      };

}
