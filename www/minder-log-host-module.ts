import { bindService } from "@dao-xyz/borsh-rpc";
import {
	type CanonicalChannel,
	type CanonicalContext,
	type CanonicalModule,
	createMessagePortTransport,
} from "@peerbit/canonical-host";
import { Entry } from "@peerbit/log";
import { createSharedLogService } from "@peerbit/shared-log-proxy/host";
import { SharedLogService } from "@peerbit/shared-log-proxy";
import { MinderLog } from "./minder-log.js";
import { IndexedDBStore } from "./minder-idb-store.js";

// Refcount open MinderLog programs by address so concurrent channel opens
// reuse one program instance and only close it once the last channel drops.
const openPrograms: Map<string, { program: MinderLog; refs: number; channels: Set<CanonicalChannel> }> = new Map();

// Head-hash persistence. The service worker cannot install OPFS sqlite3_vfs
// (no COOP/COEP headers → no SharedArrayBuffer/Atomics), so @peerbit's
// sqlite-backed EntryIndex falls back to a memory store and is wiped on
// browser restart. The *blocks* do persist (IndexedDBStore), so the log is
// recoverable as long as we remember the head hashes. We keep them in a tiny
// IDB store keyed by program address and rebuild the index via
// `log.load({ reset: true, heads })` when an acquire finds zero heads.
const headsStore = new IndexedDBStore("minder-peerbit-heads");

const persistHeadHashes = async (peer: any, addressKey: string, shared: any): Promise<void> => {
	try {
		const lower = shared?.log;
		if (!lower) return;
		const heads = await lower.getHeads(true).all();
		const hashes = heads.map((h: any) => h.hash);
		await headsStore.open();
		await headsStore.put(addressKey, new TextEncoder().encode(JSON.stringify(hashes)));
		console.log(`PERSISTED HEADS for ${addressKey}: ${hashes.length} heads`);
	} catch (e) {
		console.error("persistHeadHashes failed", e);
	}
};

const recoverHeadHashes = async (peer: any, addressKey: string, shared: any): Promise<number> => {
	try {
		const lower = shared?.log;
		if (!lower) return 0;
		const existing = await lower.getHeads(true).all();
		if (existing.length > 0) return existing.length; // index already healthy
		await headsStore.open();
		const bytes = await headsStore.get(addressKey);
		if (!bytes) return 0;
		const hashes = JSON.parse(new TextDecoder().decode(bytes));
		if (!Array.isArray(hashes) || hashes.length === 0) return 0;
		const blocks = peer.services.blocks;
		const entries = [];
		for (const hash of hashes) {
			try {
				const entry = await Entry.fromMultihash(blocks, hash, { remote: false });
				entries.push(entry);
			} catch (e) {
				console.error("recoverHeadHashes: failed to resolve block", hash, e);
			}
		}
		if (entries.length === 0) return 0;
		await lower.load({ reset: true, heads: entries });
		const after = await lower.toArray();
		console.log(`RECOVERED HEADS for ${addressKey}: ${after.length} entries from ${entries.length} persisted heads`);
		return after.length;
	} catch (e) {
		console.error("recoverHeadHashes failed", e);
		return 0;
	}
};

const releaseProgram = async (key: string, port: CanonicalChannel): Promise<void> => {
	const existing = openPrograms.get(key);
	if (!existing) return;
	existing.channels.delete(port);
	existing.refs -= 1;
	console.log(`RELEASED PROGRAM PORT FOR KEY ${key}. REMAINING CHANNELS: ${existing.channels.size}`);
	if (existing.refs > 0) return;
	openPrograms.delete(key);
	await existing.program.close();
};

