const appSettings = require("@nativescript/core/application-settings");

export function addStoragePorts (elmPorts) {
    // SET STORAGE -----------------------------------------------------------------
    if (elmPorts.setStorage) elmPorts.setStorage.subscribe(function(data) {

        //console.info("App Data being set");

        // let lines = data.split("\\n");
        // for (var line in lines) {
        //     console.info("Line: " + lines[line]);
        // }
        appSettings.setString("appData", appSettings.getString("appData", "") + data);
    });
}