import * as d from '../../declarations';
export declare function normalizePrerenderLocation(config: d.Config, outputTarget: d.OutputTargetWww, windowLocationHref: string, url: string): d.PrerenderLocation;
export declare function crawlAnchorsForNextUrls(config: d.Config, outputTarget: d.OutputTargetWww, prerenderQueue: d.PrerenderLocation[], windowLocationHref: string, anchors: d.HydrateAnchor[]): void;
export declare function isValidCrawlableAnchor(anchor: d.HydrateAnchor): boolean;
export declare function getPrerenderQueue(config: d.Config, outputTarget: d.OutputTargetWww): d.PrerenderLocation[];
export declare function getWritePathFromUrl(config: d.Config, outputTarget: d.OutputTargetWww, url: string): string;
