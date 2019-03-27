[![npm][npm-badge]][npm-badge-url]
[![Build Status][circle-badge]][circle-badge-url]

# Stencil Dev Server

This is a very simple http-server with a filewatcher and livereload built in. This server
was built with the purpose of making it easy to develop stencil apps and components, but it will work
with about any dev workflow.

Just provide a directory.

```
stencil-dev-server --root public
```

There are a number of options available, but all have sane defaults.

- **--root**
  - The directory that should be watched and served
  - It defaults to the current directory that the command was executed from.
- **--watchGlob**
  - The pattern of files to watch in the root directory for changes.
  - The glob defaults to **\*\*/\*\***.
- **--address**
  - The ip address that the server should listen to.
  - Defaults to *0.0.0.0*. Point your browser to localhost.
- **--httpPort**
  - The port that the http server should use.  If the number provided is in use it will choose another.
  - Defaults to *3333*.
- **--liveReloadPort**
  - The port that the live-reload server should use. If the number provided is in use it will choose another.
  - Defaults to *35729*.
- **--additionalJsScripts**
  - A comma separated list of javascript files that you would like appended to all html page body tags. This allows you to expand the dev server to do additional behaviors.
- **--config**
  - The path to a config file for the dev server. This allows you to keep a specific set of default parameters in a configuration file.
  - Defaults to *./stencil.config.js*
- **--no-open**
  - Disables automatically opening a browser.

Config File Structure

```js
exports.devServer = {
  root: './',
  additionalJSScripts: [
    'http://localhost:3529/debug.js',
    './scripts/additionalDebug.js'
  ],
  watchGlob: '**/*'
};
```

[npm-badge]: https://img.shields.io/npm/v/@stencil/dev-server.svg?style=flat-square
[npm-badge-url]: https://www.npmjs.com/package/@stencil/dev-server
[circle-badge]: https://circleci.com/gh/ionic-team/stencil-dev-server.svg?style=shield
[circle-badge-url]: https://circleci.com/gh/ionic-team/stencil-dev-server
