const ActivitiesViewModel = require("./activities-view-model");

var elmApp = require("../app.js").app;



function onNavigatingTo(args) {
    const component = args.object;
    component.bindingContext = new ActivitiesViewModel();
}

function onItemTapOld(args) {
    const view = args.view;
    const page = view.page;
    const tappedItem = view.bindingContext;

    page.frame.navigate({
        moduleName: "activities/activity-detail/activity-detail-page",
        context: tappedItem,
        animated: true,
        transition: {
            name: "slide",
            duration: 200,
            curve: "ease"
        }
    });
}

function onItemTapNew(args) {
    const view = args.view;
    const page = view.page;
    const tappedItem = view.bindingContext;

    elmApp.ports.headlessMsg.send("http://minder.app/?start=" + tappedItem.name);

    console.dir(tappedItem);

}


exports.onItemTap = onItemTapNew;
exports.onNavigatingTo = onNavigatingTo;
