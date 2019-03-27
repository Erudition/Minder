import * as d from '../../../declarations';
import ts from 'typescript';
export default function addComponentMetadata(moduleFiles: d.ModuleFiles): ts.TransformerFactory<ts.SourceFile>;
export declare function addStaticMeta(cmpMeta: d.ComponentMeta): ConstructorComponentMeta;
export interface ConstructorComponentMeta {
    is?: ts.Expression;
    encapsulation?: ts.Expression;
    host?: ts.Expression;
    properties?: ts.Expression;
    didChange?: ts.Expression;
    willChange?: ts.Expression;
    events?: ts.Expression;
    listeners?: ts.Expression;
    style?: ts.Expression;
    styleMode?: ts.Expression;
}
