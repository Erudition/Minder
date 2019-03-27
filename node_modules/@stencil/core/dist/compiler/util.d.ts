import * as d from '../declarations';
export declare function hasServiceWorkerChanges(config: d.Config, buildCtx: d.BuildCtx): boolean;
/**
 * Test if a file is a typescript source file, such as .ts or .tsx.
 * However, d.ts files and spec.ts files return false.
 * @param filePath
 */
export declare function isTsFile(filePath: string): boolean;
export declare function isDtsFile(filePath: string): boolean;
export declare function isJsFile(filePath: string): boolean;
export declare function hasFileExtension(filePath: string, extensions: string[]): boolean;
export declare function isCssFile(filePath: string): boolean;
export declare function isHtmlFile(filePath: string): boolean;
/**
 * Only web development text files, like ts, tsx,
 * js, html, css, scss, etc.
 * @param filePath
 */
export declare function isWebDevFile(filePath: string): boolean;
export declare function generatePreamble(config: d.Config, opts?: {
    prefix?: string;
    suffix?: string;
    defaultBanner?: boolean;
}): string;
export declare function buildError(diagnostics: d.Diagnostic[]): d.Diagnostic;
export declare function buildWarn(diagnostics: d.Diagnostic[]): d.Diagnostic;
export declare function catchError(diagnostics: d.Diagnostic[], err: Error, msg?: string): void;
export declare const TASK_CANCELED_MSG = "task canceled";
export declare function shouldIgnoreError(msg: any): boolean;
export declare function hasError(diagnostics: d.Diagnostic[]): boolean;
export declare function hasWarning(diagnostics: d.Diagnostic[]): boolean;
export declare function pathJoin(config: d.Config, ...paths: string[]): string;
export declare function normalizePath(str: string): string;
export declare function isDocsPublic(jsDocs: d.JsDoc | undefined): boolean;
