'use strict';

function _interopDefault (ex) { return (ex && (typeof ex === 'object') && 'default' in ex) ? ex['default'] : ex; }

var fs = _interopDefault(require('../sys/node/graceful-fs.js'));
var path = require('path');
var querystring = require('querystring');
var Url = require('url');
var zlib = require('zlib');
var buffer = require('buffer');
var net = require('net');
var fs$1 = require('fs');
var http = require('http');
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

class NodeFs {
    copyFile(src, dest) {
        return new Promise((resolve, reject) => {
            const readStream = fs.createReadStream(src);
            readStream.on('error', reject);
            const writeStream = fs.createWriteStream(dest);
            writeStream.on('error', reject);
            writeStream.on('close', resolve);
            readStream.pipe(writeStream);
        });
    }
    createReadStream(filePath) {
        return fs.createReadStream(filePath);
    }
    mkdir(dirPath) {
        return new Promise((resolve, reject) => {
            fs.mkdir(dirPath, (err) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve();
                }
            });
        });
    }
    mkdirSync(dirPath) {
        fs.mkdirSync(dirPath);
    }
    readdir(dirPath) {
        return new Promise((resolve, reject) => {
            fs.readdir(dirPath, (err, files) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(files);
                }
            });
        });
    }
    readdirSync(dirPath) {
        return fs.readdirSync(dirPath);
    }
    readFile(filePath) {
        return new Promise((resolve, reject) => {
            fs.readFile(filePath, 'utf8', (err, content) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(content);
                }
            });
        });
    }
    exists(filePath) {
        return new Promise(resolve => {
            fs.exists(filePath, resolve);
        });
    }
    existsSync(filePath) {
        return fs.existsSync(filePath);
    }
    readFileSync(filePath) {
        return fs.readFileSync(filePath, 'utf8');
    }
    rmdir(dirPath) {
        return new Promise((resolve, reject) => {
            fs.rmdir(dirPath, (err) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve();
                }
            });
        });
    }
    stat(itemPath) {
        return new Promise((resolve, reject) => {
            fs.stat(itemPath, (err, stats) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(stats);
                }
            });
        });
    }
    statSync(itemPath) {
        return fs.statSync(itemPath);
    }
    unlink(filePath) {
        return new Promise((resolve, reject) => {
            fs.unlink(filePath, (err) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve();
                }
            });
        });
    }
    writeFile(filePath, content) {
        return new Promise((resolve, reject) => {
            fs.writeFile(filePath, content, { encoding: 'utf8' }, (err) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve();
                }
            });
        });
    }
    writeFileSync(filePath, content) {
        return fs.writeFileSync(filePath, content, { encoding: 'utf8' });
    }
}

