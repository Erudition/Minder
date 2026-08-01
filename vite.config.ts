import { defineConfig } from 'vite'
import elmPlugin from "vite-plugin-elm"

import { nodePolyfills } from 'vite-plugin-node-polyfills'
import { VitePWA } from 'vite-plugin-pwa'


export default defineConfig({
  // identify what plugins we want to use
  plugins: [ // PWA plugin causing capacitor errors
    VitePWA({ 
        strategies: 'injectManifest',
        srcDir: '.',
        filename: 'sw.ts',
        injectRegister: false,
        registerType: 'autoUpdate',
        devOptions: { enabled: true, type: 'module' },
        includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
        injectManifest: {
          globPatterns: ['**/*'],
          globIgnores: ['**/*.js.map']
        },
        outDir: "../dist", // weird it's not default, it looks for webapp files to cache here
        manifest: {
          name: 'Minder Prototype',
          short_name: 'Minder',
          description: 'Mental Assistant',
          theme_color: '#ffffff',
          icons: [
            {
              src: 'android-chrome-192x192.png',
              sizes: '192x192',
              type: 'image/png'
            },
            {
              src: 'android-chrome-512x512.png',
              sizes: '512x512',
              type: 'image/png'
            }
          ]
        }
    }),
    elmPlugin({debug: false, optimize: false, nodeElmCompilerOptions: { pathToElm: "elm" }} ),
    nodePolyfills({
        // Whether to polyfill `node:` protocol imports.
        protocolImports: true,
        exclude: ['fs'],
      }),
    ],
  // configure our build
  build: {
    // file path for the build output directory
    outDir: "../dist",
    // esbuild target
    target: "es2020",
    sourcemap: true,
    emptyOutDir: true,
    rollupOptions: { 
      // trick to try to avoid OOM in CI
      //currently just raising node ram limit
      //https://github.com/vitejs/vite/issues/2433
      //maxParallelFileOps: 2,
      output: {
        sourcemap: true, //don't sourcemap node_modules?
        // manualChunks: (id) => { 
        //   // this makes node_modules manually chunked so we don't have a huge index.ts file or too many micro js files
        //   if (id.includes('capacitor')) {
        //     return 'capacitor-modules';
        //   } else if (id.includes('libp2p')) {
        //     return 'libp2p-modules';
        //   } else if (id.includes('ipfs') || id.includes('helia') || id.includes('multiaddr') || id.includes('multiformats')) {
        //     return 'ipfs-modules';
        //   } else if (id.includes('orbit') || id.includes('orbit-db') || id.includes('dids') || id.includes('apg-js')) {
        //     return 'orbit-modules';
        //   } else if (id.includes('ionic') || id.includes('ion-')) {
        //     return 'ionic-modules';
        //   } else if (id.includes('elm')) {
        //     return 'elm-modules';
        //   } else if (id.includes('node_modules')) {
        //     return 'other-modules';
        //   }
        // },
      }
    }
  },
  root: "www/",
  optimizeDeps: {
    exclude: [
        '@ionic/core/loader', //fix weird Vite error "outdated optimize dep"
        '@ionic/pwa-elements/loader', // same
        '@ionic/pwa-elements/dist/esm-es5/pwa-toast.entry.js',
        '@peerbit/shared-log-rust' // keep WASM relative import pointing at the package's dist/wasm directory
    ],
    force: true
  },
  server: {
    strictPort: true,
    headers: {
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp'
    }
  },
  publicDir: "vite-extra-assets"
})