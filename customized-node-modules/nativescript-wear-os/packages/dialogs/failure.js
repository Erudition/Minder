import { Application, Utils } from '@nativescript/core';
const FAILURE_ACTIVITY_REQUEST_CODE = 5675;
export const showFailure = (msg, dismissTime = 3) => {
    return new Promise((resolve, reject) => {
        const intent = new android.content.Intent(Utils.android.getApplicationContext(), com.github.bradmartin.smartwearos.FailureActivity.class);
        if (msg) {
            intent.putExtra('MESSAGE', msg);
        }
        intent.putExtra('DISMISS_TIMEOUT', dismissTime);
        const activity = Application.android.foregroundActivity ||
            Application.android.startActivity;
        activity.startActivityForResult(intent, FAILURE_ACTIVITY_REQUEST_CODE);
        activity.onActivityResult = (requestCode, resultCode, data) => {
            if (requestCode === FAILURE_ACTIVITY_REQUEST_CODE) {
                resolve();
            }
        };
    });
};
