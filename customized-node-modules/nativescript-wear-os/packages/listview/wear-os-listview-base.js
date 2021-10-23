import { addWeakEventListener, Builder, CoercibleProperty, CSSType, Label, makeParser, makeValidator, Observable, ObservableArray, PercentLength, Property, removeWeakEventListener, Trace, View } from '@nativescript/core';
export const ITEMLOADING = 'itemLoading';
export const LOADMOREITEMS = 'loadMoreItems';
export const ITEMTAP = 'itemTap';
export const SCROLLEVENT = 'scroll';
export const ITEMSELECTED = 'itemSelected';
export const ITEMSELECTING = 'itemSelecting';
export const ITEMDESELECTED = 'itemDeselected';
export const ITEMDESELECTING = 'itemDeselecting';
export const PULLTOREFRESHINITIATEDEVENT = 'pullToRefreshInitiated';
export var knownTemplates;
(function (knownTemplates) {
    knownTemplates.itemTemplate = 'itemTemplate';
})(knownTemplates || (knownTemplates = {}));
export var knownMultiTemplates;
(function (knownMultiTemplates) {
    knownMultiTemplates.itemTemplates = 'itemTemplates';
})(knownMultiTemplates || (knownMultiTemplates = {}));
export var knownCollections;
(function (knownCollections) {
    knownCollections.items = 'items';
})(knownCollections || (knownCollections = {}));
export const wearOsListViewTraceCategory = 'ns-wear-os-listview';
export function WearOsListViewLog(message) {
    Trace.write(message, wearOsListViewTraceCategory);
}
export function WearOsListViewError(message) {
    Trace.write(message, wearOsListViewTraceCategory, Trace.messageType.error);
}
const autoEffectiveItemHeight = 100;
const autoEffectiveItemWidth = 100;
let WearOsListViewBase = class WearOsListViewBase extends View {
    constructor() {
        super();
        this.pullToRefresh = false;
        this._defaultTemplate = {
            key: 'default',
            createView: () => {
                if (this.itemTemplate) {
                    return Builder.parse(this.itemTemplate, this);
                }
                return undefined;
            }
        };
        this._itemTemplatesInternal = new Array(this._defaultTemplate);
        this._innerWidth = 0;
        this._innerHeight = 0;
        this.itemReorder = false;
        this.selectionBehavior = 'None';
        this.multipleSelection = false;
        this._itemTemplateSelectorBindable = new Label();
        this._itemIdGenerator = (_item, index) => index;
    }
    get itemIdGenerator() {
        return this._itemIdGenerator;
    }
    set itemIdGenerator(generatorFn) {
        this._itemIdGenerator = generatorFn;
    }
    get itemTemplateSelector() {
        return this._itemTemplateSelector;
    }
    set itemTemplateSelector(value) {
        if (typeof value === 'string') {
            this._itemTemplateSelectorBindable.bind({
                sourceProperty: null,
                targetProperty: 'templateKey',
                expression: value
            });
            this._itemTemplateSelector = (item, index, items) => {
                item['$index'] = index;
                this._itemTemplateSelectorBindable.bindingContext = item;
                return this._itemTemplateSelectorBindable.get('templateKey');
            };
        }
        else if (typeof value === 'function') {
            this._itemTemplateSelector = value;
        }
    }
    onLayout(left, top, right, bottom) {
        super.onLayout(left, top, right, bottom);
        this._innerWidth =
            right - left - this.effectivePaddingLeft - this.effectivePaddingRight;
        this._innerHeight =
            bottom - top - this.effectivePaddingTop - this.effectivePaddingBottom;
        this._effectiveItemWidth = PercentLength.toDevicePixels(this.itemWidth, autoEffectiveItemWidth, this._innerWidth);
        this._effectiveItemHeight = PercentLength.toDevicePixels(this.itemHeight, autoEffectiveItemHeight, this._innerHeight);
    }
    _getItemTemplate(index) {
        let templateKey = 'default';
        if (this.itemTemplateSelector) {
            const dataItem = this._getDataItem(index);
            templateKey = this._itemTemplateSelector(dataItem, index, this.items);
        }
        for (let i = 0, length = this._itemTemplatesInternal.length; i < length; i++) {
            if (this._itemTemplatesInternal[i].key === templateKey) {
                return this._itemTemplatesInternal[i];
            }
        }
        return this._itemTemplatesInternal[0];
    }
    _prepareItem(item, index) {
        if (item) {
            item.bindingContext = this._getDataItem(index);
        }
    }
    _getDefaultItemContent(index) {
        const lbl = new Label();
        lbl.bind({
            targetProperty: 'text',
            sourceProperty: '$value'
        });
        return lbl;
    }
    _updateNativeItems(args) {
        this.refresh();
    }
    _getDataItem(index) {
        const thisItems = this.items;
        return thisItems && thisItems.getItem
            ? thisItems.getItem(index)
            : thisItems[index];
    }
};
WearOsListViewBase.knownFunctions = ['itemTemplateSelector', 'itemIdGenerator'];
WearOsListViewBase.itemLoadingEvent = ITEMLOADING;
WearOsListViewBase.itemTapEvent = ITEMTAP;
WearOsListViewBase.loadMoreItemsEvent = LOADMOREITEMS;
WearOsListViewBase.scrollEvent = SCROLLEVENT;
WearOsListViewBase = __decorate([
    CSSType('WearOsListView')
], WearOsListViewBase);
export { WearOsListViewBase };
export var LayoutTypeOptions;
(function (LayoutTypeOptions) {
    LayoutTypeOptions["GRID"] = "grid";
    LayoutTypeOptions["LINEAR"] = "linear";
    LayoutTypeOptions["STAGGERED"] = "staggered";
})(LayoutTypeOptions || (LayoutTypeOptions = {}));
export const itemsProperty = new Property({
    name: 'items',
    valueChanged: (target, oldValue, newValue) => {
        if (oldValue instanceof Observable) {
            removeWeakEventListener(oldValue, ObservableArray.changeEvent, target._updateNativeItems, target);
        }
        if (newValue instanceof Observable) {
            addWeakEventListener(newValue, ObservableArray.changeEvent, target._updateNativeItems, target);
        }
        target.refresh();
    }
});
itemsProperty.register(WearOsListViewBase);
export const itemTemplateProperty = new Property({
    name: 'itemTemplate',
    affectsLayout: true,
    valueChanged: target => {
        target.refresh();
    }
});
itemTemplateProperty.register(WearOsListViewBase);
export const itemTemplatesProperty = new Property({
    name: 'itemTemplates',
    affectsLayout: true,
    valueConverter: value => {
        if (typeof value === 'string') {
            return Builder.parseMultipleTemplates(value);
        }
        return value;
    }
});
itemTemplatesProperty.register(WearOsListViewBase);
export const layoutTypeProperty = new Property({
    name: 'layoutType',
    affectsLayout: true
});
layoutTypeProperty.register(WearOsListViewBase);
export const spanCountProperty = new Property({
    name: 'spanCount',
    defaultValue: 1,
    affectsLayout: true,
    valueConverter: v => parseInt(v, 10)
});
spanCountProperty.register(WearOsListViewBase);
const defaultItemWidth = 'auto';
export const itemWidthProperty = new CoercibleProperty({
    name: 'itemWidth',
    affectsLayout: true,
    defaultValue: { value: 1, unit: '%' },
    equalityComparer: PercentLength.equals,
    valueConverter: PercentLength.parse,
    coerceValue: (target, value) => {
        return target.nativeView ? value : defaultItemWidth;
    },
    valueChanged: (target, oldValue, newValue) => {
        target._itemWidth = newValue;
        target._effectiveItemWidth = PercentLength.toDevicePixels(newValue, autoEffectiveItemWidth, target._innerWidth);
        target.refresh();
    }
});
itemWidthProperty.register(WearOsListViewBase);
const defaultItemHeight = 'auto';
export const itemHeightProperty = new CoercibleProperty({
    name: 'itemHeight',
    affectsLayout: true,
    defaultValue: { value: 0.2, unit: '%' },
    coerceValue: (target, value) => {
        return target.nativeView ? value : defaultItemHeight;
    },
    equalityComparer: PercentLength.equals,
    valueConverter: PercentLength.parse,
    valueChanged: (target, oldValue, newValue) => {
        target._itemHeight = newValue;
        target._effectiveItemHeight = PercentLength.toDevicePixels(newValue, autoEffectiveItemHeight, target._innerHeight);
        target.refresh();
    }
});
itemHeightProperty.register(WearOsListViewBase);
const converter = makeParser(makeValidator('horizontal', 'vertical'));
export const orientationProperty = new Property({
    name: 'orientation',
    defaultValue: 'vertical',
    affectsLayout: true,
    valueChanged: (target, oldValue, newValue) => {
        target.refresh();
    },
    valueConverter: converter
});
orientationProperty.register(WearOsListViewBase);
export const maxProperty = new Property({
    name: 'max',
    affectsLayout: true,
    defaultValue: { value: 1, unit: '%' },
    equalityComparer: PercentLength.equals,
    valueConverter: PercentLength.parse
});
maxProperty.register(WearOsListViewBase);
export const minProperty = new Property({
    name: 'min',
    affectsLayout: true,
    defaultValue: { value: 1 / 3, unit: '%' },
    equalityComparer: PercentLength.equals,
    valueConverter: PercentLength.parse
});
minProperty.register(WearOsListViewBase);
export const hideScrollBarProperty = new Property({
    name: 'hideScrollBar'
});
hideScrollBarProperty.register(WearOsListViewBase);
export const circularScrollingEnabled = new Property({
    name: 'circularScrollingEnabled',
    defaultValue: false
});
circularScrollingEnabled.register(WearOsListViewBase);
export const useScalingScroll = new Property({
    name: 'useScalingScroll',
    defaultValue: false
});
useScalingScroll.register(WearOsListViewBase);
