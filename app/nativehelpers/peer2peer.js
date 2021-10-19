//https://docs.libp2p.io/tutorials/getting-started/javascript/

require("nativescript-nodeify");

const Libp2p = require('libp2p');
const multiaddr = require('multiaddr');

// TRANSPORT modules:
//const TCP = require('libp2p-tcp'); // requires node - may try in future
const WebSockets = require('libp2p-websockets')

// CRYPTO (connection encryption) modules:
const { NOISE } = require('libp2p-noise');

// STREAM MULTIPLEXER modules:
const MPLEX = require('libp2p-mplex');


//const main = async () => {
//  const node = await Libp2p.create({
//    addresses: {
//      listen: ['/ip4/127.0.0.1/tcp/8000/ws']
//    },
//    modules: {
//      transport: [WebSockets],
//      connEncryption: [NOISE],
//      streamMuxer: [MPLEX]
//    }
//  });
//
//  // start libp2p
//  await node.start();
//  console.log('libp2p has started');
//
//  // print out listening addresses
//    const listenAddrs = node.transportManager.getAddrs()
//    console.log('libp2p is listening on the following addresses: ', listenAddrs)
//
//    const advertiseAddrs = node.multiaddrs
//    console.log('libp2p is advertising the following addresses: ', advertiseAddrs)
//
//  // stop libp2p
//  await node.stop();
//  console.log('libp2p has stopped');
//}
//
//main();
