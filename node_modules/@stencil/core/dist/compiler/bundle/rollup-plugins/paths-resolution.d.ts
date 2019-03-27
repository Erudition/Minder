import * as d from '../../../declarations';
import ts from 'typescript';
export default function pathsResolver(config: d.Config, compilerCtx: d.CompilerCtx, tsCompilerOptions: ts.CompilerOptions): {
    name: string;
    resolveId(importee: string, importer: string): string;
};
