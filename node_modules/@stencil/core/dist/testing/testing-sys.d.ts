import { StencilSystem } from '../declarations';
export declare const NodeSystem: NodeSystemSystemConstructor;
export interface NodeSystemSystemConstructor {
    new (fs: any): StencilSystem;
}
export declare class TestingSystem extends NodeSystem {
    constructor();
    readonly compiler: {
        name: string;
        version: string;
        typescriptVersion?: string;
        runtime?: string;
        packageDir?: string;
    };
    getClientCoreFile(opts: any): Promise<string>;
    tmpdir(): string;
}
