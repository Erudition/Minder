import * as d from '../declarations';
export declare class InMemoryFileSystem implements d.InMemoryFileSystem {
    disk: d.FileSystem;
    private sys;
    private items;
    constructor(disk: d.FileSystem, sys: d.StencilSystem);
    accessData(filePath: string): Promise<{
        exists: boolean;
        isDirectory: boolean;
        isFile: boolean;
    }>;
    access(filePath: string): Promise<boolean>;
    /**
     * Synchronous!!! Do not use!!!
     * (Only typescript transpiling is allowed to use)
     * @param filePath
     */
    accessSync(filePath: string): boolean;
    emptyDir(dirPath: string): Promise<void>;
    readdir(dirPath: string, opts?: d.FsReaddirOptions): Promise<d.FsReaddirItem[]>;
    private readDirectory;
    readFile(filePath: string, opts?: d.FsReadOptions): Promise<string>;
    /**
     * Synchronous!!! Do not use!!!
     * (Only typescript transpiling is allowed to use)
     * @param filePath
     */
    readFileSync(filePath: string, opts?: d.FsReadOptions): string;
    remove(itemPath: string): Promise<void>;
    private removeDir;
    private removeItem;
    stat(itemPath: string): Promise<{
        exists: boolean;
        isFile: boolean;
        isDirectory: boolean;
        size: number;
    }>;
    /**
     * Synchronous!!! Do not use!!!
     * (Only typescript transpiling is allowed to use)
     * @param itemPath
     */
    statSync(itemPath: string): {
        isFile: boolean;
        isDirectory: boolean;
    };
    writeFile(filePath: string, content: string, opts?: d.FsWriteOptions): Promise<d.FsWriteResults>;
    writeFiles(files: {
        [filePath: string]: string;
    }, opts?: d.FsWriteOptions): Promise<d.FsWriteResults[]>;
    commit(): Promise<{
        filesWritten: string[];
        filesDeleted: string[];
        dirsDeleted: string[];
        dirsAdded: string[];
    }>;
    private commitEnsureDirs;
    private commitWriteFiles;
    private commitWriteFile;
    private commitDeleteFiles;
    private commitDeleteDirs;
    clearDirCache(dirPath: string): void;
    clearFileCache(filePath: string): void;
    cancelDeleteFilesFromDisk(filePaths: string[]): void;
    cancelDeleteDirectoriesFromDisk(dirPaths: string[]): void;
    getItem(itemPath: string): d.FsItem;
    clearCache(): void;
    readonly keys: string[];
    getMemoryStats(): string;
}
export declare function getCommitInstructions(path: d.Path, d: d.FsItems): {
    filesToDelete: string[];
    filesToWrite: string[];
    dirsToDelete: string[];
    dirsToEnsure: string[];
};
export declare function isTextFile(filePath: string): boolean;
export declare function shouldIgnore(filePath: string): boolean;
