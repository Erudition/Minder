import { MockElement } from './node';
export declare function serializeNodeToHtml(elm: MockElement, opts?: SerializeElementOptions): string;
export declare const NON_ESCAPABLE_CONTENT: Set<string>;
export interface SerializeElementOptions {
    collapseBooleanAttributes?: boolean;
    excludeTagContent?: string[];
    excludeTags?: string[];
    indentSpaces?: number;
    minifyInlineStyles?: boolean;
    newLines?: boolean;
    outerHTML?: boolean;
    pretty?: boolean;
    removeAttributeQuotes?: boolean;
    removeHtmlComments?: boolean;
    removeEmptyAttributes?: boolean;
}
