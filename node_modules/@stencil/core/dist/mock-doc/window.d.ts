import { MockEvent } from './event';
import { MockHistory } from './history';
import { MockLocation } from './location';
import { MockNavigator } from './navigator';
import { MockStorage } from './storage';
export declare class MockWindow {
    addEventListener(type: string, handler: (ev?: any) => void): void;
    private _customElements;
    customElements: any;
    dispatchEvent(ev: MockEvent): boolean;
    private _document;
    document: Document;
    fetch(): Promise<void>;
    private _history;
    history: MockHistory;
    private _localStorage;
    localStorage: MockStorage;
    private _location;
    location: MockLocation;
    matchMedia(): {
        matches: boolean;
    };
    private _navigator;
    navigator: MockNavigator;
    private _performance;
    performance: any;
    private _parent;
    parent: any;
    removeEventListener(type: string, handler: any): void;
    requestAnimationFrame(cb: (timestamp: number) => void): void;
    readonly self: this;
    private _sessionStorage;
    sessionStorage: any;
    readonly top: this;
    readonly window: this;
    static readonly CSS: {
        supports: () => boolean;
    };
    private _MockEvent;
    Event: any;
    private _MockCustomEvent;
    CustomEvent: any;
    getComputedStyle(_: any): any;
}
