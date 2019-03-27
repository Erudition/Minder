import { AppRegistry, BuildCtx, CompilerCtx, Config, SourceTarget } from '../../declarations';
export declare function generateBrowserAppGlobalScript(config: Config, compilerCtx: CompilerCtx, buildCtx: BuildCtx, appRegistry: AppRegistry, sourceTarget: SourceTarget): Promise<string>;
export declare function generateEsmAppGlobalScript(config: Config, compilerCtx: CompilerCtx, buildCtx: BuildCtx, sourceTarget: SourceTarget): Promise<string>;
export declare function generateAppGlobalContent(config: Config, compilerCtx: CompilerCtx, buildCtx: BuildCtx, sourceTarget: SourceTarget): Promise<string>;
export declare function generateGlobalJs(config: Config, globalJsContents: string): string;
export declare function generateGlobalEsm(config: Config, globalJsContents: string): string;
