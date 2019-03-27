import * as d from '../../../declarations';
export default function abortPlugin(buildCtx: d.BuildCtx): {
    name: string;
    resolveId(): string;
    load(): string;
};
