/**
 * CSS parser adopted from rework/css by
 * TJ Holowaychuk (@tj)
 * Licensed under the MIT License
 * https://github.com/reworkcss/css/blob/master/LICENSE
 */
import * as d from '../../declarations';
export declare function parseCss(_config: d.Config, css: string, filePath?: string): {
    type: string;
    stylesheet: {
        source: string;
        rules: any[];
        diagnostics: d.Diagnostic[];
    };
};
