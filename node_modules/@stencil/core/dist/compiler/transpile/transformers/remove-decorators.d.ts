import ts from 'typescript';
/**
 * Remove all decorators that are for metadata purposes
 */
export declare function removeDecorators(): ts.TransformerFactory<ts.SourceFile>;
