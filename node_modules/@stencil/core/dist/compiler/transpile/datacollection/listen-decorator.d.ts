import * as d from '../../../declarations';
import ts from 'typescript';
export declare function getListenDecoratorMeta(checker: ts.TypeChecker, classNode: ts.ClassDeclaration): d.ListenMeta[];
export declare function validateListener(eventName: string, rawListenOpts: d.ListenOptions, methodName: string): d.ListenMeta | null;
export declare function isValidElementRefPrefix(prefix: string): boolean;
export declare function isValidKeycodeSuffix(prefix: string): boolean;
