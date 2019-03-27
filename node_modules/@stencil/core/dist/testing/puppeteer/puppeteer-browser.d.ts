import * as d from '../../declarations';
import * as puppeteer from 'puppeteer';
export declare function startPuppeteerBrowser(config: d.Config): Promise<any>;
export declare function connectBrowser(): Promise<any>;
export declare function disconnectBrowser(browser: puppeteer.Browser, pages: puppeteer.Page[]): Promise<void>;
export declare function newBrowserPage(browser: puppeteer.Browser): Promise<puppeteer.Page>;
export declare function closePage(page: any): Promise<void>;
