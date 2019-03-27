import * as d from '../../declarations';
export declare function generateLoader(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, outputTarget: d.OutputTargetBuild, appRegistry: d.AppRegistry, cmpRegistry: d.ComponentRegistry): Promise<string>;
export declare function injectAppIntoLoader(config: d.Config, outputTarget: d.OutputTargetBuild, appCoreFileName: string, appCorePolyfilledFileName: string, hydratedCssClass: string, cmpRegistry: d.ComponentRegistry, loaderContent: string): string;
