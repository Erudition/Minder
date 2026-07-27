import assert from "node:assert";
import { createPeerbitHost } from "./peerbit-host.js";

async function main() {
	// Given a fresh Peerbit host
	const host = await createPeerbitHost();

	// When a RON op is appended
	const op = "*lww#id@time!:key'value'";
	await host.appendOp(op);

	// Then the same op can be read back
	const ops = await host.getAllOps();
	assert.deepStrictEqual(ops, [op]);

	await host.close();
	console.log("PASS");
}

main().catch((error) => {
	console.error("FAIL:", error);
	process.exit(1);
});
