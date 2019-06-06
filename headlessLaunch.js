

//my helper functions:

function getGlobalVar (name) {
    try {
        let g = global(name);
        if (typeof g !== 'undefined')
            return g;
        else {
            logflash(`Failed to get global: ${name} because it was undefined`);
            return null;
        }
    } catch (e) {
        //logflash(`Failed to get global: ${name} because ${e}`);
        return null;
    }
}

function getLocalUrl () {
    if (typeof elmurl !== 'undefined')
        return elmurl;
    else
        logflash(`Failed to get local url because it was undefined`);
        return null;
}

function taskerOut (name, value) {
    try {
        if (name.toLower == name)
          setLocal(name, value);
        else
          setGlobal(name, value);
    } catch (e) {
        logflash("Setting " +name+ " to " +value+ " if tasker was here");
    }
}

function logflash(msg) {
    try {
        flash(msg);
    } catch (e) {
        console.log(msg);
    }
}

function taskerTry (func) {
    try {
        return func();
    } catch (e) {
        //logflash("Tried " + func);
        return null;
    }
}

function taskerReadAppData () {
    try {
        //return readFile("docket.dat");
        return getGlobalVar("ElmAppData");
    } catch (e) {
        //logflash("Failed to read file " + file);
        return ' ';
    }
}

// Elm init
//var storedState = localStorage.getItem('docket-v0.1-data');
//var startingState = storedState ? storedState : null;

var Elm = this.Elm; //trick I discovered to bypass importing



var taskerUrl = getLocalUrl();
var taskerUrl = (taskerUrl != null) ? taskerUrl : "http://docket.com/?start=pet";


// touch file in case it's not There
//taskerTry(() => {writeFile("docket.dat","",true)});

var app = this.Elm.Headless.init(
    { flags: [
        //taskerUrl, taskerReadAppData()
        "", taskerReadAppData()
    ]
    });

 logflash(`Running Elm! \n Url: ${taskerUrl} \n Data: ${taskerReadAppData()}`);

app.ports.variableOut.subscribe(function(data) {
    taskerOut(data[0], data[1]);
});

app.ports.exit.subscribe(function(data) {
  try {
      exit()
  } catch (e) {
      logflash("Tried to exit, if tasker was here");
  }
});


app.ports.setStorage.subscribe(function(state) {
    taskerOut("ElmAppData", state);
    logflash("Storage set!");
    //taskerTry(() => {writeFile("docket.dat",state,false)});
});


app.ports.flash.subscribe(function(data) {
  logflash(data);
});


//setTimeout(sendIt, 1500);

function sendIt() {
    app.ports.headlessMsg.send(taskerUrl);
}

logflash("Hit bottom of headlessLaunch.js, rev 29");
