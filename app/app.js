const application = require("tns-core-modules/application");

//var storagefilename = "Minder/personal-data.json";

const toasty = require('nativescript-toasty').Toasty;

const notifications = require ("nativescript-local-notifications").LocalNotifications;

const applicationModule = require("tns-core-modules/application");

var androidApp = applicationModule.android
let isPaused = androidApp.paused; // e.g. false
let packageName = androidApp.packageName; // The package ID e.g. org.nativescript.nativescriptsdkexamplesng
let nativeApp = androidApp.nativeApp; // The native APplication reference
let foregroundActivity = androidApp.foregroundActivity; // The current Activity reference
//let context = androidApp.context; // The current Android context

const appSettings = require("tns-core-modules/application-settings");

// appSettings.clear("appData");

console.info("Got past headers! ---------------------------------");

let appDataString = appSettings.getString("appData", "");

try {
    var finalAppData = JSON.parse(appDataString);
} catch (e) {
    console.error("Epic failure when parsing stored AppData. Here's what it was set to: ", appDataString)
    var finalAppData = {};
}
export var appData = finalAppData;



// URL HANDLING ---------------------------------------------------------------
var handleOpenURL = require("nativescript-urlhandler").handleOpenURL;

const testingExport = "http://minder.app/?export=all";
const testingClearErrors = "http://minder.app/?clearerrors=clearerrors";
const testingActivity = "http://minder.app/?start=Restroom";
const testingSync = "http://minder.app/?sync=todoist";
var launchURL = testingExport;

// URL passed in via somewhere else on the system
handleOpenURL(function(appURL) {
  if (!app) {
      console.info('Launching with the supplied URL: ', appURL);
      launchURL = appURL.toString();
  } else {
      console.info('Already running, changing URL to: ', appURL);
      app.ports.headlessMsg.send(appURL.toString());
  }
});


// ELM INITIALIZATION -----------------------------------------------------------

var Elm = require('../www/elm-headless.js').Elm;

export var app = Elm.Headless.init(
    { flags: [launchURL, appDataString] });








console.info("Got past Elm initialization! ---------------------------------");

// ELM COMMANDS --------------------------------------------------------


// BATTERY INFO UPDATE
const batteryChanged = (androidContext, intent) => {
    const level = intent.getIntExtra(android.os.BatteryManager.EXTRA_LEVEL, -1);
    const scale = intent.getIntExtra(android.os.BatteryManager.EXTRA_SCALE, -1);
    //vm.set("batteryLife", percent.toString()); //???
    app.ports.headlessMsg.send("http://minder.app/?battery=" + level)
};



// EXTERNAL ELM COMMAND
const secretMessageReceived = (androidContext, intent) => {
    //vm.set("batteryLife", percent.toString()); //???
    let maybeMessage = intent.getStringExtra("command");
    if (typeof maybeMessage === 'string' || maybeMessage instanceof String)
    {
        app.ports.headlessMsg.send(maybeMessage);
        console.info("received secret message:" + maybeMessage);
    } else {
        console.warn("Got an secretMessage intent, but it was empty!");
    }
};


notifications.addOnMessageReceivedCallback(
    function (notification) {
      console.dir(notification);
      app.ports.headlessMsg.send("http://minder.app/?" + notification.response );
    }
).then(
    function() {
      console.info("Listener added");
    }
)


// ANDROID INTENTS AND BROADCASTS

applicationModule.android.registerBroadcastReceiver(
    "app.minder.secretMessage",
    secretMessageReceived
);


// applicationModule.android.registerBroadcastReceiver(
//     android.content.Intent.ACTION_BATTERY_CHANGED,
//     batteryChanged
// );




// SUBSCRIBING TO STUFF ELM GIVES US -----------------------------------------------


// FLASH OR TOAST
app.ports.flash.subscribe(function(toast_message) {
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


// NOTIFICATIONS
app.ports.ns_notify.subscribe(function(notificationList) {

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




// VARIABLE OUT
app.ports.variableOut.subscribe(function(data) {
    appSettings.setString(data[0], data[1]);
    console.info("Setting " + data[0] + " to " + data[1])
});


// SET STORAGE
app.ports.setStorage.subscribe(function(data) {

    console.info(" App Data being set");

    // let lines = data.split("\\n");
    // for (var line in lines) {
    //     console.info("Line: " + lines[line]);
    // }

    appSettings.setString("appData", data);
    appData = data; //needed?
});




/// ANDROID SERVICES -------------------------------------------------------------


android.app.IntentService.extend("app.minder.CommandListenerService" /* declared in the AndroidManifest */, {
   onHandleIntent: function (intent) {
       var action = intent.getAction();

       respondToIntent(action);

    //    if ("ACTION_START" == action) {
    //        respondToIntent();
    //    } else if ("ACTION_STOP" == action) {
    // /* get the system alarm manager and cancel all pending alarms, which will stop the service from executing periodically  */
    //    }

       // android.support.v4.content.WakefulBroadcastReceiver.completeWakefulIntent(intent);


   }
});


function respondToIntent() {
    app.ports.headlessMsg.send("http://minder.app/?" + "externalCommand" )
}

//
// android.support.v4.content.WakefulBroadcastReceiver.extend("app.minder.broadcastreceivers.EventReceiver", {
//    onReceive: function (context, intent) {
//        var action = intent.getAction();
//        var serviceIntent;
//        if ("ACTION_START_NOTIFICATION_SERVICE" == action) {
//            serviceIntent = createIntentStartNotificationService(context);
//        } else if ("ACTION_DELETE_NOTIFICATION" == action) {
//            serviceIntent = createIntentDeleteNotification(context);
//        }
//        if (serviceIntent) {
//            android.support.v4.content.WakefulBroadcastReceiver.startWakefulService(context, serviceIntent);
//        }
//    }
// })
// var Intent = android.content.Intent;
// function createIntentStartNotificationService(context) {
//    var intent = new Intent(context, com.tns.notifications.NotificationIntentService.class);
//    intent.setAction("ACTION_START");
//    return intent;
// }
//



console.info("Done with app.js! ---------------------------------");
application.run({ moduleName: "app-root" });

/*
Do not place any code after the application has been started as it will not
be executed on iOS.
*/
