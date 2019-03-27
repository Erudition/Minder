'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var https = require('https');

/*! *****************************************************************************
Copyright (c) Microsoft Corporation. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at http://www.apache.org/licenses/LICENSE-2.0

THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
MERCHANTABLITY OR NON-INFRINGEMENT.

See the Apache Version 2.0 License for specific language governing permissions
and limitations under the License.
***************************************************************************** */

function __awaiter(thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
}

/**
 * SSR Attribute Names
 */

const TASK_CANCELED_MSG = `task canceled`;
function shouldIgnoreError(msg) {
    return (msg === TASK_CANCELED_MSG);
}
function normalizePath(str) {
    // Convert Windows backslash paths to slash paths: foo\\bar ➔ foo/bar
    // https://github.com/sindresorhus/slash MIT
    // By Sindre Sorhus
    if (typeof str !== 'string') {
        throw new Error(`invalid path to normalize`);
    }
    str = str.trim();
    if (EXTENDED_PATH_REGEX.test(str) || NON_ASCII_REGEX.test(str)) {
        return str;
    }
    str = str.replace(SLASH_REGEX, '/');
    // always remove the trailing /
    // this makes our file cache look ups consistent
    if (str.charAt(str.length - 1) === '/') {
        const colonIndex = str.indexOf(':');
        if (colonIndex > -1) {
            if (colonIndex < str.length - 2) {
                str = str.substring(0, str.length - 1);
            }
        }
        else if (str.length > 1) {
            str = str.substring(0, str.length - 1);
        }
    }
    return str;
}
const EXTENDED_PATH_REGEX = /^\\\\\?\\/;
const NON_ASCII_REGEX = /[^\x00-\x80]+/;
const SLASH_REGEX = /\\/g;

function getConfigFilePath(process, sys, configArg) {
    if (configArg) {
        if (!sys.path.isAbsolute(configArg)) {
            // passed in a custom stencil config location
            // but it's relative, so prefix the cwd
            return normalizePath(sys.path.join(process.cwd(), configArg));
        }
        // config path already an absolute path, we're good here
        return normalizePath(configArg);
    }
    // nothing was passed in, use the current working directory
    return normalizePath(process.cwd());
}
function hasError$1(diagnostics) {
    if (!diagnostics) {
        return false;
    }
    return diagnostics.some(d => d.level === 'error' && d.type !== 'runtime');
}

const toLowerCase = (str) => str.toLowerCase();
const dashToPascalCase = (str) => toLowerCase(str).split('-').map(segment => segment.charAt(0).toUpperCase() + segment.slice(1)).join('');

