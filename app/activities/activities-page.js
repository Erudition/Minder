
var main = require("../app.js");

function onPageLoaded(args) {
    const page = args.object;
    console.log("page is " + page);

    console.info("Attempting Elm initialization! ---------------------------------");

    //var rootElement =  document.getElementById("root-tabview");

    //console.log("finding root element: " + document.getElementById("root-tabview"));

    var document =
    { location : {href : "https://minder.app/"}
    , getElementById : getElementById
    , createElement : function() {}
    }
    var elm = require('../../www/elm-browserless.js').Elm.Browserless.init(
        { node: page
        , flags: ["https://minder.app/", ""]
        });

    console.info("Got past Elm initialization! ---------------------------------");
}
// UNCOMMENT to try browserless gui again
//exports.onPageLoaded = onPageLoaded;



function onNavigatingTo(args) {
    const component = args.object;
    component.bindingContext = global.globalViewModel;
    main.tellElm("headlessMsg", "http://minder.app/?export=all");
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

    main.tellElm("headlessMsg", "http://minder.app/?start=" + tappedItem.name);

    console.dir(tappedItem);

}


exports.onItemTap = onItemTapNew;
exports.onNavigatingTo = onNavigatingTo;
