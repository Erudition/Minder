import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.github.erudition.Minder',
  appName: 'Minder',
  webDir: 'www',
  bundledWebRuntime: true,
  server: { allowNavigation: ["https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/"]}
};

export default config;
