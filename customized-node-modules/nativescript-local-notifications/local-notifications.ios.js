"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var fileSystemModule = require("@nativescript/core/file-system");
var image_source_1 = require("@nativescript/core/image-source");
var local_notifications_common_1 = require("./local-notifications-common");
var LocalNotificationsImpl = (function (_super) {
    __extends(LocalNotificationsImpl, _super);
    function LocalNotificationsImpl() {
        var _this = _super.call(this) || this;
        _this.pendingReceivedNotifications = [];
        if (LocalNotificationsImpl.isUNUserNotificationCenterAvailable()) {
            _this.delegate = UNUserNotificationCenterDelegateImpl.initWithOwner(new WeakRef(_this));
            UNUserNotificationCenter.currentNotificationCenter().delegate = _this.delegate;
        }
        else {
            _this.notificationReceivedObserver = LocalNotificationsImpl.addObserver("notificationReceived", function (result) {
                var notificationDetails = JSON.parse(result.userInfo.objectForKey("message"));
                _this.addOrProcessNotification(notificationDetails);
            });
            _this.notificationHandler = Notification.new();
            _this.notificationManager = NotificationManager.new();
        }
        return _this;
    }
    LocalNotificationsImpl.isUNUserNotificationCenterAvailable = function () {
        try {
            return !!UNUserNotificationCenter;
        }
        catch (ignore) {
            return false;
        }
    };
    LocalNotificationsImpl.hasPermission = function () {
        var settings = UIApplication.sharedApplication.currentUserNotificationSettings;
        var types = 4 | 1 | 2;
        return (settings.types & types) > 0;
    };
    LocalNotificationsImpl.getImageName = function (imageURL, extension) {
        if (imageURL === void 0) { imageURL = ""; }
        if (extension === void 0) { extension = "png"; }
        var name = imageURL.split(/[\/\.]/).slice(-2, -1)[0] || LocalNotificationsImpl.generateUUID();
        return [name, name + "." + extension];
    };
    LocalNotificationsImpl.addObserver = function (eventName, callback) {
        return NSNotificationCenter.defaultCenter.addObserverForNameObjectQueueUsingBlock(eventName, null, NSOperationQueue.mainQueue, callback);
    };
    LocalNotificationsImpl.getInterval = function (interval) {
        if (interval === "minute") {
            return 128;
        }
        else if (interval === "hour") {
            return 64 | 128;
        }
        else if (interval === "day") {
            return 32 | 64 | 128;
        }
        else if (interval === "week") {
            return 512 | 32 | 64 | 128;
        }
        else if (interval === "month") {
            return 16 | 32 | 64 | 128;
        }
        else if (interval === "year") {
            return 8 | 16 | 32 | 64 | 128;
        }
        else {
            return 4 | 8 | 16 | 32 | 64 | 128;
        }
    };
    LocalNotificationsImpl.getIntervalSeconds = function (interval, ticks) {
        if (!interval) {
            return ticks;
        }
        else if (interval === "second") {
            return ticks;
        }
        else if (interval === "minute") {
            return ticks * 60;
        }
        else if (interval === "hour") {
            return ticks * 60 * 60;
        }
        else if (interval === "day") {
            return ticks * 60 * 60 * 24;
        }
        else if (interval === "week") {
            return ticks * 60 * 60 * 24 * 7;
        }
        else if (interval === "month") {
            return ticks * 60 * 60 * 24 * 30.438;
        }
        else if (interval === "quarter") {
            return ticks * 60 * 60 * 24 * 91.313;
        }
        else if (interval === "year") {
            return ticks * 60 * 60 * 24 * 365;
        }
        else {
            return ticks;
        }
    };
    LocalNotificationsImpl.schedulePendingNotifications = function (pending) {
        if (LocalNotificationsImpl.isUNUserNotificationCenterAvailable()) {
            return LocalNotificationsImpl.schedulePendingNotificationsNew(pending);
        }
        else {
            return LocalNotificationsImpl.schedulePendingNotificationsLegacy(pending);
        }
    };
    LocalNotificationsImpl.schedulePendingNotificationsNew = function (pending) {
        var scheduledIds = [];
        var _loop_1 = function (n) {
            var options = LocalNotificationsImpl.merge(pending[n], LocalNotificationsImpl.defaults);
            LocalNotificationsImpl.ensureID(options);
            scheduledIds.push(options.id);
            var content = UNMutableNotificationContent.new();
            var title = options.title, subtitle = options.subtitle, body = options.body;
            content.title = body || subtitle ? title : undefined;
            content.subtitle = body ? subtitle : undefined;
            content.body = body || subtitle || title || " ";
            content.badge = options.badge;
            if (options.sound === undefined || options.sound === "default") {
                content.sound = UNNotificationSound.defaultSound;
            }
            var userInfoDict = new NSMutableDictionary({ capacity: 1 });
            userInfoDict.setObjectForKey(options.forceShowWhenInForeground, "forceShowWhenInForeground");
            content.userInfo = userInfoDict;
            var trigger;
            if (options.at) {
                var cal = LocalNotificationsImpl.calendarWithMondayAsFirstDay();
                var date = cal.componentsFromDate(LocalNotificationsImpl.getInterval(options.interval), options.at);
                date.timeZone = NSTimeZone.defaultTimeZone;
                trigger = UNCalendarNotificationTrigger.triggerWithDateMatchingComponentsRepeats(date, options.interval !== undefined);
            }
            else {
                trigger = UNTimeIntervalNotificationTrigger.triggerWithTimeIntervalRepeats(2, false);
            }
            if (options.actions) {
                var categoryIdentifier_1 = "CATEGORY";
                var actions_1 = [];
                options.actions.forEach(function (action) {
                    categoryIdentifier_1 += ("_" + action.id);
                    var notificationActionOptions = UNNotificationActionOptionNone;
                    if (action.launch) {
                        notificationActionOptions = 4;
                    }
                    if (action.type === "input") {
                        actions_1.push(UNTextInputNotificationAction.actionWithIdentifierTitleOptionsTextInputButtonTitleTextInputPlaceholder("" + action.id, action.title, notificationActionOptions, action.submitLabel || "Submit", action.placeholder));
                    }
                    else if (action.type === "button") {
                        actions_1.push(UNNotificationAction.actionWithIdentifierTitleOptions("" + action.id, action.title, notificationActionOptions));
                    }
                    else {
                        console.log("Unsupported action type: " + action.type);
                    }
                });
                var notificationCategory_1 = UNNotificationCategory.categoryWithIdentifierActionsIntentIdentifiersOptions(categoryIdentifier_1, actions_1, [], 1);
                content.categoryIdentifier = categoryIdentifier_1;
                UNUserNotificationCenter.currentNotificationCenter().getNotificationCategoriesWithCompletionHandler(function (categories) {
                    if (categories) {
                        UNUserNotificationCenter.currentNotificationCenter().setNotificationCategories(categories.setByAddingObject(notificationCategory_1));
                    }
                    else {
                        UNUserNotificationCenter.currentNotificationCenter().setNotificationCategories(NSSet.setWithObject(notificationCategory_1));
                    }
                });
            }
            if (!options.image) {
                UNUserNotificationCenter.currentNotificationCenter().addNotificationRequestWithCompletionHandler(UNNotificationRequest.requestWithIdentifierContentTrigger("" + options.id, content, trigger), function (error) { return error ? console.log("Error scheduling notification (id " + options.id + "): " + error.localizedDescription) : null; });
            }
            else {
                image_source_1.fromUrl(options.image).then(function (image) {
                    var _a = LocalNotificationsImpl.getImageName(options.image, "png"), imageName = _a[0], imageNameWithExtension = _a[1];
                    var path = fileSystemModule.path.join(fileSystemModule.knownFolders.temp().path, imageNameWithExtension);
                    var saved = image.saveToFile(path, "png");
                    if (saved || fileSystemModule.File.exists(path)) {
                        try {
                            content.attachments = NSArray.arrayWithObject(UNNotificationAttachment.attachmentWithIdentifierURLOptionsError(imageName, NSURL.fileURLWithPath(path), null));
                        }
                        catch (err) {
                            console.log("Error adding image attachment - ignoring the image. Error: " + err);
                        }
                    }
                    UNUserNotificationCenter.currentNotificationCenter().addNotificationRequestWithCompletionHandler(UNNotificationRequest.requestWithIdentifierContentTrigger("" + options.id, content, trigger), function (error) { return error ? console.log("Error scheduling notification (id " + options.id + "): " + error.localizedDescription) : null; });
                });
            }
        };
        for (var n in pending) {
            _loop_1(n);
        }
        return scheduledIds;
    };
    LocalNotificationsImpl.calendarWithMondayAsFirstDay = function () {
        var cal = NSCalendar.alloc().initWithCalendarIdentifier(NSCalendarIdentifierISO8601);
        cal.firstWeekday = 2;
        cal.minimumDaysInFirstWeek = 1;
        return cal;
    };
    LocalNotificationsImpl.schedulePendingNotificationsLegacy = function (pending) {
        var scheduledIds = [];
        for (var n in pending) {
            var options = LocalNotificationsImpl.merge(pending[n], LocalNotificationsImpl.defaults);
            LocalNotificationsImpl.ensureID(options);
            scheduledIds.push(options.id);
            var notification = UILocalNotification.new();
            notification.fireDate = options.at ? options.at : new Date();
            notification.alertTitle = options.title;
            notification.alertBody = options.body;
            notification.timeZone = NSTimeZone.defaultTimeZone;
            notification.applicationIconBadgeNumber = options.badge;
            var userInfoDict = NSMutableDictionary.alloc().initWithCapacity(4);
            userInfoDict.setObjectForKey(options.id, "id");
            userInfoDict.setObjectForKey(options.title, "title");
            userInfoDict.setObjectForKey(options.body, "body");
            userInfoDict.setObjectForKey(options.interval, "interval");
            notification.userInfo = userInfoDict;
            switch (options.sound) {
                case null:
                case false:
                    break;
                case undefined:
                case "default":
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    break;
                default:
                    notification.soundName = options.sound;
                    break;
            }
            options.repeatInterval = LocalNotificationsImpl.getInterval(options.interval);
            UIApplication.sharedApplication.scheduleLocalNotification(notification);
        }
        return scheduledIds;
    };
    LocalNotificationsImpl.prototype.addOrProcessNotification = function (notificationDetails) {
        if (this.receivedNotificationCallback) {
            this.receivedNotificationCallback(notificationDetails);
        }
        else {
            this.pendingReceivedNotifications.push(notificationDetails);
        }
    };
    LocalNotificationsImpl.prototype.hasPermission = function () {
        return new Promise(function (resolve, reject) {
            try {
                resolve(LocalNotificationsImpl.hasPermission());
            }
            catch (ex) {
                console.log("Error in LocalNotifications.hasPermission: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.requestPermission = function () {
        return new Promise(function (resolve, reject) {
            if (LocalNotificationsImpl.isUNUserNotificationCenterAvailable()) {
                var center = UNUserNotificationCenter.currentNotificationCenter();
                center.requestAuthorizationWithOptionsCompletionHandler(4 | 1 | 2, function (granted, error) { return resolve(granted); });
            }
            else {
                LocalNotificationsImpl.didRegisterUserNotificationSettingsObserver = LocalNotificationsImpl.addObserver("didRegisterUserNotificationSettings", function (result) {
                    NSNotificationCenter.defaultCenter.removeObserver(LocalNotificationsImpl.didRegisterUserNotificationSettingsObserver);
                    LocalNotificationsImpl.didRegisterUserNotificationSettingsObserver = undefined;
                    var granted = result.userInfo.objectForKey("message");
                    resolve(granted !== "false" && granted !== false);
                });
                var types = UIApplication.sharedApplication.currentUserNotificationSettings.types | 4 | 1 | 2;
                var settings = UIUserNotificationSettings.settingsForTypesCategories(types, null);
                UIApplication.sharedApplication.registerUserNotificationSettings(settings);
            }
        });
    };
    LocalNotificationsImpl.prototype.addOnMessageReceivedCallback = function (onReceived) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            try {
                _this.receivedNotificationCallback = onReceived;
                for (var _i = 0, _a = _this.pendingReceivedNotifications; _i < _a.length; _i++) {
                    var pendingReceivedNotification = _a[_i];
                    onReceived(pendingReceivedNotification);
                }
                _this.pendingReceivedNotifications = [];
                resolve(true);
            }
            catch (ex) {
                console.log("Error in LocalNotifications.addOnMessageReceivedCallback: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.addOnMessageClearedCallback = function (onReceived) {
        return Promise.resolve(false);
    };
    LocalNotificationsImpl.prototype.cancel = function (id) {
        return new Promise(function (resolve, reject) {
            try {
                if (LocalNotificationsImpl.isUNUserNotificationCenterAvailable()) {
                    UNUserNotificationCenter.currentNotificationCenter().removePendingNotificationRequestsWithIdentifiers(["" + id]);
                    resolve(true);
                }
                else {
                    var scheduled = UIApplication.sharedApplication.scheduledLocalNotifications;
                    for (var i = 0, l = scheduled.count; i < l; i++) {
                        var noti = scheduled.objectAtIndex(i);
                        if (id === +noti.userInfo.valueForKey("id")) {
                            UIApplication.sharedApplication.cancelLocalNotification(noti);
                            resolve(true);
                            return;
                        }
                    }
                    resolve(false);
                }
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
                if (LocalNotificationsImpl.isUNUserNotificationCenterAvailable()) {
                    UNUserNotificationCenter.currentNotificationCenter().removeAllPendingNotificationRequests();
                }
                else {
                    UIApplication.sharedApplication.cancelAllLocalNotifications();
                }
                UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
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
                var scheduledIds_1 = [];
                if (LocalNotificationsImpl.isUNUserNotificationCenterAvailable()) {
                    UNUserNotificationCenter.currentNotificationCenter().getPendingNotificationRequestsWithCompletionHandler(function (notRequests) {
                        for (var i = 0; i < notRequests.count; i++) {
                            scheduledIds_1.push(notRequests[i].identifier);
                        }
                        resolve(scheduledIds_1.map(Number));
                    });
                }
                else {
                    var scheduled = UIApplication.sharedApplication.scheduledLocalNotifications;
                    for (var i = 0, l = scheduled.count; i < l; i++) {
                        scheduledIds_1.push(scheduled.objectAtIndex(i).userInfo.valueForKey("id"));
                    }
                    resolve(scheduledIds_1.map(Number));
                }
            }
            catch (ex) {
                console.log("Error in LocalNotifications.getScheduledIds: " + ex);
                reject(ex);
            }
        });
    };
    LocalNotificationsImpl.prototype.schedule = function (options) {
        var _this = this;
        return new Promise(function (resolve, reject) {
            try {
                if (!LocalNotificationsImpl.hasPermission()) {
                    _this.requestPermission().then(function (granted) {
                        if (granted) {
                            resolve(LocalNotificationsImpl.schedulePendingNotifications(options));
                        }
                    });
                }
                else {
                    resolve(LocalNotificationsImpl.schedulePendingNotifications(options));
                }
            }
            catch (ex) {
                console.log("Error in LocalNotifications.schedule: " + ex);
                reject(ex);
            }
        });
    };
    return LocalNotificationsImpl;
}(local_notifications_common_1.LocalNotificationsCommon));
exports.LocalNotificationsImpl = LocalNotificationsImpl;
var UNUserNotificationCenterDelegateImpl = (function (_super) {
    __extends(UNUserNotificationCenterDelegateImpl, _super);
    function UNUserNotificationCenterDelegateImpl() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this.receivedInForeground = false;
        return _this;
    }
    UNUserNotificationCenterDelegateImpl.new = function () {
        try {
            UNUserNotificationCenterDelegateImpl.ObjCProtocols.push(UNUserNotificationCenterDelegate);
        }
        catch (ignore) {
        }
        return _super.new.call(this);
    };
    UNUserNotificationCenterDelegateImpl.initWithOwner = function (owner) {
        var delegate = UNUserNotificationCenterDelegateImpl.new();
        delegate._owner = owner;
        return delegate;
    };
    UNUserNotificationCenterDelegateImpl.prototype.userNotificationCenterDidReceiveNotificationResponseWithCompletionHandler = function (center, notificationResponse, completionHandler) {
        var request = notificationResponse.notification.request, notificationContent = request.content, action = notificationResponse.actionIdentifier;
        if (action === UNNotificationDismissActionIdentifier) {
            completionHandler();
            return;
        }
        var event = "default";
        if (action !== UNNotificationDefaultActionIdentifier) {
            event = notificationResponse instanceof UNTextInputNotificationResponse ? "input" : "button";
        }
        var response = notificationResponse.actionIdentifier;
        if (response === UNNotificationDefaultActionIdentifier) {
            response = undefined;
        }
        else if (notificationResponse instanceof UNTextInputNotificationResponse) {
            response = notificationResponse.userText;
        }
        this._owner.get().addOrProcessNotification({
            id: +request.identifier,
            title: notificationContent.title,
            body: notificationContent.body,
            foreground: this.receivedInForeground || UIApplication.sharedApplication.applicationState === 0,
            event: event,
            response: response
        });
        this.receivedInForeground = false;
        completionHandler();
    };
    UNUserNotificationCenterDelegateImpl.prototype.userNotificationCenterWillPresentNotificationWithCompletionHandler = function (center, notification, completionHandler) {
        if (notification.request.trigger instanceof UNPushNotificationTrigger) {
            return;
        }
        this.receivedInForeground = true;
        if (notification.request.content.userInfo.valueForKey("forceShowWhenInForeground")) {
            completionHandler(1 | 2 | 4);
        }
        else {
            completionHandler(1 | 2);
        }
    };
    UNUserNotificationCenterDelegateImpl.ObjCProtocols = [];
    return UNUserNotificationCenterDelegateImpl;
}(NSObject));
var instance = new LocalNotificationsImpl();
exports.LocalNotifications = instance;
