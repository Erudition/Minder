const webpack = require("@nativescript/webpack");

module.exports = (env) => {
	webpack.init(env);

	// Learn how to customize:
	// https://docs.nativescript.org/webpack

	// added for sake of libp2p dependencies
	  // using a function
      webpack.mergeWebpack(env => {
        // return the object to be merged
        return {
          resolve: {
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
                fs: "empty",
                child_process: "empty",
                net: "empty",
                tls: "empty",
                dns: "empty",
                dgram: "empty",
              },
            }
        }
      })



	return webpack.resolveConfig();
};


