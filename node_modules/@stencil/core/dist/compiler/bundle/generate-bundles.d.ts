import * as d from '../../declarations';
export declare function generateBundles(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, entryModules: d.EntryModule[], rawModules: d.DerivedModule[]): Promise<d.ComponentRegistry>;
export declare function injectComponentStyleMode(cmpMeta: d.ComponentMeta, modeName: string, jsText: string, isScopedStyles: boolean): string;
export declare function setBundleModeIds(moduleFiles: d.ModuleFile[], modeName: string, bundleId: string): void;
export declare function getBundleId(config: d.Config, entryModule: d.EntryModule, modeName: string, jsText: string): string;
export declare function getBundleIdHashed(config: d.Config, jsText: string): string;
export declare function getBundleIdDev(entryModule: d.EntryModule, modeName: string): string;
