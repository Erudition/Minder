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
