import * as TaskPort from 'elm-taskport';
import {LocalNotifications} from '@capacitor/local-notifications'


export function registerNotificationTaskPorts() {
    TaskPort.register("scheduleNotifications", (notificationList) => {

        // Elm-encoded JSON object obviously can't contain the required Date() object
        var correctedList = notificationList.map(
            function(notifObj) {
                //wrap js time (unix ms float) with Date object
                notifObj["at"] = new Date(notifObj["at"]);

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
