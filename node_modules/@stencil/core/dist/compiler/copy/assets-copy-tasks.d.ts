import * as d from '../../declarations';
export declare function getComponentAssetsCopyTasks(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, entryModules: d.EntryModule[], filesChanged: string[]): d.CopyTask[];
export declare function canSkipAssetsCopy(config: d.Config, compilerCtx: d.CompilerCtx, entryModules: d.EntryModule[], filesChanged: string[]): boolean;
