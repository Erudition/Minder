import { View } from '@nativescript/core';
export class CircularProgressLayout extends View {
    constructor() {
        super();
    }
    set strokeWidth(value) {
        if (value) {
            this.android.setStrokeWidth(value);
        }
    }
    set indeterminate(value) {
        if (value) {
            this.android.setIndeterminate(value);
        }
    }
    set totalTime(value) {
        if (value) {
            this.android.setTotalTime(value);
        }
    }
    createNativeView() {
        this._android = new androidx.wear.widget.CircularProgressLayout(this._context);
        if (!this._androidViewId) {
            this._androidViewId = android.view.View.generateViewId();
        }
        this._android.setId(this._androidViewId);
        return this._android;
    }
    initNativeView() {
        super.initNativeView();
        if (this.totalTime) {
            this.android.setTotalTime(this.totalTime);
        }
        const timerFinishedListener = new androidx.wear.widget.CircularProgressLayout.OnTimerFinishedListener({
            onTimerFinished(param0) {
                console.log('timer finished');
            }
        });
        this.android.setOnTimerFinishedListener(timerFinishedListener);
    }
    disposeNativeView() {
        super.disposeNativeView();
    }
    startTimer() {
        this.android.startTimer();
    }
    stopTimer() {
        this.android.stopTimer();
    }
    onLoaded() {
        super.onLoaded();
        this._childViews.forEach(value => {
            this._addView(value);
            this._holder.addView(value.nativeView);
        });
    }
    _addChildFromBuilder(name, value) {
        if (!this._childViews) {
            this._childViews = new Map();
        }
        if (!value.parent) {
            this._childViews.set(value._domId, value);
        }
    }
}
