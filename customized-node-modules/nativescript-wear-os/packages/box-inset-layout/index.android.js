import { ContentView, View } from '@nativescript/core';
export class BoxInsetLayout extends ContentView {
    constructor() {
        super();
    }
    createNativeView() {
        this._android = new androidx.wear.widget.BoxInsetLayout(this._context);
        this._holder = new android.widget.LinearLayout(this._context);
        if (!this._androidViewId) {
            this._androidViewId = android.view.View.generateViewId();
        }
        this._android.setId(this._androidViewId);
        this._holder.setOrientation(android.widget.LinearLayout.VERTICAL);
        this._holder.setGravity(android.view.Gravity.FILL_VERTICAL);
        this._holder.setLayoutParams(new androidx.wear.widget.BoxInsetLayout.LayoutParams(android.view.ViewGroup.LayoutParams.FILL_PARENT, android.view.ViewGroup.LayoutParams.FILL_PARENT, android.view.Gravity.FILL_VERTICAL, 15));
        this._android.addView(this._holder);
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
        if (this._content.nativeView.getParent() != null) {
            this._content.nativeView.getParent().removeView(this._content.nativeView);
        }
        this._holder.addView(this._content.nativeView);
    }
    get _childrenCount() {
        return this._content ? 1 : 0;
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
}
