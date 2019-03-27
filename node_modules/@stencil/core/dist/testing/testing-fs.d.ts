import * as d from '../declarations';
export declare class TestingFs implements d.FileSystem {
    data: {
        [filePath: string]: {
            isFile: boolean;
            isDirectory: boolean;
            content?: string;
        };
    };
    diskWrites: number;
    diskReads: number;
    copyFile(srcPath: string, destPath: string): Promise<void>;
    exists(filePath: string): Promise<boolean>;
    existsSync(filePath: string): boolean;
    createReadStream(_filePath: string): any;
    mkdir(dirPath: string): Promise<void>;
    mkdirSync(dirPath: string): void;
    readdir(dirPath: string): Promise<string[]>;
    readdirSync(dirPath: string): string[];
    readFile(filePath: string): Promise<string>;
    readFileSync(filePath: string): string;
    rmdir(dirPath: string): Promise<void>;
    stat(itemPath: string): Promise<d.FsStats>;
    statSync(itemPath: string): d.FsStats;
    unlink(filePath: string): Promise<void>;
    writeFile(filePath: string, content: string): Promise<void>;
    writeFileSync(filePath: string, content: string): void;
    writeFiles(files: {
        [filePath: string]: string;
    }): Promise<void[]>;
    readonly resolveTime: number;
}
