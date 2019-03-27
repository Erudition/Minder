import * as d from '../../declarations';
export declare function buildCoreContent(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, coreBuild: d.BuildConditionals, coreContent: string): Promise<string>;
export declare function minifyCore(config: d.Config, compilerCtx: d.CompilerCtx, sourceTarget: d.SourceTarget, input: string): Promise<{
    output: string;
    sourceMap?: any;
    diagnostics?: d.Diagnostic[];
}>;
