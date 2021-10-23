import { AndroidApplication, Application, Utils } from '@nativescript/core';
const CONFIRMATION_ACTIVITY_REQUEST_CODE = 5673;
export function showConfirmationActivity(message, type) {
    return new Promise((resolve, reject) => {
        try {
            const activityType = _getActivityType(type);
            const intent = new android.content.Intent(Utils.android.getApplicationContext(), android.support.wearable.activity.ConfirmationActivity.class);
            intent.putExtra(android.support.wearable.activity.ConfirmationActivity
                .EXTRA_ANIMATION_TYPE, activityType);
            intent.putExtra(android.support.wearable.activity.ConfirmationActivity.EXTRA_MESSAGE, message);
            Application.android.on(AndroidApplication.activityResultEvent, (args) => {
                if (args.requestCode === CONFIRMATION_ACTIVITY_REQUEST_CODE &&
                    args.resultCode === android.app.Activity.RESULT_OK) {
                    const intentData = args.intent;
                    resolve(intentData);
                }
            });
            const activity = Application.android.foregroundActivity ||
                Application.android.startActivity;
            activity.startActivityForResult(intent, CONFIRMATION_ACTIVITY_REQUEST_CODE);
        }
        catch (error) {
            reject(error);
        }
    });
}
export var ConfirmationActivityType;
(function (ConfirmationActivityType) {
    ConfirmationActivityType["SUCCESS"] = "SUCCESS";
    ConfirmationActivityType["FAILURE"] = "FAILURE";
    ConfirmationActivityType["OPEN_ON_PHONE"] = "OPEN_ON_PHONE";
})(ConfirmationActivityType || (ConfirmationActivityType = {}));
function _getActivityType(type) {
    switch (type) {
        case ConfirmationActivityType.SUCCESS:
            return android.support.wearable.activity.ConfirmationActivity
                .SUCCESS_ANIMATION;
        case ConfirmationActivityType.FAILURE:
            return android.support.wearable.activity.ConfirmationActivity
                .FAILURE_ANIMATION;
        case ConfirmationActivityType.OPEN_ON_PHONE:
            return android.support.wearable.activity.ConfirmationActivity
                .OPEN_ON_PHONE_ANIMATION;
        default:
            return android.support.wearable.activity.ConfirmationActivity
                .SUCCESS_ANIMATION;
    }
}
