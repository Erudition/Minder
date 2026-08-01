import { bindService } from "@dao-xyz/borsh-rpc";
import {
	type CanonicalChannel,
	type CanonicalContext,
	type CanonicalModule,
	createMessagePortTransport,
} from "@peerbit/canonical-host";
import { createSharedLogService } from "@peerbit/shared-log-proxy/host";
import { SharedLogService } from "@peerbit/shared-log-proxy";
import { MinderLog } from "./minder-log.js";

const decoder = new TextDecoder();

// Refcount open MinderLog programs by address so concurrent channel opens
// reuse one program instance and only close it once the last channel drops.
const openPrograms: Map<string, { program: MinderLog; refs: number; channels: Set<CanonicalChannel> }> = new Map();

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
	address: string,
	port: CanonicalChannel,
): Promise<{ program: MinderLog; key: string; release: () => Promise<void> }> => {
	// If address is specified and doesn't match the active cached sharedProgramPromise, reset it so we open/reuse the requested program.
	const peer = await ctx.peer();
	let program: MinderLog;
	if (address) {
		try {
			program = await peer.open<MinderLog>(address, {
				args: { replicate: true },
				existing: "reuse",
				timeout: 10_000,
			});
		} catch (e) {
			console.warn(`Failed to open program at address ${address}, falling back to existing or new MinderLog:`, e);
			if (openPrograms.size > 0) {
				const existing = openPrograms.values().next().value;
				if (existing) program = existing.program;
				else {
					program = await peer.open<MinderLog>(new MinderLog(), {
						args: { replicate: true },
					});
					await program.save();
				}
			} else {
				program = await peer.open<MinderLog>(new MinderLog(), {
					args: { replicate: true },
				});
				await program.save();
			}
		}
	} else if (openPrograms.size > 0) {
		const existing = openPrograms.values().next().value;
		if (existing) program = existing.program;
		else {
			program = await peer.open<MinderLog>(new MinderLog(), {
				args: { replicate: true },
			});
			await program.save();
		}
	} else {
		program = await peer.open<MinderLog>(new MinderLog(), {
			args: { replicate: true },
		});
		await program.save();
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
		// Payload is the program address as UTF-8, or empty when creating new.
		const address = decoder.decode(payload);

		const acquired = await acquireProgram(ctx, address, port);

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
