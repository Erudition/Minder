/// <reference types="node" />
declare function _exports(cwd: string, pattern: string, options?: {
    hidden?: boolean | undefined;
    followSymlinks?: boolean | undefined;
    preserveMode?: boolean | undefined;
    preserveMtime?: boolean | undefined;
    mode?: number | undefined;
    mtime?: import("ipfs-unixfs/types/src/types").MtimeLike | undefined;
} | undefined): AsyncGenerator<{
    path: string;
    content: fs.ReadStream | undefined;
    mode: number | undefined;
    mtime: import("ipfs-unixfs/types/src/types").MtimeLike | undefined;
}, void, unknown>;
export = _exports;
import fs = require("fs");
//# sourceMappingURL=glob-source.d.ts.map