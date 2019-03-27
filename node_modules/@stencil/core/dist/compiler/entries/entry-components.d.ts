import * as d from '../../declarations';
export declare function generateComponentEntries(_config: d.Config, buildCtx: d.BuildCtx, allModules: d.ModuleFile[], userConfigEntryTags: string[][], appEntryTags: string[]): d.EntryPoint[];
export declare function processAppComponentEntryTags(buildCtx: d.BuildCtx, allModules: d.ModuleFile[], entryPoints: d.EntryPoint[], appEntryTags: string[]): d.EntryComponent[][];
export declare function processUserConfigBundles(userConfigEntryTags: string[][]): d.EntryComponent[][];
