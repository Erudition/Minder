import { defineConfig } from 'vite'
import elmPlugin from "vite-plugin-elm"

import { nodePolyfills } from 'vite-plugin-node-polyfills'
import { VitePWA } from 'vite-plugin-pwa'


export default defineConfig({
  // identify what plugins we want to use
  plugins: [
    VitePWA({ registerType: 'autoUpdate',
        devOptions: {enabled: true},
        includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
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
    elmPlugin({debug: true}),
    nodePolyfills({
        // Whether to polyfill `node:` protocol imports.
        protocolImports: true,
      }),
    ],
  // configure our build
  build: {
    // file path for the build output directory
    outDir: "../dist",
    // esbuild target
    target: "es2020"
  },
  root: "www/",
  optimizeDeps: {
    exclude: [
        '@ionic/core/loader' //fix weird Vite error "outdated optimize dep"
    ],
    force: true
  },
})