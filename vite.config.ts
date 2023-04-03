import { defineConfig } from 'vite'
import elmPlugin from "vite-plugin-elm"

import { nodePolyfills } from 'vite-plugin-node-polyfills'


export default defineConfig({
  // identify what plugins we want to use
  plugins: [elmPlugin({debug: true}),
    nodePolyfills({
        // Whether to polyfill `node:` protocol imports.
        protocolImports: true,
      }),
    ],
  // configure our build
  build: {
    // file path for the build output directory
    outDir: "dist",
    // esbuild target
    target: "es2020"
  },
  root: "www/"
})