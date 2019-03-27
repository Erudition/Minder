import * as d from '../../../declarations';
export default function inMemoryFsRead(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, entryModules?: d.EntryModule[]): {
    name: string;
    resolveId(importee: string, importer: string): Promise<string>;
    load(sourcePath: string): Promise<string>;
};
