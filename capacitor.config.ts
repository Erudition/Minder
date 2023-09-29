import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.github.erudition.Minder',
  appName: 'Minder',
  webDir: 'dist',
  server: { 
    allowNavigation: ["erudition.github.io"], // don't add "localhost" here
    // url: "https://localhost/", // default is https://localhost, but setting this to ANYTHING prevents navigation to localhost...
    //url: "https://erudition.github.io/minder-preview/Erudition/Minder/branch/master/",
    hostname: 'minder-localhost',
    // can't be localhost because service worker is blocked in android webview. https://stackoverflow.com/a/76373851/8645412 can't be erudition.github.io or else online requests will become local requests.
    androidScheme: 'https',
    cleartext: true,
    //errorPath: "error.html",
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
