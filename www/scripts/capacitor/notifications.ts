import * as TaskPort from 'elm-taskport';
import {LocalNotifications} from '@capacitor/local-notifications'


export function registerNotificationTaskPorts() {
    TaskPort.register("scheduleNotifications", (notificationList) => {

        // Elm-encoded JSON object obviously can't contain the required Date() object
        var correctedList = notificationList.map(
            function(notifObj) {
                if (notifObj["schedule"]) {
                    //wrap js time (unix ms float) with Date object
                    let oldScheduleAt = notifObj["schedule"]["at"]
                    notifObj["schedule"]["at"] = oldScheduleAt ? new Date(oldScheduleAt) : new Date();
                } else {
                    notifObj["schedule"] = { at : new Date()}
                }
                Object.assign(notifObj, {schedule : {at: new Date()}})
                console.log("new notif Object", notifObj)
                try {
                notifObj["when"] = new Date(notifObj["when"]);
                } catch (e)
                {console.log(e)}

                return notifObj;
            }
        );



        LocalNotifications.requestPermissions()
        return LocalNotifications.schedule({
            notifications: correctedList
            });
    });
}
