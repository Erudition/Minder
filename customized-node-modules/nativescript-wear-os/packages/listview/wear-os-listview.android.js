import { Observable, ProxyViewContainer, StackLayout, Utils, View } from '@nativescript/core';
import { ITEMDESELECTED, itemHeightProperty, ITEMLOADING, ITEMSELECTED, ITEMTAP, itemTemplatesProperty, itemWidthProperty, LayoutTypeOptions, WearOsListViewBase } from './wear-os-listview-base';
export class WearOsListView extends WearOsListViewBase {
    constructor() {
        super();
        this.circularScrollingEnabled = false;
        this.useScalingScroll = false;
        this._realizedItems = new Map();
        this._androidViewId = -1;
    }
    createNativeView() {
        this._itemsSelected = [];
        this._staggeredMap = new Map();
        this._random = new java.util.Random();
        this.listView = new TNS_WearableRecyclerView(this._context, new WeakRef(this));
        return this.listView;
    }
    initNativeView() {
        super.initNativeView();
        const that = new WeakRef(this);
        this.nativeViewProtected.setEnabled(false);
        if (this._androidViewId < 0) {
            this._androidViewId = android.view.View.generateViewId();
        }
        this.nativeViewProtected.setId(this._androidViewId);
        this.listView.setEdgeItemsCenteringEnabled(true);
        const adapter = new TNS_WearOsListViewAdapter(new WeakRef(this));
        adapter.owner = that;
        adapter.setHasStableIds(true);
        this.listView.setAdapter(adapter);
        this.listView.adapter = adapter;
        const androidConfig = Utils.android.getApplicationContext()
            .getResources()
            .getConfiguration();
        const isCircleWatch = androidConfig.isScreenRound();
        if (isCircleWatch === true && this.useScalingScroll) {
            const customScrollingLayoutCallback = new TNS_CustomScrollingLayoutCallback();
            this.listView.setLayoutManager(new androidx.wear.widget.WearableLinearLayoutManager(this._context, customScrollingLayoutCallback));
        }
        else {
            this.listView.setLayoutManager(new androidx.wear.widget.WearableLinearLayoutManager(this._context));
        }
        if (this.circularScrollingEnabled === true) {
            this.listView.setCircularScrollingGestureEnabled(true);
        }
        const params = new androidx.recyclerview.widget.RecyclerView.LayoutParams(-1, -1);
        itemWidthProperty.coerce(this);
        itemHeightProperty.coerce(this);
    }
    disposeNativeView() {
        const nativeView = this.nativeViewProtected;
        nativeView.setAdapter(null);
        this.eachChildView(view => {
            if (view && view.parent) {
                view.parent._removeView(view);
            }
            return true;
        });
        nativeView.adapter.owner = null;
        this._clearRealizedCells();
        super.disposeNativeView();
    }
    onLoaded() {
        super.onLoaded();
        this.requestLayout();
    }
    onLayout(left, top, right, bottom) {
        super.onLayout(left, top, right, bottom);
        this.refresh();
    }
    refresh() {
        const nativeView = this.listView;
        if (!nativeView || !nativeView.getAdapter()) {
            return;
        }
        this._realizedItems.forEach((view, nativeView) => {
            if (!(view.bindingContext instanceof Observable)) {
                view.bindingContext = null;
            }
        });
        nativeView.getAdapter().notifyDataSetChanged();
    }
    scrollToIndex(index) {
        const nativeView = this.nativeViewProtected;
        if (nativeView) {
            nativeView.setSelection(index);
        }
    }
    scrollToIndexAnimated(index) {
        const nativeView = this.nativeViewProtected;
        if (nativeView) {
            nativeView.smoothScrollToPosition(index);
        }
    }
    get _childrenCount() {
        return this._realizedItems.size;
    }
    eachChildView(callback) {
        this._realizedItems.forEach((view, nativeView) => {
            if (view.parent instanceof WearOsListView) {
                callback(view);
            }
            else {
                if (view.parent) {
                    callback(view.parent);
                }
            }
        });
    }
    _clearRealizedCells() {
        this._realizedItems.forEach((view, nativeView) => {
            if (view.parent) {
                if (!(view.parent instanceof WearOsListView)) {
                    this._removeView(view.parent);
                }
                view.parent._removeView(view);
            }
        });
        this._realizedItems.clear();
        this._staggeredMap.clear();
    }
    [itemTemplatesProperty.getDefault]() {
        return null;
    }
    [itemTemplatesProperty.setNative](value) {
        this._itemTemplatesInternal = new Array(this._defaultTemplate);
        if (value) {
            this._itemTemplatesInternal = this._itemTemplatesInternal.concat(value);
        }
        this.listView.setAdapter(new TNS_WearOsListViewAdapter(new WeakRef(this)));
        this.refresh();
    }
}
WearOsListView.itemLoadingEvent = ITEMLOADING;
WearOsListView.itemTapEvent = ITEMTAP;
var TNS_CustomScrollingLayoutCallback = /** @class */ (function (_super) {
    __extends(TNS_CustomScrollingLayoutCallback, _super);
    function TNS_CustomScrollingLayoutCallback() {
        return _super.call(this) || this;
    }
    TNS_CustomScrollingLayoutCallback.prototype.onLayoutFinished = function (child, parent) {
        // Figure out % progress from top to bottom
        var centerOffset = child.getHeight() / 2.0 / parent.getHeight();
        var yRelativeToCenterOffset = child.getY() / parent.getHeight() + centerOffset;
        var progresstoCenter = Math.sin(yRelativeToCenterOffset * Math.PI);
        // Normalize for center
        var mProgressToCenter = Math.abs(0.5 - yRelativeToCenterOffset);
        // Adjust to the maximum scale
        mProgressToCenter = Math.min(mProgressToCenter, TNS_CustomScrollingLayoutCallback.MAX_ICON_PROGRESS);
        // scale the items
        child.setScaleX(1 - mProgressToCenter);
        child.setScaleY(1 - mProgressToCenter);
        child.setX(+(1 - progresstoCenter) * 100);
    };
    /** How much should we scale the icon at most. */
    TNS_CustomScrollingLayoutCallback.MAX_ICON_PROGRESS = 2;
    return TNS_CustomScrollingLayoutCallback;
}(androidx.wear.widget
    .WearableLinearLayoutManager.LayoutCallback));
