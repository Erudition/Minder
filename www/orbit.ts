import {create} from 'ipfs'
import OrbitDb from 'orbit-db'

// if (globalThis && globalThis.process && globalThis.process.env)
// 	globalThis.process.env.LIBP2P_FORCE_PNET = false;

const ipfsConfig = {
  preload: { enabled: false }, // Prevents large data transfers
  repo: '/minder/0.0',
  config: {
    Addresses: {
      Swarm: [
        // Use IPFS dev signal server
        // Websocket:
        // '/dns4/ws-star-signal-1.servep2p.com/tcp/443/wss/p2p-websocket-star',
        // '/dns4/ws-star-signal-2.servep2p.com/tcp/443/wss/p2p-websocket-star',
        // '/dns4/ws-star.discovery.libp2p.io/tcp/443/wss/p2p-websocket-star',
        // WebRTC:
        // '/dns4/star-signal.cloud.ipfs.team/wss/p2p-webrtc-star',
        '/dns4/wrtc-star1.par.dwebops.pub/tcp/443/wss/p2p-webrtc-star/',
        '/dns4/wrtc-star2.sjc.dwebops.pub/tcp/443/wss/p2p-webrtc-star/',
        '/dns4/webrtc-star.discovery.libp2p.io/tcp/443/wss/p2p-webrtc-star/',
        '/dns4/wrtc-star1.par.dwebops.pub/tcp/443/wss/p2p-webrtc-star/',
        '/dns4/wrtc-star2.sjc.dwebops.pub/tcp/443/wss/p2p-webrtc-star/',
        '/dns4/secure-beyond-12878.herokuapp.com/tcp/443/wss/p2p-webrtc-star/',
        // Use local signal server
        // '/ip4/0.0.0.0/tcp/9090/wss/p2p-webrtc-star',
      ]
    },
  }
}

// Configuration for the database
const dbConfig = {
  // If database doesn't exist, create it?
  create: true,
  // Wait to load from the network?
  sync: true,
  // Load only the local version of the database
  //localOnly: true,
  // Allow anyone to write to the database,
  // otherwise only the creator of the database can write
  accessController: {
    write: ['*'],
  }
}

const store = async (name) => {
  // Create IPFS instance
  const ipfs = await create(ipfsConfig)
  // Create an OrbitDB instance
  const orbitdb = await OrbitDb.createInstance(ipfs)
  // Open (or create) database
  const db = await orbitdb.log(name, dbConfig)
  // Done
  return db
}

export async function startOrbit() {
  
  const ipfs = await create(ipfsConfig)
  const orbitdb = await OrbitDb.createInstance(ipfs)
  
  // Create / Open a database
  const db = await orbitdb.log("minder5", dbConfig)
  await db.load()
  console.log("OrbitDB database started at ", db.address.toString())

  // Listen for updates from peers
  // db.events.on("replicated", address => {
  //   console.log(db.iterator({ limit: -1 }).collect())
  // })

  // Add an entry
  // const hash = await db.add("@0+s0	:lww ;.❃")
  // console.log(hash)

  // Query
  //
  //console.log(JSON.stringify(result, null, 2))

  // db.events.on('peer', (peer) => {
  //   console.log("New peer connected!", peer);
  // } )

  db.events.on('write', (address, entry, heads) => {
    console.log("Wrote entry to database. ", entry);
  } )

  db.events.on('ready', (dbname, heads) => {
    console.log("Loaded locally cached database ", dbname);
  } )

  return db;
}
