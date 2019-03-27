import * as d from '../../../declarations';
import ts from 'typescript';
export declare function getMethodDecoratorMeta(config: d.Config, diagnostics: d.Diagnostic[], checker: ts.TypeChecker, classNode: ts.ClassDeclaration, sourceFile: ts.SourceFile, componentClass: string): d.MembersMeta;
