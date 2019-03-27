import * as d from '../../declarations';
export declare function generateComponentTypes(config: d.Config, compilerCtx: d.CompilerCtx, buildCtx: d.BuildCtx, destination?: string): Promise<void>;
/**
 * Generate a string based on the types that are defined within a component.
 *
 * @param cmpMeta the metadata for the component that a type definition string is generated for
 * @param importPath the path of the component file
 */
export declare function createTypesAsString(cmpMeta: d.ComponentMeta, _importPath: string): {
    tagNameAsPascal: string;
    StencilComponents: string;
    JSXElements: string;
    global: string;
    HTMLElementTagNameMap: string;
    ElementTagNameMap: string;
    IntrinsicElements: string;
};
export interface ImportData {
    [key: string]: MemberNameData[];
}
export interface MemberNameData {
    localName: string;
    importName?: string;
}
