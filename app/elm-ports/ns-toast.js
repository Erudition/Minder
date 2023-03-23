export function addToastPorts (elmPorts) {
    // FLASH OR "TOAST" POPUPS ---------------------------------------
    const toasty = require('@triniwiz/nativescript-toasty');
    console.log("ElmPorts is ", elmPorts)
    if (elmPorts.flash) {
        elmPorts.flash.subscribe(function(toast_message) {
            const toast = new toasty.Toasty({
                text: toast_message,
                duration: toasty.ToastDuration.LONG,
                textColor: '#fff',
                //backgroundColor: new Color('purple'),
                position: toasty.ToastPosition.BOTTOM,
                android: { yAxisOffset: 100 },
                ios: {
                    displayShadow: true,
                    shadowColor: '#fff000',
                    cornerRadius: 24
                }
            }).show();
        });
    }

    if (elmPorts.ns_notify) {

    }
}
