import * as d from '../../declarations';
export declare function minifyInlineScripts(config: d.Config, compilerCtx: d.CompilerCtx, doc: Document, diagnostics: d.Diagnostic[]): Promise<void>;
export declare function canMinifyInlineScript(script: HTMLScriptElement): boolean;
export declare function minifyInlineScript(config: d.Config, compilerCtx: d.CompilerCtx, diagnostics: d.Diagnostic[], script: HTMLScriptElement): Promise<void>;
export declare function minifyInlineStyles(config: d.Config, compilerCtx: d.CompilerCtx, doc: Document, diagnostics: d.Diagnostic[]): Promise<void>;
export declare function canMinifyInlineStyle(style: HTMLStyleElement): boolean;
