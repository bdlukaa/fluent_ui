'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"main.dart.js_26.part.js": "e54038c65d9bcedc1cc63873cc978827",
"main.dart.js_4.part.js": "cc811259fec3896fe12fc3807843a06d",
"main.dart.js_11.part.js": "e3cdea8ddeaa93dadeac0f8f043db356",
"main.dart.js_8.part.js": "0706f29e03468efcda42adbaf345dc84",
"main.dart.js_14.part.js": "e8a9df4f34ee166a3207fc2a2839d2a8",
"main.dart.js_3.part.js": "925daba834aa6c156f08d6c8c84b4c90",
"main.dart.js_24.part.js": "fef9ac706c73eeb1e911ac989996dbe0",
"main.dart.js_25.part.js": "14366c608876008afe57c8a6172cf446",
"main.dart.js_1.part.js": "7ebc64385bc41c1cc8819492a235dd71",
"main.dart.js_28.part.js": "a75ba45dc124271196298f879dbd9156",
"main.dart.js_16.part.js": "0c4a0f54ec84575fecea2878bcffcdf2",
"icons/Icon-maskable-192.png": "ef3b512b1c79d917c832c8c8c75ced88",
"icons/Icon-192.png": "ef3b512b1c79d917c832c8c8c75ced88",
"icons/Icon-maskable-512.png": "2650274e44ece6729a43d7ee130fdfbd",
"icons/Icon-512.png": "2650274e44ece6729a43d7ee130fdfbd",
"main.dart.js_23.part.js": "11b8ac0eebf7304af50590e2c80c7ec4",
"assets/fonts/MaterialIcons-Regular.otf": "bda2b48a6329d4ccfc68b2287bca28e6",
"assets/AssetManifest.bin.json": "ddd3257fb805b264e2dadba5b806e0f3",
"assets/AssetManifest.bin": "b6563f51aab4da1919b1718cb313cc3b",
"assets/AssetManifest.json": "d28c888634906fb585a4e78b850824ca",
"assets/packages/window_manager/images/ic_chrome_unmaximize.png": "4a90c1909cb74e8f0d35794e2f61d8bf",
"assets/packages/window_manager/images/ic_chrome_maximize.png": "af7499d7657c8b69d23b85156b60298c",
"assets/packages/window_manager/images/ic_chrome_minimize.png": "4282cd84cb36edf2efb950ad9269ca62",
"assets/packages/window_manager/images/ic_chrome_close.png": "75f4b8ab3608a05461a31fc18d6b47c2",
"assets/packages/fluent_ui/fonts/FluentIcons.ttf": "f3c4f09a37ace3246250ff7142da5cdd",
"assets/packages/fluent_ui/assets/AcrylicNoise.png": "81f27726c45346351eca125bd062e9a7",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/FontManifest.json": "6b53bbac7e12ce88331411914c31782e",
"assets/NOTICES": "aca87da215f434ce9045925e8f483eeb",
"main.dart.js_17.part.js": "256736227001d20f832aab510a3043da",
"main.dart.js": "1b3ce872fda0f175fc55699241fbd9b3",
"main.dart.js_29.part.js": "29da57f7a4f30d39b417e27e2ac628cc",
"manifest.json": "1e04e819df5e7720a7659fb598692f21",
"version.json": "ff966ab969ba381b900e61629bfb9789",
"main.dart.js_7.part.js": "c7c609fe9a7a0b5feae2b4aaafee987d",
"canvaskit/skwasm.js.symbols": "9fe690d47b904d72c7d020bd303adf16",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.wasm": "1c93738510f202d9ff44d36a4760126b",
"canvaskit/canvaskit.wasm": "a37f2b0af4995714de856e21e882325c",
"canvaskit/canvaskit.js.symbols": "27361387bc24144b46a745f1afe92b50",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "c054c2c892172308ca5a0bd1d7a7754b",
"canvaskit/chromium/canvaskit.js.symbols": "f7c5e5502d577306fb6d530b1864ff86",
"main.dart.js_20.part.js": "19ee31d6fa2cf03d39698c8abdf52644",
"main.dart.js_13.part.js": "332e9764b6360c88a95d9af50994c9a3",
"main.dart.js_5.part.js": "0e91df770d96ae6e7174f81e40518e26",
"main.dart.js_2.part.js": "31bf114edeb4083b11a9099691a9f518",
"flutter_bootstrap.js": "51435f8fc02aa04bd4a3b32c614d35c7",
"main.dart.js_19.part.js": "25a9dd51976c5ea3b64f205695a2e46b",
"splash/splash.js": "123c400b58bea74c1305ca3ac966748d",
"splash/img/light-3x.png": "6dce9ac774ebd7411409ac717fad1c3a",
"splash/img/dark-4x.png": "db9f16f985c9a2daf9c84e33358f0b14",
"splash/img/light-1x.png": "299ee6a20da3b8b2eedabe5d07d1e365",
"splash/img/dark-1x.png": "299ee6a20da3b8b2eedabe5d07d1e365",
"splash/img/light-2x.png": "19b7dded1199d8f2118591f39f5cc169",
"splash/img/dark-2x.png": "19b7dded1199d8f2118591f39f5cc169",
"splash/img/dark-3x.png": "6dce9ac774ebd7411409ac717fad1c3a",
"splash/img/light-4x.png": "db9f16f985c9a2daf9c84e33358f0b14",
"splash/style.css": "1404a5cdf67c618f89467983c828bd26",
"main.dart.js_10.part.js": "1f96f083124e078d00b38e4ff2d3c2ca",
"main.dart.js_18.part.js": "3def70186fa4d5376e77aeb6243b9dfd",
"main.dart.js_21.part.js": "8f6d88e3f3f7a010e417ca0614bdc6c4",
"favicon.png": "aa55c22e0c7bce9da0110b3035be5332",
"main.dart.js_6.part.js": "454c4457f43ebb997b67442d821f9701",
"index.html": "f5dc41e25713bec754bebb46a3215509",
"/": "f5dc41e25713bec754bebb46a3215509",
"main.dart.js_9.part.js": "2a3b1de8f3aa3f47b1db92eafd27c303",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"main.dart.js_30.part.js": "1a067a9293148a84107ccd2f7db9d06b",
"main.dart.js_27.part.js": "12e11abd442de80e082771bb3cbe282a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
