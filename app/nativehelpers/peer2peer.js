//https://docs.libp2p.io/tutorials/getting-started/javascript/

const Libp2p = require('libp2p');
const multiaddr = require('multiaddr');

// TRANSPORT modules:
const TCP = require('libp2p-tcp');

// CRYPTO (connection encryption) modules:
const { NOISE } = require('libp2p-noise');

// STREAM MULTIPLEXER modules:
const MPLEX = require('libp2p-mplex');


const main = async () => {
  const node = await Libp2p.create({
    addresses: {
      // add a listen address (localhost) to accept TCP connections on a random port
      listen: ['/ip4/127.0.0.1/tcp/0']
    },
    modules: {
      transport: [TCP],
      connEncryption: [NOISE],
      streamMuxer: [MPLEX]
    }
  });

  // start libp2p
  await node.start();
  console.log('libp2p has started');

  // print out listening addresses
  console.log('listening on addresses:');
  node.multiaddrs.forEach(addr => {
    console.log(`${addr.toString()}/p2p/${node.peerId.toB58String()}`)
  });

  // stop libp2p
  await node.stop();
  console.log('libp2p has stopped');
}

main();
