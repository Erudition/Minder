require('globals'); // necessary to bootstrap tns modules on the new thread

console.log("I'm in the worker!");


// GET ENVIRONMENT DETAILS ---------------------------------------------------------
const applicationModule = require("tns-core-modules/application");
var androidApp = applicationModule.android
let isPaused = androidApp.paused; // e.g. false
let packageName = androidApp.packageName; // The package ID e.g. org.nativescript.nativescriptsdkexamplesng
let nativeApp = androidApp.nativeApp; // The native APplication reference
let foregroundActivity = androidApp.foregroundActivity; // The current Activity reference
//let context = androidApp.context; // The current Android context



// APP DATA & SETTINGS STORAGE -----------------------------------------------------
const appSettings = require("tns-core-modules/application-settings");
// appSettings.clear("appData");
try {
    let appDataString = appSettings.getString("appData", "");
} catch (e) {
    console.error("Epic failure when fetching stored AppData.", e.toString());
    let appDataString = "";
}


try {
    var appData = JSON.parse(appDataString);
} catch (e) {
    console.error("Epic failure when parsing stored AppData. Here's what it was set to: '" + appDataString + "'");
    var appData = {};
}


// URL HANDLING ---------------------------------------------------------------
var handleOpenURL = require("nativescript-urlhandler").handleOpenURL;

const testingExport = "https://minder.app/?export=all";
const testingClearErrors = "https://minder.app/?clearerrors=clearerrors";
const testingActivity = "https://minder.app/?start=Restroom";
const testingSync = "https://minder.app/?sync=todoist";
var launchURL = testingExport;

// URL passed in via somewhere else on the system
handleOpenURL(function(appURL) {
  if (!app) {
      console.info('Launching with the supplied URL: ', appURL);
      launchURL = appURL.toString();
  } else {
      console.info('Already running, changing URL to: ', appURL);
      elm.ports.headlessMsg.send(appURL.toString());
  }
});




// ELM INITIALIZATION -----------------------------------------------------------


var elm = require('../www/elm-headless.js').Elm.Headless.init(
    { flags: [launchURL, appDataString] });

console.info("Got past Elm initialization! ---------------------------------");





// FLASH OR "TOAST" POPUPS ------------------------------------------
const toasty = require('nativescript-toasty').Toasty;

elm.ports.flash.subscribe(function(toast_message) {
    const toast = new toasty({
        text: toast_message,
        //duration: ToastDuration.SHORT,
        textColor: '#fff',
        //backgroundColor: new Color('purple'),
        //position: ToastPosition.TOP,
        android: { yAxisOffset: 100 },
        ios: {
            displayShadow: true,
            shadowColor: '#fff000',
            cornerRadius: 24
        }
    }).show();
});


// NOTIFICATIONS --------------------------------------------------------
const notifications = require ("nativescript-local-notifications").LocalNotifications;

elm.ports.ns_notify.subscribe(function(notificationList) {

    // Elm-encoded JSON object obviously can't contain the required Date() object
    var correctedList = notificationList.map(
        function(notifObj) {
            //wrap js time (unix ms float) with Date object
            notifObj["at"] = new Date(notifObj["at"]);

            // While we're at it, check if we missed it
            if (new Date() > notifObj["at"]) {
                // make it dispatch right away
                notifObj["at"] = null;
            }
            return notifObj;
        }
    );

    console.info("Here are the Notifications I'll try to schedule:");
    console.dir(correctedList);

    // Clean slate every time - TODO: better way
    notifications.cancelAll();

    notifications.schedule(correctedList).then(
        function(scheduledIds) {
          console.info("Notification id(s) scheduled: " + JSON.stringify(scheduledIds) + "\n from JSON: ");

        },
        function(error) {
          console.error("scheduling error: " + error);
        }
    )
});

notifications.addOnMessageReceivedCallback(
    function (notification) {
      console.dir(notification);
      whatHappened = notification.response ? notification.response : notification.channel
      elm.ports.headlessMsg.send("http://minder.app/?" + whatHappened );
    }
).then(
    function() {
      console.info("Listener added");
    }
)



// LEGACY PORT: VARIABLE OUT -------------------------------------------------------
elm.ports.variableOut.subscribe(function(data) {
    appSettings.setString(data[0], data[1]);
    console.info("Setting " + data[0] + " to " + data[1])
});


// SET STORAGE -----------------------------------------------------------------
elm.ports.setStorage.subscribe(function(data) {

    console.info(" App Data being set");

    // let lines = data.split("\\n");
    // for (var line in lines) {
    //     console.info("Line: " + lines[line]);
    // }

    appSettings.setString("appData", data);
    appData = data; //needed?
});


// WORKER THREAD: UNIVERSAL MESSAGE PASSING - HANDLER ---------------------------

global.onmessage = function(incoming) {
    try {
        elm.ports[incoming.data.port].send(incoming.data.message);
    } catch (e) {
        console.error("Worker got a message, but couldn't act on it: " + incoming.toString());
        console.dir(incoming);
    }

}
