# Decentralized offline-first replicated databases

For now we just need a simple append-only log for our RON frames, that replicates to other devices with NAT hole-punching included. All non-internet sync methods are welcome, especially something like local Bluetooth sync.

## WebNative
- Uses IPFS, custom block-sync solution (not Helia)
- has a public+private filesystem, Webnative File System, where private is encrypted
- adds auth and account sharing, adding devices

## OrbitDb
- Uses IPFS, now Helia
- Berty uses it

## Peerbit
- Uses LibP2P, custom block-sync solution (not Helia)
- Designed to be super low latency

## Berty Protocol
- On top of orbitDb, details are settled
- IPFS transport includes Bluetooth!
- Not yet ready
- add a new device by QR code

## Hypercore
- Simple append-only logs is all we need
- No IPFS required, probably lighter