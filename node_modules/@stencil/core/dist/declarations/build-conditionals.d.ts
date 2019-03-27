export declare type BuildCoreIds = 'core' | 'core.pf' | 'esm.es5' | 'esm.es2017';
export interface BuildConditionals {
    [key: string]: any;
    coreId: BuildCoreIds;
    polyfills: boolean;
    es5: boolean;
    cssVarShim: boolean;
    clientSide: boolean;
    browserModuleLoader: boolean;
    externalModuleLoader: boolean;
    isDev: boolean;
    isProd: boolean;
    devInspector: boolean;
    hotModuleReplacement: boolean;
    verboseError: boolean;
    profile: boolean;
    ssrServerSide: boolean;
    prerenderClientSide: boolean;
    prerenderExternal: boolean;
    styles: boolean;
    hasMode: boolean;
    shadowDom: boolean;
    scoped: boolean;
    slotPolyfill: boolean;
    hostData: boolean;
    hostTheme: boolean;
    reflectToAttr: boolean;
    element: boolean;
    event: boolean;
    listener: boolean;
    method: boolean;
    propConnect: boolean;
    propContext: boolean;
    prop: boolean;
    propMutable: boolean;
    state: boolean;
    watchCallback: boolean;
    hasMembers: boolean;
    updatable: boolean;
    cmpDidLoad: boolean;
    cmpWillLoad: boolean;
    cmpDidUpdate: boolean;
    cmpWillUpdate: boolean;
    cmpDidUnload: boolean;
    observeAttr: boolean;
    hasSlot: boolean;
    hasSvg: boolean;
}
declare global {
    var _BUILD_: BuildConditionals;
}
export interface UserBuildConditionals {
    isDev: boolean;
}
