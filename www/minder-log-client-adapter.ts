import { createProxyFromService } from "@dao-xyz/borsh-rpc";
import {
	type CanonicalClient,
	createMessagePortTransport,
	createVariantAdapter,
} from "@peerbit/canonical-client";
import type { Address } from "@peerbit/program";
import {
	createSharedLogProxyFromService,
	type SharedLogProxy,
} from "@peerbit/shared-log-proxy/client";
import { SharedLogService } from "@peerbit/shared-log-proxy";
import type { MinderLog } from "./minder-log.js";

export type MinderLogProxy = SharedLogProxy;

/**
 * Open a MinderLog program over the canonical "minder-log" channel. The
 * 32-byte program id (the SharedLog Log id, serialized with the program)
 * travels as the channel payload; the host module derives the deterministic
 * program address from it and opens (or reuses) the underlying MinderLog,
 * exposing its SharedLog through the same SharedLogService RPC used by
 * @peerbit/shared-log-proxy.
 */
export const openMinderLog = async (properties: {
	client: CanonicalClient;
	address: Address;
	program: MinderLog;
	create?: boolean;
}): Promise<MinderLogProxy> => {
	const idBytes = (properties.program as any).log?.log?.id;
	if (!(idBytes instanceof Uint8Array) || idBytes.length !== 32) {
		throw new Error("MinderLog program has no valid 32-byte id");
	}
	
	const payload = properties.create ? new Uint8Array([0x01, ...idBytes]) : idBytes;
	const channel = await properties.client.openPort("minder-log", payload);

	const proxyRef: { current: MinderLogProxy | undefined } = { current: undefined };

	const customChannel: typeof channel = {
		send: channel.send.bind(channel),
		onMessage: (handler: (data: Uint8Array) => void) => {
			return channel.onMessage((data) => {
				console.log("CLIENT CHANNEL RECEIVED MSG LENGTH:", data.length, "PREFIX:", data[0], data[1]);
				if (data.length >= 2 && data[0] === 0xff && data[1] === 0x02) {
					console.log("CLIENT RECEIVED 0xff 0x02 BROADCAST OP! proxyRef exists:", !!proxyRef.current);
					const opBytes = data.subarray(2);
					if (proxyRef.current) {
						console.log("DISPATCHING CHANGE EVENT ON PROXY EVENTS TARGET!");
						proxyRef.current.events.dispatchEvent(new CustomEvent("change", { detail: opBytes }));
						proxyRef.current.events.dispatchEvent(new CustomEvent("replication:change", { detail: opBytes }));
					}
					return;
				}
				handler(data);
			});
		},
		close: channel.close?.bind(channel),
		onClose: channel.onClose?.bind(channel),
	};

	const transport = createMessagePortTransport(customChannel, {
		requestTimeoutMs: (method) => {
			if (method === "waitForReplicator" || method === "waitForReplicators") {
				return undefined;
			}
			return 30_000;
		},
	});

	const raw = createProxyFromService(
		SharedLogService,
		transport,
	) as unknown as SharedLogService;

	const proxy = await createSharedLogProxyFromService(raw);
	proxyRef.current = proxy;

	const appendFn = async (bytes: Uint8Array) => {
		const msg = new Uint8Array(2 + bytes.length);
		msg[0] = 0xff;
		msg[1] = 0x01;
		msg.set(bytes, 2);
		channel.send(msg);
	};
	(proxy as any).append = appendFn;
	(proxy.log as any).append = appendFn;

	const rawClose = proxy.close.bind(proxy);
	proxy.close = async () => {
		try {
			await rawClose();
		} finally {
			channel.close?.();
		}
	};
	return proxy;
};
	export const minderLogAdapter = createVariantAdapter<MinderLog, MinderLogProxy>({
	name: "minder-log",
	variant: "minder-log",
	open: async ({ program, address, client, options }: any) => {
		const targetAddress = address || (program ? (await program.calculateAddress()).address : "");
		const proxy = await openMinderLog({ client, address: targetAddress, program, create: options?.create === true });
		return { proxy, address: targetAddress };
	},
});
