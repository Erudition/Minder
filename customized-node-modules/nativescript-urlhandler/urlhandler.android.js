"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var application = require("@nativescript/core/application");
var urlhandler_common_1 = require("./urlhandler.common");
var urlhandler_common_2 = require("./urlhandler.common");
exports.handleOpenURL = urlhandler_common_2.handleOpenURL;
function handleIntent(intent) {
    var data = intent.getData();
    try {
        var appURL_1 = urlhandler_common_1.extractAppURL(data);
        if (appURL_1 != null &&
            (new String(intent.getAction()).valueOf() === new String(android.content.Intent.ACTION_MAIN).valueOf()
                || new String(intent.getAction()).valueOf() === new String(android.content.Intent.ACTION_VIEW).valueOf())) {
            try {
                setTimeout(function () { return urlhandler_common_1.getCallback()(appURL_1); });
            }
            catch (ignored) {
                application.android.on(application.AndroidApplication.activityResultEvent, function () {
                    setTimeout(function () { return urlhandler_common_1.getCallback()(appURL_1); });
                });
            }
        }
    }
    catch (e) {
        console.error('Unknown error during getting App URL data', e);
    }
}
exports.handleIntent = handleIntent;
application.android.on(application.AndroidApplication.activityStartedEvent, function (args) {
    setTimeout(function () {
        var intent = args.activity.getIntent();
        try {
            handleIntent(intent);
        }
        catch (e) {
            console.error('Unknown error during getting App URL data', e);
        }
    });
});
//# sourceMappingURL=urlhandler.android.js.map
