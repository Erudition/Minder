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


// START THE APP
const application = require("tns-core-modules/application");
application.run({ moduleName: "app-root" });

/*
Do not place any code after the application has been started as it will not
be executed on iOS.
*/
