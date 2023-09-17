import * as TaskPort from 'elm-taskport';
import {LocalNotifications} from '@capacitor/local-notifications'
import { native } from '@nativescript/capacitor';


export function registerNotificationTaskPorts() {
    TaskPort.register("scheduleNotifications", scheduleNotifications );
}

export function scheduleNotifications(notificationList) {

    // Elm-encoded JSON object obviously can't contain the required Date() object
    var correctedList = notificationList.map(
        function(notifObj) {
            let now = new Date();

            if (notifObj["schedule"]) {
                //wrap js time (unix ms float) with Date object
                let oldScheduleAt = new Date( notifObj["schedule"]["at"])

                if (oldScheduleAt.getTime() > now.getTime()) {
                    notifObj["schedule"]["at"] = oldScheduleAt;
                } else {
                    notifObj["schedule"]["at"] = null;
                }

            }
            try {
            notifObj["when"] = new Date(notifObj["when"]);
            } catch (e)
            {console.log(e)}

            if (!notifObj["id"]) {
                notifObj["id"] = (0 - now.getTime());
            }

            // convert from NativeScript format to Capacitor format for now -----
            if (notifObj["subtitle"]) {
                notifObj["title"] = notifObj["title"] + " (" + notifObj["subtitle"] + ")";
                // since capacitor notification does not support subtitle
            } 
            if (notifObj["bigTextStyle"]) {
                notifObj["largeBody"] = notifObj["body"];
            } 
            if (notifObj["groupSummary"]) {
                notifObj["summaryText"] = notifObj["groupSummary"];
            } 
            if (notifObj["groupedMessages"]) {
                notifObj["inboxList"] = notifObj["groupedMessages"];
            } 
            if (notifObj["color"]) {
                notifObj["iconColor"] = notifObj["color"];
            } 
            if (notifObj["channel"]) {
                notifObj["channelId"] = notifObj["channel"];
            } 


            // missing support: silhouetteIcon
            // missing support: image
            // missing support: thumbnail

            // TODO: image -> Attachment

            setupChannel(notifObj);

            return notifObj;
        }
    );



    return LocalNotifications.schedule({
        notifications: correctedList
        });
}

function setupChannel(notif) {
    if (notif["channel"]) {
        LocalNotifications.createChannel(
            {
            id: notif["channel"],
            name: notif["channel"],
            description: notif["channelDescription"],
            sound: notif["sound"],
            importance: notif["priority"],
            lightColor: notif["notificationLed"],
            // vibration?: boolean; TODO not pattern
            }
        );
    } 
}