import * as d from '../../declarations';
export declare function generateEsmCores(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, outputTarget: d.OutputTargetBuild, entryModules: d.EntryModule[]): Promise<void>;
export declare function generateEsmCore(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, outputTarget: d.OutputTargetDist, entryModules: d.EntryModule[], sourceTarget: d.SourceTarget, coreId: d.BuildCoreIds): Promise<void>;
