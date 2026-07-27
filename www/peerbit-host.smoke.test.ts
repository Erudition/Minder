import assert from "node:assert";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { Peerbit } from "peerbit";
import { createPeerbitHost } from "./peerbit-host.js";

const SYNC_TIMEOUT_MS = 30_000;
const POLL_INTERVAL_MS = 250;

async function waitForOp(
	host: Awaited<ReturnType<typeof createPeerbitHost>>,
	op: string,
	timeoutMs = SYNC_TIMEOUT_MS,
): Promise<void> {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		const ops = await host.getAllOps();
		if (ops.includes(op)) {
			return;
		}
		await new Promise((resolve) => setTimeout(resolve, POLL_INTERVAL_MS));
	}
	const finalOps = await host.getAllOps();
	throw new Error(
		`Timed out waiting for op after ${timeoutMs}ms. Expected ${JSON.stringify(
			op,
		)} in ${JSON.stringify(finalOps)}`,
	);
}

async function testOfflineAppendAndReadBack(): Promise<void> {
	const host = await createPeerbitHost({
		directory: "/tmp/minder-smoke-offline",
	});

	try {
		const op = "*lww#offline@time!:key'offline-value'";
		await host.appendOp(op);

		const ops = await host.getAllOps();
		assert.deepStrictEqual(ops, [op], "offline host should read back its own op");
	} finally {
		await host.close();
	}
}

async function testTwoClientSync(): Promise<void> {
	const hostA = await createPeerbitHost({
		directory: "/tmp/minder-smoke-a",
	});
	let clientB: Peerbit | undefined;
	let hostB: Awaited<ReturnType<typeof createPeerbitHost>> | undefined;

	try {
		clientB = await Peerbit.create({ directory: "/tmp/minder-smoke-b" });

		const multiaddrs = hostA.client.libp2p.getMultiaddrs();
		assert.ok(
			multiaddrs.length > 0,
			"host A should advertise at least one multiaddr",
		);
		const connected = await clientB.dial(multiaddrs, {
			readiness: "services",
			serviceWaitTimeoutMs: 30_000,
		});
		assert.ok(connected, "client B should dial host A successfully");

		// Wait for the blocks direct stream to settle so that client B can resolve
		// the program manifest from host A.
		await clientB.services.blocks.waitFor(hostA.client.identity.publicKey, {
			seek: "present",
			timeout: 30_000,
		});

		hostB = await createPeerbitHost({
			client: clientB,
			programAddress: hostA.programAddress,
		});

		const op = "*lww#sync@time!:key'synced-value'";
		await hostA.appendOp(op);

		await waitForOp(hostB, op);
		const opsB = await hostB.getAllOps();
		assert.deepStrictEqual(
			opsB,
			[op],
			"host B should observe the op appended by host A",
		);
	} finally {
		await hostA.close();
		await hostB?.close();
	}
}

async function testRestartPersistence(): Promise<void> {
	const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "minder-smoke-restart-"));
	const op = "*lww#restart@time!:key'restart-value'";

	const host1 = await createPeerbitHost({ directory: tempDir });
	let programAddress: string;
	try {
		await host1.appendOp(op);
		const ops1 = await host1.getAllOps();
		assert.deepStrictEqual(
			ops1,
			[op],
			"first host should read back its own op",
		);
		programAddress = host1.programAddress;
	} finally {
		await host1.close();
	}

	const host2 = await createPeerbitHost({
		directory: tempDir,
		programAddress,
	});
	try {
		const ops2 = await host2.getAllOps();
		assert.deepStrictEqual(
			ops2,
			[op],
			"second host should recover the op from the same directory",
		);
	} finally {
		await host2.close();
	}
}

async function main() {
	await testOfflineAppendAndReadBack();
	console.log("OFFLINE PASS");

	await testTwoClientSync();
	console.log("SYNC PASS");

	await testRestartPersistence();
	console.log("RESTART PERSISTENCE PASS");

	console.log("ALL PASS");
}

main().catch((error) => {
	console.error("FAIL:", error);
	process.exit(1);
});
