import * as d from '../declarations';
export declare class Renderer {
    config: d.Config;
    private ctx;
    private outputTarget;
    private cmpRegistry;
    constructor(config: d.Config, registry?: d.ComponentRegistry, ctx?: d.CompilerCtx, outputTarget?: d.OutputTargetWww);
    hydrate(hydrateOpts: d.HydrateOptions): Promise<d.HydrateResults>;
    readonly fs: d.InMemoryFileSystem;
    destroy(): void;
}
