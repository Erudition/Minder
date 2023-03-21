const appSettings = require("@nativescript/core/application-settings");

export function addToastPorts (elmPorts) {
    // SET STORAGE -----------------------------------------------------------------
    elmPorts.setStorage.subscribe(function(data) {

        //console.info("App Data being set");

        // let lines = data.split("\\n");
        // for (var line in lines) {
        //     console.info("Line: " + lines[line]);
        // }

        appSettings.setString("appData", data);
    });
}