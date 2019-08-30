const observableModule = require("tns-core-modules/data/observable");

var appData = require("../app.js").appData;
//var activitiesVM = [ { name: "demo" } ];//JSON.parse(appData.activitiesVM);
//console.log(appData.activitiesVM);
//activitiesVM = activitiesVM ? activitiesVM : [ { name: "demo" } ] ;

const appSettings = require("tns-core-modules/application-settings");
let settingsString = appSettings.getString("activitiesVM", "[]");
try {
    var activitylist = JSON.parse(settingsString);
} catch (e) {
    console.log("Failed to parse activitylist JSON, defaulting to empty list: ", settingsString)
    var activitylist = [];
}



function ActivitiesViewModel() {
    const viewModel = observableModule.fromObject({activities : activitylist});

    return viewModel;
}

module.exports = ActivitiesViewModel;
