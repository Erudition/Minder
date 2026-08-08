const fs = require('fs');
const path = require('path');

const pnpmDir = path.join('node_modules', '.pnpm');
const entries = fs.readdirSync(pnpmDir);

function findPnpmDir(namePrefix) {
	const pkgDir = entries.find((e) => e.startsWith(namePrefix));
	if (!pkgDir) {
		throw new Error(`${namePrefix} not found in node_modules/.pnpm`);
	}
	return path.join(pnpmDir, pkgDir, 'node_modules');
}

function copyAssetDir(sourceDir, targetDir) {
	fs.mkdirSync(targetDir, { recursive: true });
	const files = fs.readdirSync(sourceDir);
	for (const file of files) {
		fs.copyFileSync(path.join(sourceDir, file), path.join(targetDir, file));
	}
	return files.length;
}

const indexerDir = findPnpmDir('@peerbit+indexer-sqlite3@');
const sqlite3Source = path.join(indexerDir, '@peerbit', 'indexer-sqlite3', 'dist', 'assets', 'sqlite3');
const sqlite3Target = path.join('www', 'vite-extra-assets', 'peerbit', 'sqlite3');
const sqlite3Count = copyAssetDir(sqlite3Source, sqlite3Target);
console.log(`Copied ${sqlite3Count} Peerbit SQLite3 assets to`, sqlite3Target);

const ribltDir = findPnpmDir('@peerbit+riblt@');
const ribltSource = path.join(ribltDir, '@peerbit', 'riblt', 'dist', 'assets', 'riblt');
const ribltTarget = path.join('www', 'vite-extra-assets', 'peerbit', 'riblt');
const ribltCount = copyAssetDir(ribltSource, ribltTarget);
console.log(`Copied ${ribltCount} Peerbit riblt assets to`, ribltTarget);

const opfsDir = findPnpmDir('@peerbit+any-store-opfs@');
const opfsSource = path.join(opfsDir, '@peerbit', 'any-store-opfs', 'dist', 'assets', 'opfs');
const opfsTarget = path.join('www', 'vite-extra-assets', 'peerbit', 'opfs');
const opfsCount = copyAssetDir(opfsSource, opfsTarget);
console.log(`Copied ${opfsCount} Peerbit OPFS assets to`, opfsTarget);

// wasm files loaded by the SW host runtime via package-relative '../wasm/...'
// URLs that break in the bundled sw.js. Copy them un-hashed under peerbit/wasm/
// so the SW's fetch shim can serve them from the deployment root.
const wasmTarget = path.join('www', 'vite-extra-assets', 'peerbit', 'wasm');

const sharedLogRustDir = findPnpmDir('@peerbit+shared-log-rust@');
const sharedLogRustSource = path.join(sharedLogRustDir, '@peerbit', 'shared-log-rust', 'dist', 'wasm');
const sharedLogRustCount = copyAssetDir(sharedLogRustSource, wasmTarget);
console.log(`Copied ${sharedLogRustCount} shared-log-rust wasm assets to`, wasmTarget);

const nativeBackboneDir = findPnpmDir('@peerbit+native-backbone@');
const nativeBackboneSource = path.join(nativeBackboneDir, '@peerbit', 'native-backbone', 'dist', 'wasm');
const nativeBackboneCount = copyAssetDir(nativeBackboneSource, wasmTarget);
console.log(`Copied ${nativeBackboneCount} native-backbone wasm assets to`, wasmTarget);
