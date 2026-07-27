import { field, variant } from "@dao-xyz/borsh";
import { Program, type Address } from "@peerbit/program";
import { SharedLog, type ReplicationOptions } from "@peerbit/shared-log";
import { Peerbit } from "peerbit";

export type CreatePeerbitHostOptions = {
	client?: Peerbit;
	directory?: string;
	programAddress?: Address;
};

export type PeerbitHost = {
	client: Peerbit;
	programAddress: Address;
	appendOp(ronOpString: string): Promise<void>;
	getAllOps(): Promise<string[]>;
	close(): Promise<void>;
};

type MinderLogArgs = {
	replicate: ReplicationOptions;
};

@variant("minder-log")
export class MinderLog extends Program<MinderLogArgs> {
	@field({ type: SharedLog })
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

const encoder = new TextEncoder();
const decoder = new TextDecoder();

export async function createPeerbitHost(
	options: CreatePeerbitHostOptions = {},
): Promise<PeerbitHost> {
	const client =
		options.client ??
		(await Peerbit.create({
			directory: options.directory,
		}));

	let program: MinderLog;
	if (options.programAddress) {
		program = await client.open<MinderLog>(options.programAddress, {
			args: { replicate: true },
			timeout: 30_000,
		});
	} else {
		program = await client.open(new MinderLog(), {
			args: { replicate: true },
		});
		await program.save();
	}

	return {
		client,
		programAddress: program.address,

		async appendOp(ronOpString: string): Promise<void> {
			const bytes = encoder.encode(ronOpString);
			await program.log.append(bytes);
		},

		async getAllOps(): Promise<string[]> {
			const entries = await program.log.log.toArray();
			const ops: string[] = [];
			for (const entry of entries) {
				const payload = await Promise.resolve(entry.getPayloadValue());
				ops.push(decoder.decode(payload));
			}
			return ops;
		},

		async close(): Promise<void> {
			await client.stop();
		},
	};
}
