'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function _interopDefault (ex) { return (ex && (typeof ex === 'object') && 'default' in ex) ? ex['default'] : ex; }

var fs = _interopDefault(require('../sys/node/graceful-fs.js'));
var path = require('path');
var path__default = _interopDefault(path);
var os = require('os');
var url = require('url');

var __awaiter = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
function fileExists(filePath) {
    return new Promise(resolve => {
        fs.access(filePath, (err) => resolve(!err));
    });
}
function readFile(filePath) {
    return new Promise((resolve, reject) => {
        fs.readFile(filePath, 'utf-8', (err, data) => {
            if (err) {
                reject(err);
            }
            else {
                resolve(data);
            }
        });
    });
}
function readFileBuffer(filePath) {
    return new Promise((resolve, reject) => {
        fs.readFile(filePath, (err, data) => {
            if (err) {
                reject(err);
            }
            else {
                resolve(data);
            }
        });
    });
}
function writeFile(filePath, data) {
    return new Promise((resolve, reject) => {
        fs.writeFile(filePath, data, (err) => {
            if (err) {
                reject(err);
            }
            else {
                resolve();
            }
        });
    });
}
function mkDir(filePath) {
    return new Promise(resolve => {
        fs.mkdir(filePath, () => {
            resolve();
        });
    });
}
function rmDir(filePath) {
    return new Promise(resolve => {
        fs.rmdir(filePath, () => {
            resolve();
        });
    });
}
function emptyDir(dir) {
    return __awaiter(this, void 0, void 0, function* () {
        const files = yield readDir(dir);
        const promises = files.map((fileName) => __awaiter(this, void 0, void 0, function* () {
            const filePath = path__default.join(dir, fileName);
            const isDirFile = yield isFile(filePath);
            if (isDirFile) {
                yield unlink(filePath);
            }
        }));
        yield Promise.all(promises);
    });
}
function readDir(dir) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise(resolve => {
            fs.readdir(dir, (err, files) => {
                if (err) {
                    resolve([]);
                }
                else {
                    resolve(files);
                }
            });
        });
    });
}
function isFile(itemPath) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise(resolve => {
            fs.stat(itemPath, (err, stat) => {
                if (err) {
                    resolve(false);
                }
                else {
                    resolve(stat.isFile());
                }
            });
        });
    });
}
function unlink(filePath) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise(resolve => {
            fs.unlink(filePath, () => {
                resolve();
            });
        });
    });
}

