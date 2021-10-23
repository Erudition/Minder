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
const TCP = require('libp2p-tcp');

// CRYPTO (connection encryption) modules:
const { NOISE } = require('libp2p-noise');

// STREAM MULTIPLEXER modules:
const MPLEX = require('libp2p-mplex');

// PEER DISCOVERY modules:
const MDNS = require('libp2p-mdns');

let nodeSettings = {
   addresses: {
     listen: ['/ip4/127.0.0.1/tcp/8000/ws']
   },
   modules: {
     transport: [WebSockets],
     connEncryption: [NOISE],
     streamMuxer: [MPLEX]
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
//  console.log("Looking at the node..." + node);
//    console.dir(node);
  node.start().then(result => nodeStartSucceeded(node), nodeStartFailed);
}

function nodeStartFailed(error) {
   console.error("Error starting Libp2p node.", error.stack);
}


// STEP 3 -

function nodeStartSucceeded(node) {
  console.log("Successfully started Libp2p node.");

//console.log("Looking at the node...");
//  console.dir(node);

   console.log("Looking at the transport manager...");
  const transman = node.transportManager;
  console.dir(transman);
    console.log("looked it in the eyes! getting addresses...");

  const listenAddrs = transman.getAddrs()
  console.log('libp2p is listening on the following addresses: ');

  const advertiseAddrs = node.multiaddrs
  console.log('libp2p is advertising the following addresses: ', advertiseAddrs)
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
