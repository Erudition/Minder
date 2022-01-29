const webpack = require("@nativescript/webpack");

const CircularDependencyPlugin = require('circular-dependency-plugin');
const { IgnorePlugin } = require('webpack');





const configuredCircularPlugin = new CircularDependencyPlugin(
{
 // exclude detection of files based on a RegExp
 exclude: /a\.js|node_modules|node_modules\/@nativescript\/.*/,
 // include specific files based on a RegExp
 include: /dir/,
 // add errors to webpack instead of warnings
 failOnError: false,
 // allow import cycles that include an asyncronous import,
 // e.g. via import(/* webpackMode: "weak" */ './file.js')
 allowAsyncCycles: true,
 // set the current working directory for displaying module paths
 cwd: process.cwd(),
});

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
              mainFields: ['module', 'main', 'browser'],
              alias: { "tns-core-modules": "@nativescript/core", //somehow still necessary for old node modules
                        //"url": "whatwg-url", //better replacement
                        "randombytes" : "nativescript-randombytes", // for crypto library
                        "nativescript-nodeify" : "/customized-node-modules/nativescript-nodeify",
                        "nativescript-urlhandler" : "/customized-node-modules/nativescript-urlhandler",
                        "ipfs-utils" : "/customized-node-modules/ipfs-utils",
                        "crypto" : '/customized-node-modules/nativescript-crypto',
                        "nativescript-wear-os" : '/customized-node-modules/nativescript-wear-os'
                        },
              fallback: {
//                assert: require.resolve('assert'),
//                buffer: require.resolve('buffer'),
                console: require.resolve('console-browserify'),
                constants: require.resolve('constants-browserify'),
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
                //url: require.resolve('whatwg-url'), conflict with ui-webview
                util: require.resolve('util'),
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
        config.plugin('IgnorePlugin').use(IgnorePlugin, [{ resourceRegExp: /backup/ }])
        //config.plugin('CircularDependencyPlugin').use(CircularDependencyPlugin, [configuredCircularPlugin])

      });



        webpack.Utils.addCopyRule({
            from: '**/*.*',
            to: 'assets/www',
            // the context of the "from" rule:
            context: webpack.Utils.project.getProjectFilePath('www')
          });


	return webpack.resolveConfig();
};
