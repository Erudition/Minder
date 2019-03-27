import * as d from '../../../declarations';
export default function bundleJson(config: d.Config, options?: Options): {
    name: string;
    resolveId(importee: string, importer: string): any;
    transform(json: string, id: string): {
        ast: ASTNode;
        code: string;
        map: {
            mappings: string;
        };
    };
};
export interface Options {
    indent?: string;
    preferConst?: boolean;
    include?: any;
    exclude?: any;
}
export interface ASTNode {
    type: string;
    sourceType?: string;
    start: number | null;
    end: number | null;
    body?: any[];
    declaration?: any;
}
