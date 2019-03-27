import { Config, Diagnostic } from '../../declarations';
import { UsedSelectors } from '../html/used-selectors';
export declare function removeUnusedStyles(config: Config, usedSelectors: UsedSelectors, cssContent: string, diagnostics?: Diagnostic[]): string;
