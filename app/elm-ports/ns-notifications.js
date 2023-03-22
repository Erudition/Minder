const notifications = require ("@nativescript/local-notifications").LocalNotifications;

const Color = require("tns-core-modules/color").Color;
const colors = require("tns-core-modules/color/known-colors");

export function addNotificationPorts (elmPorts) {
// NOTIFICATIONS --------------------------------------------------------

    if (elmPorts.ns_notify_cancel) elmPorts.ns_notify_cancel.subscribe(function(notificationID) {
        console.log("Canceling notification " + notificationID);
        notifications.cancel(notificationID);
        }
    );

    if (elmPorts.ns_notify) elmPorts.ns_notify.subscribe(function(notificationList) {

        // Elm-encoded JSON object obviously can't contain the required Date() object
        var correctedList = notificationList.map(
            function(notifObj) {
                //wrap js time (unix ms float) with Date object
                notifObj["at"] = new Date(notifObj["at"]);

                try {
                notifObj["when"] = new Date(notifObj["when"]);
                } catch (e)
                {console.log(e)}

                let notifColor = notifObj["color"];
                if (notifColor) {
                // supports known names and hex values short and long
                    notifObj["color"] = new Color(notifColor);
                }


                // While we're at it, check if we missed it
                if (new Date() > notifObj["at"]) {
                    // make it dispatch right away
                    notifObj["at"] = null;
                }
                return notifObj;
            }
        );

        console.info("Here are the " + correctedList.length + " Notifications I'll try to schedule:");
        console.dir(correctedList);


        notifications.schedule(correctedList).then(
            function(scheduledIds) {
            console.info("Notification id(s) scheduled: " + JSON.stringify(scheduledIds) + "\n from JSON: ");

            },
            function(error) {
            console.error("Minder Notif scheduling error: " + error);
            }
        )
    });

    notifications.addOnMessageReceivedCallback(
        function (notification) {

        //console.dir(notification);
        let actionTaken = notification.response;
            if (typeof actionTaken !== 'undefined') // No response if they just tap it or "Open"
            console.log('ID: ' + notification.id);
            console.log('Title: ' + notification.title);
            console.log('Body: ' + notification.body);
            { elmPorts.headlessMsg.send("http://minder.app/?" + actionTaken ); }

        }
    ).then(
        function() {
        //console.info("Listener added");elm.ports
        }
    )

}
