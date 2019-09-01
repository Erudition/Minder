// START BUSINESS LOGIC THREAD
const ElmManager = require("nativescript-worker-loader!./logic.js");
const worker = new ElmManager();


// UNIVERSAL COMMUNICATION CHANNEL
export function tellElm(destinationPort, outgoingMessage) {
    worker.postMessage({port : destinationPort, message: outgoingMessage});
}
worker.onmessage = function(event) {
    console.log(incomingMessage);
}

// Broadcasts can't be in logic.js (because worker shuts off?)

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
        tellElm(headlessMsg, maybeMessage);
        console.info("received secret message:" + maybeMessage);
    } else {
        console.warn("Got an secretMessage intent, but it was empty!");
    }
};

applicationModule.android.registerBroadcastReceiver(
    "app.minder.secretMessage",
    secretMessageReceived
);


// LISTENING FOR STANDARD SYSTEM BROADCASTS ---------------------------------------






// START THE APP
const application = require("tns-core-modules/application");
application.run({ moduleName: "app-root" });

/*
Do not place any code after the application has been started as it will not
be executed on iOS.
*/
