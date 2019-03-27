/**
 * Member Types
 */
export declare const enum MEMBER_TYPE {
    Prop = 1,
    PropMutable = 2,
    PropContext = 4,
    PropConnect = 8,
    State = 16,
    Method = 32,
    Element = 64
}
/**
 * Property Types
 */
export declare const enum PROP_TYPE {
    Unknown = 0,
    Any = 1,
    String = 2,
    Boolean = 4,
    Number = 8
}
/**
 * JS Property to Attribute Name Options
 */
export declare const enum ATTR_CASE {
    LowerCase = 1
}
/**
 * Priority Levels
 */
export declare const enum PRIORITY {
    Low = 1,
    Medium = 2,
    High = 3
}
/**
 * Encapsulation
 */
export declare const enum ENCAPSULATION {
    NoEncapsulation = 0,
    ShadowDom = 1,
    ScopedCss = 2
}
/**
 * Node Types
 * https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeType
 */
export declare const enum NODE_TYPE {
    ElementNode = 1,
    TextNode = 3,
    CommentNode = 8,
    DocumentNode = 9,
    DocumentTypeNode = 10,
    DocumentFragment = 11
}
/**
 * SSR Attribute Names
 */
export declare const SSR_VNODE_ID = "ssrv";
export declare const SSR_CHILD_ID = "ssrc";
/**
 * Default style mode id
 */
export declare const DEFAULT_STYLE_MODE = "$";
/**
 * Reusable empty obj/array
 * Don't add values to these!!
 */
export declare const EMPTY_OBJ: any;
export declare const EMPTY_ARR: any[];
/**
 * Key Name to Key Code Map
 */
export declare const KEY_CODE_MAP: {
    [key: string]: number;
};
/**
 * Namespaces
 */
export declare const SVG_NS = "http://www.w3.org/2000/svg";
export declare const XLINK_NS = "http://www.w3.org/1999/xlink";
export declare const XML_NS = "http://www.w3.org/XML/1998/namespace";
/**
 * File names and value
 */
export declare const BANNER = "Built with http://stenciljs.com";
export declare const COLLECTION_MANIFEST_FILE_NAME = "collection-manifest.json";
export declare const WEB_COMPONENTS_JSON_FILE_NAME = "web-components.json";
export declare const APP_NAMESPACE_REGEX: RegExp;
/**
 * Runtime Errors
 */
export declare const enum RUNTIME_ERROR {
    LoadBundleError = 1,
    QueueEventsError = 2,
    WillLoadError = 3,
    DidLoadError = 4,
    WillUpdateError = 5,
    DidUpdateError = 6,
    InitInstanceError = 7,
    RenderError = 8
}
