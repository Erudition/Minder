export declare class MockCustomElementRegistry {
    private ces;
    define(name: string, cstr: any, _options?: any): void;
    get(name: string): any;
    whenDefined(_name: string): Promise<void>;
}
