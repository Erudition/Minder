import { CompilerCtx, Config } from '../../../declarations';
export default function localResolution(config: Config, compilerCtx: CompilerCtx): {
    name: string;
    resolveId(importee: string, importer: string): Promise<string>;
};
