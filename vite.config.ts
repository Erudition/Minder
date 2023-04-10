import { defineConfig } from 'vite'
import elmPlugin from "vite-plugin-elm"

import { nodePolyfills } from 'vite-plugin-node-polyfills'
import { VitePWA } from 'vite-plugin-pwa'


export default defineConfig({
  // identify what plugins we want to use
  resolve: {
    alias: {
      fs: "fs"
    }
  },
  plugins: [
    // VitePWA({ registerType: 'autoUpdate',
    //     //devOptions: {enabled: true},
    //     includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
    //     workbox: {
    //       globPatterns: ['**/*.{js,css,html,ico,png,svg}']
    //     },
    //     manifest: {
    //       name: 'Minder Prototype',
    //       short_name: 'Minder',
    //       description: 'Mental Assistant',
    //       theme_color: '#ffffff',
    //       icons: [
    //         {
    //           src: 'android-chrome-192x192.png',
    //           sizes: '192x192',
    //           type: 'image/png'
    //         },
    //         {
    //           src: 'android-chrome-512x512.png',
    //           sizes: '512x512',
    //           type: 'image/png'
    //         }
    //       ]
    //     }
    // }),
    elmPlugin({debug: false, optimize: false} ),
    nodePolyfills({
        // Whether to polyfill `node:` protocol imports.
        protocolImports: false,
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
    // rollupOptions: { // trick to try to avoid OOM in CI
    // currently just raising node ram limit
    // https://github.com/vitejs/vite/issues/2433
    //   maxParallelFileOps: 2,
    //   output: {
    //     sourcemap: true,
    //     manualChunks: (id) => { //don't sourcemap node_modules?
    //      if (id.includes('node_modules')) {
    //         return 'vendor';
    //       }
    //     },
    // }
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
  }
})