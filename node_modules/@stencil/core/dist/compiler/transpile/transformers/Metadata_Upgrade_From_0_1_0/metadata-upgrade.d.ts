import * as d from '../../../../declarations';
import ts from 'typescript';
export default function upgradeFromMetadata(moduleFiles: d.ModuleFiles): (tsSourceFile: ts.SourceFile) => ts.SourceFile;