function sendMsg(process, msg) {
    process.send(msg);
}
function sendError(process, e) {
    const msg = {
        error: {
            message: e
        }
    };
    if (typeof e === 'string') {
        msg.error.message = e + '';
    }
    else if (e) {
        Object.keys(e).forEach(key => {
            try {
                msg.error[key] = e[key] + '';
            }
            catch (idk) {
                console.log(idk);
            }
        });
    }
    sendMsg(process, msg);
}
function responseHeaders(headers) {
    return Object.assign({}, DEFAULT_HEADERS, headers);
}
const DEFAULT_HEADERS = {
    'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
    'Expires': '0',
    'X-Powered-By': 'Stencil Dev Server',
    'Access-Control-Allow-Origin': '*'
};
function getBrowserUrl(protocol, address, port, baseUrl, pathname) {
    address = (address === `0.0.0.0`) ? `localhost` : address;
    const portSuffix = (!port || port === 80 || port === 443) ? '' : (':' + port);
    let path$$1 = baseUrl;
    if (pathname.startsWith('/')) {
        pathname = pathname.substring(1);
    }
    path$$1 += pathname;
    protocol = protocol.replace(/\:/g, '');
    return `${protocol}://${address}${portSuffix}${path$$1}`;
}
function getDevServerClientUrl(devServerConfig, host) {
    let address = devServerConfig.address;
    let port = devServerConfig.port;
    if (host) {
        address = host;
        port = null;
    }
    return getBrowserUrl(devServerConfig.protocol, address, port, devServerConfig.baseUrl, DEV_SERVER_URL);
}
function getContentType(devServerConfig, filePath) {
    const last = filePath.replace(/^.*[/\\]/, '').toLowerCase();
    const ext = last.replace(/^.*\./, '').toLowerCase();
    const hasPath = last.length < filePath.length;
    const hasDot = ext.length < last.length - 1;
    return ((hasDot || !hasPath) && devServerConfig.contentTypes[ext]) || 'application/octet-stream';
}
function isHtmlFile(filePath) {
    filePath = filePath.toLowerCase().trim();
    return (filePath.endsWith('.html') || filePath.endsWith('.htm'));
}
function isCssFile(filePath) {
    filePath = filePath.toLowerCase().trim();
    return filePath.endsWith('.css');
}
const TXT_EXT = ['css', 'html', 'htm', 'js', 'json', 'svg', 'xml'];
function isSimpleText(filePath) {
    const ext = filePath.toLowerCase().trim().split('.').pop();
    return TXT_EXT.includes(ext);
}
function isDevClient(pathname) {
    return pathname.startsWith(DEV_SERVER_URL);
}
function isOpenInEditor(pathname) {
    return pathname === OPEN_IN_EDITOR_URL;
}
function isInitialDevServerLoad(pathname) {
    return pathname === DEV_SERVER_INIT_URL;
}
function isDevServerClient(pathname) {
    return pathname === DEV_SERVER_URL;
}
const DEV_SERVER_URL = '/~dev-server';
const DEV_SERVER_INIT_URL = `${DEV_SERVER_URL}-init`;
const OPEN_IN_EDITOR_URL = `${DEV_SERVER_URL}-open-in-editor`;
function shouldCompress(devServerConfig, req) {
    if (!devServerConfig.gzip) {
        return false;
    }
    if (req.method !== 'GET') {
        return false;
    }
    const acceptEncoding = req.headers && req.headers['accept-encoding'];
    if (typeof acceptEncoding !== 'string') {
        return false;
    }
    if (!acceptEncoding.includes('gzip')) {
        return false;
    }
    return true;
}

/**
 * SSR Attribute Names
 */

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

function serve500(res, error) {
    try {
        res.writeHead(500, responseHeaders({
            'Content-Type': 'text/plain'
        }));
        let errorMsg = '';
        if (typeof error === 'string') {
            errorMsg = error;
        }
        else if (error) {
            if (error.message) {
                errorMsg += error.message + '\n';
            }
            if (error.stack) {
                errorMsg += error.stack + '\n';
            }
        }
        res.write(errorMsg);
        res.end();
    }
    catch (e) {
        sendError(process, 'serve500: ' + e);
    }
}

function serve404(devServerConfig, fs$$1, req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            if (req.pathname === '/favicon.ico') {
                try {
                    const defaultFavicon = path.join(devServerConfig.devServerDir, 'static', 'favicon.ico');
                    res.writeHead(200, responseHeaders({
                        'Content-Type': 'image/x-icon'
                    }));
                    fs$$1.createReadStream(defaultFavicon).pipe(res);
                    return;
                }
                catch (e) { }
            }
            const content = [
                '404 File Not Found',
                'Url: ' + req.pathname,
                'File: ' + req.filePath
            ].join('\n');
            serve404Content(res, content);
        }
        catch (e) {
            serve500(res, e);
        }
    });
}
function serve404Content(res, content) {
    try {
        const headers = responseHeaders({
            'Content-Type': 'text/plain'
        });
        res.writeHead(404, headers);
        res.write(content);
        res.end();
    }
    catch (e) {
        serve500(res, e);
    }
}

