require("nativescript-dom-free");
require("@nativescript/canvas-polyfill");

// START BUSINESS LOGIC THREAD
const ElmManager = require("nativescript-worker-loader!./logic.js");
const worker = new ElmManager();



const observableModule = require("tns-core-modules/data/observable");
global.globalViewModel = observableModule.fromObject(
    {activities:[   {"name":"Unloaded"
                    ,"excusedUsage": new Date().toString()
                    ,"totalToday": "bleh"
                    }
                ]
    });

// UNIVERSAL COMMUNICATION CHANNEL
export function tellElm(destinationPort, outgoingMessage) {
    worker.postMessage({port : destinationPort, message: outgoingMessage});
}
worker.onmessage = function(incomingMessage) {
    if (incomingMessage.data[0] == "activities") {
        updateVM(incomingMessage.data);
    } else {
        console.info("Setting " + incomingMessage.data[0] + " to " + incomingMessage.data[1]);
        global[incomingMessage.data[0]] = incomingMessage.data[1]
    }

}



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
const applicationModule = require("tns-core-modules/application");
// BROADCAST: BATTERY INFO UPDATE ----------------------------------------------

// applicationModule.android.registerBroadcastReceiver(
//     android.content.Intent.ACTION_BATTERY_CHANGED,
//     batteryChanged
// );

const batteryChanged = (androidContext, intent) => {
    const level = intent.getIntExtra(android.os.BatteryManager.EXTRA_LEVEL, -1);
    const scale = intent.getIntExtra(android.os.BatteryManager.EXTRA_SCALE, -1);
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


// START THE APP
const application = require("tns-core-modules/application");



function launchListener (args)  {
    console.info("Attempting Elm initialization! ---------------------------------");
    console.log("args is " + JSON.stringify(args));

//    var rootElement =  document.getElementById("root-tabview");
//
//    console.log("finding root element: " + document.getElementById("root-tabview"));
//
//    var document = {location : {href : "https://minder.app/"}, getElementById : getElementById}
//    var elm = require('../www/elm-browserless.js').Elm.Browserless.init(
//        { node: rootElement
//        , flags: ["https://minder.app/", ""]
//        });

    console.info("Got past Elm initialization! ---------------------------------");
    console.log("The app was launched!");
}
application.on(application.launchEvent, launchListener);

//TODO detect if on wear
//application.run({ moduleName: "app-root" });
application.run({ moduleName: "app-root-wear" });

/*
Do not place any code after the application has been started as it will not
be executed on iOS.
*/
