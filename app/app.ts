console.info("Loading app.js.");
//require("nativescript-dom-free");

//require("./nativehelpers/wearDataLayer.js");



// START BUSINESS LOGIC THREAD
//const ElmManager = require("nativescript-worker-loader!./elm-background.js");
//const worker = new ElmManager();


// GET ENVIRONMENT DETAILS ---------------------------------------------------------
const applicationModule = require("@nativescript/core/application");
var androidApp = applicationModule.android
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
} catch (e) {
    console.error("Epic failure when fetching stored AppData.", e.toString());
}
global.appDataString = appDataString;

try {
    var appData = JSON.parse(appDataString);
} catch (e) {
    console.error("Epic failure when parsing stored AppData. Here's what it was set to: '" + appDataString + "'");
    //var appData = {};
}


// URL HANDLING ---------------------------------------------------------------
var handleOpenURL = require("nativescript-urlhandler").handleOpenURL;

const testingExport = "https://minder.app/?export=all";
const testingClearErrors = "https://minder.app/?clearerrors=clearerrors";
const testingActivity = "https://minder.app/?start=Project";
const testingSync = "https://minder.app/?sync=marvin";
var launchURL = testingSync;





// ELM INITIALIZATION -----------------------------------------------------------

console.info("starting Elm headless.");
var elm = require('../www/elm-headless.js').Elm.Headless.init(
    { flags: [launchURL, appDataString] });

console.info("Elm headless initialized.");

const ns_hookup = require('./elm-nativescript.js');
ns_hookup.addNativeScriptFeaturesToElm(elm);



// URL passed in via somewhere else on the system
handleOpenURL(function(appURL) {
    if (androidApp === undefined) {
        console.info('Launching with the supplied URL: ', appURL);
        launchURL = appURL.toString();
    } else {
        console.info('Already running, changing URL to: ', appURL);
        elm.ports.headlessMsg.send(appURL.toString());
    }
  });




// NOTIFICATIONS --------------------------------------------------------
const notifications = require ("@nativescript/local-notifications").LocalNotifications;

const Color = require("tns-core-modules/color").Color;
const colors = require("tns-core-modules/color/known-colors");

elm.ports.ns_notify_cancel.subscribe(function(notificationID) {
    console.log("Canceling notification " + notificationID);
    notifications.cancel(notificationID);
    }
);

elm.ports.ns_notify.subscribe(function(notificationList) {

    // Elm-encoded JSON object obviously can't contain the required Date() object
    var correctedList = notificationList.map(
        function(notifObj) {
            //wrap js time (unix ms float) with Date object
            notifObj["at"] = new Date(notifObj["at"]);

            try {
              notifObj["when"] = new Date(notifObj["when"]);
            } catch (e)
            {console.log(e)}

            let notifColor = notifObj["color"];
            if (notifColor) {
              // supports known names and hex values short and long
                  notifObj["color"] = new Color(notifColor);
            }


            // While we're at it, check if we missed it
            if (new Date() > notifObj["at"]) {
                // make it dispatch right away
                notifObj["at"] = null;
            }
            return notifObj;
        }
    );

    console.info("Here are the " + correctedList.length + " Notifications I'll try to schedule:");
    console.dir(correctedList);


    notifications.schedule(correctedList).then(
        function(scheduledIds) {
          console.info("Notification id(s) scheduled: " + JSON.stringify(scheduledIds) + "\n from JSON: ");

        },
        function(error) {
          console.error("Minder Notif scheduling error: " + error);
        }
    )
});

notifications.addOnMessageReceivedCallback(
    function (notification) {

      //console.dir(notification);
      let actionTaken = notification.response;
        if (typeof actionTaken !== 'undefined') // No response if they just tap it or "Open"
        console.log('ID: ' + notification.id);
        console.log('Title: ' + notification.title);
        console.log('Body: ' + notification.body);
        { elm.ports.headlessMsg.send("http://minder.app/?" + actionTaken ); }

    }
).then(
    function() {
      //console.info("Listener added");
    }
)



// LEGACY PORT: VARIABLE OUT ------------------------------------------

elm.ports.variableOut.subscribe(function(data) {
    // are we a worker?
    if (typeof postMessage !== 'undefined') {
    postMessage(data);
    } else {
    messageFromElm(data);
    }


});