function serveFile(devServerConfig, fs$$1, req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            if (isSimpleText(req.filePath)) {
                // easy text file, use the internal cache
                let content = yield fs$$1.readFile(req.filePath);
                if (isHtmlFile(req.filePath) && !isDevServerClient(req.pathname)) {
                    // auto inject our dev server script
                    content += getDevServerClientScript(devServerConfig, req);
                }
                else if (isCssFile(req.filePath)) {
                    content = updateStyleUrls(req.url, content);
                }
                if (shouldCompress(devServerConfig, req)) {
                    // let's gzip this well known web dev text file
                    res.writeHead(200, responseHeaders({
                        'Content-Type': getContentType(devServerConfig, req.filePath),
                        'Content-Encoding': 'gzip',
                        'Vary': 'Accept-Encoding'
                    }));
                    zlib.gzip(content, { level: 9 }, (_, data) => {
                        res.end(data);
                    });
                }
                else {
                    // let's not gzip this file
                    res.writeHead(200, responseHeaders({
                        'Content-Type': getContentType(devServerConfig, req.filePath),
                        'Content-Length': buffer.Buffer.byteLength(content, 'utf8')
                    }));
                    res.write(content);
                    res.end();
                }
            }
            else {
                // non-well-known text file or other file, probably best we use a stream
                // but don't bother trying to gzip this file for the dev server
                res.writeHead(200, responseHeaders({
                    'Content-Type': getContentType(devServerConfig, req.filePath),
                    'Content-Length': req.stats.size
                }));
                fs$$1.createReadStream(req.filePath).pipe(res);
            }
        }
        catch (e) {
            serve500(res, e);
        }
    });
}
function updateStyleUrls(cssUrl, oldCss) {
    const parsedUrl = Url.parse(cssUrl);
    const qs = querystring.parse(parsedUrl.query);
    const versionId = qs['s-hmr'];
    const hmrUrls = qs['s-hmr-urls'];
    if (versionId && hmrUrls) {
        hmrUrls.split(',').forEach(hmrUrl => {
            urlVersionIds.set(hmrUrl, versionId);
        });
    }
    const reg = /url\((['"]?)(.*)\1\)/ig;
    let result;
    let newCss = oldCss;
    while ((result = reg.exec(oldCss)) !== null) {
        const oldUrl = result[2];
        const parsedUrl = Url.parse(oldUrl);
        const fileName = path.basename(parsedUrl.pathname);
        const versionId = urlVersionIds.get(fileName);
        if (!versionId) {
            continue;
        }
        const qs = querystring.parse(parsedUrl.query);
        qs['s-hmr'] = versionId;
        parsedUrl.search = querystring.stringify(qs);
        const newUrl = Url.format(parsedUrl);
        newCss = newCss.replace(oldUrl, newUrl);
    }
    return newCss;
}
const urlVersionIds = new Map();
function getDevServerClientScript(devServerConfig, req) {
    const devServerClientUrl = getDevServerClientUrl(devServerConfig, req.host);
    return `\n<iframe src="${devServerClientUrl}" style="display:block;width:0;height:0;border:0"></iframe>`;
}

const openInEditorPath = path.join(__dirname, '..', 'sys', 'node', 'open-in-editor.js');
function serveOpenInEditor(devServerConfig, fs$$1, req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        let status = 200;
        const data = {};
        try {
            if (devServerConfig.editors.length > 0) {
                yield parseData(devServerConfig, fs$$1, req, data);
                yield openInEditor(data);
            }
            else {
                data.error = `no editors available`;
            }
        }
        catch (e) {
            data.error = e + '';
            status = 500;
        }
        res.writeHead(status, responseHeaders({
            'Content-Type': 'application/json'
        }));
        res.write(JSON.stringify(data, null, 2));
        res.end();
    });
}
function parseData(devServerConfig, fs$$1, req, data) {
    return __awaiter(this, void 0, void 0, function* () {
        const query = Url.parse(req.url).query;
        const qs = querystring.parse(query);
        if (typeof qs.file !== 'string') {
            data.error = `missing file`;
            return;
        }
        data.file = qs.file;
        if (qs.line != null && !isNaN(qs.line)) {
            data.line = parseInt(qs.line, 10);
        }
        else {
            data.line = 1;
        }
        if (qs.column != null && !isNaN(qs.column)) {
            data.column = parseInt(qs.column, 10);
        }
        else {
            data.column = 1;
        }
        if (typeof qs.editor === 'string') {
            qs.editor = qs.editor.trim().toLowerCase();
            if (devServerConfig.editors.some(e => e.id === qs.editor)) {
                data.editor = qs.editor;
            }
            else {
                data.error = `invalid editor: ${qs.editor}`;
                return;
            }
        }
        else {
            data.editor = devServerConfig.editors[0].id;
        }
        try {
            const stat = yield fs$$1.stat(data.file);
            data.exists = stat.isFile();
        }
        catch (e) {
            data.exists = false;
        }
    });
}
function openInEditor(data) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!data.exists || data.error) {
            return;
        }
        try {
            const opts = {
                editor: data.editor
            };
            const oie = require(openInEditorPath);
            const editor = oie.openInEditor.configure(opts, (err) => data.error = err + '');
            if (data.error) {
                return;
            }
            data.open = `${data.file}:${data.line}:${data.column}`;
            yield editor.open(data.open);
        }
        catch (e) {
            data.error = e + '';
        }
    });
}
function getEditors() {
    return __awaiter(this, void 0, void 0, function* () {
        const editors = [];
        try {
            const oie = require(openInEditorPath);
            yield Promise.all(Object.keys(oie.editors).map((id) => __awaiter(this, void 0, void 0, function* () {
                const isSupported = yield isEditorSupported(oie, id);
                editors.push({
                    id: id,
                    priority: EDITOR_PRIORITY[id],
                    supported: isSupported
                });
            })));
        }
        catch (e) { }
        return editors
            .filter(e => e.supported)
            .sort((a, b) => {
            if (a.priority < b.priority)
                return -1;
            if (a.priority > b.priority)
                return 1;
            return 0;
        }).map(e => {
            return {
                id: e.id,
                name: EDITORS[e.id]
            };
        });
    });
}
function isEditorSupported(oie, editor) {
    return __awaiter(this, void 0, void 0, function* () {
        let isSupported = false;
        try {
            yield oie.editors[editor].detect();
            isSupported = true;
        }
        catch (e) { }
        return isSupported;
    });
}
const EDITORS = {
    atom: 'Atom',
    code: 'Code',
    emacs: 'Emacs',
    idea14ce: 'IDEA 14 Community Edition',
    phpstorm: 'PhpStorm',
    sublime: 'Sublime',
    webstorm: 'WebStorm',
    vim: 'Vim',
    visualstudio: 'Visual Studio',
};
const EDITOR_PRIORITY = {
    code: 1,
    atom: 2,
    sublime: 3,
    visualstudio: 4,
    idea14ce: 5,
    webstorm: 6,
    phpstorm: 7,
    vim: 8,
    emacs: 9,
};

