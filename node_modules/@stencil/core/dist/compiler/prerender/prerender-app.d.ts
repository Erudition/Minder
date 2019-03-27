import * as d from '../../declarations';
export declare function prerenderOutputTargets(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, entryModules: d.EntryModule[]): Promise<void>;
export declare function shouldPrerender(config: d.Config): boolean;
/**
 * shouldPrerenderExternal
 * @description Checks if the cli flag has been set that a external prerenderer will be used
 * @param config build config
 */
export declare function shouldPrerenderExternal(config: d.Config): boolean;
