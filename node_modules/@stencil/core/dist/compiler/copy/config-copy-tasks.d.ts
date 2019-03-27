import * as d from '../../declarations';
export declare function getConfigCopyTasks(config: d.Config, buildCtx: d.BuildCtx): Promise<d.CopyTask[]>;
export declare function processCopyTasks(config: d.Config, allCopyTasks: d.CopyTask[], copyTask: d.CopyTask): Promise<any>;
export declare function createGlobCopyTask(config: d.Config, copyTask: d.CopyTask, destDir: string, globRelPath: string): d.CopyTask;
export declare function getSrcAbsPath(config: d.Config, src: string): string;
export declare function getDestAbsPath(config: d.Config, src: string, destAbsPath: string, destRelPath: string): string;
export declare function isCopyTaskFile(config: d.Config, filePath: string): boolean;
