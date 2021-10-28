"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var LocalNotificationsCommon = (function () {
    function LocalNotificationsCommon() {
    }
    LocalNotificationsCommon.merge = function (obj1, obj2) {
        var result = {};
        for (var i in obj1) {
            if ((i in obj2) && (typeof obj1[i] === "object") && (i !== null)) {
                result[i] = this.merge(obj1[i], obj2[i]);
            }
            else {
                result[i] = obj1[i];
            }
        }
        for (var i in obj2) {
            if (i in result) {
                continue;
            }
            result[i] = obj2[i];
        }
        return result;
    };
    LocalNotificationsCommon.generateUUID = function () {
        var s4 = function () { return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1); };
        return "" + s4() + s4() + "-" + s4() + "-" + s4() + "-" + s4() + "-" + s4() + s4() + s4();
    };
    LocalNotificationsCommon.generateNotificationID = function () {
        return Math.round((Date.now() + Math.round((100000 * Math.random()))) / 1000);
    };
    LocalNotificationsCommon.ensureID = function (opts) {
        var id = opts.id;
        if (typeof id === "number") {
            return id;
        }
        else {
            return opts.id = LocalNotificationsCommon.generateNotificationID();
        }
    };
    LocalNotificationsCommon.defaults = {
        badge: 0,
        interval: undefined,
        ongoing: false,
        groupSummary: null,
        bigTextStyle: false,
        channel: "Default Channel",
        forceShowWhenInForeground: false
    };
    return LocalNotificationsCommon;
}());
exports.LocalNotificationsCommon = LocalNotificationsCommon;
