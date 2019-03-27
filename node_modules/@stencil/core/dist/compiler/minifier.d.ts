import * as d from '../declarations';
/**
 * Interal minifier, not exposed publicly.
 */
export declare function minifyJs(config: d.Config, compilerCtx: d.CompilerCtx, diagnostics: d.Diagnostic[], jsText: string, sourceTarget: d.SourceTarget, preamble: boolean, buildTimestamp?: string): Promise<string>;
