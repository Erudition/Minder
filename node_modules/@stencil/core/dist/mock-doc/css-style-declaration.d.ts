export declare class CSSStyleDeclaration {
    private _styles;
    setProperty(prop: string, value: string): void;
    getPropertyValue(prop: string): string;
    removeProperty(prop: string): void;
    readonly length: number;
    cssText: string;
    readonly cssTextMinified: string;
}
export declare function createCSSStyleDeclaration(): CSSStyleDeclaration;
