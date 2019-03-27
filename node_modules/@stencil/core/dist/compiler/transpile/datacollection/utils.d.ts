import * as d from '../../../declarations';
import ts from 'typescript';
export declare function evalText(text: string): any;
export interface GetDeclarationParameters {
    <T>(decorator: ts.Decorator): [T];
    <T, T1>(decorator: ts.Decorator): [T, T1];
    <T, T1, T2>(decorator: ts.Decorator): [T, T1, T2];
}
export declare const getDeclarationParameters: GetDeclarationParameters;
export declare function isDecoratorNamed(name: string): (dec: ts.Decorator) => boolean;
export declare function isPropertyWithDecorators(member: ts.ClassElement): boolean;
export declare function isMethodWithDecorators(member: ts.ClassElement): boolean;
export declare function serializeSymbol(checker: ts.TypeChecker, symbol: ts.Symbol): d.JsDoc;
export declare function serializeDocsSymbol(checker: ts.TypeChecker, symbol: ts.Symbol): string;
export declare function typeToString(checker: ts.TypeChecker, type: ts.Type): string;
export declare function parseDocsType(checker: ts.TypeChecker, type: ts.Type, parts: Set<string>): void;
export declare function isMethod(member: ts.ClassElement, methodName: string): boolean;
export declare function getAttributeTypeInfo(baseNode: ts.Node, sourceFile: ts.SourceFile): d.AttributeTypeReferences;