var TNS_WearOsListViewAdapter = /** @class */ (function (_super) {
    __extends(TNS_WearOsListViewAdapter, _super);
    function TNS_WearOsListViewAdapter(owner) {
        var _this = _super.call(this) || this;
        _this.owner = owner;
        return global.__native(_this);
    }
    TNS_WearOsListViewAdapter.prototype.onCreateViewHolder = function (parent, viewType) {
        var owner = this.owner ? this.owner.get() : null;
        if (!owner) {
            return null;
        }
        var template = owner._itemTemplatesInternal[viewType];
        var view = template.createView();
        if (view instanceof View && !(view instanceof ProxyViewContainer)) {
            owner._addView(view);
        }
        else {
            var sp = new StackLayout();
            sp.addChild(view || owner._getDefaultItemContent(viewType));
            owner._addView(sp);
            view = sp;
        }
        owner._realizedItems.set(view.nativeView, view);
        return new TNS_WearOsListViewHolder(new WeakRef(view), new WeakRef(owner));
    };
    TNS_WearOsListViewAdapter.prototype.onBindViewHolder = function (holder, index) {
        var owner = this.owner ? this.owner.get() : null;
        if (owner) {
            var view = holder.view;
            var args = {
                eventName: ITEMLOADING,
                object: owner,
                android: holder,
                ios: undefined,
                index: index,
                view: view
            };
            owner.notify(args);
            if (args.view !== view) {
                view = args.view;
                // the view has been changed on the event handler
                // (holder.view as StackLayout).removeChildren();
                holder.view.removeChildren();
                holder.view.addChild(args.view);
                // holder["defaultItemView"] = false;
            }
            if (owner.layoutType === LayoutTypeOptions.STAGGERED) {
                var random = void 0;
                var max = Utils.layout.toDeviceIndependentPixels(owner._effectiveItemHeight);
                var min = Utils.layout.toDeviceIndependentPixels(owner._effectiveItemHeight) *
                    (1 / 3);
                if (min && max) {
                    if (owner._staggeredMap && owner._staggeredMap.has(index)) {
                        random = owner._staggeredMap.get(index);
                    }
                    else {
                        random =
                            owner._random.nextInt(max - min + min) +
                                min;
                        if (!owner._staggeredMap) {
                            owner._staggeredMap = new Map();
                        }
                        owner._staggeredMap.set(index, random);
                    }
                    view.height = random;
                }
            }
            else {
                if (owner._itemHeight) {
                    view.height = Utils.layout.toDeviceIndependentPixels(owner._effectiveItemHeight);
                }
                if (owner._itemWidth) {
                    view.width = Utils.layout.toDeviceIndependentPixels(owner._effectiveItemWidth);
                }
            }
            owner._prepareItem(view, index);
        }
    };
    TNS_WearOsListViewAdapter.prototype.getItemId = function (i) {
        var owner = this.owner ? this.owner.get() : null;
        var id = i;
        if (owner && owner.items) {
            var item = owner.items.getItem
                ? owner.items.getItem(i)
                : owner.items[i];
            if (item) {
                id = owner.itemIdGenerator(item, i, owner.items);
            }
        }
        return long(id);
    };
    TNS_WearOsListViewAdapter.prototype.getItemCount = function () {
        var owner = this.owner ? this.owner.get() : null;
        return owner && owner.items && owner.items.length ? owner.items.length : 0;
    };
    TNS_WearOsListViewAdapter.prototype.getItemViewType = function (index) {
        var owner = this.owner ? this.owner.get() : null;
        if (owner) {
            var template = owner._getItemTemplate(index);
            return owner._itemTemplatesInternal.indexOf(template);
        }
        return 0;
    };
    return TNS_WearOsListViewAdapter;
}(androidx.recyclerview.widget
    .RecyclerView.Adapter));