function serveDevClient(devServerConfig, fs$$1, req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            if (isOpenInEditor(req.pathname)) {
                return serveOpenInEditor(devServerConfig, fs$$1, req, res);
            }
            if (isDevServerClient(req.pathname)) {
                return serveDevClientScript(devServerConfig, fs$$1, res);
            }
            if (isInitialDevServerLoad(req.pathname)) {
                req.filePath = path.join(devServerConfig.devServerDir, 'templates', 'initial-load.html');
            }
            else {
                const staticFile = req.pathname.replace(DEV_SERVER_URL + '/', '');
                req.filePath = path.join(devServerConfig.devServerDir, 'static', staticFile);
            }
            try {
                req.stats = yield fs$$1.stat(req.filePath);
                return serveFile(devServerConfig, fs$$1, req, res);
            }
            catch (e) {
                return serve404(devServerConfig, fs$$1, req, res);
            }
        }
        catch (e) {
            return serve500(res, e);
        }
    });
}
function serveDevClientScript(devServerConfig, fs$$1, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const filePath = path.join(devServerConfig.devServerDir, 'static', 'dev-server-client.html');
        let content = yield fs$$1.readFile(filePath);
        const devClientConfig = {
            baseUrl: devServerConfig.baseUrl,
            editors: devServerConfig.editors,
            hmr: devServerConfig.hotReplacement
        };
        content = content.replace('__DEV_CLIENT_CONFIG__', JSON.stringify(devClientConfig));
        res.writeHead(200, responseHeaders({
            'Content-Type': 'text/html'
        }));
        res.write(content);
        res.end();
    });
}

