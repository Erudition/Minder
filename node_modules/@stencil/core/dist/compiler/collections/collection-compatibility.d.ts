import * as d from '../../declarations';
export declare function validateCollectionCompatibility(config: d.Config, collection: d.Collection): number[];
export declare function calculateRequiredUpgrades(config: d.Config, collectionVersion: string): CompilerUpgrade[];
export declare const enum CompilerUpgrade {
    JSX_Upgrade_From_0_0_5 = 0,
    Metadata_Upgrade_From_0_1_0 = 1,
    Remove_Stencil_Imports = 2,
    Add_Component_Dependencies = 3,
    Add_Local_Intrinsic_Elements = 4
}