function parseFlags(process) {
    const flags = {
        task: null,
        args: [],
        knownArgs: [],
        unknownArgs: null
    };
    // cmd line has more priority over npm scripts cmd
    flags.args = process.argv.slice(2);
    if (flags.args.length > 0 && flags.args[0] && !flags.args[0].startsWith('-')) {
        flags.task = flags.args[0];
    }
    parseArgs(flags, flags.args, flags.knownArgs);
    const npmScriptCmdArgs = getNpmScriptArgs(process);
    parseArgs(flags, npmScriptCmdArgs, flags.knownArgs);
    npmScriptCmdArgs.forEach(npmArg => {
        if (!flags.args.includes(npmArg)) {
            flags.args.push(npmArg);
        }
    });
    if (flags.task != null) {
        const i = flags.args.indexOf(flags.task);
        if (i > -1) {
            flags.args.splice(i, 1);
        }
    }
    flags.unknownArgs = flags.args.filter((arg) => {
        return !flags.knownArgs.includes(arg);
    });
    return flags;
}
function parseArgs(flags, args, knownArgs) {
    ARG_OPTS.boolean.forEach(booleanName => {
        const alias = ARG_OPTS.alias[booleanName];
        const flagKey = configCase(booleanName);
        if (typeof flags[flagKey] !== 'boolean') {
            flags[flagKey] = null;
        }
        args.forEach(cmdArg => {
            if (cmdArg === `--${booleanName}`) {
                flags[flagKey] = true;
                knownArgs.push(cmdArg);
            }
            else if (cmdArg === `--no-${booleanName}`) {
                flags[flagKey] = false;
                knownArgs.push(cmdArg);
            }
            else if (alias && cmdArg === `-${alias}`) {
                flags[flagKey] = true;
                knownArgs.push(cmdArg);
            }
        });
    });
    ARG_OPTS.string.forEach(stringName => {
        const alias = ARG_OPTS.alias[stringName];
        const flagKey = configCase(stringName);
        if (typeof flags[flagKey] !== 'string') {
            flags[flagKey] = null;
        }
        for (let i = 0; i < args.length; i++) {
            const cmdArg = args[i];
            if (cmdArg.startsWith(`--${stringName}=`)) {
                const values = cmdArg.split('=');
                values.shift();
                flags[flagKey] = values.join('=');
                knownArgs.push(cmdArg);
            }
            else if (cmdArg === `--${stringName}`) {
                flags[flagKey] = args[i + 1];
                knownArgs.push(cmdArg);
                knownArgs.push(args[i + 1]);
            }
            else if (alias) {
                if (cmdArg.startsWith(`-${alias}=`)) {
                    const values = cmdArg.split('=');
                    values.shift();
                    flags[flagKey] = values.join('=');
                    knownArgs.push(cmdArg);
                }
                else if (cmdArg === `-${alias}`) {
                    flags[flagKey] = args[i + 1];
                    knownArgs.push(args[i + 1]);
                }
            }
        }
    });
    ARG_OPTS.number.forEach(numberName => {
        const alias = ARG_OPTS.alias[numberName];
        const flagKey = configCase(numberName);
        if (typeof flags[flagKey] !== 'number') {
            flags[flagKey] = null;
        }
        for (let i = 0; i < args.length; i++) {
            const cmdArg = args[i];
            if (cmdArg.startsWith(`--${numberName}=`)) {
                const values = cmdArg.split('=');
                values.shift();
                flags[flagKey] = parseInt(values.join(''), 10);
                knownArgs.push(cmdArg);
            }
            else if (cmdArg === `--${numberName}`) {
                flags[flagKey] = parseInt(args[i + 1], 10);
                knownArgs.push(args[i + 1]);
            }
            else if (alias) {
                if (cmdArg.startsWith(`-${alias}=`)) {
                    const values = cmdArg.split('=');
                    values.shift();
                    flags[flagKey] = parseInt(values.join(''), 10);
                    knownArgs.push(cmdArg);
                }
                else if (cmdArg === `-${alias}`) {
                    flags[flagKey] = parseInt(args[i + 1], 10);
                    knownArgs.push(args[i + 1]);
                }
            }
        }
    });
    return flags;
}
function configCase(prop) {
    prop = dashToPascalCase(prop);
    return prop.charAt(0).toLowerCase() + prop.substr(1);
}
const ARG_OPTS = {
    boolean: [
        'build',
        'cache',
        'check-version',
        'ci',
        'compare',
        'debug',
        'dev',
        'docs',
        'e2e',
        'es5',
        'esm',
        'headless',
        'help',
        'log',
        'open',
        'prerender',
        'prerender-external',
        'prod',
        'profile',
        'service-worker',
        'screenshot',
        'serve',
        'skip-node-check',
        'spec',
        'stats',
        'update-screenshot',
        'version',
        'watch'
    ],
    number: [
        'max-workers',
        'port'
    ],
    string: [
        'address',
        'config',
        'docs-json',
        'emulate',
        'log-level',
        'root',
        'screenshot-connector'
    ],
    alias: {
        'config': 'c',
        'help': 'h',
        'port': 'p',
        'version': 'v'
    }
};
function getNpmScriptArgs(process) {
    // process.env.npm_config_argv
    // {"remain":["4444"],"cooked":["run","serve","--port","4444"],"original":["run","serve","--port","4444"]}
    let args = [];
    try {
        if (process.env) {
            const npmConfigArgs = process.env.npm_config_argv;
            if (npmConfigArgs) {
                args = JSON.parse(npmConfigArgs).original;
                if (args[0] === 'run') {
                    args = args.slice(2);
                }
            }
        }
    }
    catch (e) { }
    return args;
}

