import * as TaskPort from 'elm-taskport';
import {LocalNotifications} from '@capacitor/local-notifications'


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

            return notifObj;
        }
    );


    return LocalNotifications.schedule({
        notifications: correctedList
        });
}