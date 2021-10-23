import { Application, Utils } from '@nativescript/core';
const SUCCESS_ACTIVITY_REQUEST_CODE = 5674;
export const showSuccess = (msg, dismissTime = 3) => {
    return new Promise((resolve, reject) => {
        const intent = new android.content.Intent(Utils.android.getApplicationContext(), com.github.bradmartin.smartwearos.SuccessActivity.class);
        if (msg) {
            intent.putExtra('MESSAGE', msg);
        }
        intent.putExtra('DISMISS_TIMEOUT', dismissTime);
        const activity = Application.android.foregroundActivity ||
            Application.android.startActivity;
        activity.startActivityForResult(intent, SUCCESS_ACTIVITY_REQUEST_CODE);
        activity.onActivityResult = (requestCode, resultCode, data) => {
            if (requestCode === SUCCESS_ACTIVITY_REQUEST_CODE) {
                return resolve();
            }
        };
    });
};
