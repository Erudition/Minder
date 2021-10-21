const webpack = require("@nativescript/webpack");

const { IgnorePlugin } = require('webpack');

module.exports = (env) => {
	webpack.init(env);

//config.resolve.alias.set('tns-core-modules', '@nativescript/core');

	// Learn how to customize:
	// https://docs.nativescript.org/webpack

	// added for sake of libp2p dependencies
	  // using a function
      webpack.mergeWebpack(env => {
        // return the object to be merged
        return {
          resolve: {
              alias: { "tns-core-modules": "@nativescript/core" }, //somehow still necessary for old node modules
              fallback: {
//                assert: require.resolve('assert'),
//                buffer: require.resolve('buffer'),
                console: require.resolve('console-browserify'),
                constants: require.resolve('constants-browserify'),
                crypto: require.resolve('crypto-browserify'),
//                domain: require.resolve('domain-browser'),
                events: require.resolve('events'),
                http: require.resolve('stream-http'),
                https: require.resolve('https-browserify'),
                os: require.resolve('os-browserify/browser'),
                path: require.resolve('path-browserify'),
//                punycode: require.resolve('punycode'),
//                process: require.resolve('process/browser'),
//                querystring: require.resolve('querystring-es3'),
                stream: require.resolve('stream-browserify'),
//                string_decoder: require.resolve('string_decoder'),
//                sys: require.resolve('util'),
                timers: require.resolve('timers-browserify'),
                tty: require.resolve('tty-browserify'),
                url: require.resolve('url'),
//                util: require.resolve('util'),
                vm: require.resolve('vm-browserify'),
                zlib: require.resolve('browserify-zlib'),
                "fs": false,
                "child_process": false,
                "net": false,
                "tls": false,
                "dns": false,
                "dgram": false,
                "_stream_transform": require.resolve("readable-stream"),
              },
            }
        }
      })



      // using the IgnorePlugin so we don't get errors from direc
      webpack.chainWebpack(config => {
        // we add the plugin
        config.plugin('IgnorePlugin').use(IgnorePlugin, [{ resourceRegExp: /backup/ }]) });


	return webpack.resolveConfig();
};


