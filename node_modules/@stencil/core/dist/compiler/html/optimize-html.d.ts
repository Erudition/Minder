import * as d from '../../declarations';
export declare function optimizeHtml(config: d.Config, compilerCtx: d.CompilerCtx, hydrateTarget: d.OutputTargetHydrate, windowLocationPath: string, doc: Document, diagnostics: d.Diagnostic[]): Promise<void>;
export declare function optimizeIndexHtml(config: d.Config, compilerCtx: d.CompilerCtx, hydrateTarget: d.OutputTargetHydrate, windowLocationPath: string, diagnostics: d.Diagnostic[]): Promise<void>;
