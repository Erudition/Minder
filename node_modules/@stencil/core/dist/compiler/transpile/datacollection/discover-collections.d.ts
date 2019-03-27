import * as d from '../../../declarations';
import ts from 'typescript';
export declare function getCollections(config: d.Config, compilerCtx: d.CompilerCtx, collections: d.Collection[], moduleFile: d.ModuleFile, importNode: ts.ImportDeclaration): void;
export declare function addCollection(config: d.Config, compilerCtx: d.CompilerCtx, collections: d.Collection[], moduleFile: d.ModuleFile, resolveFromDir: string, moduleId: string): void;