function serveDirectoryIndex(devServerConfig, fs$$1, req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const indexFilePath = path.join(req.filePath, 'index.html');
            req.stats = yield fs$$1.stat(indexFilePath);
            if (req.stats.isFile()) {
                req.filePath = indexFilePath;
                return serveFile(devServerConfig, fs$$1, req, res);
            }
        }
        catch (e) { }
        if (!req.pathname.endsWith('/')) {
            res.writeHead(302, {
                'location': req.pathname + '/'
            });
            return res.end();
        }
        try {
            const dirItemNames = yield fs$$1.readdir(req.filePath);
            try {
                const dirTemplatePath = path.join(devServerConfig.devServerDir, 'templates', 'directory-index.html');
                const dirTemplate = yield fs$$1.readFile(dirTemplatePath);
                const files = yield getFiles(fs$$1, req.filePath, req.pathname, dirItemNames);
                const templateHtml = dirTemplate
                    .replace('{{title}}', getTitle(req.pathname))
                    .replace('{{nav}}', getName(req.pathname))
                    .replace('{{files}}', files);
                res.writeHead(200, responseHeaders({
                    'Content-Type': 'text/html',
                    'X-Directory-Index': req.pathname
                }));
                res.write(templateHtml);
                res.end();
            }
            catch (e) {
                serve500(res, e);
            }
        }
        catch (e) {
            serve404(devServerConfig, fs$$1, req, res);
        }
    });
}
function getFiles(fs$$1, filePath, urlPathName, dirItemNames) {
    return __awaiter(this, void 0, void 0, function* () {
        const items = yield getDirectoryItems(fs$$1, filePath, urlPathName, dirItemNames);
        if (urlPathName !== '/') {
            items.unshift({
                isDirectory: true,
                pathname: '../',
                name: '..'
            });
        }
        return items
            .map(item => {
            return (`
        <li class="${item.isDirectory ? 'directory' : 'file'}">
          <a href="${item.pathname}">
            <span class="icon"></span>
            <span>${item.name}</span>
          </a>
        </li>`);
        })
            .join('');
    });
}
function getDirectoryItems(fs$$1, filePath, urlPathName, dirItemNames) {
    return __awaiter(this, void 0, void 0, function* () {
        const items = yield Promise.all(dirItemNames.map((dirItemName) => __awaiter(this, void 0, void 0, function* () {
            const absPath = path.join(filePath, dirItemName);
            const stats = yield fs$$1.stat(absPath);
            const item = {
                name: dirItemName,
                pathname: Url.resolve(urlPathName, dirItemName),
                isDirectory: stats.isDirectory()
            };
            return item;
        })));
        return items;
    });
}
function getTitle(pathName) {
    return pathName;
}
function getName(pathName) {
    const dirs = pathName.split('/');
    dirs.pop();
    let url = '';
    return dirs.map((dir, index) => {
        url += dir + '/';
        const text = (index === 0 ? `~` : dir);
        return `<a href="${url}">${text}</a>`;
    }).join('<span>/</span>') + '<span>/</span>';
}

