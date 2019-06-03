

//my helper functions:

function getVar (name) {
    try {
        return global(name);
    } catch (e) {
        return null;
    }
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
        console.log("Tried " + func);
        return null;
    }
}

function taskerReadAppData () {
    try {
        //return readFile("docket.dat");
        return getVar("ElmAppData");
    } catch (e) {
        console.log("Tried to read file " + file);
        return ' ';
    }
}

// Elm init
//var storedState = localStorage.getItem('docket-v0.1-data');
//var startingState = storedState ? storedState : null;

var Elm = this.Elm; //trick I discovered to bypass importing



var taskerUrl = getVar("elmUrl")
var taskerUrl = taskerUrl ? taskerUrl : "http://docket.app/?start=pet"


// touch file in case it's not There
//taskerTry(() => {writeFile("docket.dat","",true)});

var app = this.Elm.Headless.init(
    { flags: [taskerUrl, taskerReadAppData()]
    });

 logflash("Running Elm! \n Url: "+ taskerUrl);

app.ports.variableOut.subscribe(function(data) {
    taskerOut(data[0], data[1]);
});

app.ports.exit.subscribe(function(data) {
  try {
      exit()
  } catch (e) {
      console.log("Tried to exit, if tasker was here");
  }
});


app.ports.setStorage.subscribe(function(state) {
    logflash("Storage set!");
    taskerOut("ElmAppData", state);
    exit();
    //taskerTry(() => {writeFile("docket.dat",state,false)});
});

app.ports.headlessMsg.send("yo");
