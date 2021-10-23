import { ContentView, View } from '@nativescript/core';
export class SwipeDismissLayout extends ContentView {
    constructor() {
        super();
    }
    get swipeable() {
        return this._android.isSwipeable();
    }
    set swipeable(value) {
        this._android.setSwipeable(value);
    }
    createNativeView() {
        this._android = new androidx.wear.widget.SwipeDismissFrameLayout(this._context);
        this._holder = new android.widget.LinearLayout(this._context);
        if (!this._androidViewId) {
            this._androidViewId = android.view.View.generateViewId();
        }
        this._android.setId(this._androidViewId);
        this._holder.setOrientation(android.widget.LinearLayout.VERTICAL);
        this._holder.setGravity(android.view.Gravity.FILL_VERTICAL);
        this._holder.setLayoutParams(new android.view.ViewGroup.LayoutParams(android.view.ViewGroup.LayoutParams.FILL_PARENT, android.view.ViewGroup.LayoutParams.FILL_PARENT));
        this._android.addView(this._holder);
        return this._android;
    }
    initNativeView() {
        super.initNativeView();
        this._callback = new TNS_SwipeDismissFrameLayoutCallback(new WeakRef(this));
        this._android.addCallback(this._callback);
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
SwipeDismissLayout.dimissedEvent = 'dismissed';
SwipeDismissLayout.swipeCanceledEvent = 'swipeCanceled';
SwipeDismissLayout.swipeStartedEvent = 'swipeStarted';
var TNS_SwipeDismissFrameLayoutCallback = /** @class */ (function (_super) {
    __extends(TNS_SwipeDismissFrameLayoutCallback, _super);
    function TNS_SwipeDismissFrameLayoutCallback(owner) {
        var _this = _super.call(this) || this;
        _this.owner = owner;
        return global.__native(_this);
    }
    TNS_SwipeDismissFrameLayoutCallback.prototype.onDismissed = function (layout) {
        var owner = this.owner && this.owner.get();
        if (owner) {
            owner.notify({
                eventName: SwipeDismissLayout.dimissedEvent,
                object: owner
            });
        }
    };
    TNS_SwipeDismissFrameLayoutCallback.prototype.onSwipeCanceled = function (layout) {
        var owner = this.owner && this.owner.get();
        if (owner) {
            owner.notify({
                eventName: SwipeDismissLayout.swipeCanceledEvent,
                object: owner
            });
        }
    };
    TNS_SwipeDismissFrameLayoutCallback.prototype.onSwipeStarted = function (layout) {
        var owner = this.owner && this.owner.get();
        if (owner) {
            owner.notify({
                eventName: SwipeDismissLayout.swipeStartedEvent,
                object: owner
            });
        }
    };
    return TNS_SwipeDismissFrameLayoutCallback;
}(androidx.wear.widget
    .SwipeDismissFrameLayout.Callback));
