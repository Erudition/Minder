import * as d from '../declarations';
import { Cache } from '../compiler/cache';
import { TestingFs } from './testing-fs';
import { TestingLogger } from './testing-logger';
import { mockDocument, mockWindow } from '@stencil/core/mock-doc';
export { mockDocument, mockWindow };
export declare const testingPerf: any;
export declare function mockDom(url: string, html: string): {
    win: Window;
    doc: HTMLDocument;
};
export declare function mockPlatform(win?: any, domApi?: d.DomApi, cmpRegistry?: d.ComponentRegistry): MockedPlatform;
export interface MockedPlatform extends d.PlatformApi {
    $flushQueue?: () => Promise<any>;
}
export declare function mockConfig(opts?: {
    enableLogger: boolean;
}): d.Config;
export declare function mockCompilerCtx(): d.CompilerCtx;
export declare function mockBuildCtx(config?: d.Config, compilerCtx?: d.CompilerCtx): d.BuildCtx;
export declare function mockStencilSystem(): d.StencilSystem;
export declare function mockPath(): d.Path;
export declare function mockFs(): TestingFs;
export declare function mockLogger(): TestingLogger;
export declare function mockCache(): Cache;
export declare function mockDomApi(win?: any, doc?: any): d.DomApi;
export declare function mockRenderer(plt?: MockedPlatform, domApi?: d.DomApi): d.RendererApi;
export declare function mockQueue(): d.QueueApi;
export declare function mockComponentInstance(plt: d.PlatformApi, domApi: d.DomApi, cmpMeta?: d.ComponentMeta): d.ComponentInstance;
export declare function mockDefine(plt: MockedPlatform, cmpMeta: d.ComponentMeta): d.ComponentMeta;
export declare function mockDispatchEvent(elm: HTMLElement, name: string, detail?: any): boolean;
export declare function mockConnect(plt: MockedPlatform, html: string): Promise<any>;
export declare function waitForLoad(plt: MockedPlatform, rootNode: any, tag: string): Promise<d.HostElement>;
export declare function compareHtml(input: string): string;
export declare function removeWhitespaceFromNodes(node: Node): any;
