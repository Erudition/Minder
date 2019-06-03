
//var Elm = require('./headless.js').Elm;
import { Elm } from './headless.js';

var storedState = localStorage.getItem('docket-v0.1-data');
var startingState = storedState ? storedState : null;

var app = Elm.Headless.init({ flags: ["http://docket.app/?start=pet", startingState] });


app.ports.setStorage.subscribe(function(state) {

    console.log("storage set!");
    console.log(state);
    // done = true;
});

app.ports.headlessMsg.send("Message sent Is anybody home?");

exit();
