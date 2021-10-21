"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var app = require("@nativescript/core/application");
var utils = require("@nativescript/core/utils/utils");
var local_notifications_common_1 = require("./local-notifications-common");
var NotificationManagerCompatPackageName = useAndroidX() ? global.androidx.core.app : android.support.v4.app;
function useAndroidX() {
    return global.androidx && global.androidx.appcompat;
}
(function () {
    var registerLifecycleEvents = function () {
        com.telerik.localnotifications.LifecycleCallbacks.registerCallbacks(app.android.nativeApp);
    };
    if (app.android.nativeApp) {
        registerLifecycleEvents();
    }
    else {
        app.on(app.launchEvent, registerLifecycleEvents);
    }
})();
var LocalNotificationsImpl = (function (_super) {
    __extends(LocalNotificationsImpl, _super);
    function LocalNotificationsImpl() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    LocalNotificationsImpl.getInterval = function (interval) {
        if (interval === "second") {
            return 1000;
        }
        else if (interval === "minute") {
            return android.app.AlarmManager.INTERVAL_FIFTEEN_MINUTES / 15;
        }
        else if (interval === "hour") {
            return android.app.AlarmManager.INTERVAL_HOUR;
        }
        else if (interval === "day") {
            return android.app.AlarmManager.INTERVAL_DAY;
        }
        else if (interval === "week") {
            return android.app.AlarmManager.INTERVAL_DAY * 7;
        }
        else if (interval === "month") {
            return android.app.AlarmManager.INTERVAL_DAY * 31;
        }
        else if (interval === "year") {
            return android.app.AlarmManager.INTERVAL_DAY * 365;
        }
        else {
            return undefined;
        }
    };
    LocalNotificationsImpl.getIcon = function (context, resources, iconLocation) {
        var packageName = context.getApplicationInfo().packageName;
        return iconLocation
            && iconLocation.indexOf(utils.RESOURCE_PREFIX) === 0
            && resources.getIdentifier(iconLocation.substr(utils.RESOURCE_PREFIX.length), "drawable", packageName)
            || (LocalNotificationsImpl.IS_GTE_LOLLIPOP && resources.getIdentifier("ic_stat_notify_silhouette", "drawable", packageName))
            || resources.getIdentifier("ic_stat_notify", "drawable", packageName)
            || context.getApplicationInfo().icon;
    };
    LocalNotificationsImpl.cancelById = function (id) {
        var context = utils.ad.getApplicationContext();
        var notificationIntent = new android.content.Intent(context, com.telerik.localnotifications.NotificationAlarmReceiver.class).setAction("" + id);
        var pendingIntent = android.app.PendingIntent.getBroadcast(context, 0, notificationIntent, 0);
        var alarmManager = context.getSystemService(android.content.Context.ALARM_SERVICE);
        alarmManager.cancel(pendingIntent);
        var notificationManager = context.getSystemService(android.content.Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(id);
        com.telerik.localnotifications.Store.remove(context, id);
    };
    LocalNotificationsImpl.prototype.hasPermission = function () {
        return new Promise(function (resolve, reject) {
            try {
                resolve(true);
            }
            catch (ex) {
                console.log("Error in LocalNotifications.hasPermission: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.requestPermission = function () {
        return new Promise(function (resolve, reject) {
            try {
                resolve(true);
            }
            catch (ex) {
                console.log("Error in LocalNotifications.requestPermission: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.addOnMessageReceivedCallback = function (onReceived) {
        return new Promise(function (resolve, reject) {
            try {
                com.telerik.localnotifications.LocalNotificationsPlugin.setOnMessageReceivedCallback(new com.telerik.localnotifications.LocalNotificationsPluginListener({
                    success: function (notification) {
                        onReceived(JSON.parse(notification));
                    }
                }));
                resolve();
            }
            catch (ex) {
                console.log("Error in LocalNotifications.addOnMessageReceivedCallback: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.addOnMessageClearedCallback = function (onReceived) {
        return new Promise(function (resolve, reject) {
            try {
                com.telerik.localnotifications.LocalNotificationsPlugin.setOnMessageClearedCallback(new com.telerik.localnotifications.LocalNotificationsPluginListener({
                    success: function (notification) {
                        onReceived(JSON.parse(notification));
                    }
                }));
                resolve();
            }
            catch (ex) {
                console.log("Error in LocalNotifications.addOnMessageClearedCallback: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.cancel = function (id) {
        return new Promise(function (resolve, reject) {
            try {
                LocalNotificationsImpl.cancelById(id);
                resolve(true);
            }
            catch (ex) {
                console.log("Error in LocalNotifications.cancel: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.cancelAll = function () {
        return new Promise(function (resolve, reject) {
            try {
                var context = utils.ad.getApplicationContext();
                var keys = com.telerik.localnotifications.Store.getKeys(utils.ad.getApplicationContext());
                for (var i = 0; i < keys.length; i++) {
                    LocalNotificationsImpl.cancelById(parseInt(keys[i]));
                }
                NotificationManagerCompatPackageName.NotificationManagerCompat.from(context).cancelAll();
                resolve();
            }
            catch (ex) {
                console.log("Error in LocalNotifications.cancelAll: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.getScheduledIds = function () {
        return new Promise(function (resolve, reject) {
            try {
                var keys = com.telerik.localnotifications.Store.getKeys(utils.ad.getApplicationContext());
                var ids = [];
                for (var i = 0; i < keys.length; i++) {
                    ids.push(parseInt(keys[i]));
                }
                resolve(ids);
            }
            catch (ex) {
                console.log("Error in LocalNotifications.getScheduledIds: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.schedule = function (scheduleOptions) {
        return new Promise(function (resolve, reject) {
            try {
                var context = utils.ad.getApplicationContext();
                var resources = context.getResources();
                var scheduledIds = [];
                for (var n in scheduleOptions) {
                    var options = LocalNotificationsImpl.merge(scheduleOptions[n], LocalNotificationsImpl.defaults);
                    options.icon = LocalNotificationsImpl.getIcon(context, resources, LocalNotificationsImpl.IS_GTE_LOLLIPOP && options.silhouetteIcon || options.icon);
                    options.atTime = options.at ? options.at.getTime() : 0;
                    options.repeatInterval = LocalNotificationsImpl.getInterval(options.interval);
                    if (options.color) {
                        options.color = options.color.android;
                    }
                    if (options.notificationLed && options.notificationLed !== true) {
                        options.notificationLed = options.notificationLed.android;
                    }
                    LocalNotificationsImpl.ensureID(options);
                    com.telerik.localnotifications.LocalNotificationsPlugin.scheduleNotification(new org.json.JSONObject(JSON.stringify(options)), context);
                    scheduledIds.push(options.id);
                }
                resolve(scheduledIds);
            }
            catch (ex) {
                console.log("Error in LocalNotifications.schedule: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.IS_GTE_LOLLIPOP = android.os.Build.VERSION.SDK_INT >= 21;
    return LocalNotificationsImpl;
}(local_notifications_common_1.LocalNotificationsCommon));
exports.LocalNotificationsImpl = LocalNotificationsImpl;
exports.LocalNotifications = new LocalNotificationsImpl();
