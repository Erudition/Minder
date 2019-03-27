export interface FsWatchNormalizer {
    subscribe(): void;
}
export interface FsWatchResults {
    dirsAdded: string[];
    dirsDeleted: string[];
    filesUpdated: string[];
    filesAdded: string[];
    filesDeleted: string[];
}
export interface FsWatcher {
    add(path: string | string[]): void;
}
export declare type BuildHashes = Map<string, string>;
