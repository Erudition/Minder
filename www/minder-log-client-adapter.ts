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

const encoder = new TextEncoder();

export type MinderLogProxy = SharedLogProxy;

/**
 * Open a MinderLog program over the canonical "minder-log" channel. The
 * program address travels as the channel payload (UTF-8 bytes); the host
 * module opens (or reuses) the underlying MinderLog and exposes its SharedLog
 * through the same SharedLogService RPC used by @peerbit/shared-log-proxy.
 */
export const openMinderLog = async (properties: {
	client: CanonicalClient;
	address: Address;
}): Promise<MinderLogProxy> => {
	const addressBytes = encoder.encode(properties.address);
	const channel = await properties.client.openPort("minder-log", addressBytes);

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
	open: async ({ program, address, client }: any) => {
		const targetAddress = address || (program ? (await program.calculateAddress()).address : "");
		const proxy = await openMinderLog({ client, address: targetAddress });
		return { proxy, address: targetAddress };
	},
});