function createRequestHandler(devServerConfig, fs$$1) {
    return function (incomingReq, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const req = normalizeHttpRequest(devServerConfig, incomingReq);
                if (req.url === '') {
                    res.writeHead(302, { 'location': '/' });
                    return res.end();
                }
                if (!req.url.startsWith(devServerConfig.baseUrl)) {
                    return serve404Content(res, `404 File Not Found, base url: ${devServerConfig.baseUrl}`);
                }
                if (isDevClient(req.pathname)) {
                    return serveDevClient(devServerConfig, fs$$1, req, res);
                }
                try {
                    req.stats = yield fs$$1.stat(req.filePath);
                    if (req.stats.isFile()) {
                        return serveFile(devServerConfig, fs$$1, req, res);
                    }
                    if (req.stats.isDirectory()) {
                        return serveDirectoryIndex(devServerConfig, fs$$1, req, res);
                    }
                }
                catch (e) { }
                if (isValidHistoryApi(devServerConfig, req)) {
                    try {
                        const indexFilePath = path.join(devServerConfig.root, devServerConfig.historyApiFallback.index);
                        req.stats = yield fs$$1.stat(indexFilePath);
                        if (req.stats.isFile()) {
                            req.filePath = indexFilePath;
                            return serveFile(devServerConfig, fs$$1, req, res);
                        }
                    }
                    catch (e) { }
                }
                return serve404(devServerConfig, fs$$1, req, res);
            }
            catch (e) {
                return serve500(res, e);
            }
        });
    };
}
function normalizeHttpRequest(devServerConfig, incomingReq) {
    const req = {
        method: (incomingReq.method || 'GET').toUpperCase(),
        headers: incomingReq.headers,
        acceptHeader: (incomingReq.headers && typeof incomingReq.headers.accept === 'string' && incomingReq.headers.accept) || '',
        url: (incomingReq.url || '').trim() || '',
        host: (incomingReq.headers && typeof incomingReq.headers.host === 'string' && incomingReq.headers.host) || null
    };
    const parsedUrl = Url.parse(req.url);
    const parts = (parsedUrl.pathname || '').replace(/\\/g, '/').split('/');
    req.pathname = parts.map(part => decodeURIComponent(part)).join('/');
    if (req.pathname.length > 0) {
        req.pathname = '/' + req.pathname.substring(devServerConfig.baseUrl.length);
    }
    req.filePath = normalizePath(path.normalize(path.join(devServerConfig.root, path.relative('/', req.pathname))));
    return req;
}
function isValidHistoryApi(devServerConfig, req) {
    if (!devServerConfig.historyApiFallback) {
        return false;
    }
    if (req.method !== 'GET') {
        return false;
    }
    if (!req.acceptHeader.includes('text/html')) {
        return false;
    }
    if (!devServerConfig.historyApiFallback.disableDotRule && req.pathname.includes('.')) {
        return false;
    }
    return true;
}

function findClosestOpenPort(host, port) {
    return __awaiter(this, void 0, void 0, function* () {
        function t(portToCheck) {
            return __awaiter(this, void 0, void 0, function* () {
                const isTaken = yield isPortTaken(host, portToCheck);
                if (!isTaken) {
                    return portToCheck;
                }
                return t(portToCheck + 1);
            });
        }
        return t(port);
    });
}
function isPortTaken(host, port) {
    return new Promise((resolve, reject) => {
        const tester = net.createServer()
            .once('error', () => {
            resolve(true);
        })
            .once('listening', () => {
            tester.once('close', () => {
                resolve(false);
            })
                .close();
        })
            .on('error', (err) => {
            reject(err);
        })
            .listen(port, host);
    });
}

// import getDevelopmentCertificate from 'devcert-san';
function getSSL() {
    return __awaiter(this, void 0, void 0, function* () {
        const cert = yield installSSL();
        return {
            key: fs$1.readFileSync(cert.keyPath, 'utf-8'),
            cert: fs$1.readFileSync(cert.certPath, 'utf-8')
        };
    });
}
function installSSL() {
    return __awaiter(this, void 0, void 0, function* () {
        // try {
        //   //  Certificates are cached by name, so two calls for getDevelopmentCertificate('foo')  will return the same key and certificate
        //   return getDevelopmentCertificate('stencil-dev-server-ssl', {
        //     installCertutil: true
        //   });
        // } catch (err) {
        //   throw new Error(`Failed to generate dev SSL certificate: ${err}\n`);
        // }
    });
}

