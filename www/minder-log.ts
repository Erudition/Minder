// IMPORTANT: Import @dao-xyz/borsh first to ensure Symbol.metadata is defined
import { field, variant } from "@dao-xyz/borsh";
import { Program } from "@peerbit/program";
import { SharedLog, type ReplicationOptions } from "@peerbit/shared-log";

export type MinderLogArgs = {
	replicate: ReplicationOptions;
};

export class MinderLog extends Program<MinderLogArgs> {
	log: SharedLog<Uint8Array>;

	constructor() {
		super();
		// Stage-3 decorators do not auto-initialize decorated fields, so we
		// construct the sub-program explicitly before the Program framework opens it.
		this.log = new SharedLog();
	}

	async open(args?: MinderLogArgs): Promise<void> {
		return this.log.open({ replicate: args?.replicate });
	}
}

// @ts-ignore - Imperative call to bypass TypeScript 5 decorator issues
variant("minder-log")(MinderLog);
// @ts-ignore - Imperative call to bypass TypeScript 5 decorator issues
field({ type: SharedLog })(MinderLog.prototype, "log");