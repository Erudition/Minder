import { ContentView, Screen, Utils, View } from '@nativescript/core';
export class WearOsLayout extends ContentView {
    constructor() {
        super();
        this.disableInsetConstraint = false;
    }
    createNativeView() {
        this._android = new android.widget.LinearLayout(this._context);
        if (!this._androidViewId) {
            this._androidViewId = android.view.View.generateViewId();
        }
        this._android.setId(this._androidViewId);
        this._android.setOrientation(android.widget.LinearLayout.VERTICAL);
        this._android.setGravity(android.view.Gravity.FILL_VERTICAL);
        this._android.setLayoutParams(new android.view.ViewGroup.LayoutParams(android.view.ViewGroup.LayoutParams.FILL_PARENT, android.view.ViewGroup.LayoutParams.FILL_PARENT));
        if (this.disableInsetConstraint === false) {
            const inset = this._adjustInset();
            if (inset) {
                this._android.setPadding(inset, inset, inset, inset);
            }
        }
        return this._android;
    }
    initNativeView() {
        super.initNativeView();
    }
    disposeNativeView() {
        super.disposeNativeView();
    }
    onLoaded() {
        super.onLoaded();
        if (this.content.nativeView.getParent() != null) {
            this.content.nativeView.getParent().removeView(this.content.nativeView);
        }
        this._android.addView(this.content.nativeView);
    }
    get _childrenCount() {
        return this.content ? 1 : 0;
    }
    _onContentChanged(oldView, newView) {
    }
    _addChildFromBuilder(name, value) {
        if (value instanceof View) {
            this.content = value;
        }
    }
    eachChildView(callback) {
        const content = this._content;
        if (content) {
            callback(content);
        }
    }
    _adjustInset() {
        let result = null;
        const androidConfig = Utils.android.getApplicationContext()
            .getResources()
            .getConfiguration();
        const isCircleWatch = androidConfig.isScreenRound();
        if (isCircleWatch) {
            result = WearOsLayout.SCALE_FACTOR * Screen.mainScreen.widthPixels;
        }
        return result;
    }
}
WearOsLayout.SCALE_FACTOR = 0.146467;
