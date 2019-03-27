import { MockNode } from './node';
export declare class MockComment extends MockNode {
    constructor(ownerDocument: any, data: string);
    cloneNode(deep?: boolean): MockComment;
    textContent: string;
}
