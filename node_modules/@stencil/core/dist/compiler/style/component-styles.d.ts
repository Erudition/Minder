import * as d from '../../declarations';
import { ENCAPSULATION } from '../../util/constants';
export declare function generateComponentStylesMode(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, moduleFile: d.ModuleFile, styleMeta: d.StyleMeta, modeName: string): Promise<void>;
export declare function escapeCssForJs(style: string): string;
export declare function requiresScopedStyles(encapsulation: ENCAPSULATION, config: d.Config): boolean;
export declare const PLUGIN_HELPERS: {
    pluginName: string;
    pluginId: string;
    pluginExts: string[];
}[];
