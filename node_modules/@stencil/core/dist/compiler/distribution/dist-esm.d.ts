import * as d from '../../declarations';
export declare function generateEsmIndexes(config: d.Config, compilerCtx: d.CompilerCtx, outputTarget: d.OutputTargetDist): Promise<void>;
export declare function generateEsmHosts(config: d.Config, compilerCtx: d.CompilerCtx, cmpRegistry: d.ComponentRegistry, outputTarget: d.OutputTarget): Promise<void>;
export declare function generateEsmHost(config: d.Config, compilerCtx: d.CompilerCtx, outputTarget: d.OutputTargetDist, sourceTarget: d.SourceTarget, esmImports: EsmImport[]): Promise<void>;
interface EsmImport {
    name: string;
    data: any;
}
export {};
