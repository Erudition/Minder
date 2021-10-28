//https://docs.libp2p.io/tutorials/getting-started/javascript/

console.log("Loading libp2p patches.");
require("nativescript-nodeify");
global.process.versions.node = "yes"; // because "utils" checks for node or browser and finds neither
require('util'); // because the node implementation gets in the way
const URL = require('url');

console.log("Loading libp2p libraries.");
const Libp2p = require('libp2p');
const multiaddr = require('multiaddr');

// TRANSPORT modules:
//const TCP = require('libp2p-tcp'); // requires node - may try in future
const WebSockets = require('libp2p-websockets');
const WebRTCStar = require('libp2p-webrtc-star');

import { WebRTC } from 'nativescript-webrtc-plugin';

// CRYPTO (connection encryption) modules:
const { NOISE } = require('libp2p-noise');

// STREAM MULTIPLEXER modules:
const MPLEX = require('libp2p-mplex');

// PEER DISCOVERY modules:
const MDNS = require('libp2p-mdns');

const transportKey = WebRTCStar.prototype[Symbol.toStringTag];
// SETTINGS
let nodeSettings = {
   addresses: {
     listen: ['/ip4/188.166.203.82/tcp/20000/wss/p2p-webrtc-star/p2p/QmcgpsyWgH8Y8ajJz1Cu72KnS5uo2Aa2LpzU7kinSooo2a',
     '/dns4/wrtc-star1.par.dwebops.pub/tcp/443/wss/p2p-webrtc-star', '/dns4/wrtc-star2.sjc.dwebops.pub/tcp/443/wss/p2p-webrtc-star']
   },
   modules: {
     transport: [WebSockets, WebRTCStar],
     connEncryption: [NOISE],
     streamMuxer: [MPLEX]
   },
   config: {
       transport: {
         [transportKey]: {
           wrtc: WebRTC
         }
       }
     }
 };


// STEP 1 - create

console.log("Initializing libp2p node.");


let myLibp2pNode = Libp2p.create(nodeSettings).then(nodeCreationSucceeded, nodeCreationFailed);


import { Trace, TraceErrorHandler } from "@nativescript/core";

function nodeCreationFailed(error) {
            console.error("Error creating Libp2p node.", error.stack);
}


// STEP 2 - start


function nodeCreationSucceeded(node) {
  console.log("Successfully created Libp2p node! Starting it now.");

debugger;
  node.start().then(result => nodeStartSucceeded(node), nodeStartFailed);
}

function nodeStartFailed(error) {
   console.error("Error starting Libp2p node.", error.stack);
}


// STEP 3 -

function nodeStartSucceeded(node) {
  console.log("Successfully started Libp2p node.");


//   console.log("Looking at the transport manager...");
  const transman = node.transportManager;
//  console.dir(transman);
//    console.log("looked it in the eyes! getting addresses...");

  const listenAddrs = transman.getAddrs()
  console.log('libp2p is listening on the following addresses: ', listenAddrs);

  console.log("getting advertising addresses...");

//  const advertiseAddrs = node.multiaddrs
  console.log('libp2p is advertising the following addresses: ', node.multiaddrs)
}



//const main = async () => {
//  const node = await Libp2p.create(nodeSettings);
//
//  // start libp2p
//  await node.start();
//  console.log('libp2p has started');
//

//
//  // stop libp2p
//  await node.stop();
//  console.log('libp2p has stopped');
//}
//console.log("about to launch main async function for p2p");
//main();
//console.log("launched main async function for p2p");


console.log("End of peer2peer.js");
