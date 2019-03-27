import { MockElement } from './node';
export declare class MockEvent {
    bubbles: boolean;
    cancelBubble: boolean;
    cancelable: boolean;
    composed: boolean;
    currentTarget: MockElement;
    defaultPrevented: boolean;
    srcElement: MockElement;
    target: MockElement;
    timeStamp: number;
    type: string;
    constructor(type: string, eventInitDict?: any);
    preventDefault(): void;
    stopPropagation(): void;
    stopImmediatePropagation(): void;
}
export declare class MockCustomEvent extends MockEvent {
    detail: any;
    constructor(type: string, eventInitDict?: any);
}
export declare class MockEventListener {
    type: string;
    handler: (ev?: any) => void;
    constructor(type: string, handler: any);
}
export declare function addEventListener(elm: any, type: string, handler: any): void;
export declare function removeEventListener(elm: any, type: string, handler: any): void;
export declare function dispatchEvent(currentTarget: any, ev: MockEvent): boolean;
export interface EventTarget {
    _listeners: MockEventListener[];
}
