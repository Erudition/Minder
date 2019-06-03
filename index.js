const { Toast, App, SplashScreen, Clipboard, LocalNotifications, Storage } = window.Capacitor.Plugins;


//var storedState = localStorage.getItem('docket-v0.1-data');
Storage.get({ key: 'docket-v0.1-data' }).then((output) => {startElm(output.value)});

//var startingState = storedState ? JSON.parse(storedState) : null;
function startElm(storedState)  {
    var startingState = storedState ? storedState : null;
    var app = Elm.Main.init({ flags: startingState });


    app.ports.setStorage.subscribe(function(state) {
        //localStorage.setItem('docket-v0.1-data', state);
        //console.log(state);
        Storage.set({
         key: 'docket-v0.1-data',
         value: state
        });
    });//was JSON.stringify(state)




    app.ports.flash.subscribe(function(data) {
      try {
          tk.flash(data)
      } catch (e) {
          Toast.show({
              text: data,
              duration: '10000'
          }).then();
      } finally {
          console.log("Would have flashed: " +data);
      }



    });

    app.ports.variableOut.subscribe(function(data) {
      try {
          if (data[0].toLower == data[0])
            tk.setLocal(data[0], data[1]);
          else
            tk.setGlobal(data[0], data[1]);
      } catch (e) {
          console.log("Setting " +data[0]+ " to " +data[1]+ " if tasker was here");
      }
    });

    app.ports.exit.subscribe(function(data) {
      try {
          tk.exit()
      } catch (e) {
          console.log("Tried to exit, if tasker was here");
      }
    });



    SplashScreen.hide().catch((err) => {
        console.log("No splash screen to hide");
    });
}



LocalNotifications.schedule({
  notifications: [
    {
      title: "Title",
      body: "Body",
      id: 1,
      schedule: { at: new Date(Date.now() + 1000 * 5) },
      sound: null,
      attachments: null,
      actionTypeId: "",
      extra: null
    }
  ]
});


// const setItem =  () => {
//    Storage.set({
//     key: 'pet',
//     value: 'dog'
//   });
// }
const setItem = Storage.set({
 key: 'pet',
 value: 'dog'
});
console.log('Set item: ', setItem);

const value = Storage.get({ key: 'pet' });
  console.log('Got item: ', value);

 toast = Toast.show({
   text: 'Hello! not async'
 });
  console.log('Toasted: ', toast);


// Clipboard.write({
//   string: "Hello, Moto"
// });





// below copied from https://capacitor.ionicframework.com/docs/apis/app

// import { Plugins, AppState } from '@capacitor/core';
//
//import { Plugins, AppState } from './capacitor.js';
//const { Toast, App } = window.Capacitor.Plugins;

// async show => {
//   await Toast.show({
//     text: 'Hello!'
//   });
// }
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
ret2 =  App.getLaunchUrl();
if(ret2 && ret2.url) {
  console.log('App opened with URL: ' + ret2.url);
}
console.log('Launch url: ', ret2);


const show = async () => {
  await Toast.show({
    text: 'Hello async!'
  });
}

show();
// CapApp.addListener('appUrlOpen', (data: any) => {
//   console.log('App opened with URL: ' +  data.url);
// });

// CapApp.addListener('appRestoredResult', (data: any) => {
//   console.log('Restored state:', data);
// });