function getLatestCompilerVersion(sys, logger) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const lastCheck = yield getLastCheck(sys.storage);
            if (lastCheck == null) {
                // we've never check before, so probably first install, so don't bother
                // save that we did just do a check though
                yield setLastCheck(sys.storage);
                return null;
            }
            if (!requiresCheck(Date.now(), lastCheck, CHECK_INTERVAL)) {
                // within the range that we did a check recently, so don't bother
                return null;
            }
            // remember we just did a check
            yield setLastCheck(sys.storage);
            const latestVersion = yield sys.requestLatestCompilerVersion();
            return latestVersion;
        }
        catch (e) {
            // quietly catch, could have no network connection which is fine
            logger.debug(`checkVersion error: ${e}`);
        }
        return null;
    });
}
function validateCompilerVersion(config, latestVersionPromise) {
    return __awaiter(this, void 0, void 0, function* () {
        const latestVersion = yield latestVersionPromise;
        if (latestVersion == null) {
            return;
        }
        const currentVersion = config.sys.compiler.version;
        if (config.sys.semver.lt(currentVersion, latestVersion)) {
            printUpdateMessage(config.logger, currentVersion, latestVersion);
        }
    });
}
function requestLatestCompilerVersion() {
    return __awaiter(this, void 0, void 0, function* () {
        const body = yield requestUrl(REGISTRY_URL);
        const data = JSON.parse(body);
        return data['dist-tags'].latest;
    });
}
function requestUrl(url) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => {
            const req = https.request(url, res => {
                if (res.statusCode > 299) {
                    reject(`url: ${url}, staus: ${res.statusCode}`);
                    return;
                }
                res.once('error', reject);
                const ret = [];
                res.once('end', () => {
                    resolve(ret.join(''));
                });
                res.on('data', data => {
                    ret.push(data);
                });
            });
            req.once('error', reject);
            req.end();
        });
    });
}
function requiresCheck(now, lastCheck, checkInterval) {
    return ((lastCheck + checkInterval) < now);
}
const CHECK_INTERVAL = (1000 * 60 * 60 * 24 * 7);
function getLastCheck(storage) {
    return storage.get(STORAGE_KEY);
}
function setLastCheck(storage) {
    storage.set(STORAGE_KEY, Date.now());
}
const STORAGE_KEY = 'last_version_check';
function printUpdateMessage(logger, currentVersion, latestVersion) {
    const msg = [
        `Update available: ${currentVersion} ${ARROW} ${latestVersion}`,
        `To get the latest, please run:`,
        NPM_INSTALL
    ];
    const lineLength = msg[0].length;
    const o = [];
    let top = BOX_TOP_LEFT;
    while (top.length <= lineLength + (PADDING * 2)) {
        top += BOX_HORIZONTAL;
    }
    top += BOX_TOP_RIGHT;
    o.push(top);
    msg.forEach(m => {
        let line = BOX_VERTICAL;
        for (let i = 0; i < PADDING; i++) {
            line += ` `;
        }
        line += m;
        while (line.length <= lineLength + (PADDING * 2)) {
            line += ` `;
        }
        line += BOX_VERTICAL;
        o.push(line);
    });
    let bottom = BOX_BOTTOM_LEFT;
    while (bottom.length <= lineLength + (PADDING * 2)) {
        bottom += BOX_HORIZONTAL;
    }
    bottom += BOX_BOTTOM_RIGHT;
    o.push(bottom);
    let output = `\n${INDENT}${o.join(`\n${INDENT}`)}\n`;
    output = output.replace(currentVersion, logger.red(currentVersion));
    output = output.replace(latestVersion, logger.green(latestVersion));
    output = output.replace(NPM_INSTALL, logger.cyan(NPM_INSTALL));
    console.log(output);
}
const NPM_INSTALL = `npm install @stencil/core`;
const ARROW = `→`;
const BOX_TOP_LEFT = `╭`;
const BOX_TOP_RIGHT = `╮`;
const BOX_BOTTOM_LEFT = `╰`;
const BOX_BOTTOM_RIGHT = `╯`;
const BOX_VERTICAL = `│`;
const BOX_HORIZONTAL = `─`;
const PADDING = 2;
const INDENT = `           `;
const REGISTRY_URL = `https://registry.npmjs.org/@stencil/core`;

/*
 * exit
 * https://github.com/cowboy/node-exit
 *
 * Copyright (c) 2013 "Cowboy" Ben Alman
 * Licensed under the MIT license.
 */

