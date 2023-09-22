import { defineConfig } from 'vite'
import elmPlugin from "vite-plugin-elm"

import { nodePolyfills } from 'vite-plugin-node-polyfills'
import { VitePWA } from 'vite-plugin-pwa'


export default defineConfig({
  // identify what plugins we want to use
  plugins: [ // PWA plugin causing import errors
    VitePWA({ registerType: 'autoUpdate',
        // After messing with service worker you may need to rm -rf android/app/src/main/assets/* before sync. https://github.com/ionic-team/capacitor/issues/5430#issuecomment-1042990925
        //devOptions: {enabled: true},
        //filename: 'sw2.js', // useful if cache is sticky
        includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
        workbox: {  
          //additionalManifestEntries: ["fallback.html"], // TODO test if this works
          navigateFallback: "error.html",
          navigateFallbackDenylist: [new RegExp("sw\\.js"), new RegExp("sw\.js"), new RegExp("sw.js"), new RegExp("sw2.js")],
          globPatterns: ['**/*'], // was **/*.{js,html,css,ico,png,svg}
          globIgnores: ['**/*.js.map'] // don't precache map files
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
    elmPlugin({debug: false, optimize: false} ),
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
        manualChunks: (id) => { 
          // this makes node_modules manually chunked so we don't have a huge index.ts file or too many micro js files
          if (id.includes('capacitor')) {
            return 'capacitor-modules';
          } else if (id.includes('libp2p')) {
            return 'libp2p-modules';
          } else if (id.includes('ipfs') || id.includes('helia') || id.includes('multiaddr') || id.includes('multiformats')) {
            return 'ipfs-modules';
          } else if (id.includes('orbit') || id.includes('orbit-db') || id.includes('dids') || id.includes('apg-js')) {
            return 'orbit-modules';
          } else if (id.includes('ionic') || id.includes('ion-')) {
            return 'ionic-modules';
          } else if (id.includes('elm')) {
            return 'elm-modules';
          } else if (id.includes('node_modules')) {
            return 'other-modules';
          }
        },
      }
    }
  },
  root: "www/",
  optimizeDeps: {
    exclude: [
        '@ionic/core/loader', //fix weird Vite error "outdated optimize dep"
        '@ionic/pwa-elements/loader', // same
        '@ionic/pwa-elements/dist/esm-es5/pwa-toast.entry.js'
    ],
    force: true
  },
  server: {
    strictPort: true
  },
  publicDir: "vite-extra-assets"
})