const acquireProgram = async (
	ctx: CanonicalContext,
	address: string | { toString(): string },
	port: CanonicalChannel,
	id: Uint8Array,
	mode: "reuse" | "create",
): Promise<{ program: MinderLog; key: string; release: () => Promise<void> }> => {
	// openPrograms is keyed by the address string; normalize the (possibly
	// Address-object) input so the cache lookup actually matches.
	const addressKey = address.toString();
	console.log(`ACQUIRE: calling ctx.peer() for ${addressKey}`);
	const peer = await ctx.peer();
	console.log(`ACQUIRE: ctx.peer() resolved, peerId=${peer.peerId.toString()}`);
	let program: MinderLog;
	// Fast path: the program for this address is already open in this SW
	// (opened by an earlier tab) → reuse the live instance. This is what makes
	// new tabs attach to the existing host instantly: no blockstore read, no
	// fresh open, just the cached program.
	const cached = openPrograms.get(addressKey);
	if (cached) {
		program = cached.program;
	} else {
		// The block is persisted (or arrives via replication for ?program= shares) → open it.
		try {
			console.log(`ACQUIRE: reuse-open attempt for ${addressKey}`);
			program = await peer.open<MinderLog>(addressKey, {
				args: { replicate: true },
				existing: "reuse",
				timeout: 10_000,
			});
			console.log(`ACQUIRE: reuse-open RESOLVED for ${addressKey}`);
		} catch (e) {
			if (mode === "reuse") {
				console.warn(`ACQUIRE: reuse-open FAILED for ${addressKey} (mode=reuse), propagating: `, e);
				throw new Error(`MinderLog program not found or could not be loaded at address ${addressKey}. Start from Scratch to create a new profile.`);
			}
			console.warn(`Failed to open program at address ${addressKey} (mode=create), creating new MinderLog:`, e);
			console.log(`ACQUIRE: creating new MinderLog, id=${id.length} bytes`);
			program = await peer.open<MinderLog>(new MinderLog({ id }), {
				args: { replicate: true },
			});
			console.log(`ACQUIRE: new MinderLog open RESOLVED, saving...`);
			await program.save();
			console.log(`ACQUIRE: SAVED PROGRAM ${program.address.toString()}, blocks.has: ${await peer.services.blocks.has(program.address.toString())}`);
		}
	}
	const storedKey = program.address.toString();
	let entry = openPrograms.get(storedKey);
	if (!entry) {
		entry = { program, refs: 0, channels: new Set() };
		openPrograms.set(storedKey, entry);
	}
	entry.refs += 1;
	entry.channels.add(port);
	console.log(`ACQUIRED CANONICAL PROGRAM ${storedKey}. CHANNELS COUNT NOW: ${entry.channels.size}`);

	// Persistence fix: a browser restart wipes the (memory-backed, no-OPFS)
	// EntryIndex while blocks survive in IDB. Rebuild the index from persisted
	// head hashes when empty, then persist the current heads for next time.
	{
		const shared = (program as any).log as { log?: any; events?: EventTarget } | undefined;
		const lower = shared?.log;
		const evts = shared?.events;
		if (lower && evts) {
			await recoverHeadHashes(peer, storedKey, shared as any);
			await persistHeadHashes(peer, storedKey, shared as any);
			// Keep heads fresh on log changes so the next restart can recover.
			const persist = () => { void persistHeadHashes(peer, storedKey, shared as any); };
			for (const evName of ["replication:change", "replicator:join"]) {
				evts.addEventListener?.(evName, persist);
			}
		}
	}

	// DIAGNOSTIC: measure the raw log's index/head state after acquire so we can
	// tell whether the receiving node ever adopts replicated entries.
	// heads>0 && toArray==0  => join/index path broken (canAppend/signatures)
	// heads==0               => head exchange never completes (replication)
	// post-load toArray>0    => forced load() recovers the index => the fix.
	{
		const shared = (program as any).log as
			| {
					events?: EventTarget;
					getReplicators?(): Promise<Set<string>>;
					log?: {
						getHeads(gid?: any): { all(): Promise<any[]> };
						toArray(): Promise<any[]>;
						load(opts: any): Promise<void>;
					};
			  }
			| undefined;
		const lower = shared?.log;
		const evts = shared?.events;

		// Log every replication/replicator event with the peer key it concerns,
		// so we can tell WHOSE key churns (replication:change) and whether the
		// data-holder is ever registered (replicator:join) or dropped (leave).
		const pkShort = (pk: any) => {
			if (pk == null) return "null";
			const s = typeof pk === "string" ? pk : pk.toString ? pk.toString() : String(pk);
			return s.length > 20 ? `${s.slice(0, 20)}...` : s;
		};
		let evCount = 0;
		for (const evName of ["replication:change", "replicator:join", "replicator:leave", "replicator:mature"]) {
			evts?.addEventListener?.(evName, (ev: any) => {
				evCount++;
				console.log(`DIAG[ev] ${evName} #${evCount} pk=${pkShort(ev?.detail?.publicKey)}`);
			});
		}

		const diag = async (tag: string) => {
			if (!lower) {
				console.log(`DIAG[${tag}] no lower log`);
				return;
			}
			try {
				const heads = await lower.getHeads(true).all();
				const arr = await lower.toArray();
				let reps = "n/a";
				try {
					const repSet = await shared?.getReplicators?.();
					reps = repSet ? `${repSet.size}` : "n/a";
				} catch {}
				console.log(`DIAG[${tag}] heads=${heads.length} toArray=${arr.length} replicators=${reps} evCount=${evCount}`);
			} catch (e) {
				console.error(`DIAG[${tag}] error`, e);
			}
		};
		void diag("acquire");
		setTimeout(() => void diag("8s"), 8000);
		setTimeout(async () => {
			if (!lower) return;
			try {
				const heads = await lower.getHeads(true).all();
				console.log(`DIAG[12s] heads=${heads.length}`);
				// Dump the full replicator hash set once, to see if the data-holder is known.
				try {
					const repSet = await shared?.getReplicators?.();
					if (repSet) {
						const arr = [...repSet];
						console.log(`DIAG[12s] replicators=${arr.length} ${arr.slice(0, 8).join(",")}`);
					}
				} catch (e) {
					console.error("DIAG getReplicators error", e);
				}
				if (heads.length > 0) {
					await lower.load({ reset: true, heads });
					const arr = await lower.toArray();
					console.log(`DIAG[post-load] toArray=${arr.length}`);
				}
			} catch (e) {
				console.error("DIAG post-load error", e);
			}
		}, 12000);
	}

	return {
		program,
		key: storedKey,
		release: async () => releaseProgram(storedKey, port),
	};
};