var exit = function exit(exitCode, streams) {
  if (!streams) { streams = [process.stdout, process.stderr]; }
  var drainCount = 0;
  // Actually exit if all streams are drained.
  function tryToExit() {
    if (drainCount === streams.length) {
      process.exit(exitCode);
    }
  }
  streams.forEach(function(stream) {
    // Count drained streams now, but monitor non-drained streams.
    if (stream.bufferSize === 0) {
      drainCount++;
    } else {
      stream.write('', 'utf-8', function() {
        drainCount++;
        tryToExit();
      });
    }
    // Prevent further writing.
    stream.write = function() {};
  });
  // If all streams were already drained, exit now.
  tryToExit();
  // In Windows, when run as a Node.js child process, a script utilizing
  // this library might just exit with a 0 exit code, regardless. This code,
  // despite the fact that it looks a bit crazy, appears to fix that.
  process.on('exit', function() {
    process.exit(exitCode);
  });
};

function taskBuild(process, config, flags) {
    return __awaiter(this, void 0, void 0, function* () {
        const { Compiler } = require('../compiler/index.js');
        const compiler = new Compiler(config);
        if (!compiler.isValid) {
            exit(1);
        }
        let devServerStart = null;
        if (config.devServer && flags.serve) {
            try {
                devServerStart = compiler.startDevServer();
            }
            catch (e) {
                config.logger.error(e);
                exit(1);
            }
        }
        const latestVersion = getLatestCompilerVersion(config.sys, config.logger);
        const results = yield compiler.build();
        let devServer = null;
        if (devServerStart) {
            devServer = yield devServerStart;
        }
        if (!config.watch && hasError$1(results && results.diagnostics)) {
            config.sys.destroy();
            if (devServer) {
                yield devServer.close();
            }
            exit(1);
        }
        if (config.watch || devServerStart) {
            process.once('SIGINT', () => {
                config.sys.destroy();
                if (devServer) {
                    devServer.close();
                }
            });
        }
        yield validateCompilerVersion(config, latestVersion);
        return results;
    });
}

function taskDocs(config) {
    const { Compiler } = require('../compiler/index.js');
    const compiler = new Compiler(config);
    if (!compiler.isValid) {
        exit(1);
    }
    return compiler.docs();
}

function taskHelp(process, logger) {
    const p = logger.dim((process.platform === 'win32') ? '>' : '$');
    console.log(`
  ${logger.bold('Build:')} ${logger.dim('Build components for development or production.')}

    ${p} ${logger.green('stencil build [--dev] [--watch] [--prerender] [--debug]')}

      ${logger.cyan('--dev')} ${logger.dim('.............')} Development build
      ${logger.cyan('--watch')} ${logger.dim('...........')} Rebuild when files update
      ${logger.cyan('--serve')} ${logger.dim('...........')} Start the dev-server
      ${logger.cyan('--prerender')} ${logger.dim('.......')} Prerender the application
      ${logger.cyan('--docs')} ${logger.dim('............')} Generate component readme.md docs
      ${logger.cyan('--config')} ${logger.dim('..........')} Set stencil config file
      ${logger.cyan('--stats')} ${logger.dim('...........')} Write stencil-stats.json file
      ${logger.cyan('--log')} ${logger.dim('.............')} Write stencil-build.log file
      ${logger.cyan('--debug')} ${logger.dim('...........')} Set the log level to debug


  ${logger.bold('Test:')} ${logger.dim('Run unit and end-to-end tests.')}

    ${p} ${logger.green('stencil test [--spec] [--e2e]')}

      ${logger.cyan('--spec')} ${logger.dim('............')} Run unit tests with Jest
      ${logger.cyan('--e2e')} ${logger.dim('.............')} Run e2e tests with Puppeteer


  ${logger.bold('Examples:')}

    ${p} ${logger.green('stencil build --dev --watch --serve')}
    ${p} ${logger.green('stencil build --prerender')}
    ${p} ${logger.green('stencil test --spec --e2e')}

`);
}

function taskServe(process, config, flags) {
    return __awaiter(this, void 0, void 0, function* () {
        const { Compiler } = require('../compiler/index.js');
        const compiler = new Compiler(config);
        if (!compiler.isValid) {
            exit(1);
        }
        config.flags.serve = true;
        config.devServer.openBrowser = false;
        config.devServer.hotReplacement = false;
        config.maxConcurrentWorkers = 1;
        config.devServer.root = process.cwd();
        if (typeof flags.root === 'string') {
            if (!config.sys.path.isAbsolute(config.flags.root)) {
                config.devServer.root = config.sys.path.relative(process.cwd(), flags.root);
            }
        }
        config.devServer.root = normalizePath(config.devServer.root);
        const devServer = yield compiler.startDevServer();
        if (devServer) {
            compiler.config.logger.info(`dev server: ${devServer.browserUrl}`);
        }
        process.once('SIGINT', () => {
            compiler.config.sys.destroy();
            devServer && devServer.close();
            exit(0);
        });
    });
}

