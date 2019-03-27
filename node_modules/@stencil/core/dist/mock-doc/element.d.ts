import { MockElement } from './node';
import { MockDocumentFragment } from './document-fragment';
export declare function createElement(ownerDocument: any, tagName: string): MockElement;
export declare class MockTemplateElement extends MockElement {
    content: MockDocumentFragment;
    constructor(ownerDocument: any);
    innerHTML: string;
}
