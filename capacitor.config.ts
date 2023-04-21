import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.github.erudition.Minder',
  appName: 'Minder',
  webDir: 'dist',
  bundledWebRuntime: false,
  server: { 
    allowNavigation: ["https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/"],
    url: "https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/",
    hostname: 'erudition.github.io',
    androidScheme: 'https',
    cleartext: true,
    },
  plugins: {
    SplashScreen: {
      launchShowDuration: 100,
      launchAutoHide: true,
      launchFadeOutDuration: 300,
      backgroundColor: "#ffffffff",
      androidSplashResourceName: "splash",
      androidScaleType: "CENTER_CROP",
      showSpinner: true,
      androidSpinnerStyle: "large",
      iosSpinnerStyle: "small",
      spinnerColor: "#999999",
      //splashFullScreen: true,
      //splashImmersive: true,
      layoutName: "launch_screen",
      useDialog: false,
    },
    Toast: {},
    LocalNotifications: {
      smallIcon: "alpha-logo",
      // iconColor: "#488AFF",
      // sound: "beep.wav",
    },
    App: {},
    Clipboard: {},
    Storage: {}
  }
};

export default config;