// SET STORAGE -----------------------------------------------------------------
elm.ports.setStorage.subscribe(function(data) {

    //console.info("App Data being set");

    // let lines = data.split("\\n");
    // for (var line in lines) {
    //     console.info("Line: " + lines[line]);
    // }

    appSettings.setString("appData", data);
});




const observableModule = require("@nativescript/core/data/observable");
global.globalViewModel = observableModule.fromObject(
    {activities:[ ]
    });

// UNIVERSAL COMMUNICATION CHANNEL
export function tellElm(destinationPort, outgoingMessage) {
    elm.ports[destinationPort].send(outgoingMessage);
}

export function messageFromElm(incomingMessage) {
    if (incomingMessage[0] == "activities") {
        updateVM(incomingMessage);
    } else {
        console.info("Setting " + incomingMessage[0] + " to " + incomingMessage[1]);
        global[incomingMessage[0]] = incomingMessage[1]
    }
}

//worker.onmessage = function(messageFromElm(incomingMessage));





// VIEWMODEL UPDATER
function updateVM (data) {
    // No access to globals in worker
    //global.globalViewModel.set(part, value);

    try {
        let newObservable = (JSON.parse(data[1]));
        global.globalViewModel.set(data[0], newObservable);
        // console.info("Here's the new globalViewModel:");
        // console.dir(global.globalViewModel);

    } catch (e) {
        console.error("Unable to set viewModel " + data[0] + " because " + e.toString())
    }
}


// BROADCAST RECEIVERS
// Broadcasts can't be in logic.js (because worker shuts off?)
//const applicationModule = require("@nativescript/core/application");
// BROADCAST: BATTERY INFO UPDATE ----------------------------------------------

// applicationModule.android.registerBroadcastReceiver(
//     android.content.Intent.ACTION_BATTERY_CHANGED,
//     batteryChanged
// );

const batteryChanged = (androidContext, intent) => {
    const level = intent.getIntExtra(applicationModule.android.os.BatteryManager.EXTRA_LEVEL, -1);
    const scale = intent.getIntExtra(applicationModule.android.os.BatteryManager.EXTRA_SCALE, -1);
    //vm.set("batteryLife", percent.toString()); //???
    tellElm("headlessMsg", "http://minder.app/?battery=" + level);
};



// BROADCAST: EXTERNAL ELM COMMAND VIA INTENT ---------------------------------
const secretMessageReceived = (androidContext, intent) => {
    //vm.set("batteryLife", percent.toString()); //???
    let maybeMessage = intent.getStringExtra("command");
    if (typeof maybeMessage === 'string' || maybeMessage instanceof String)
    {
        tellElm("headlessMsg", maybeMessage);
        console.info("received secret message:" + maybeMessage);
    } else {
        console.warn("Got an secretMessage intent, but it was empty!");
    }
};

applicationModule.android.registerBroadcastReceiver(
    "app.minder.secretMessage",
    secretMessageReceived
);







// LISTENING FOR STANDARD SYSTEM BROADCASTS ------------------------------------


// START THE APP --------------------------------------------
//const application = require("@nativescript/core/application");
const traceModule = require("@nativescript/core/trace").Trace;
const notaTraceCategory = require("@nativescript-community/ui-webview").NotaTraceCategory

traceModule.addCategories(notaTraceCategory);
traceModule.enable();


function launchListener (args)  {
//    console.info("Attempting Elm initialization!");
//    console.log("args is " + JSON.stringify(args));

//    var rootElement =  document.getElementById("root-tabview");
//
//    console.log("finding root element: " + document.getElementById("root-tabview"));
//
//    var document = {location : {href : "https://minder.app/"}, getElementById : getElementById}
//    var elm = require('../www/elm-browserless.js').Elm.Browserless.init(
//        { node: rootElement
//        , flags: ["https://minder.app/", ""]
//        });
//
//    console.info("Got past Elm initialization! ---------------------------------");
    console.log("The app was launched!");

    // Choose launch screen based on watch or not
    const applicationModule2 = require("@nativescript/core/application");
    var PackageManager = androidApp.content.pm.PackageManager;
    if (applicationModule2.android.context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_WATCH)) {
        applicationModule2.run({ moduleName: "app-root-wear" });
    }


}
applicationModule.on(applicationModule.launchEvent, launchListener);

//LAUNCH!
applicationModule.run({ moduleName: "app-root" });




/*
Do not place any code after the application has been started as it will not
be executed on iOS.
*/

//global.startP2P = function() {require("./nativehelpers/peer2peer.js");};
