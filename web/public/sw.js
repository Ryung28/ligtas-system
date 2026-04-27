// ResQTrack PWA Service Worker (V7 - Optimized for Next.js 14)
// STRATEGY: Zero-Blocking. Let Next.js handle routing. Only provide offline fallbacks.

const CACHE_NAME = 'resqtrack-tactical-v7';
const OFFLINE_URL = '/offline.html';

const PRECACHE_ASSETS = [
  '/offline.html',
  '/resqtrack-logo.jpg',
  '/oro-cervo.png',
  '/favicon.ico'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(
      keys.map((key) => key !== CACHE_NAME && caches.delete(key))
    ))
  );
  self.clients.claim();
});

// ✅ SENIOR FIX: Only intercept navigation requests if the network is TRULY down.
// We remove Strategy 1, 2, and 3 which were blocking the main thread.
self.addEventListener('fetch', (event) => {
  if (event.request.mode !== 'navigate') return;

  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(OFFLINE_URL);
    })
  );
});
