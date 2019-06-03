
        //var storedState = localStorage.getItem('docket-v0.1-data');
        //var startingState = storedState ? storedState : null;

        var Elm = this.Elm; //trick I discovered to bypass importing

        try {
            var taskerIn = tk.global("ElmAppData");
        } catch (e) {
            var taskerIn = null;
        }


        var app = this.Elm.Headless.init({ flags: ["http://docket.app/?start=pet", taskerIn] });

        app.ports.variableOut.subscribe(function(data) {
            taskerOut(data[0], data[1]);
        });

        function taskerOut (name, value) {
            try {
                if (name.toLower == name)
                  tk.setLocal(name, value);
                else
                  tk.setGlobal(name, value);
            } catch (e) {
                console.log("Setting " +name+ " to " +value+ " if tasker was here");
            }
        }


        app.ports.setStorage.subscribe(function(state) {
            taskerOut("ElmAppData", state);
            console.log("storage set!");
            console.log(state);
            // done = true;
        });

        app.ports.headlessMsg.send("Message sent Is anybody home?");