var TNS_WearOsListViewHolder = /** @class */ (function (_super) {
    __extends(TNS_WearOsListViewHolder, _super);
    function TNS_WearOsListViewHolder(owner, list) {
        var _this = _super.call(this, owner.get().nativeViewProtected) || this;
        _this.owner = owner;
        _this.list = list;
        _this._selected = false;
        var that = global.__native(_this);
        owner.get().nativeViewProtected.setOnClickListener(that);
        owner.get().nativeViewProtected.setOnLongClickListener(that);
        return that;
    }
    TNS_WearOsListViewHolder.prototype.isSelected = function () {
        return this._selected;
    };
    TNS_WearOsListViewHolder.prototype.setIsSelected = function (selected) {
        this._selected = selected;
    };
    Object.defineProperty(TNS_WearOsListViewHolder.prototype, "view", {
        get: function () {
            return this.owner ? this.owner.get() : null;
        },
        enumerable: true,
        configurable: true
    });
    TNS_WearOsListViewHolder.prototype.onClick = function (v) {
        var listView = this.list.get();
        var index = this.getAdapterPosition();
        listView.notify({
            eventName: ITEMTAP,
            object: listView,
            index: index,
            view: this.view,
            android: v,
            ios: undefined
        });
        if (listView.selectionBehavior !== 'Press')
            return;
        var items = listView.items;
        var item = items.getItem ? items.getItem(index) : items[index];
        if (listView.multipleSelection) {
            if (this.isSelected()) {
                listView._itemsSelected = listView._itemsSelected.filter(function (selected) {
                    if (selected !== item) {
                        return selected;
                    }
                });
                this.setIsSelected(false);
                listView.notify({
                    eventName: ITEMDESELECTED,
                    object: listView,
                    index: index,
                    view: this.view,
                    android: v,
                    ios: undefined
                });
            }
            else {
                this.setIsSelected(true);
                listView._itemsSelected.push(item);
                listView.notify({
                    eventName: ITEMSELECTED,
                    object: listView,
                    index: index,
                    view: this.view,
                    android: v,
                    ios: undefined
                });
            }
        }
        else {
            if (this.isSelected()) {
                listView._itemsSelected.pop();
                this.setIsSelected(false);
                listView.notify({
                    eventName: ITEMDESELECTED,
                    object: listView,
                    index: index,
                    view: this.view,
                    android: v,
                    ios: undefined
                });
            }
            else {
                this.setIsSelected(true);
                listView._itemsSelected.push(item);
                listView.notify({
                    eventName: ITEMSELECTED,
                    object: listView,
                    index: index,
                    view: this.view,
                    android: v,
                    ios: undefined
                });
            }
        }
    };
    TNS_WearOsListViewHolder.prototype.onLongClick = function (v) {
        var listView = this.list.get();
        var index = this.getAdapterPosition();
        if (listView.selectionBehavior === 'LongPress') {
            var items = listView.items;
            var item_1 = items.getItem ? items.getItem(index) : items[index];
            if (listView.multipleSelection) {
                if (this.isSelected()) {
                    listView._itemsSelected = listView._itemsSelected.filter(function (selected) {
                        if (selected !== item_1) {
                            return selected;
                        }
                    });
                    this.setIsSelected(false);
                    listView.notify({
                        eventName: ITEMDESELECTED,
                        object: listView,
                        index: index,
                        view: this.view,
                        android: v,
                        ios: undefined
                    });
                }
                else {
                    this.setIsSelected(true);
                    listView._itemsSelected.push(item_1);
                    listView.notify({
                        eventName: ITEMSELECTED,
                        object: listView,
                        index: index,
                        view: this.view,
                        android: v,
                        ios: undefined
                    });
                }
            }
            else {
                if (this.isSelected()) {
                    listView._itemsSelected.pop();
                    this.setIsSelected(false);
                    listView.notify({
                        eventName: ITEMDESELECTED,
                        object: listView,
                        index: index,
                        view: this.view,
                        android: v,
                        ios: undefined
                    });
                }
                else {
                    this.setIsSelected(true);
                    listView._itemsSelected.push(item_1);
                    listView.notify({
                        eventName: ITEMSELECTED,
                        object: listView,
                        index: index,
                        view: this.view,
                        android: v,
                        ios: undefined
                    });
                }
            }
        }
        return true;
    };
    TNS_WearOsListViewHolder = __decorate([
        Interfaces([
            android.view.View.OnClickListener,
            android.view.View.OnLongClickListener
        ])
    ], TNS_WearOsListViewHolder);
    return TNS_WearOsListViewHolder;
}(androidx.recyclerview.widget.RecyclerView
    .ViewHolder));
var TNS_WearableRecyclerView = /** @class */ (function (_super) {
    __extends(TNS_WearableRecyclerView, _super);
    function TNS_WearableRecyclerView(context, owner) {
        var _this = _super.call(this, context) || this;
        _this.owner = owner;
        return global.__native(_this);
    }
    TNS_WearableRecyclerView.prototype.onLayout = function (changed, l, t, r, b) {
        if (changed) {
            var owner = this.owner.get();
            owner.onLayout(l, t, r, b);
        }
        // @ts-ignore
        _super.prototype.onLayout.call(this, changed, l, t, r, b);
    };
    return TNS_WearableRecyclerView;
}(androidx.wear.widget
    .WearableRecyclerView));
