import * as d from '../declarations';
export declare class TestLogger implements d.Logger {
    private logs;
    buildLogFilePath: string;
    level: string;
    printLogs(): void;
    info(...msgs: any[]): void;
    error(...msgs: any[]): void;
    warn(...msgs: any[]): void;
    debug(): void;
    createTimeSpan(_startMsg: string): {
        finish: () => void;
    };
    printDiagnostics(_diagnostics: d.Diagnostic[]): void;
    green(v: string): string;
    yellow(v: string): string;
    red(v: string): string;
    blue(v: string): string;
    magenta(v: string): string;
    cyan(v: string): string;
    gray(v: string): string;
    bold(v: string): string;
    dim(v: string): string;
    writeLogs(_append: boolean): void;
}