var __awaiter$1 = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
class ScreenshotConnector {
    constructor() {
        this.screenshotDirName = 'screenshot';
        this.imagesDirName = 'images';
        this.buildsDirName = 'builds';
        this.masterBuildFileName = 'master.json';
        this.screenshotCacheFileName = 'screenshot-cache.json';
    }
    initBuild(opts) {
        return __awaiter$1(this, void 0, void 0, function* () {
            this.logger = opts.logger;
            this.buildId = opts.buildId;
            this.buildMessage = opts.buildMessage || '';
            this.buildAuthor = opts.buildAuthor;
            this.buildUrl = opts.buildUrl;
            this.previewUrl = opts.previewUrl;
            this.buildTimestamp = typeof opts.buildTimestamp === 'number' ? opts.buildTimestamp : Date.now(),
                this.cacheDir = opts.cacheDir;
            this.packageDir = opts.packageDir;
            this.rootDir = opts.rootDir;
            this.appNamespace = opts.appNamespace;
            this.timeoutBeforeScreenshot = typeof opts.timeoutBeforeScreenshot === 'number' ? opts.timeoutBeforeScreenshot : 4;
            this.pixelmatchModulePath = opts.pixelmatchModulePath;
            if (!opts.logger) {
                throw new Error(`logger option required`);
            }
            if (typeof opts.buildId !== 'string') {
                throw new Error(`buildId option required`);
            }
            if (typeof opts.cacheDir !== 'string') {
                throw new Error(`cacheDir option required`);
            }
            if (typeof opts.packageDir !== 'string') {
                throw new Error(`packageDir option required`);
            }
            if (typeof opts.rootDir !== 'string') {
                throw new Error(`rootDir option required`);
            }
            this.updateMaster = !!opts.updateMaster;
            this.allowableMismatchedPixels = opts.allowableMismatchedPixels;
            this.allowableMismatchedRatio = opts.allowableMismatchedRatio;
            this.pixelmatchThreshold = opts.pixelmatchThreshold;
            this.logger.debug(`screenshot build: ${this.buildId}, ${this.buildMessage}, updateMaster: ${this.updateMaster}`);
            this.logger.debug(`screenshot, allowableMismatchedPixels: ${this.allowableMismatchedPixels}, allowableMismatchedRatio: ${this.allowableMismatchedRatio}, pixelmatchThreshold: ${this.pixelmatchThreshold}`);
            if (typeof opts.screenshotDirName === 'string') {
                this.screenshotDirName = opts.screenshotDirName;
            }
            if (typeof opts.imagesDirName === 'string') {
                this.imagesDirName = opts.imagesDirName;
            }
            if (typeof opts.buildsDirName === 'string') {
                this.buildsDirName = opts.buildsDirName;
            }
            this.screenshotDir = path.join(this.rootDir, this.screenshotDirName);
            this.imagesDir = path.join(this.screenshotDir, this.imagesDirName);
            this.buildsDir = path.join(this.screenshotDir, this.buildsDirName);
            this.masterBuildFilePath = path.join(this.buildsDir, this.masterBuildFileName);
            this.screenshotCacheFilePath = path.join(this.cacheDir, this.screenshotCacheFileName);
            this.currentBuildDir = path.join(os.tmpdir(), 'screenshot-build-' + this.buildId);
            this.logger.debug(`screenshotDirPath: ${this.screenshotDir}`);
            this.logger.debug(`imagesDirPath: ${this.imagesDir}`);
            this.logger.debug(`buildsDirPath: ${this.buildsDir}`);
            this.logger.debug(`currentBuildDir: ${this.currentBuildDir}`);
            yield mkDir(this.screenshotDir);
            yield Promise.all([
                mkDir(this.imagesDir),
                mkDir(this.buildsDir),
                mkDir(this.currentBuildDir)
            ]);
        });
    }
    pullMasterBuild() {
        return __awaiter$1(this, void 0, void 0, function* () { });
    }
    getMasterBuild() {
        return __awaiter$1(this, void 0, void 0, function* () {
            let masterBuild = null;
            try {
                masterBuild = JSON.parse(yield readFile(this.masterBuildFilePath));
            }
            catch (e) { }
            return masterBuild;
        });
    }
    completeBuild(masterBuild) {
        return __awaiter$1(this, void 0, void 0, function* () {
            const filePaths = (yield readDir(this.currentBuildDir)).map(f => path.join(this.currentBuildDir, f)).filter(f => f.endsWith('.json'));
            const screenshots = yield Promise.all(filePaths.map((f) => __awaiter$1(this, void 0, void 0, function* () { return JSON.parse(yield readFile(f)); })));
            this.sortScreenshots(screenshots);
            if (!masterBuild) {
                masterBuild = {
                    id: this.buildId,
                    message: this.buildMessage,
                    author: this.buildAuthor,
                    url: this.buildUrl,
                    previewUrl: this.previewUrl,
                    appNamespace: this.appNamespace,
                    timestamp: this.buildTimestamp,
                    screenshots: screenshots
                };
            }
            const results = {
                appNamespace: this.appNamespace,
                masterBuild: masterBuild,
                currentBuild: {
                    id: this.buildId,
                    message: this.buildMessage,
                    author: this.buildAuthor,
                    url: this.buildUrl,
                    previewUrl: this.previewUrl,
                    appNamespace: this.appNamespace,
                    timestamp: this.buildTimestamp,
                    screenshots: screenshots
                },
                compare: {
                    id: `${masterBuild.id}-${this.buildId}`,
                    a: {
                        id: masterBuild.id,
                        message: masterBuild.message,
                        author: masterBuild.author,
                        url: masterBuild.url,
                        previewUrl: masterBuild.previewUrl
                    },
                    b: {
                        id: this.buildId,
                        message: this.buildMessage,
                        author: this.buildAuthor,
                        url: this.buildUrl,
                        previewUrl: this.previewUrl,
                    },
                    url: null,
                    appNamespace: this.appNamespace,
                    timestamp: this.buildTimestamp,
                    diffs: []
                }
            };
            results.currentBuild.screenshots.forEach(screenshot => {
                screenshot.diff.device = (screenshot.diff.device || screenshot.diff.userAgent);
                results.compare.diffs.push(screenshot.diff);
                delete screenshot.diff;
            });
            this.sortCompares(results.compare.diffs);
            yield emptyDir(this.currentBuildDir);
            yield rmDir(this.currentBuildDir);
            return results;
        });
    }
    publishBuild(results) {
        return __awaiter$1(this, void 0, void 0, function* () {
            return results;
        });
    }
    generateJsonpDataUris(build) {
        return __awaiter$1(this, void 0, void 0, function* () {
            if (build && Array.isArray(build.screenshots)) {
                for (let i = 0; i < build.screenshots.length; i++) {
                    const screenshot = build.screenshots[i];
                    const jsonpFileName = `screenshot_${screenshot.image}.js`;
                    const jsonFilePath = path.join(this.cacheDir, jsonpFileName);
                    const jsonpExists = yield fileExists(jsonFilePath);
                    if (!jsonpExists) {
                        const imageFilePath = path.join(this.imagesDir, screenshot.image);
                        const imageBuf = yield readFileBuffer(imageFilePath);
                        const jsonpContent = `loadScreenshot("${screenshot.image}","data:image/png;base64,${imageBuf.toString('base64')}");`;
                        yield writeFile(jsonFilePath, jsonpContent);
                    }
                }
            }
        });
    }
    getScreenshotCache() {
        return __awaiter$1(this, void 0, void 0, function* () {
            return null;
        });
    }
    updateScreenshotCache(screenshotCache, buildResults) {
        return __awaiter$1(this, void 0, void 0, function* () {
            screenshotCache = screenshotCache || {};
            screenshotCache.timestamp = this.buildTimestamp;
            screenshotCache.lastBuildId = this.buildId;
            screenshotCache.size = 0;
            screenshotCache.items = screenshotCache.items || [];
            if (buildResults && buildResults.compare && Array.isArray(buildResults.compare.diffs)) {
                buildResults.compare.diffs.forEach(diff => {
                    if (typeof diff.cacheKey !== 'string') {
                        return;
                    }
                    if (diff.imageA === diff.imageB) {
                        // no need to cache identical matches
                        return;
                    }
                    const existingItem = screenshotCache.items.find(i => i.key === diff.cacheKey);
                    if (existingItem) {
                        // already have this cached, but update its timestamp
                        existingItem.ts = this.buildTimestamp;
                    }
                    else {
                        // add this item to the cache
                        screenshotCache.items.push({
                            key: diff.cacheKey,
                            ts: this.buildTimestamp,
                            mp: diff.mismatchedPixels
                        });
                    }
                });
            }
            // sort so the newest items are on top
            screenshotCache.items.sort((a, b) => {
                if (a.ts > b.ts)
                    return -1;
                if (a.ts < b.ts)
                    return 1;
                if (a.mp > b.mp)
                    return -1;
                if (a.mp < b.mp)
                    return 1;
                return 0;
            });
            // keep only the most recent items
            screenshotCache.items = screenshotCache.items.slice(0, 1000);
            screenshotCache.size = screenshotCache.items.length;
            return screenshotCache;
        });
    }
    toJson(masterBuild, screenshotCache) {
        const masterScreenshots = {};
        if (masterBuild && Array.isArray(masterBuild.screenshots)) {
            masterBuild.screenshots.forEach(masterScreenshot => {
                masterScreenshots[masterScreenshot.id] = masterScreenshot.image;
            });
        }
        const mismatchCache = {};
        if (screenshotCache && Array.isArray(screenshotCache.items)) {
            screenshotCache.items.forEach(cacheItem => {
                mismatchCache[cacheItem.key] = cacheItem.mp;
            });
        }
        const screenshotBuild = {
            buildId: this.buildId,
            rootDir: this.rootDir,
            screenshotDir: this.screenshotDir,
            imagesDir: this.imagesDir,
            buildsDir: this.buildsDir,
            masterScreenshots: masterScreenshots,
            cache: mismatchCache,
            currentBuildDir: this.currentBuildDir,
            updateMaster: this.updateMaster,
            allowableMismatchedPixels: this.allowableMismatchedPixels,
            allowableMismatchedRatio: this.allowableMismatchedRatio,
            pixelmatchThreshold: this.pixelmatchThreshold,
            timeoutBeforeScreenshot: this.timeoutBeforeScreenshot,
            pixelmatchModulePath: this.pixelmatchModulePath
        };
        return JSON.stringify(screenshotBuild);
    }
    sortScreenshots(screenshots) {
        return screenshots.sort((a, b) => {
            if (a.desc && b.desc) {
                if (a.desc.toLowerCase() < b.desc.toLowerCase())
                    return -1;
                if (a.desc.toLowerCase() > b.desc.toLowerCase())
                    return 1;
            }
            if (a.device && b.device) {
                if (a.device.toLowerCase() < b.device.toLowerCase())
                    return -1;
                if (a.device.toLowerCase() > b.device.toLowerCase())
                    return 1;
            }
            if (a.userAgent && b.userAgent) {
                if (a.userAgent.toLowerCase() < b.userAgent.toLowerCase())
                    return -1;
                if (a.userAgent.toLowerCase() > b.userAgent.toLowerCase())
                    return 1;
            }
            if (a.width < b.width)
                return -1;
            if (a.width > b.width)
                return 1;
            if (a.height < b.height)
                return -1;
            if (a.height > b.height)
                return 1;
            if (a.id < b.id)
                return -1;
            if (a.id > b.id)
                return 1;
            return 0;
        });
    }
    sortCompares(compares) {
        return compares.sort((a, b) => {
            if (a.allowableMismatchedPixels > b.allowableMismatchedPixels)
                return -1;
            if (a.allowableMismatchedPixels < b.allowableMismatchedPixels)
                return 1;
            if (a.allowableMismatchedRatio > b.allowableMismatchedRatio)
                return -1;
            if (a.allowableMismatchedRatio < b.allowableMismatchedRatio)
                return 1;
            if (a.desc && b.desc) {
                if (a.desc.toLowerCase() < b.desc.toLowerCase())
                    return -1;
                if (a.desc.toLowerCase() > b.desc.toLowerCase())
                    return 1;
            }
            if (a.device && b.device) {
                if (a.device.toLowerCase() < b.device.toLowerCase())
                    return -1;
                if (a.device.toLowerCase() > b.device.toLowerCase())
                    return 1;
            }
            if (a.userAgent && b.userAgent) {
                if (a.userAgent.toLowerCase() < b.userAgent.toLowerCase())
                    return -1;
                if (a.userAgent.toLowerCase() > b.userAgent.toLowerCase())
                    return 1;
            }
            if (a.width < b.width)
                return -1;
            if (a.width > b.width)
                return 1;
            if (a.height < b.height)
                return -1;
            if (a.height > b.height)
                return 1;
            if (a.id < b.id)
                return -1;
            if (a.id > b.id)
                return 1;
            return 0;
        });
    }
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

var __awaiter$2 = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
class ScreenshotLocalConnector extends ScreenshotConnector {
    publishBuild(results) {
        return __awaiter$2(this, void 0, void 0, function* () {
            if (this.updateMaster || !results.masterBuild) {
                results.masterBuild = {
                    id: 'master',
                    message: 'Master',
                    appNamespace: this.appNamespace,
                    timestamp: Date.now(),
                    screenshots: []
                };
            }
            results.currentBuild.screenshots.forEach(currentScreenshot => {
                const masterHasScreenshot = results.masterBuild.screenshots.some(masterScreenshot => {
                    return currentScreenshot.id === masterScreenshot.id;
                });
                if (!masterHasScreenshot) {
                    results.masterBuild.screenshots.push(Object.assign({}, currentScreenshot));
                }
            });
            this.sortScreenshots(results.masterBuild.screenshots);
            yield writeFile(this.masterBuildFilePath, JSON.stringify(results.masterBuild, null, 2));
            yield this.generateJsonpDataUris(results.currentBuild);
            const compareAppSourceDir = path.join(this.packageDir, 'screenshot', 'compare');
            const appSrcUrl = normalizePath(path.relative(this.screenshotDir, compareAppSourceDir));
            const imagesUrl = normalizePath(path.relative(this.screenshotDir, this.imagesDir));
            const jsonpUrl = normalizePath(path.relative(this.screenshotDir, this.cacheDir));
            const compareAppHtml = createLocalCompareApp(this.appNamespace, appSrcUrl, imagesUrl, jsonpUrl, results.masterBuild, results.currentBuild);
            const compareAppFileName = 'compare.html';
            const compareAppFilePath = path.join(this.screenshotDir, compareAppFileName);
            yield writeFile(compareAppFilePath, compareAppHtml);
            const gitIgnorePath = path.join(this.screenshotDir, '.gitignore');
            const gitIgnoreExists = yield fileExists(gitIgnorePath);
            if (!gitIgnoreExists) {
                const content = [
                    this.imagesDirName,
                    this.buildsDirName,
                    compareAppFileName
                ];
                yield writeFile(gitIgnorePath, content.join('\n'));
            }
            const url$$1 = new url.URL(`file://${compareAppFilePath}`);
            results.compare.url = url$$1.href;
            return results;
        });
    }
    getScreenshotCache() {
        return __awaiter$2(this, void 0, void 0, function* () {
            let screenshotCache = null;
            try {
                screenshotCache = JSON.parse(yield readFile(this.screenshotCacheFilePath));
            }
            catch (e) { }
            return screenshotCache;
        });
    }
    updateScreenshotCache(cache, buildResults) {
        const _super = Object.create(null, {
            updateScreenshotCache: { get: () => super.updateScreenshotCache }
        });
        return __awaiter$2(this, void 0, void 0, function* () {
            cache = yield _super.updateScreenshotCache.call(this, cache, buildResults);
            yield writeFile(this.screenshotCacheFilePath, JSON.stringify(cache, null, 2));
            return cache;
        });
    }
}
function createLocalCompareApp(namespace, appSrcUrl, imagesUrl, jsonpUrl, a, b) {
    return `<!doctype html>
<html dir="ltr" lang="en">
<head>
  <meta charset="utf-8">
  <title>Local ${namespace || ''} - Stencil Screenshot Visual Diff</title>
  <meta name="viewport" content="viewport-fit=cover, width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta http-equiv="x-ua-compatible" content="IE=Edge">
  <link href="${appSrcUrl}/build/app.css" rel="stylesheet">
  <script src="${appSrcUrl}/build/app.js"></script>
  <link rel="icon" type="image/x-icon" href="${appSrcUrl}/assets/favicon.ico">
</head>
<body>
  <script>
    (function() {
      var app = document.createElement('screenshot-compare');
      app.appSrcUrl = '${appSrcUrl}';
      app.imagesUrl = '${imagesUrl}/';
      app.jsonpUrl = '${jsonpUrl}/';
      app.a = ${JSON.stringify(a)};
      app.b = ${JSON.stringify(b)};
      document.body.appendChild(app);
    })();
  </script>
</body>
</html>`;
}

exports.ScreenshotConnector = ScreenshotConnector;
exports.ScreenshotLocalConnector = ScreenshotLocalConnector;
