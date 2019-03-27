import * as d from '../../declarations';
export declare function getComponentStylesCache(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, moduleFile: d.ModuleFile, styleMeta: d.StyleMeta, modeName: string): Promise<d.StyleMeta>;
export declare function isChangedStyleEntryFile(buildCtx: d.BuildCtx, styleMeta: d.StyleMeta): boolean;
export declare function setComponentStylesCache(compilerCtx: d.CompilerCtx, moduleFile: d.ModuleFile, modeName: string, styleMeta: d.StyleMeta): void;
