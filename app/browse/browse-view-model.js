const observableModule = require("@nativescript/core/data/observable");

function BrowseViewModel() {
    const viewModel = observableModule.fromObject({
        /* Add your view model properties here */
    });

    return viewModel;
}

module.exports = BrowseViewModel;
