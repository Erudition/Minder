export declare class MockClassList {
    private elm;
    constructor(elm: HTMLElement);
    add(...className: string[]): void;
    remove(...className: string[]): void;
    contains(className: string): boolean;
    toggle(className: string): void;
    readonly length: number;
    item(index: number): string;
    toString(): string;
}
