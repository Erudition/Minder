// For node
//import * as tk from "./tasker-fillers.mjs";


flash("running!");

var storagefilename = "Minder/personal-data.json"



var taskerUrl = tk.local("elmurl");
var taskerUrl = (taskerUrl != null) ? taskerUrl : "http://docket.com/?start=nothing";

var Elm = this.Elm; //trick I discovered to bypass importing

// touch file in case it's not There
//taskerTry(() => {writeFile("docket.dat","",true)});

var app = Elm.Headless.init(
    { flags: [taskerUrl, tk.readFile(storagefilename)] });


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
