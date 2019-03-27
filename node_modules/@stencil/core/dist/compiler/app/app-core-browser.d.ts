import * as d from '../../declarations';
export declare function generateCoreBrowser(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, outputTarget: d.OutputTargetBuild, cmpRegistry: d.ComponentRegistry, staticName: string, globalJsContent: string, buildConditionals: d.BuildConditionals): Promise<string>;
export declare function wrapCoreJs(config: d.Config, jsContent: string, cmpRegistry: d.ComponentRegistry, buildConditionals: d.BuildConditionals): string;
export declare const APP_NAMESPACE_PLACEHOLDER = "__APPNAMESPACE__";