export const minderLogModule: CanonicalModule = {
	name: "minder-log",
	open: async (
		ctx: CanonicalContext,
		port: CanonicalChannel,
		payload: Uint8Array,
	): Promise<void> => {
		// Payload is the 32-byte program id; a 33-byte payload with leading 0x01
		// additionally signals create-allowed mode (client explicitly opted in
		// via Start from Scratch / fresh passphrase flow). Reuse-only opens never
		// auto-create a fresh program: a load failure must surface to the client.
		let mode: "reuse" | "create" = "reuse";
		let id: Uint8Array;
		if (payload.length === 33 && payload[0] === 0x01) {
			mode = "create";
			id = payload.subarray(1);
		} else if (payload.length === 32) {
			id = payload;
		} else {
			throw new Error("MinderLog host module expects a 32-byte id payload or a 33-byte create payload");
		}
		if (id.length !== 32) {
			throw new Error("MinderLog host module expects a 32-byte program id");
		}
		const probe = new MinderLog({ id });
		const address = (await probe.calculateAddress()).address;

		const acquired = await acquireProgram(ctx, address, port, id, mode);

		const customPort: CanonicalChannel = {
			send: port.send,
			onMessage: (handler: (data: Uint8Array) => void) => {
				return port.onMessage((data) => {
					// Magic prefix [0xff, 0x01] indicates a custom appendOp payload
					if (data.length >= 2 && data[0] === 0xff && data[1] === 0x01) {
						console.log("SW RECEIVED 0xff 0x01 APPEND OP FROM CLIENT!");
						const opBytes = data.subarray(2);
						acquired.program.log.append(opBytes).then(() => {
							const broadcastMsg = new Uint8Array(2 + opBytes.length);
							broadcastMsg[0] = 0xff;
							broadcastMsg[1] = 0x02;
							broadcastMsg.set(opBytes, 2);
							const prog = openPrograms.get(acquired.key);
							if (prog) {
								console.log(`HOST BROADCASTING OP TO ${prog.channels.size} CHANNELS`);
								for (const ch of prog.channels) {
									try {
										ch.send(broadcastMsg);
									} catch (e) {
										console.error("HOST BROADCAST ERROR:", e);
									}
								}
							}
						}).catch((err) => {
							console.error("SW PROGRAM LOG APPEND FAILED:", err);
						});
						return;
					}
					handler(data);
				});
			},
			close: port.close,
			onClose: port.onClose,
		};

		const transport = createMessagePortTransport(customPort);
		const service = createSharedLogService(acquired.program.log, {
			onClose: async () => {
				unbind?.();
				await acquired.release();
			},
		});

		let unbind: (() => void) | undefined;
		unbind = bindService(SharedLogService, transport, service);

		port.onClose?.(() => {
			void service.close();
		});
	},
};
