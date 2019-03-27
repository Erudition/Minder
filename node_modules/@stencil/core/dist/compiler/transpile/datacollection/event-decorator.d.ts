import * as d from '../../../declarations';
import ts from 'typescript';
export declare function getEventDecoratorMeta(diagnostics: d.Diagnostic[], checker: ts.TypeChecker, classNode: ts.ClassDeclaration, sourceFile: ts.SourceFile): d.EventMeta[];
export declare function convertOptionsToMeta(diagnostics: d.Diagnostic[], rawEventOpts: d.EventOptions, memberName: string): d.EventMeta;
export declare function getEventName(diagnostics: d.Diagnostic[], rawEventOpts: d.EventOptions, memberName: string): string;
export declare function validateEventEmitterMemeberName(diagnostics: d.Diagnostic[], memberName: string): void;
