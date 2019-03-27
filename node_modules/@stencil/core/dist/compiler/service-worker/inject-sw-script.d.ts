import * as d from '../../declarations';
export declare function updateIndexHtmlServiceWorker(config: d.Config, buildCtx: d.BuildCtx, outputTarget: d.OutputTargetWww, indexHtml: string): Promise<string>;
export declare function injectRegisterServiceWorker(config: d.Config, buildCtx: d.BuildCtx, outputTarget: d.OutputTargetWww, indexHtml: string): Promise<string>;
export declare function injectUnregisterServiceWorker(indexHtml: string): string;