function taskTest(config) {
    return __awaiter(this, void 0, void 0, function* () {
        // always ensure we have jest modules installed
        const ensureModuleIds = [
            '@types/jest',
            'jest',
            'jest-cli'
        ];
        if (config.flags && config.flags.e2e) {
            // if it's an e2e test, also make sure we're got
            // puppeteer modules installed
            ensureModuleIds.push('@types/puppeteer', 'puppeteer');
            if (config.flags.screenshot) {
                // ensure we've got pixelmatch for screenshots
                config.logger.warn(config.logger.yellow(`EXPERIMENTAL: screenshot visual diff testing is currently under heavy development and has not reached a stable status. However, any assistance testing would be appreciated.`));
            }
        }
        // ensure we've got the required modules installed
        // jest and puppeteer are quite large, so this
        // is an experiment to lazy install these
        // modules only when you need them
        yield config.sys.lazyRequire.ensure(config.logger, config.rootDir, ensureModuleIds);
        try {
            const { Testing } = require('../testing/index.js');
            const testing = new Testing(config);
            if (!testing.isValid) {
                exit(1);
            }
            const passed = yield testing.runTests();
            yield testing.destroy();
            if (!passed) {
                exit(1);
            }
        }
        catch (e) {
            config.logger.error(e);
            exit(1);
        }
    });
}

function taskVersion(config) {
    console.log(config.sys.compiler.version);
}
function taskCheckVersion(config) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const currentVersion = config.sys.compiler.version;
            const latestVersion = yield requestLatestCompilerVersion();
            if (config.sys.semver.lt(currentVersion, latestVersion)) {
                printUpdateMessage(config.logger, currentVersion, latestVersion);
            }
            else {
                console.log(`${config.logger.cyan(config.sys.compiler.name)} version ${config.logger.green(config.sys.compiler.version)} is the latest version`);
            }
        }
        catch (e) {
            config.logger.error(`unable to load latest compiler version: ${e}`);
            exit(1);
        }
    });
}

function runTask(process, config, flags) {
    return __awaiter(this, void 0, void 0, function* () {
        if (flags.help || flags.task === `help`) {
            taskHelp(process, config.logger);
        }
        else if (flags.version) {
            taskVersion(config);
        }
        else if (flags.checkVersion) {
            yield taskCheckVersion(config);
        }
        else {
            switch (flags.task) {
                case 'build':
                    yield taskBuild(process, config, flags);
                    break;
                case 'docs':
                    yield taskDocs(config);
                    break;
                case 'serve':
                    yield taskServe(process, config, flags);
                    break;
                case 'test':
                    yield taskTest(config);
                    break;
                default:
                    config.logger.error(`Invalid stencil command, please see the options below:`);
                    taskHelp(process, config.logger);
                    exit(1);
            }
        }
    });
}

function run(process, sys, logger) {
    return __awaiter(this, void 0, void 0, function* () {
        process.on(`unhandledRejection`, (r) => {
            if (!shouldIgnoreError(r)) {
                logger.error(`unhandledRejection`, r);
            }
        });
        process.title = `Stencil`;
        const flags = parseFlags(process);
        // load the config file
        let config;
        try {
            const configPath = getConfigFilePath(process, sys, flags.config);
            // if --config is provided we need to check if it exists
            if (flags.config && !sys.fs.existsSync(configPath)) {
                throw new Error(`Stencil configuration file cannot be found at: "${flags.config}"`);
            }
            config = sys.loadConfigFile(configPath, process);
        }
        catch (e) {
            logger.error(e);
            exit(1);
        }
        try {
            if (!config.logger) {
                // if a logger was not provided then use the
                // default stencil command line logger
                config.logger = logger;
            }
            if (config.logLevel) {
                config.logger.level = config.logLevel;
            }
            if (!config.sys) {
                // if the config was not provided then use the default node sys
                config.sys = sys;
            }
            config.flags = flags;
            process.title = `Stencil: ${config.namespace}`;
            yield runTask(process, config, flags);
        }
        catch (e) {
            if (!shouldIgnoreError(e)) {
                config.logger.error(`uncaught cli error: ${e}`);
                exit(1);
            }
        }
    });
}

exports.run = run;
