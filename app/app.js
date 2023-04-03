//console.info("Loading app.js.");
//require("nativescript-dom-free");
//require("./nativehelpers/wearDataLayer.js");
// START BUSINESS LOGIC THREAD
//const ElmManager = require("nativescript-worker-loader!./elm-background.js");
//const worker = new ElmManager();
// GET ENVIRONMENT DETAILS ---------------------------------------------------------
const application = require("@nativescript/core/application");
var androidApp = application.android;
//let isPaused = androidApp.paused; // e.g. false
//let packageName = androidApp.packageName; // The package ID e.g. org.nativescript.nativescriptsdkexamplesng
//let nativeApp = androidApp.nativeApp; // The native Application reference
//let foregroundActivity = androidApp.foregroundActivity; // The current Activity reference
// APP DATA & SETTINGS STORAGE -----------------------------------------------------
const appSettings = require("@nativescript/core/application-settings");
// appSettings.clear("appData");
var appDataString = "";
try {
    appDataString = appSettings.getString("appData", "");
}
catch (e) {
    console.error("Epic failure when fetching stored AppData.", e.toString());
}
global.appDataString = appDataString;
// URL HANDLING ---------------------------------------------------------------
var handleOpenURL = require("nativescript-urlhandler").handleOpenURL;
const testingExport = "https://minder.app/?export=all";
const testingClearErrors = "https://minder.app/?clearerrors=clearerrors";
const testingActivity = "https://minder.app/?start=Project";
const testingSync = "https://minder.app/?sync=marvin";
var launchURL = testingSync;
// ELM INITIALIZATION -----------------------------------------------------------
// console.info("starting Elm headless.");
// var elm = require('../www/elm-headless.js').Elm.Headless.init(
//     { flags: [launchURL, appDataString] });
// console.info("Elm headless initialized.");
import Elm from "../elm/NativeMain.elm";
import { start } from "elm-native-js";
let initElmPorts = (ports) => {
    // hook up all of our ports!
    // each should check if the port is defined first, as unused Elm ports get tree-shaken away, so it will crash when trying to subscribe.
    require('./elm-ports/ns-toast').addToastPorts(ports);
    require('./elm-ports/ns-notifications').addNotificationPorts(ports);
    require('./elm-ports/ns-storage').addStoragePorts(ports);
    require('./elm-ports/ns-geolocation').addGeolocationPorts(ports);
};
// URL passed in via somewhere else on the system
handleOpenURL(function (appURL) {
    if (androidApp === undefined) {
        console.info('Launching with the supplied URL: ', appURL);
        launchURL = appURL.toString();
    }
    else {
        console.info('Already running, changing URL to: ', appURL);
        //elm.ports.headlessMsg.send(appURL.toString());
    }
});
const observableModule = require("@nativescript/core/data/observable");
global.globalViewModel = observableModule.fromObject({ activities: []
});
// UNIVERSAL COMMUNICATION CHANNEL
export function tellElm(destinationPort, outgoingMessage) {
    //elm.ports[destinationPort].send(outgoingMessage);
    console.log(outgoingMessage);
}
export function messageFromElm(incomingMessage) {
    if (incomingMessage[0] == "activities") {
        //updateVM(incomingMessage);
    }
    else {
        console.info("Setting " + incomingMessage[0] + " to " + incomingMessage[1]);
        global[incomingMessage[0]] = incomingMessage[1];
    }
}
//worker.onmessage = function(messageFromElm(incomingMessage));
// VIEWMODEL UPDATER
// function updateVM (data) {
//     // No access to globals in worker
//     //global.globalViewModel.set(part, value);
//     try {
//         let newObservable = (JSON.parse(data[1]));
//         global.globalViewModel.set(data[0], newObservable);
//         // console.info("Here's the new globalViewModel:");
//         // console.dir(global.globalViewModel);
//     } catch (e) {
//         console.error("Unable to set viewModel " + data[0] + " because " + e.toString())
//     }
// }
// BROADCAST RECEIVERS
// Broadcasts can't be in logic.js (because worker shuts off?)
//const applicationModule = require("@nativescript/core/application");
// BROADCAST: BATTERY INFO UPDATE ----------------------------------------------
// applicationModule.android.registerBroadcastReceiver(
//     android.content.Intent.ACTION_BATTERY_CHANGED,
//     batteryChanged
// );
const batteryChanged = (androidContext, intent) => {
    const level = intent.getIntExtra(application.android.os.BatteryManager.EXTRA_LEVEL, -1);
    const scale = intent.getIntExtra(application.android.os.BatteryManager.EXTRA_SCALE, -1);
    //vm.set("batteryLife", percent.toString()); //???
    //tellElm("headlessMsg", "http://minder.app/?battery=" + level);
};
// BROADCAST: EXTERNAL ELM COMMAND VIA INTENT ---------------------------------
const secretMessageReceived = (androidContext, intent) => {
    //vm.set("batteryLife", percent.toString()); //???
    let maybeMessage = intent.getStringExtra("command");
    if (typeof maybeMessage === 'string' || maybeMessage instanceof String) {
        //tellElm("headlessMsg", maybeMessage);
        console.info("received secret message:" + maybeMessage);
    }
    else {
        console.warn("Got an secretMessage intent, but it was empty!");
    }
};
application.android.registerBroadcastReceiver("app.minder.secretMessage", secretMessageReceived);
// LISTENING FOR STANDARD SYSTEM BROADCASTS ------------------------------------
// START THE APP --------------------------------------------
//const application = require("@nativescript/core/application");
import { Trace } from "@nativescript/core/trace";
//const notaTraceCategory = require("@nativescript-community/ui-webview").NotaTraceCategory
//traceModule.addCategories(notaTraceCategory);
Trace.enable();
Trace.write("Tracer working!", Trace.categories.Debug);
function readyToLaunch(args) {
    console.log("Ready to launch app, determining watch mode.");
    // Choose launch screen based on watch or not
    var PackageManager = android.content.pm.PackageManager;
    if (androidApp.context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_WATCH)) {
        androidApp.run({ moduleName: "app-root-wear" });
    }
    else {
        //LAUNCH!
        application.run({ moduleName: "app-root" });
    }
}
//application.on(application.launchEvent, readyToLaunch);
application.run({ moduleName: "app-root-wear" });
function launchElmNative() {
    const config = {
        elmModule: Elm,
        elmModuleName: "NativeMain",
        initPorts: initElmPorts,
        flags: { storedRonMaybe: appSettings.getString("appData", null),
            userFlags: null
        }
    };
    start(config);
}
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Do not place any code after the application has been started as it will not
be executed on iOS.
*/
//global.startP2P = function() {require("./nativehelpers/peer2peer.js");};