function createHttpServer(devServerConfig, fs$$1, destroys) {
    return __awaiter(this, void 0, void 0, function* () {
        // figure out the port to be listening on
        // by figuring out the first one available
        devServerConfig.port = yield findClosestOpenPort(devServerConfig.address, devServerConfig.port);
        // create our request handler
        const reqHandler = createRequestHandler(devServerConfig, fs$$1);
        let server;
        if (devServerConfig.protocol === 'https') {
            // https server
            server = https.createServer(yield getSSL(), reqHandler);
        }
        else {
            // http server
            server = http.createServer(reqHandler);
        }
        destroys.push(() => {
            // close down the serve on destroy
            server.close();
            server = null;
        });
        return server;
    });
}

const noop = () => { };

const WebSocket = require('../sys/node/websocket').WebSocket;
function createWebSocket(process, httpServer, destroys) {
    const wsConfig = {
        server: httpServer
    };
    const wsServer = new WebSocket.Server(wsConfig);
    function heartbeat() {
        this.isAlive = true;
    }
    wsServer.on('connection', (ws) => {
        ws.on('message', (data) => {
            // the server process has received a message from the browser
            // pass the message received from the browser to the main cli process
            process.send(JSON.parse(data.toString()));
        });
        ws.isAlive = true;
        ws.on('pong', heartbeat);
    });
    const pingInternval = setInterval(() => {
        wsServer.clients.forEach((ws) => {
            if (!ws.isAlive) {
                return ws.close(1000);
            }
            ws.isAlive = false;
            ws.ping(noop);
        });
    }, 10000);
    function onMessageFromCli(msg) {
        // the server process has received a message from the cli's main thread
        // pass the data to each web socket for each browser/tab connected
        if (msg) {
            const data = JSON.stringify(msg);
            wsServer.clients.forEach(ws => {
                if (ws.readyState === ws.OPEN) {
                    ws.send(data);
                }
            });
        }
    }
    process.addListener('message', onMessageFromCli);
    destroys.push(() => {
        clearInterval(pingInternval);
        wsServer.clients.forEach(ws => {
            ws.close(1000);
        });
    });
}

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

function startDevServerWorker(process, devServerConfig, fs$$1) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const destroys = [];
            devServerConfig.editors = yield getEditors();
            // create the http server listening for and responding to requests from the browser
            let httpServer = yield createHttpServer(devServerConfig, fs$$1, destroys);
            // upgrade web socket requests the server receives
            createWebSocket(process, httpServer, destroys);
            // start listening!
            httpServer.listen(devServerConfig.port, devServerConfig.address);
            // have the server worker send a message to the main cli
            // process that the server has successfully started up
            sendMsg(process, {
                serverStated: {
                    browserUrl: getBrowserUrl(devServerConfig.protocol, devServerConfig.address, devServerConfig.port, devServerConfig.baseUrl, '/'),
                    initialLoadUrl: getBrowserUrl(devServerConfig.protocol, devServerConfig.address, devServerConfig.port, devServerConfig.baseUrl, DEV_SERVER_INIT_URL)
                }
            });
            function closeServer() {
                // probably recived a SIGINT message from the parent cli process
                // let's do our best to gracefully close everything down first
                destroys.forEach(destroy => {
                    destroy();
                });
                destroys.length = 0;
                httpServer = null;
                setTimeout(() => {
                    exit(0);
                }, 5000).unref();
                process.removeAllListeners('message');
            }
            process.once('SIGINT', closeServer);
        }
        catch (e) {
            sendError(process, e);
        }
    });
}

function startServer(devServerConfig) {
    return __awaiter(this, void 0, void 0, function* () {
        // received a message from main to start the server
        try {
            const fs$$1 = new NodeFs();
            devServerConfig.contentTypes = yield loadContentTypes(fs$$1);
            startDevServerWorker(process, devServerConfig, fs$$1);
        }
        catch (e) {
            sendError(process, e);
        }
    });
}
function loadContentTypes(fs$$1) {
    return __awaiter(this, void 0, void 0, function* () {
        const contentTypePath = path.join(__dirname, 'content-type-db.json');
        const contentTypeJson = yield fs$$1.readFile(contentTypePath);
        return JSON.parse(contentTypeJson);
    });
}
process.on('message', (msg) => {
    if (msg.startServer) {
        startServer(msg.startServer);
    }
});
process.on('unhandledRejection', (e) => {
    console.log(e);
});
