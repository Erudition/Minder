import * as d from '../../declarations';
import * as pd from './puppeteer-declarations';
import * as puppeteer from 'puppeteer';
export declare function initPageEvents(page: pd.E2EPageInternal): Promise<void>;
export declare class EventSpy implements d.EventSpy {
    eventName: string;
    events: d.SerializedEvent[];
    constructor(eventName: string);
    readonly length: number;
    readonly firstEvent: d.SerializedEvent;
    readonly lastEvent: d.SerializedEvent;
}
export declare function addE2EListener(page: pd.E2EPageInternal, elmHandle: puppeteer.JSHandle, eventName: string, resolve: (ev: any) => void, cancelRejectId?: any): Promise<void>;
