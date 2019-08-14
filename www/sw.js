//log all requests
//self.addEventListener('fetch', function(event) { console.log(event.request.url); });

var CACHE_NAME = 'minder-1';



// install itself
self.addEventListener('install', function(e) {
 e.waitUntil(
   caches.open(CACHE_NAME).then(function(cache) {
     return cache.addAll([
       './',
       './index.html',
       './index.html?start=nothing',
       './capacitor.js',
       './elm-gui.js',
       './gui.js',
       './tasker-fillers.js',
     ]);
   }, function(err) {
      // registration failed :(
      console.log('ServiceWorker registration failed: ', err);
    })
 );
});

// use what's cached, if available
self.addEventListener('fetch', (event) => {
  event.respondWith(async function() {
    const response = await caches.match(event.request);
    return response || fetch(event.request);
  }());
});

// cache anything we see requested later
self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // Cache hit - return response
        if (response) {
          return response;
        }

        return fetch(event.request).then(
          function(response) {
            // Check if we received a valid response (basic == our domain)
            if(!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // IMPORTANT: Clone the response. A response is a stream
            // and because we want the browser to consume the response
            // as well as the cache consuming the response, we need
            // to clone it so we have two streams.
            var responseToCache = response.clone();

            caches.open(CACHE_NAME)
              .then(function(cache) {
                cache.put(event.request, responseToCache);
              });

            return response;
          }
        );
      })
    );
});



// wipe out old caches
self.addEventListener('activate', function(event) {

  var cacheWhitelist = [CACHE_NAME, 'example'];

  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
