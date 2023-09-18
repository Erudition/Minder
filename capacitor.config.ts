import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.github.erudition.Minder',
  appName: 'Minder',
  webDir: 'dist',
  server: { 
    allowNavigation: ["erudition.github.io", "localhost"],
    url: "https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/",
    hostname: 'localhost',
    androidScheme: 'https',
    cleartext: true,
    errorPath: "error.html",
    },
  plugins: {
    SplashScreen: {
      launchShowDuration: 200,
      launchAutoHide: true,
      launchFadeOutDuration: 200,
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
      smallIcon: "alpha_logo",
      // iconColor: "#488AFF",
      // sound: "beep.wav",
    },
    App: {},
    Clipboard: {},
    Storage: {},
    CapacitorCookies: {
      enabled: true
    }
  }
};

export default config;
