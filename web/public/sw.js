// LIGTAS PWA Service Worker
// Network-first strategy for auth-gated routes, cache-first for static assets

const CACHE_NAME = 'ligtas-tactical-v3';
const OFFLINE_URL = '/offline';

// Only cache truly static assets — NOT auth-gated routes
const PRECACHE_ASSETS = [
  '/offline',
  '/oro-cervo.png',
  '/favicon.ico'
];

// Install event - cache essential static assets only
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Precaching static assets');
      return cache.addAll(PRECACHE_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('[SW] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Message handler - cache busting on logout
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'LOGOUT') {
    console.log('[SW] Logout signal received — clearing all caches');
    caches.keys().then((cacheNames) => {
      return Promise.all(cacheNames.map((name) => caches.delete(name)));
    });
  }
});

// Fetch event - Optimized Strategy: Cache-First for static, Network-First for everything else
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  if (!event.request.url.startsWith('http')) return;

  const url = new URL(event.request.url);

  // 🏛️ STRATEGY 1: Static Assets & JS Chunks - CACHE FIRST
  if (url.pathname.startsWith('/_next/static/') || 
      url.pathname.startsWith('/icons/') ||
      url.pathname.endsWith('.png') ||
      url.pathname.endsWith('.webp')) {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        if (cachedResponse) return cachedResponse;
        return fetch(event.request).then((response) => {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
          return response;
        });
      })
    );
    return;
  }

  // 🏛️ STRATEGY 2: Navigation & Auth-Gated Routes - NETWORK FIRST
  // Always hit the server so middleware can validate session cookies.
  // Only fall back to cache if network is unavailable (true offline mode).
  if (event.request.mode === 'navigate' || url.pathname.startsWith('/m')) {
    event.respondWith(
      fetch(event.request)
        .then((networkResponse) => {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
          return networkResponse;
        })
        .catch(() => {
          return caches.match(event.request)
            .then((cached) => cached || caches.match(OFFLINE_URL));
        })
    );
    return;
  }

  // 🏛️ STRATEGY 3: General Requests - NETWORK FIRST
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const responseToCache = response.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseToCache);
        });
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
