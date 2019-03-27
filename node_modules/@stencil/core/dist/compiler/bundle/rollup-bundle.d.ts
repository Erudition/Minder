import * as d from '../../declarations';
import { RollupBuild } from 'rollup';
export declare function createBundle(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, entryModules: d.EntryModule[]): Promise<RollupBuild>;
