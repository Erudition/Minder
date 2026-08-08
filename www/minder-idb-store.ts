import { BrowserLevel } from "browser-level";
import type { AnyStore } from "@peerbit/any-store";

// A worker-free persistent AnyStore backed by IndexedDB.
//
// Why: `Peerbit.create({ directory })` makes @peerbit/any-store's default
// browser store construct an OPFSStore, and OPFSStore's constructor
// unconditionally spawns a Worker (any-store-opfs/dist/src/create.js). The
// service worker host cannot spawn Workers (www/sw.ts installs a throwing
// LazyWorker shim), so a directory-based peer can never start there.
//
// This wrapper injects the store used for cache/blocks/keychain via
// `storage.storeFactory` (and friends) in Peerbit.create options instead,
// giving the same persistent storage with no Worker dependency. Only
// `level`'s browser backend (IndexedDB) is pulled in; it is usable from
// both service worker and window contexts.
//
// Key normalization: although the AnyStore interface types keys as strings,
// peerbit's runtime passes raw byte keys (ArrayBuffer/Uint8Array) for
// block/CID and keychain storage. browser-level's utf8 keyEncoding coerces
// those with String(), collapsing every byte key to "[object ArrayBuffer]".
// Byte-keyed writes still round-trip (identical mangling on read), but
// program entries are later looked up by their base58btc *string* address,
// which misses. Encoding byte keys as base58btc (the exact string form
// peerbit uses for CID-based addresses) makes both spellings collide.

const BASE58_ALPHABET =
	"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

function encodeBase58btc(bytes: Uint8Array): string {
	let zeros = 0;
	while (zeros < bytes.length && bytes[zeros] === 0) zeros++;
	let num = 0n;
	for (const b of bytes) {
		num = num * 256n + BigInt(b);
	}
	let out = "";
	while (num > 0n) {
		out = BASE58_ALPHABET[Number(num % 58n)] + out;
		num /= 58n;
	}
	while (zeros--) {
		out = "1" + out;
	}
	return out;
}

function normalizeKey(key: unknown): string {
	if (typeof key === "string") {
		return key;
	}
	const bytes =
		key instanceof Uint8Array
			? key
			: key instanceof ArrayBuffer
				? new Uint8Array(key)
				: undefined;
	if (bytes) {
		return encodeBase58btc(bytes);
	}
	// Defensive: never silently collapse a key to "[object X]" like the utf8
	// keyEncoding coercion does.
	return String(key);
}

type LevelStore = BrowserLevel<string, Uint8Array>;

// Structural subset of a level DB (BrowserLevel or one of its sublevels)
// sufficient for the AnyStore surface. Sublevels are created with
// valueEncoding "view", but their TYPE still declares the default value type
// (string), so the concrete class is narrowed to this view-typed interface at
// the sublevel creation boundary instead of fighting the generics.
interface LevelLike {
	status: "opening" | "open" | "closing" | "closed";
	open(options?: { passive?: boolean }): Promise<void>;
	close(): Promise<void>;
	get(
		key: string,
		options?: { valueEncoding?: string },
	): Promise<Uint8Array | undefined>;
	put(
		key: string,
		value: Uint8Array,
		options?: { valueEncoding?: string },
	): Promise<void>;
	del(key: string): Promise<void>;
	clear(): Promise<void>;
	iterator(options?: {
		valueEncoding?: string;
	}): AsyncIterable<[string, Uint8Array]>;
	sublevel(name: string, options?: { valueEncoding?: string }): LevelLike;
}

export class IndexedDBStore implements AnyStore {
	private readonly store: LevelStore;

	constructor(location: string) {
		this.store = new BrowserLevel<string, Uint8Array>(location, {
			valueEncoding: "view",
		});
	}

	status(): "opening" | "open" | "closing" | "closed" {
		return this.store.status;
	}

	async open(): Promise<void> {
		await this.store.open();
	}

	async close(): Promise<void> {
		if (this.store.status !== "closed" && this.store.status !== "closing") {
			await this.store.close();
		}
	}

	async get(key: string): Promise<Uint8Array | undefined> {
		// browser-level returns undefined for missing keys (abstract-level
		// semantics), matching AnyStore.get's contract.
		return this.store.get(normalizeKey(key), { valueEncoding: "view" });
	}

	async put(key: string, value: Uint8Array): Promise<void> {
		// IndexedDB transactions are durable once they complete, so unlike the
		// Node ClassicLevel reference there is no sync option to pass.
		await this.store.put(normalizeKey(key), value, {
			valueEncoding: "view",
		});
	}

	async del(key: string): Promise<void> {
		if (this.store.status !== "open") {
			throw new Error("Cache store not open: " + this.store.status);
		}
		await this.store.del(normalizeKey(key));
	}

	async clear(): Promise<void> {
		await this.store.clear();
	}

	async *iterator(): AsyncGenerator<[string, Uint8Array]> {
		const it = this.store.iterator({ valueEncoding: "view" });
		for await (const [key, value] of it) {
			yield [key, value];
		}
	}

	async size(): Promise<number> {
		let size = 0;
		for await (const [, value] of this.iterator()) {
			size += value.length;
		}
		return size;
	}

	persisted(): boolean {
		return true;
	}

	async sublevel(name: string): Promise<AnyStore> {
		const sub = this.store.sublevel(name, { valueEncoding: "view" });
		return new IndexedDBStoreFromLevel(sub as unknown as LevelLike);
	}
}

// Wraps an existing BrowserLevel (used for sublevels) with the same AnyStore
// surface as IndexedDBStore, minus store construction.
class IndexedDBStoreFromLevel implements AnyStore {
	constructor(private readonly store: LevelLike) {}

	status(): "opening" | "open" | "closing" | "closed" {
		return this.store.status;
	}

	async open(): Promise<void> {
		await this.store.open();
	}

	async close(): Promise<void> {
		if (this.store.status !== "closed" && this.store.status !== "closing") {
			await this.store.close();
		}
	}

	async get(key: string): Promise<Uint8Array | undefined> {
		return this.store.get(normalizeKey(key), { valueEncoding: "view" });
	}

	async put(key: string, value: Uint8Array): Promise<void> {
		// IndexedDB transactions are durable once they complete, so unlike the
		// Node ClassicLevel reference there is no sync option to pass.
		await this.store.put(normalizeKey(key), value, {
			valueEncoding: "view",
		});
	}

	async del(key: string): Promise<void> {
		if (this.store.status !== "open") {
			throw new Error("Cache store not open: " + this.store.status);
		}
		await this.store.del(normalizeKey(key));
	}

	async clear(): Promise<void> {
		await this.store.clear();
	}

	async *iterator(): AsyncGenerator<[string, Uint8Array]> {
		const it = this.store.iterator({ valueEncoding: "view" });
		for await (const [key, value] of it) {
			yield [key, value];
		}
	}

	async size(): Promise<number> {
		let size = 0;
		for await (const [, value] of this.iterator()) {
			size += value.length;
		}
		return size;
	}

	persisted(): boolean {
		return true;
	}

	async sublevel(name: string): Promise<AnyStore> {
		const sub = this.store.sublevel(name, { valueEncoding: "view" });
		return new IndexedDBStoreFromLevel(sub as unknown as LevelLike);
	}
}
