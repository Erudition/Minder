import * as d from '../declarations';
import { PROP_TYPE } from './constants';
export declare const parseComponentLoader: (cmpRegistryData: [string, d.BundleIds, boolean, d.ComponentMemberData[], number, d.ComponentListenersData[]], i?: number, cmpData?: any) => d.ComponentMeta;
export declare const parsePropertyValue: (propType: StringConstructor | BooleanConstructor | NumberConstructor | "Any" | PROP_TYPE, propValue: any) => any;
