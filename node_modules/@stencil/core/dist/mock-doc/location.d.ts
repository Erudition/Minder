export declare class MockLocation {
    protocol: string;
    host: string;
    hostname: string;
    port: string;
    pathname: string;
    search: string;
    hash: string;
    username: string;
    password: string;
    origin: string;
    private _href;
    href: string;
    assign(_url: string): void;
    reload(_forcedReload?: boolean): void;
    replace(_url: string): void;
    toString(): string;
}
