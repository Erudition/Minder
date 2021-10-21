const observableModule = require("@nativescript/core/data/observable");
const appSettings = require("@nativescript/core/application-settings");

let settingsString = appSettings.getString("appData", "{}");
var appData = JSON.parse(settingsString);
// console.log(" App Data: ");
// let lines = settingsString.split("\\n");
// for (var line in lines) {
//     console.log("Line: " + lines[line]);
// }

// appSettings.setString("appData", '');

function SearchViewModel() {
    const viewModel = observableModule.fromObject({

    });

    return viewModel;
}

module.exports = SearchViewModel;
