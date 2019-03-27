import * as d from '../../declarations';
export declare function createAppRegistry(config: d.Config): d.AppRegistry;
export declare function getAppRegistry(config: d.Config, compilerCtx: d.CompilerCtx, outputTarget: d.OutputTargetWww): d.AppRegistry;
export declare function serializeComponentRegistry(cmpRegistry: d.ComponentRegistry): d.AppRegistryComponents;
export declare function writeAppRegistry(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, outputTarget: d.OutputTarget, appRegistry: d.AppRegistry, cmpRegistry: d.ComponentRegistry): Promise<void>;
