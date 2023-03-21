import { NativeScriptConfig } from '@nativescript/core'

export default {
  id: 'minder.erudition.github.io',
  appResourcesPath: 'App_Resources',
  android: {
    v8Flags: '--expose_gc',
    markingMode: 'none',
  },
  appPath: 'app',
} as NativeScriptConfig
