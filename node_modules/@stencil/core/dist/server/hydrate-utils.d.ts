import * as d from '../declarations';
export declare function normalizeHydrateOptions(wwwTarget: d.OutputTargetWww, opts: d.HydrateOptions): d.OutputTargetHydrate;
export declare function generateHydrateResults(config: d.Config, hydrateTarget: d.OutputTargetHydrate): d.HydrateResults;
export declare function normalizeDirection(doc: Document, hydrateTarget: d.OutputTargetHydrate): void;
export declare function normalizeLanguage(doc: Document, hydrateTarget: d.OutputTargetHydrate): void;
export declare function collectAnchors(config: d.Config, doc: Document, results: d.HydrateResults): void;
export declare function generateFailureDiagnostic(diagnostic: d.Diagnostic): string;
