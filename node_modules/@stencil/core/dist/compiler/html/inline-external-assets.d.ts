import * as d from '../../declarations';
export declare function inlineExternalAssets(config: d.Config, compilerCtx: d.CompilerCtx, outputTarget: d.OutputTargetHydrate, windowLocationPath: string, doc: Document): Promise<void>;
export declare function getFilePathFromUrl(config: d.Config, outputTarget: d.OutputTargetHydrate, fromUrl: d.Url, toUrl: d.Url): string;
