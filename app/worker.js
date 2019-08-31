require('globals'); // necessary to bootstrap tns modules on the new thread

console.log("I'm in the worker!");










// UNIVERSAL MESSAGE HANDLER

   global.onmessage = function(msg) {
       var request = msg.data;
       var src = request.src;
       var mode = request.mode || 'noop'
       var options = request.options;

       var result = processImage(src, mode, options);

       var msg = result !== undefined ? { success: true, src: result } : { }

       global.postMessage(msg);
   }
