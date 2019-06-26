// if (tk != undefined) {
// tk.flash("hello");
// }


import * as taskerFillers from "./tasker.mjs";

if (tk === undefined) {
    var tk = taskerDummies;
}


tk.flash("hello world!");
// tk.flash = function() {console.log("hi")}
