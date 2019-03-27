"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const os = require("os");
const dgram = require("dgram");
const events = require("events");
const netmask_1 = require("netmask");
const PREFIX = 'ION_DP';
const PORT = 41234;
class Publisher extends events.EventEmitter {
    constructor(namespace, name, port) {
        super();
        this.namespace = namespace;
        this.name = name;
        this.port = port;
        this.path = '/';
        this.running = false;
        this.interval = 2000;
        if (name.indexOf(':') >= 0) {
            console.warn('name should not contain ":"');
            name = name.replace(':', ' ');
        }
        this.id = String(Math.round(Math.random() * 1000000));
    }
    start() {
        return new Promise((resolve, reject) => {
            if (this.running) {
                return resolve();
            }
            this.running = true;
            const client = this.client = dgram.createSocket('udp4');
            client.on('error', err => {
                this.emit('error', err);
            });
            client.on('listening', () => {
                client.setBroadcast(true);
                this.timer = setInterval(this.sayHello.bind(this), this.interval);
                this.sayHello();
                resolve();
            });
            client.bind();
        });
    }
    stop() {
        if (!this.running) {
            return;
        }
        this.running = false;
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = undefined;
        }
        if (this.client) {
            this.client.close();
            this.client = undefined;
        }
    }
    buildMessage(ip) {
        const now = Date.now();
        const message = {
            t: now,
            id: this.id,
            nspace: this.namespace,
            name: this.name,
            host: os.hostname(),
            ip: ip,
            port: this.port,
            path: this.path
        };
        return PREFIX + JSON.stringify(message);
    }
    sayHello() {
        try {
            for (let iface of this.getInterfaces()) {
                const message = new Buffer(this.buildMessage(iface.address));
                this.client.send(message, 0, message.length, PORT, iface.broadcast, err => {
                    if (err) {
                        this.emit('error', err);
                    }
                });
            }
        }
        catch (e) {
            this.emit('error', e);
        }
    }
    getInterfaces() {
        return prepareInterfaces(os.networkInterfaces());
    }
}
exports.Publisher = Publisher;
function prepareInterfaces(interfaces) {
    const set = new Set();
    return Object.keys(interfaces)
        .map(key => interfaces[key])
        .reduce((prev, current) => prev.concat(current))
        .filter(iface => iface.family === 'IPv4')
        .map(iface => {
        return {
            address: iface.address,
            broadcast: computeMulticast(iface.address, iface.netmask),
        };
    })
        .filter(iface => {
        if (!set.has(iface.broadcast)) {
            set.add(iface.broadcast);
            return true;
        }
        return false;
    });
}
exports.prepareInterfaces = prepareInterfaces;
function newSilentPublisher(namespace, name, port) {
    name = `${name}@${port}`;
    const service = new Publisher(namespace, name, port);
    service.on('error', () => { });
    service.start().catch(() => { });
    return service;
}
exports.newSilentPublisher = newSilentPublisher;
function computeMulticast(address, netmask) {
    const ip = address + '/' + netmask;
    const block = new netmask_1.Netmask(ip);
    return block.broadcast;
}
