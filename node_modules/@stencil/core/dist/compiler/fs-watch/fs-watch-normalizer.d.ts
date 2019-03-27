import * as d from '../../declarations';
export declare class FsWatchNormalizer {
    private config;
    private events;
    private dirsAdded;
    private dirsDeleted;
    private filesAdded;
    private filesDeleted;
    private filesUpdated;
    private flushTmrId;
    constructor(config: d.Config, events: d.BuildEvents);
    fileUpdate(filePath: string): void;
    fileAdd(filePath: string): void;
    fileDelete(filePath: string): void;
    dirAdd(dirPath: string): void;
    dirDelete(dirPath: string): void;
    queue(): void;
    flush(): void;
    subscribe(): void;
    private log;
}
