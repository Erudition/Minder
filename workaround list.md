# Nodeify

old and outdated

- first file nodeify.js has line requiring xhr. remove it
  https://github.com/EddyVerbruggen/nativescript-nodeify/blob/d24c34e5dadc1798baabda01aad296cde3e9db46/nodeify.js#L2

# Nativescript-urlhandler

android.js mentions "application", should be @nativescript/core/application

# Libp2p

- deep dependency "tough-cookie" uses node-util
  - in util, util.inherits() function implementation is punted to a "inherits" package
  - inherits has node passthrough and browser fallback implementation
  - for whatever reason the fallback is not triggered unless we require it directly ourselves, with `require("util");`
  - `inherits` is now a dependency
  - util requires `global.process.versions.node` to exist, so we make it up
- deep dependency `iso-url` depends on `url` by extending the `URL` object, but the fake one provided by the `url` npm
  package has no constructor (not an object). Trying `url-parse` as our polyfill instead. Nope. Trying `whatwg-url`.
  Yes!
  - `whatwg-url` is now a dependency
  - works to replace require line in iso-url
  - works to alias for `url` in webpack config!
  - `"url": "whatwg-url"` is now forwarded
- NOISE crypto library needs randombytes, node version doesn't work, using `nativescript-randombytes` instead! aliased
  in webpack config too
- `crypto-browserify` no good, got ` TypeError: crypto__default.default.createHash is not a function` on node creation.
  Trying `nativescript-crypto`. Used as fallback in webpack config.
- with native crypto,
  got `Execution failed for task ':app:processDebugManifest'. Manifest merger failed : Attribute application@allowBackup value=(true) from AndroidManifest.xml:25:3-29 is also present at [:libsodium-jni-aar-1.0.7:] AndroidManifest.xml:11:18-45 value=(false). Suggestion: add 'tools:replace="android:allowBackup"' to <application> element at AndroidManifest.xml:23:2-63:16 to override.
  ` so added it to manifest. Also needed to add namespace declaration `xmlns:tools="http://schemas.android.com/tools"`
  to the manifest tag.
- nativescript-crypto does not define the constants object, libp2p looks for it. in the mean time it works to add to
  nativescript-crypto/crypto.common.js : `exports.constants = {
  'DH_CHECK_P_NOT_SAFE_PRIME': 2,
  'DH_CHECK_P_NOT_PRIME': 1,
  'DH_UNABLE_TO_CHECK_GENERATOR': 4,
  'DH_NOT_SUITABLE_GENERATOR': 8,
  'NPN_ENABLED': 1,
  'ALPN_ENABLED': 1,
  'RSA_PKCS1_PADDING': 1,
  'RSA_SSLV23_PADDING': 2,
  'RSA_NO_PADDING': 3,
  'RSA_PKCS1_OAEP_PADDING': 4,
  'RSA_X931_PADDING': 5,
  'RSA_PKCS1_PSS_PADDING': 6,
  'POINT_CONVERSION_COMPRESSED': 2,
  'POINT_CONVERSION_UNCOMPRESSED': 4,
  'POINT_CONVERSION_HYBRID': 6 }`
- nativescript-crypto has "crypto" as main entry point but the file's name is actually crypto.common(.js) - webpack
  should expand that? adding direct file path in webpack config
- `libp2p-websockets` tries to create an http server but our stand-in http module, `http-stream`, is only for client
  stuff - no `createServer` function.
  - found package `@rill/http` that gives us this function just like node!
  - expects node if not in browser so we have to require deeply: `var http = require('@rill/http/dist/client/index.js')`
    but the module can stay stock!
  - currently putting that line into `it-ws/server.js` directly (replaces line 3) because our current http module is
    probably better for everything else, so moving it-ws to customized for now

# Google play services: wear os

- adds a dependency in gradle, but then can't build app for non-watch
  - switched dependency from "implementation:" (as docs say to do) to "compileOnly" (gotta check for it at runtime)
  - when I do that it wants 17.0.0 and not 17.1.0, still fails to build
  - same error in this bug https://github.com/flutter/flutter/issues/72592#issuecomment-748359923 so using that solution
    - upgrading gradle versions.
    - not confident this fix is permanent, since ./platforms is not included in the git repo

# Nativescript-wearos

- include.gradle needs BradMartin library changed from "implementation" to "compileOnly"

