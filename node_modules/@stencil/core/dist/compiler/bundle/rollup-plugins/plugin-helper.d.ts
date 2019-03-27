import * as d from '../../../declarations';
export default function rollupPluginHelper(config: d.Config, compilerCtx: d.CompilerCtx, builtCtx: d.BuildCtx): {
    name: string;
    resolveId(importee: string, importer: string): Promise<string>;
};
