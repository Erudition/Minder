import { Application, Utils } from '@nativescript/core';
const CONFIRMATION_ACTIVITY_REQUEST_CODE = 5673;
export const confirm = (options) => {
    return new Promise((resolve, reject) => {
        const intent = new android.content.Intent(Utils.android.getApplicationContext(), com.github.bradmartin.smartwearos.ConfirmationActivity.class);
        intent.putExtra('MESSAGE', options.message);
        if (options.title) {
            intent.putExtra('TITLE', options.title);
        }
        if (options.autoCloseTime) {
            intent.putExtra('AUTO_CLOSE_TIME', options.autoCloseTime);
        }
        const activity = Application.android.foregroundActivity ||
            Application.android.startActivity;
        activity.startActivityForResult(intent, CONFIRMATION_ACTIVITY_REQUEST_CODE);
        activity.onActivityResult = (requestCode, resultCode, data) => {
            if (requestCode === CONFIRMATION_ACTIVITY_REQUEST_CODE) {
                if (resultCode === android.app.Activity.RESULT_OK) {
                    return resolve(true);
                }
                else if (resultCode === android.app.Activity.RESULT_CANCELED) {
                    return resolve(false);
                }
                else {
                    return resolve(null);
                }
            }
        };
    });
};
