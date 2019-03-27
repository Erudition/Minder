import * as d from '../../declarations';
export declare function inlineLoaderScript(config: d.Config, compilerCtx: d.CompilerCtx, outputTarget: d.OutputTargetHydrate, windowLocationPath: string, doc: Document): Promise<void>;
export declare function isLoaderScriptSrc(loaderFileName: string, scriptSrc: string): boolean;
export declare function setDataResourcesUrlAttr(config: d.Config, outputTarget: d.OutputTargetHydrate): string;
