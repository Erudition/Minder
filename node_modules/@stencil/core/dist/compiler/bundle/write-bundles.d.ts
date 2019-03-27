import * as d from '../../declarations';
import { RollupBuild } from 'rollup';
import { EntryModule } from '../../declarations';
export declare function writeEntryModules(config: d.Config, compilerCtx: d.CompilerCtx, entryModules: EntryModule[]): Promise<void>;
export declare function writeEsmModules(config: d.Config, rollupBundle: RollupBuild): Promise<d.JSModuleList>;
export declare function writeAmdModules(config: d.Config, rollupBundle: RollupBuild, entryModules: d.EntryModule[]): Promise<d.JSModuleList>;
