import * as d from '../../declarations';
export declare function generateReadmeDocs(config: d.Config, compilerCtx: d.CompilerCtx, readmeOutputs: d.OutputTargetDocsReadme[], docs: d.JsonDocs): Promise<void>;
export declare function generateMarkdown(userContent: string, cmp: d.JsonDocsComponent): string[];
