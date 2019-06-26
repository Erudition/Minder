// Check for Tasker on Android
import * as taskerFillers from "./tasker-fillers.mjs";
try {
    var inTasker = ( tk.global( 'sdk' ) > 0 );
} catch (e) {
    var tk = taskerFillers;
    var inTasker = false;
}


var storagefilename = "Minder/personal-data.json"

var Elm = this.Elm; //trick I discovered to bypass importing

var taskerUrl = getLocalUrl();
var taskerUrl = (taskerUrl != null) ? taskerUrl : "http://docket.com/?start=configure";


// touch file in case it's not There
//taskerTry(() => {writeFile("docket.dat","",true)});

var app = this.Elm.Headless.init(
    { flags: [taskerUrl, taskerReadAppData()] });

//logflash(`Running Elm! \n Url: ${taskerUrl} \n Data: ${taskerReadAppData()}`);

// SUBSCRIPTIONS --------------------------------------------------------

// SET STORAGE
app.ports.setStorage.subscribe(function(data) {
    tk.writeFile(storagefilename,data,false)
});


// FLASH OR TOAST
app.ports.flash.subscribe(function(data) {
    tk.flash(data)
});


// TASKER VARIABLE OUT
app.ports.variableOut.subscribe(function(data) {
      if (data[0].toLower == data[0])
        tk.setLocal(data[0], data[1]);
      else
        tk.setGlobal(data[0], data[1]);
});

// TASKER STOP EXECUTING
app.ports.exit.subscribe(function(data) {
      tk.exit()
});
