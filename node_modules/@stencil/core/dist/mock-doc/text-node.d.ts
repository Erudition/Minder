import { MockNode } from './node';
export declare class MockTextNode extends MockNode {
    constructor(ownerDocument: any, text: string);
    cloneNode(deep?: boolean): MockTextNode;
    textContent: string;
    readonly wholeText: string;
}
