
// below copied from https://capacitor.ionicframework.com/docs/apis/app

// import { Plugins, AppState } from '@capacitor/core';
//
//import { Plugins, AppState } from './capacitor.js';
const { Toast, App } = window.Capacitor.Plugins;

async show() {
  await Toast.show({
    text: 'Hello!'
  });
}
//const { AppState } = window.Capacitor.AppState;

//const CapApp = window.Capacitor.Plugins;

// CapApp.addListener('appStateChange', (state: AppState) => {
//   // state.isActive contains the active state
//   console.log('App state changed. Is active?', state.isActive);
//   app.ports.appStateChange.send(state.isActive);
// });

// Listen for serious plugin errors
// CapApp.addListener('pluginError', (info: any) => {
//   console.error('There was a serious error with a plugin', err, info);
//   app.ports.pluginError.send(state.isActive);
// });

//was await
var ret = App.canOpenUrl({ url: 'app.docket' });
console.log('Can open url: ', ret.value);

//ret = await CapApp.openUrl({ url: 'app.docket://page?id=ionicframework' });
//console.log('Open url response: ', ret);

//was await
ret =  App.getLaunchUrl();
if(ret && ret.url) {
  console.log('App opened with URL: ' + ret.url);
}
console.log('Launch url: ', ret);

// CapApp.addListener('appUrlOpen', (data: any) => {
//   console.log('App opened with URL: ' +  data.url);
// });

// CapApp.addListener('appRestoredResult', (data: any) => {
//   console.log('Restored state:', data);
// });
