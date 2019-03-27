import * as d from '../../declarations';
export declare function createJestPuppeteerEnvironment(): {
    new (config: any): {
        global: d.JestEnvironmentGlobal;
        browser: any;
        pages: any[];
        setup(): Promise<void>;
        newPuppeteerPage(): Promise<import("puppeteer").Page>;
        teardown(): Promise<void>;
    };
};
