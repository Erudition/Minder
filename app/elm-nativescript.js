export function addNativeScriptFeaturesToElm (elm) {
    // FLASH OR "TOAST" POPUPS ---------------------------------------
    const toasty = require('nativescript-toasty');

    if (elm.ports.flash) {
        elm.ports.flash.subscribe(function(toast_message) {
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

    if (elm.ports.ns_notify) {

    }
}
