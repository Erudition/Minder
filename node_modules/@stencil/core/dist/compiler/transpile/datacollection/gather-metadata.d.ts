import * as d from '../../../declarations';
import ts from 'typescript';
export declare function gatherMetadata(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, typeChecker: ts.TypeChecker): ts.TransformerFactory<ts.SourceFile>;
export declare function visitClass(config: d.Config, diagnostics: d.Diagnostic[], typeChecker: ts.TypeChecker, classNode: ts.ClassDeclaration, sourceFile: ts.SourceFile): d.ComponentMeta | undefined;
