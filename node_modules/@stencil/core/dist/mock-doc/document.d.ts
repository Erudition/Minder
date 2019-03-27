import { MockComment } from './comment-node';
import { MockDocumentFragment } from './document-fragment';
import { MockDocumentTypeNode } from './document-type-node';
import { MockElement } from './node';
import { MockTextNode } from './text-node';
export declare class MockDocument extends MockElement {
    body: MockElement;
    defaultView: any;
    documentElement: MockElement;
    head: MockElement;
    _parser: any;
    constructor(html?: string);
    createComment(data: string): MockComment;
    createElement(tagName: string): MockElement;
    createElementNS(namespaceURI: string, tagName: string): MockElement;
    createTextNode(text: string): MockTextNode;
    createDocumentFragment(): MockDocumentFragment;
    createDocumentTypeNode(): MockDocumentTypeNode;
    getElementById(id: string): MockElement;
    getElementsByClassName(classNames: string): MockElement[];
    getElementsByTagName(tagName: string): MockElement[];
    getElementsByName(name: string): MockElement[];
    title: string;
}
