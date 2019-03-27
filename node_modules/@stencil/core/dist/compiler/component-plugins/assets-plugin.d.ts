import { AssetsMeta, Config } from '../../declarations';
export declare function normalizeAssetsDir(config: Config, componentFilePath: string, assetsMetas: AssetsMeta[]): {
    absolutePath?: string;
    cmpRelativePath?: string;
    originalComponentPath?: string;
    originalCollectionPath?: string;
}[];
