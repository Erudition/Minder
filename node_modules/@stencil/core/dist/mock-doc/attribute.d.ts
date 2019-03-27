export declare class MockAttributeMap {
    items: MockAttr[];
    readonly length: number;
    cloneAttributes(): MockAttributeMap;
    getNamedItem(name: string): MockAttr;
    setNamedItem(attr: MockAttr): void;
    removeNamedItem(attr: MockAttr): void;
    item(index: number): MockAttr;
    getNamedItemNS(namespaceURI: string, name: string): MockAttr;
    setNamedItemNS(attr: MockAttr): void;
    removeNamedItemNS(attr: MockAttr): void;
}
export declare class MockAttr {
    private _name;
    private _value;
    private _namespaceURI;
    name: string;
    value: string;
    namespaceURI: string;
}
