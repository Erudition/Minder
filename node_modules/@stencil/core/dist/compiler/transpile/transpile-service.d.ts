import * as d from '../../declarations';
export declare function transpileService(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx): Promise<boolean>;
export declare function isFileIncludePath(config: d.Config, readPath: string): boolean;
